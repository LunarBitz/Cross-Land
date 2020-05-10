package hazards.parents;

import LevelGlobals;
import misc.Hitbox;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import systems.Action.ActionSystem;
import hazards.parents.EnemyLogic;
import systems.ExtendedAnimation;


class Enemy extends Damager
{
    public var enemyLogic:EnemyStateLogic;
    public var actionSystem:ActionSystem;
    public var enemyAnimation:ExtAnimationSystem;

    public var enemyReach:Float = 175; 
    public var isAttacking:Bool = false;
    public var target:FlxSprite;
    public var hitboxes:Map<String, Hitbox>;
    public var invincibilityTimer:Int = 0;
    public var canChangeDirections:Bool = true;
    
    override public function new(?X:Float = 0, ?Y:Float = 0, ?Width:Int = 1, ?Height:Int = 1, ?initialTarget:FlxSprite) 
    {
        super(X, Y);

        hitboxes = new Map<String, Hitbox>();
        createHitbox("Attack", 8, 8, false); 

        acceleration.y = 981;
		maxVelocity.y = 1500;

        enemyLogic = new EnemyStateLogic(this);
        actionSystem = new ActionSystem(enemyLogic.states.Idle);
        enemyAnimation = new ExtAnimationSystem(this);

        makeGraphic(Width, Height, 0xFFFF00FF);
        visible = true;
        alpha = 1;

        // Set immovable to true, prevents this from getting pushed during FlxG.collide()
        immovable = false;

        damgeValue = 10;

        target = initialTarget;
    }

    override function update(elapsed:Float) 
    {
        if (hitboxes != null && LevelGlobals.totalElapsed == 0)
        {
            LevelGlobals.combineMaps(LevelGlobals.currentState, [hitboxes]);
            LevelGlobals.combineMaps(LevelGlobals.allDamagers, [hitboxes]);  
        }
        
        var states = enemyLogic.states;
        actionSystem.updateTimer(elapsed, actionSystem.isAnAction([states.Detected, states.Pre_Attack, states.Damaged]) || isAttacking);

        for (solid in LevelGlobals.solidsReference)
            if (!solid.exists)
                solid.exists = isObjectWithinDistance(solid, 0, 64);

        updateDirection();

        tickInvincibilityTimer();

        callStates();

        for (hb in hitboxes)
        {
            hb.positionBox("South", "South");
            hb.followOwner();
        }

        super.update(elapsed);

        
			
    }

    public function createHitbox(?hitboxName:String = null, ?w:Int = 0, ?h:Int = 0, initialExist:Bool = false) 
    {
        if (hitboxes == null)
            hitboxes = new Map<String, Hitbox>();

        hitboxes[hitboxName] = new Hitbox(x, y, w, h, initialExist, this);
    }

    /**
		Change the facing direction of the player based on the input
	**/
	private function updateDirection():Void
    {
        var velSign = FlxMath.signOf(Std.int(velocity.x));
        if (velSign != 0 && Math.abs(velocity.x) >= 5 && canChangeDirections)
            facing = (velSign == -1)? FlxObject.LEFT : FlxObject.RIGHT;
    }

    public function isObjectWithinDistance(other:FlxSprite, ?innerBound:Float = 8, ?outerBound:Float = 50, ?ignoreY:Bool = false, ?ignoreX:Bool = false):Bool
    {
        var ownerX:Float = ignoreX? 0 : (this.x + (width / 2));
        var ownerY:Float = ignoreY? 0 : (this.y + (height / 2));
        var targetX:Float = ignoreX? 0 : (other.x + (other.width / 2));
        var targetY:Float = ignoreY? 0 : (other.y + (other.height / 2));
        var dist:Float = Math.sqrt(Math.pow(ownerX - targetX, 2) + Math.pow(ownerY - targetY, 2));
       
        return dist >= (innerBound + (width / 2)) && dist <= (outerBound + (width / 2));
    }

    /**
		Function to handle what happens with each action state.
		See `[xx]Logic.hx`
	**/
	public function callStates():Void
    {
        //for (state in Type.allEnums(enemyLogic.states))
        //{ 
            var fn = Reflect.field(enemyLogic, "_State_" + Std.string(actionSystem.getState()));
            if (fn != null)
            {
                Reflect.callMethod(enemyLogic, fn, []);
            }	
        //}
    }

    /**
		Function that updates the actual velocity of the player
	**/
	public function tickInvincibilityTimer():Void 
    {
        if (invincibilityTimer > 0)
        {
            invincibilityTimer -= Std.int(LevelGlobals.deltaTime * 1000);
        }

        if (FlxMath.equal(invincibilityTimer, 0.0, 1) || invincibilityTimer < 0)
            invincibilityTimer = 0;

        canInflictDamage = !(invincibilityTimer > 0);
    }

    /**
		Function that's called to resolve damage related statements when object overlapping is invoked.
		@param player Object that collided with something.
		@param other Object that `player` has collided with.
	**/
	public static function resolveDamagerCollision(hitter:Enemy, other:Damager):Void
    {
        var states = hitter.enemyLogic.states;
        var dir = 0;

        if (hitter.alive && hitter.exists && other.alive && other.exists)
        {
            // Exit function if hitbox collides with its owner or with another enemy
            if (Type.getClass(other) == Hitbox)
            {
                if (cast(other, Hitbox).owner == hitter) { return; }
            }
            else if (Type.getClass(other) == Enemy) { return; }

            if (hitter.invincibilityTimer == 0 && other.canInflictDamage)
            {
                dir = FlxMath.signOf(other.x - hitter.x);
                
                hitter.invincibilityTimer = 750;
                hitter.health -= other.damgeValue;
                hitter.velocity.x = 150 * -dir;
                hitter.velocity.y = -300 / 3;
                
                hitter.actionSystem.setState(states.Damaged);
            }
        }
    }

}