package entities.player;

import entities.player.PlayerParent;
import flixel.math.FlxMath;

enum PlayerStates 
{
	Null;
	Normal;
	Jumping;
	Crouching;
	Sliding;
}

class HeroStateLogics
{
    var owner:Player;

    public function new(hero:Player) { owner = hero; }    
     
    public function _State_Normal() 
    {
        // Smooth out horizontal movement
        owner.velocity.x = FlxMath.lerp(owner.velocity.x, 200 * owner.facingDirection, owner.MOVEMENT_INTERP_RATIO);
        
        // Jump
        if (owner.playerInput.getInput("jump_just_pressed") == 1 && owner.canJump())
        {
            owner.jump(owner.maxJumpCount);
            owner.playerState.setState(Jumping);
        }
    
        // Crouch
        if (owner.playerInput.getInput("crouch") == 1)
        {
            owner.playerState.setState(Crouching);
        }



        //--- Update Animations ---//
        // Only allow an animation change if there has been a state change
        if (owner.playerState.hasChanged())
        {
            // To uncrouching animation if previously crouching
            if (owner.playerAnimation.getPreviousAnimation() == "crouching")
                owner.playerAnimation.setAnimation("uncrouching");
        }

        // Only allow an animation change once the previous animation has finished
        if (owner.playerAnimation.isFinished())
        {
            // To idle animation if previously uncrouching
            if (owner.playerAnimation.getPreviousAnimation() == "uncrouching")
                owner.playerAnimation.setAnimation("idle");
        }
    }

    public function _State_Crouching() 
    {
        // Smooth out horizontal movement
        owner.velocity.x = FlxMath.lerp(owner.velocity.x, 0, owner.MOVEMENT_INTERP_RATIO);

        // Crouch
        if (owner.playerInput.getInput("crouch_released") == 1)
        {
            owner.playerState.setState(Normal);
        }



        //--- Update Animations ---//
        if (owner.playerState.hasChanged())
            owner.playerAnimation.setAnimation("crouching", false, false, 0, true);
    }

    public function _State_Jumping() 
    {
        // Smooth out horizontal movement
        owner.velocity.x = FlxMath.lerp(owner.velocity.x, 250 * owner.facingDirection, owner.MOVEMENT_INTERP_RATIO);
        
        // 2nd, nth jump
        if (owner.playerInput.getInput("jump_just_pressed") == 1 && owner.canJump())
        {
            owner.jump(owner.maxJumpCount);
            owner.playerState.setState(Jumping);
        }
        


        //--- Update Animations ---//
        if (owner.playerState.hasChanged())
            owner.playerAnimation.setAnimation("idle");
    }

    public function _State_Sliding() 
    {
        //--- Update Animations ---//
        if (owner.playerState.hasChanged())
            owner.playerAnimation.setAnimation("crouching");
    }
}
