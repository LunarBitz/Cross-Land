package hazards.parents;

import flixel.math.FlxMath;

enum EnemyStates 
{
	Null;
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
        trace("Idle");
        owner.velocity.x = 0;

        if (owner.isPlayerWithin(175))
        {
            owner.actionSystem.setState(Detected);
        }
        
    }

    public function _State_Detected() 
    {
        trace("Detected");
        owner.velocity.x = 0;

        owner.actionSystem.setState(Walking, true);
    }

    public function _State_Walking() 
    {
        trace("Walking");
        owner.velocity.x = 50 * FlxMath.signOf(owner.target.x - owner.x);
        

        if (owner.isPlayerWithin(16))
        {
            owner.actionSystem.setState(Pre_Attack);
        }
        else if (!owner.isPlayerWithin(175))
        {
            owner.actionSystem.setState(Idle);
        }
    }

    public function _State_Pre_Attack() 
    {
        trace("Pre_attack");
        owner.velocity.x = 0;

        owner.actionSystem.setState(Attack_1, true);
    }

    public function _State_Attack_1() 
    {
        trace("Attacking_1");
        if (!owner.isPlayerWithin(16))
        {
            owner.actionSystem.setState(Idle, true);
        }
    }

    public function _State_Attack_2() 
    {
        trace("Attacking_2");
    }

    public function _State_Attack_3() 
    {
        trace("Attacking_3");
    }
}