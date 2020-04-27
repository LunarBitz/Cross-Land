package entities.player.characters;

import entities.player.PlayerParent;
import entities.player.PlayerLogic;
import flixel.math.FlxMath;

enum PlayerStates 
{
	Null;
	Normal;
    Jumping;
    Falling;
    Crouching;
    Uncrouching;
    Sliding;
    KL;
}

class KholuStateLogics extends PlayerStateLogics
{

    override public function new(obj:Player) 
    { 
        super(obj);

        owner = obj; 
        states = KholuLogic.PlayerStates;
    }    
     

    
    override public function _State_Normal() 
    {
        // #region Logic
        owner.canChangeDirections = true;

        // horizontal Movement
        if (owner.playerAnimation.getCurrentAnimation() != "uncrouching")
            owner.setHorizontalMovement(175, owner.MOVEMENT_INTERP_RATIO);

        // Jump
        if (owner.playerInput.isInputDown("jump_just_pressed"))
            owner.actionSystem.setState(Jumping);

        if (!owner.isOnGround())
            owner.actionSystem.setState(Falling);
    
        // Crouch
        if (owner.playerInput.isInputDown("crouch"))
            owner.actionSystem.setState(Crouching);
        // #endregion

        // #region Animations
        if (owner.isOnGround())
        {
            if (owner.playerAnimation.isAnAnimation(["idle_normal", "walking", "running", "sprinting"]))
            {
                var xX = Math.floor(Math.abs(owner.velocity.x));
                if (xX <= 3)
                    owner.playerAnimation.setAnimation("idle_normal");
                else if (xX > 3 && xX <= 60)
                    owner.playerAnimation.setAnimation("walking");
                else if (xX > 60 && xX <= 120)
                    owner.playerAnimation.setAnimation("running");
                else if (xX > 120)
                    owner.playerAnimation.setAnimation("sprinting");

                owner.animation.getByName("walking").frameRate = Math.round(((xX + 0.1) / 40) * 10);
            }
        }

        // Only allow an animation change if there has been a state change
        if (owner.actionSystem.hasChanged())
        {
            // To uncrouching animation if previously crouching
            owner.playerAnimation.transition("uncrouching", "idle_normal");

            // To uncrouching animation if previously crouching
            owner.playerAnimation.transition("jumping", "idle_normal");
            owner.playerAnimation.transition("jump_fall", "idle_normal");
        }
        // #endregion
    }



    override public function _State_Crouching() 
    {
        // #region Logic
        owner.canChangeDirections = false;

        // Horizontal movement
        owner.setHorizontalMovement(0, owner.MOVEMENT_INTERP_RATIO * 4);

        // Crouch
        if (owner.playerInput.isInputDown("crouch_released"))
        {
            owner.actionSystem.setState(Uncrouching);
        }
        // #endregion

        // #region Animations
        if (owner.actionSystem.hasChanged())
        {
            owner.playerAnimation.setAnimation("crouching", false, false, 0, true);
        }
        // #endregion
    }



    public function _State_Uncrouching() 
    {
        // #region Logic
        owner.canChangeDirections = false;

        // Horizontal movement
        owner.setHorizontalMovement(5, owner.MOVEMENT_INTERP_RATIO / 2);
        // #endregion

        // #region Animations
        if (owner.actionSystem.hasChanged())
        {
            owner.playerAnimation.setAnimation("uncrouching");
        }

        if (owner.playerAnimation.isOnLastFrame())
        {
            owner.actionSystem.setState(Normal);
        }
        // #endregion
    }



    override public function _State_Jumping() 
    {
        // #region Logic 
        owner.canChangeDirections = true;

        // Horizontal movement
        owner.setHorizontalMovement(200, owner.MOVEMENT_INTERP_RATIO);
        
        owner.jump();
        // #endregion

        // #region Animations
        if (owner.velocity.y < 0)
            owner.playerAnimation.setAnimation("jumping");
        else if (owner.velocity.y >= 0)
            owner.playerAnimation.setAnimation("jump_fall");
        // #endregion
    }



    public function _State_Falling() 
    {
        // #region Logic 
        owner.canChangeDirections = true;

        // Horizontal movement
        owner.setHorizontalMovement(175, owner.MOVEMENT_INTERP_RATIO);
        // #endregion

        // #region Animations
        if (owner.velocity.y >= 0)
            owner.playerAnimation.setAnimation("jump_fall");
        // #endregion
    }


    
    override public function _State_Sliding() 
    {
        owner.canChangeDirections = false;

        // #region Animations
        if (owner.actionSystem.hasChanged())
            owner.playerAnimation.setAnimation("crouching");
        // #endregion
    }
}
