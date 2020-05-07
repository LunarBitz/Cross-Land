package hazards.enemies;

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

        owner.isAttacking = false;
        // #endregion 

        // #region Logic
        if (owner.isPlayerWithin(5, 64, true))
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

        owner.isAttacking = false;
        // #endregion 

        // #region Logic
        if (owner.isPlayerWithin(5, 135, true))
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

        owner.isAttacking = false;
        // #endregion 

        // #region Logic
        owner.actionSystem.setState(Walking, true);
        // #endregion 

        // #region Animations
        owner.enemyAnimation.setAnimation("idle");
        // #endregion 
    }

    override public function _State_Walking() 
    {
        // #region Basics
        owner.velocity.x = 50 * FlxMath.signOf(owner.target.x - owner.x);
        // #endregion 

        // #region Logic
        if (owner.isPlayerWithin(0, 16, true))
            owner.actionSystem.setState(Pre_Attack);
        else if (!owner.isPlayerWithin(5, 135, true))
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

        owner.isAttacking = false;
        // #endregion 

        // #region Logic
        owner.actionSystem.setState(Attack_1, true);
        // #endregion 

        // #region Animations
        // #endregion 
    }

    override public function _State_Attack_1() 
    {
        // #region Basics
        owner.velocity.x = 0;

        owner.isAttacking = true;
        // #endregion 

        // #region Logic
        if (!owner.isPlayerWithin(0, 16, true))
            owner.actionSystem.setState(Idle, true);
        // #endregion 

        // #region Animations
        // #endregion 
    }

}