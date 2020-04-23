package entities.player.characters;

import entities.player.PlayerParent;
import entities.player.PlayerLogic;
import flixel.math.FlxMath;

enum PlayerStates 
{
	Null;
	Normal;
	Jumping;
	Crouching;
    Sliding;
    KL;
}

class KholuStateLogics extends PlayerStateLogics
{

    override public function new(obj:Player) 
    { 
        super(obj);

        owner = obj; 
        enumerator = KholuLogic.PlayerStates;
    }    
     

    
    override public function _State_Normal() 
    {

        // Smooth out horizontal movement
        owner.moveX(225, owner.MOVEMENT_INTERP_RATIO);
        
        // Jump
        if (owner.playerInput.isInputDown("jump_just_pressed"))
            owner.actionSystem.setState(Jumping);
    
        // Crouch
        if (owner.playerInput.isInputDown("crouch"))
            owner.actionSystem.setState(Crouching);



        //--- Update Animations ---//
        if (owner.playerAnimation.getCurrentAnimation() != "uncrouching")
        {
            var xX = Math.floor(Math.abs(owner.velocity.x));
            trace("Speed: ", xX);
            if (xX <= 30)
                owner.playerAnimation.setAnimation("idle_normal");
            else if (xX > 30 && xX <= 80)
                owner.playerAnimation.setAnimation("walking");
            else if (xX > 80 && xX <= 160)
                owner.playerAnimation.setAnimation("running");
            else if (xX > 160)
                owner.playerAnimation.setAnimation("sprinting");
        }
        else 
        {
            if (owner.playerAnimation.isFinished())
                owner.playerAnimation.setAnimation("idle_normal");
        }

        // Only allow an animation change if there has been a state change
        if (owner.actionSystem.hasChanged())
        {
            
            // To uncrouching animation if previously crouching
            if (owner.playerAnimation.getPreviousAnimation() == "crouching")
            {
                owner.playerAnimation.setAnimation("uncrouching");
            }

            // To uncrouching animation if previously crouching
            if (owner.playerAnimation.getPreviousAnimation() == "jumping")
            {
               owner.playerAnimation.setAnimation("idle_normal");
            }
        }

        // Only allow an animation change once the previous animation has finished
        if (owner.playerAnimation.isFinished())
        {
            
            // To idle animation if previously uncrouching
            if (owner.playerAnimation.getPreviousAnimation() == "uncrouching")
            {
                owner.playerAnimation.setAnimation("idle_normal");
            }
        }
    }



    override public function _State_Crouching() 
    {
        // Smooth out horizontal movement
        owner.moveX(0, 0.9);

        // Crouch
        if (owner.playerInput.isInputDown("crouch_released"))
        {
            owner.actionSystem.setState(Normal);
        }



        //--- Update Animations ---//
        if (owner.actionSystem.hasChanged())
            owner.playerAnimation.setAnimation("crouching", false, false, 0, true);
    }



    override public function _State_Jumping() 
    {
        
        // Smooth out horizontal movement
        owner.moveX(250, owner.MOVEMENT_INTERP_RATIO);
        
        owner.jump();

        //--- Update Animations ---//
        if (owner.velocity.y < 0)
            owner.playerAnimation.setAnimation("jumping");
        else if (owner.velocity.y >= 0)
            owner.playerAnimation.setAnimation("jump_fall");
    }

    override public function _State_Sliding() 
    {
        //--- Update Animations ---//
        if (owner.actionSystem.hasChanged())
            owner.playerAnimation.setAnimation("crouching");
    }
}
