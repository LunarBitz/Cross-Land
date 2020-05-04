package entities.player;

import entities.player.PlayerParent;
import flixel.math.FlxMath;

enum PlayerStates 
{
	Null;
	Normal;
    Jumping;
    Falling;
    Damaged;
    Crouching;
    Uncrouching;
    PL;
}

class PlayerStateLogics
{
    public var owner:Player;
    public var states:Dynamic;

    public function new(obj:Player) 
    { 
        owner = obj; 
        states = PlayerLogic.PlayerStates;
    }    
     
    public function _State_Normal() {}

    public function _State_Crouching() {}

    public function _State_Jumping() {}

    public function _State_Sliding() {}

    public function _State_Damaged() {}
}
