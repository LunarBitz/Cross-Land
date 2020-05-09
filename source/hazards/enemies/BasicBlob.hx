package hazards.enemies;

import misc.Hitbox;
import flixel.FlxObject;
import hazards.enemies.BasicBlobLogic.BlobStateLogic;
import hazards.parents.Enemy;
import flixel.FlxSprite;
import systems.Action.ActionSystem;
import systems.ExtendedAnimation;

class BasicBlob extends Enemy
{
    override public function new(?X:Float = 0, ?Y:Float = 0, ?Width:Int = 1, ?Height:Int = 1, ?initialTarget:FlxSprite) 
    {
        super(X, Y);

        createHitbox("Spinning", 36, 26); 

        visible = true;
        alpha = 1;
        immovable = false;
        damgeValue = 10;
        target = initialTarget;

        enemyLogic = new BlobStateLogic(this);
        actionSystem = new ActionSystem(enemyLogic.states.Sleeping);
        enemyAnimation = new ExtAnimationSystem(this);

        loadGraphic(AssetPaths.sprBlob__png, true, 45, 45);
        setSize(frameWidth / 2, (frameHeight / 2) - 3);
		offset.set(width / 2, frameHeight - height - 2);
        centerOrigin();
        
        setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);

        gatherAnimations();
    }

    override function update(elapsed:Float) 
    {
        alpha = (invincibilityTimer>0)? (0.35 + (0.35 * invincibilityTimer % 5)): 1;

        // We're updating from EnemyLogic.hx bois
        super.update(elapsed);
    }

    /**
		Helper to add all animations of the player
	**/
    private function gatherAnimations():Void 
    {
        enemyAnimation.createAnimation("idle", [0,1], 3, true);
        enemyAnimation.createAnimation("pre-jump", [2,3,4,5], 20, true);
        enemyAnimation.createAnimation("jump", [6,7], 20, true);
        enemyAnimation.createAnimation("landing", [8,9,10,11,12,13,14,15], 20, true);
        enemyAnimation.createAnimation("sleeping", [16,17,18,19,20,21], 5, true);
        enemyAnimation.createAnimation("detected", [0,1], 20, true);
        enemyAnimation.createAnimation("pre-spin", [9,10,11,12], 10, false);
        enemyAnimation.createAnimation("spinning", [12,11,10,9,22,23,24,25,26,27,28,29,30,31,32,33], 20, true, 8);
        enemyAnimation.createAnimation("post-spin", [25,24,23,22], 10, false);
        enemyAnimation.createAnimation("walking", [34, 35, 36, 37, 36, 35], 8, false);
        enemyAnimation.createAnimation("damaged", [8], 3, true);
    }
}