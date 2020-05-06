package hazards.enemies;

import hazards.parents.Enemy;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import systems.Action.ActionSystem;
import hazards.parents.EnemyLogic;
import systems.ExtendedAnimation;

class BasicBlob extends Enemy
{
    override public function new(?X:Float = 0, ?Y:Float = 0, ?Width:Int = 1, ?Height:Int = 1, ?initialTarget:FlxSprite) 
    {
        super(X, Y);

        visible = true;
        alpha = 1;
        immovable = false;
        damgeValue = 10;
        target = initialTarget;

        enemyLogic = new EnemyStateLogic(this);
        actionSystem = new ActionSystem(enemyLogic.states.Idle);
        actionSystem.setDelay(500);
        enemyAnimation = new ExtAnimationSystem(this);

        loadGraphic(AssetPaths.sprBlob__png, true, 45, 45);
        setSize(frameWidth / 3, frameHeight - 4);
		
		offset.set(width, frameHeight - height);
		centerOrigin();

        gatherAnimations();
    }

    /**
		Helper to add all animations of the player
	**/
    private function gatherAnimations():Void 
    {
        enemyAnimation.createAnimation("idle", [0,1], 20, true);
        enemyAnimation.createAnimation("pre-jump", [2,3,4,5], 20, true);
        enemyAnimation.createAnimation("jump", [6,7], 20, true);
        enemyAnimation.createAnimation("landing", [8,9,10,11,12,13,14,15], 20, true);
        enemyAnimation.createAnimation("sleeping", [16,17,18,19,20,21], 20, true);
        enemyAnimation.createAnimation("spinning", [22,23,24,25,26,27,28,29,30,31,32,33], 20, false);
        enemyAnimation.createAnimation("walking", [34,35,36,37,36,35], 20, true);
    }
}