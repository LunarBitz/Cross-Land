package hazards.parents;

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
    Attack_2;
    Attack_3;
}

class EnemyStateLogic
{
    public var owner:Enemy;
    public var states:Dynamic;

    public function new(obj:Enemy) 
    { 
        owner = obj; 
        states = EnemyLogic.EnemyStates;
    }    
     
    public function _State_Idle() 
    {
        #if debug
        //trace("Idle");
        #end
        owner.isAttacking = false;
        owner.velocity.x = 0;

        if (owner.isPlayerWithin(5, 175, true))
        {
            owner.actionSystem.setState(Detected);
        }
    }

    public function _State_Detected() 
    {
        #if debug
        //trace("Detected");
        #end
        owner.isAttacking = false;
        owner.velocity.x = 0;

        owner.actionSystem.setState(Walking, true);
    }

    public function _State_Walking() 
    {
        #if debug
        //trace("Walking");
        #end
        owner.isAttacking = false;
        owner.velocity.x = 50 * FlxMath.signOf(owner.target.x - owner.x);
        

        if (owner.isPlayerWithin(0, 16, true))
        {
            owner.actionSystem.setState(Pre_Attack);
        }
        else if (!owner.isPlayerWithin(5, 175, true))
        {
            owner.actionSystem.setState(Idle);
        }
    }

    public function _State_Pre_Attack() 
    {
        #if debug
        //trace("Pre_attack");
        #end
        owner.velocity.x = 0;

        owner.actionSystem.setState(Attack_1, true);
    }

    public function _State_Attack_1() 
    {
        owner.isAttacking = true;
        #if debug
        //trace("Attacking_1");
        #end
        if (!owner.isPlayerWithin(0, 16, true))
        {
            owner.actionSystem.setState(Idle, true);
        }
    }

    public function _State_Attack_2() 
    {
        owner.isAttacking = true;
        #if debug
        //trace("Attacking_2");
        #end
    }

    public function _State_Attack_3() 
    {
        owner.isAttacking = true;
        #if debug
        //trace("Attacking_3");
        #end
    }
}