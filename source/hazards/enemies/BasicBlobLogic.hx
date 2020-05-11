package hazards.enemies;

import flixel.FlxObject;
import hazards.parents.EnemyLogic.EnemyStateLogic;
import hazards.parents.Enemy;
import flixel.math.FlxMath;

enum EnemyStates 
{
    Null;
    Sleeping;
	Idle;
	Detected;
    Walking;
    Pre_Attack;
    Attack_1;
    Post_Attack_1;
    Damaged;
    Dying;
}

class BlobStateLogic extends EnemyStateLogic
{
    override public function new(obj:Enemy) 
    { 
        super(obj);
        
        owner = obj; 
        states = BasicBlobLogic.EnemyStates;
    }    
     
    public function _State_Sleeping() 
    {
        // #region Basics
        owner.velocity.x = 0;

        owner.canChangeDirections = false;

        owner.isAttacking = false;

        owner.hitboxes["Spinning"].exists = false;
        // #endregion 

        // #region Logic
        if (owner.isObjectWithinDistance(owner.target, 5, 64, false, false))
        {
            owner.actionSystem.setState(Detected);
        }
        // #endregion 

        // #region Animations
        owner.enemyAnimation.setAnimation("sleeping");
        // #endregion 
    }

    override public function _State_Idle() 
    {
        // #region Basics
        owner.velocity.x = 0;

        owner.canChangeDirections = false;

        owner.isAttacking = false;

        owner.hitboxes["Spinning"].exists = false;

        // #endregion 

        // #region Logic
        if (owner.isObjectWithinDistance(owner.target, 5, 135, true))
        {
            owner.actionSystem.setState(Detected);
        }
        // #endregion 

        // #region Animations
        owner.enemyAnimation.setAnimation("idle");
        // #endregion 
    }

    override public function _State_Detected() 
    {
        // #region Basics
        owner.velocity.x = 0;

        owner.canChangeDirections = false;

        owner.isAttacking = false;

        owner.hitboxes["Spinning"].exists = false;

        // #endregion 

        // #region Logic
        owner.awakeWarning.reset(owner.hudIndicatorOrigin.x, owner.hudIndicatorOrigin.y);
        owner.awakeWarning.animation.play("main");
        if (owner.awakeWarning.animation.curAnim != null)
            if (owner.awakeWarning.animation.curAnim.curFrame == 5)
                owner.awakeWarning.animation.pause();

        owner.actionSystem.setState(Walking, 750);
        // #endregion 

        // #region Animations
        owner.enemyAnimation.setAnimation("idle");
        // #endregion 
    }

    override public function _State_Walking() 
    {
        // #region Basics
        owner.velocity.x = 50 * FlxMath.signOf(owner.target.x - owner.x);

        owner.canChangeDirections = true;

        owner.hitboxes["Spinning"].exists = false;
        // #endregion 

        // #region Logic
        flixel.tweens.FlxTween.tween(owner.awakeWarning, {alpha: 0, y: owner.awakeWarning.y - 16}, 0.5, {ease: flixel.tweens.FlxEase.circOut, onComplete: 
            function(_)
            {
                owner.awakeWarning.setPosition(owner.hudIndicatorOrigin.x, owner.hudIndicatorOrigin.y);
                owner.awakeWarning.exists = false;
                
                owner.awakeWarning.animation.stop();
            }
        });
        

        if (owner.isObjectWithinDistance(owner.target, 0, 12, true))
            owner.actionSystem.setState(Pre_Attack);
        else if (!owner.isObjectWithinDistance(owner.target, 5, 135, true))
            owner.actionSystem.setState(Idle);
        // #endregion 

        // #region Animations
        if (owner.actionSystem.hasChanged())
            owner.enemyAnimation.setAnimation("walking");
        // #endregion 
    }

    override public function _State_Pre_Attack() 
    {
        // #region Basics
        owner.velocity.x = 0;

        owner.canChangeDirections = false;

        owner.isAttacking = true;

        owner.hitboxes["Spinning"].exists = false;
        // #endregion 

        // #region Logic
        owner.attackWarning.reset(owner.hudIndicatorOrigin.x, owner.hudIndicatorOrigin.y);
        owner.attackWarning.alpha = 1;
        owner.attackWarning.animation.play("main");
        if (owner.attackWarning.animation.curAnim != null)
            if (owner.attackWarning.animation.curAnim.curFrame == 5)
                owner.attackWarning.animation.pause();

        owner.actionSystem.setState(Attack_1, 500);
        // #endregion 

        // #region Animations
        if (owner.actionSystem.hasChanged())
            owner.enemyAnimation.setAnimation("pre-spin", false, false, true, 0, true);
        // #endregion 
    }

    override public function _State_Attack_1() 
    {
        // #region Basics
        owner.velocity.x = 0;

        owner.canChangeDirections = false;

        if (owner.enemyAnimation.getCurrentAnimation() == "spinning")
        {
            owner.isAttacking = owner.enemyAnimation.hasPassedLoopFrame();
            owner.hitboxes["Spinning"].exists = owner.enemyAnimation.hasPassedLoopFrame();
        }

        // #endregion 

        // #region Logic
        if (!owner.isObjectWithinDistance(owner.target, 0, 12, true))
            owner.actionSystem.setState(Post_Attack_1, 500);
        // #endregion 

        // #region Animations
        if (owner.actionSystem.hasChanged())
            owner.enemyAnimation.setAnimation("spinning", false, false, true);
        // #endregion 
    }

    public function _State_Post_Attack_1() 
    {
        // #region Basics
        owner.velocity.x = 0;

        owner.canChangeDirections = false;

        owner.isAttacking = true;

        owner.hitboxes["Spinning"].exists = false;

        // #endregion 

        // #region Logic
        flixel.tweens.FlxTween.tween(owner.attackWarning, {alpha: 0, y: owner.attackWarning.y - 16}, 0.5, {ease: flixel.tweens.FlxEase.circOut, onComplete: 
            function(_)
            {
                owner.attackWarning.setPosition(owner.hudIndicatorOrigin.x, owner.hudIndicatorOrigin.y);
                owner.attackWarning.exists = false;
                
                owner.attackWarning.animation.stop();
            }
        });
        

        if (!owner.isObjectWithinDistance(owner.target, 0, 12, true))
            owner.actionSystem.setState(Idle, 750);
        // #endregion 

        // #region Animations
        if (owner.actionSystem.hasChanged())
            owner.enemyAnimation.setAnimation("post-spin", false, false, true, 0, true);
        // #endregion 
    }

    override public function _State_Damaged() 
    {
        // #region Basics 
        // Facing Direction
        owner.canChangeDirections = false;

        // #endregion

        // #region Logic 
        if (owner.isTouching(FlxObject.DOWN) && owner.velocity.y >= 0)
            owner.actionSystem.setState(Idle, 250);
        // #endregion

        // #region Animations
        if (owner.actionSystem.hasChanged())
            owner.enemyAnimation.setAnimation("damaged", false, false, true, 0, true);
        // #endregion
    }

    override public function _State_Dying() 
    {
        // #region Basics 
        owner.velocity.x = 0;
        
        owner.isAttacking = false;

        owner.hitboxes["Spinning"].exists = false;
        // Facing Direction
        owner.canChangeDirections = false;

        // #endregion

        // #region Logic 
        flixel.tweens.FlxTween.tween(owner.awakeWarning, {alpha: 0, y: owner.awakeWarning.y - 16}, 0.5, {ease: flixel.tweens.FlxEase.circOut, onComplete: 
            function(_)
            {
                owner.awakeWarning.setPosition(owner.hudIndicatorOrigin.x, owner.hudIndicatorOrigin.y);
                owner.awakeWarning.exists = false;
                
                owner.awakeWarning.animation.stop();
            }
        });
        
        flixel.tweens.FlxTween.tween(owner.attackWarning, {alpha: 0, y: owner.attackWarning.y - 16}, 0.5, {ease: flixel.tweens.FlxEase.circOut, onComplete: 
            function(_)
            {
                owner.attackWarning.setPosition(owner.hudIndicatorOrigin.x, owner.hudIndicatorOrigin.y);
                owner.attackWarning.exists = false;
                
                owner.attackWarning.animation.stop();
            }
        });

        if (owner.alive && owner.enemyAnimation.isOnLastFrame() && owner.enemyAnimation.isAnAnimation(["dead"]))
            owner.kill();
        // #endregion

        // #region Animations
        owner.enemyAnimation.setAnimation("dead", false, false, true, 0, true);
        // #endregion
    }

}