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

    public function isPlayerWithin(?innerBound:Float = 5, ?outerBound:Float = 50, ?ignoreY:Bool = false, ?ignoreX:Bool = false):Bool
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