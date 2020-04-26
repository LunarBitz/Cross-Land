package entities.player;

import entities.player.PlayerParent;
import flixel.math.FlxMath;

enum PlayerStates 
{
	Null;
	Normal;
    Jumping;
    Falling;
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
     
    public function _State_Normal() 
    {
        owner.canChangeDirections = true;

        // Smooth out horizontal movement
        owner.setHorizontalMovement(200, owner.MOVEMENT_INTERP_RATIO);
        
        // Jump
        if (owner.playerInput.getInput("jump_just_pressed") == 1 && owner.canJump())
        {
            owner.jump();
            owner.actionSystem.setState(Jumping);
        }
    
        // Crouch
        if (owner.playerInput.getInput("crouch") == 1)
        {
            owner.actionSystem.setState(Crouching);
        }



        //--- Update Animations ---//
        // Only allow an animation change if there has been a state change
        if (owner.actionSystem.hasChanged())
        {
            // To uncrouching animation if previously crouching
            if (owner.playerAnimation.getPreviousAnimation() == "crouching")
                owner.playerAnimation.setAnimation("uncrouching");
        }

        // Only allow an animation change once the previous animation has finished
        if (owner.playerAnimation.isOnLastFrame())
        {
            // To idle animation if previously uncrouching
            if (owner.playerAnimation.getPreviousAnimation() == "uncrouching")
                owner.playerAnimation.setAnimation("idle");
        }
    }

    public function _State_Crouching() 
    {
        owner.canChangeDirections = false;

        // Smooth out horizontal movement
        owner.setHorizontalMovement(0, owner.MOVEMENT_INTERP_RATIO);

        // Crouch
        if (owner.playerInput.getInput("crouch_released") == 1)
        {
            owner.actionSystem.setState(Normal);
        }



        //--- Update Animations ---//
        if (owner.actionSystem.hasChanged())
            owner.playerAnimation.setAnimation("crouching", false, false, 0, true);
    }

    public function _State_Jumping() 
    {
        owner.canChangeDirections = true;

        // Smooth out horizontal movement
        owner.setHorizontalMovement(250, owner.MOVEMENT_INTERP_RATIO);
        
        // 2nd, nth jump
        if (owner.playerInput.getInput("jump_just_pressed") == 1 && owner.canJump())
        {
            owner.jump();
            owner.actionSystem.setState(Jumping);
        }
        


        //--- Update Animations ---//
        if (owner.actionSystem.hasChanged())
            owner.playerAnimation.setAnimation("idle");
    }

    public function _State_Sliding() 
    {
        owner.canChangeDirections = false;

        //--- Update Animations ---//
        if (owner.actionSystem.hasChanged())
            owner.playerAnimation.setAnimation("crouching");
    }
}
