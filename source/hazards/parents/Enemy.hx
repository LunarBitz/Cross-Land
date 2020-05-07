package hazards.parents;

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
    
    override public function new(?X:Float = 0, ?Y:Float = 0, ?Width:Int = 1, ?Height:Int = 1, ?initialTarget:FlxSprite) 
    {
        super(X, Y);

        acceleration.y = 981;
		maxVelocity.y = 1500;

        enemyLogic = new EnemyStateLogic(this);
        actionSystem = new ActionSystem(enemyLogic.states.Idle);
        actionSystem.setDelay(500);
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
        actionSystem.updateTimer(elapsed, actionSystem.isAnAction([states.Detected, states.Pre_Attack]) || isAttacking);

        updateDirection();

        callStates();

        super.update(elapsed);
    }

    /**
		Change the facing direction of the player based on the input
	**/
	private function updateDirection():Void
    {
        var velSign = FlxMath.signOf(Std.int(velocity.x));
        if (velSign != 0 && Math.abs(velocity.x) >= 5)
            facing = (velSign == -1)? FlxObject.LEFT : FlxObject.RIGHT;
    }

    public function isPlayerWithin(?innerBound:Float = 8, ?outerBound:Float = 50, ?ignoreY:Bool = false, ?ignoreX:Bool = false):Bool
    {
        var ownerX:Float = ignoreX? 0 : (this.x + (width / 2));
        var ownerY:Float = ignoreY? 0 : (this.y + (height / 2));
        var targetX:Float = ignoreX? 0 : (target.x + (target.width / 2));
        var targetY:Float = ignoreY? 0 : (target.y + (target.height / 2));
        var dist:Float = Math.sqrt(Math.pow(ownerX - targetX, 2) + Math.pow(ownerY - targetY, 2));
       
        return dist >= (innerBound + (width / 2)) && dist <= (outerBound + (width / 2));
    }

    /**
		Function to handle what happens with each action state.
		See `[xx]Logic.hx`
	**/
	public function callStates():Void
    {
        for (state in Type.allEnums(enemyLogic.states))
        { 
            var fn = Reflect.field(enemyLogic, "_State_" + Std.string(state));
            if (fn != null && actionSystem.getState() == state)
            {
                Reflect.callMethod(enemyLogic, fn, []);
            }	
        }
    }
}