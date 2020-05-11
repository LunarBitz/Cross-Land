package hazards.parents;

import flixel.math.FlxPoint;
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

    public var awakeWarning:FlxSprite;
    public var attackWarning:FlxSprite;
    public var hudIndicatorOrigin:FlxPoint;
    
    override public function new(?X:Float = 0, ?Y:Float = 0, ?Width:Int = 1, ?Height:Int = 1, ?initialTarget:FlxSprite) 
    {
        super(X, Y);

        hitboxes = new Map<String, Hitbox>();
        createHitbox("Attack", 8, 8, false); 

        hudIndicatorOrigin = new FlxPoint();
        awakeWarning = new FlxSprite(X, Y);
        awakeWarning.loadGraphic(AssetPaths.sprCationDetected__png, true, 16, 16);
        awakeWarning.animation.add("main", [0,1,2,3,4,5], 25, false);
        awakeWarning.exists = false;
        attackWarning = new FlxSprite(X, Y);
        attackWarning.loadGraphic(AssetPaths.sprCautionWarning__png, true, 16, 16);
        attackWarning.animation.add("main", [0,1,2,3,4,5], 25, false);
        attackWarning.exists = false;

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
        var states = enemyLogic.states;

        if (health <= 0 && actionSystem.isAnAction([states.Idle]))
        {
            trace("Go Die");
            actionSystem.setState(states.Dying);
            trace(actionSystem.getState());
        }

        if (hitboxes != null && LevelGlobals.totalElapsed == 0)
        {
            LevelGlobals.combineMaps(LevelGlobals.allHitboxes, [hitboxes]);  
            LevelGlobals.combineMaps(LevelGlobals.allDamagers, [hitboxes]);  
            LevelGlobals.combineMaps(LevelGlobals.currentState, [hitboxes]);
        }

        if (awakeWarning != null)
            LevelGlobals.currentState.add(awakeWarning);
        if (attackWarning != null)
            LevelGlobals.currentState.add(attackWarning);

        
        
        
        actionSystem.updateTimer(elapsed, actionSystem.isAnAction([states.Detected, states.Pre_Attack, states.Damaged]) || isAttacking);

        for (solid in LevelGlobals.solidsReference)
            if (!solid.exists)
                solid.exists = isObjectWithinDistance(solid, 0, 64);

        updateDirection();

        tickInvincibilityTimer();

        callStates();

        if (hitboxes != null)
        {
            for (hb in hitboxes)
            {
                hb.positionBox("South", "South");
                hb.followOwner();
            }
        }

        hudIndicatorOrigin.set(x + (width / 2) - (awakeWarning.width / 2), y - 8 - awakeWarning.height);

        if (awakeWarning.exists)
            awakeWarning.setPosition(hudIndicatorOrigin.x , hudIndicatorOrigin.y);
        if (attackWarning.exists)
            attackWarning.setPosition(hudIndicatorOrigin.x , hudIndicatorOrigin.y);

        super.update(elapsed);

        
			
    }

    public function createHitbox(?hitboxName:String = null, ?w:Int = 0, ?h:Int = 0, initialExist:Bool = false) 
    {
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
        var fn = Reflect.field(enemyLogic, "_State_" + Std.string(actionSystem.getState()));
        if (fn != null)
        {
            Reflect.callMethod(enemyLogic, fn, []);
        }	
    }

    /**
		Function that updates the actual velocity of the player
	**/
	public function tickInvincibilityTimer():Void 
    {
        if (invincibilityTimer > 0)
            invincibilityTimer -= Std.int(LevelGlobals.deltaTime * 1000);
        
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

    override function kill()
    {
        alive = false;
        flixel.tweens.FlxTween.tween(this, {alpha: 0, y: y + 4}, 1.0, {ease: flixel.tweens.FlxEase.circOut, onComplete: finishKill});
    }
    
    function finishKill(_)
    {
        exists = false;
    }

}