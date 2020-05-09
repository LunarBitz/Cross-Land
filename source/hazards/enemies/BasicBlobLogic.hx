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
        if (owner.isObjectWithinDistance(owner.target, 5, 64, true))
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

}