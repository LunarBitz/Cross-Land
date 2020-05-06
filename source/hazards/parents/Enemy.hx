package hazards.parents;

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
    public var target:FlxSprite;
    
    override public function new(?X:Float = 0, ?Y:Float = 0, ?Width:Int = 1, ?Height:Int = 1, ?initialTarget:FlxSprite) 
    {
        super(X, Y);

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

        actionSystem.updateTimer(elapsed, actionSystem.isAnAction([Detected, Pre_Attack, Attack_1, Attack_2, Attack_3]));

        callStates();

        super.update(elapsed);
    }

    public function isPlayerWithin(?distance:Float = 50):Bool
    {
        return FlxMath.isDistanceWithin(this, target, distance, true);
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