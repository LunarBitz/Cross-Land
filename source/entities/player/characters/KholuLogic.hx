package entities.player.characters;

import flixel.FlxG;
import flixel.FlxObject;
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
    Damaged;
    Walljump_Idle;
    Walljumping;
    Hurt;
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
        // #region Basics
        // Facing Direction
        owner.canChangeDirections = true;

        // Horizontal Movement
        if (owner.playerAnimation.getCurrentAnimation() != "uncrouching")
            owner.setHorizontalMovement(owner.NORMAL_TARGET_SPEED, owner.facingDirection, owner.MOVEMENT_INTERP_RATIO * 3);

        // Vertical Movement
        owner.scaleGravity(0.85, 0.65);
        // #endregion  

        // #region Logic
        // Jump
        if (owner.playerInput.isInputDown("jump_just_pressed"))
            owner.actionSystem.setState(Jumping);

        // Falling
        if (!owner.isOnGround())
        {
            owner.actionSystem.setState(Falling, 50);
        }
            
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
            owner.playerAnimation.transition("idle_walljumping", "idle_normal");
            owner.playerAnimation.transition("damaged_frontside", "idle_normal");
        }
        // #endregion
    }



    override public function _State_Crouching() 
    {
        // #region Basics
        // Facing Direction
        owner.canChangeDirections = false;

        // Horizontal movement
        owner.setHorizontalMovement(owner.CROUCH_TARGET_SPEED, owner.facingDirection, owner.MOVEMENT_INTERP_RATIO * 4);
        // #endregion

        // #region Logic
        // Crouch
        if (owner.playerInput.isInputDown("crouch_released"))
            owner.actionSystem.setState(Uncrouching);
        // #endregion

        // #region Animations
        if (owner.actionSystem.hasChanged())
            owner.playerAnimation.setAnimation("crouching", false, false, true, 0, true);
        // #endregion
    }



    public function _State_Uncrouching() 
    {
        // #region Basics
        // Facing Direction
        owner.canChangeDirections = false;

        // Horizontal movement
        owner.setHorizontalMovement(owner.UNCROUCH_TARGET_SPEED, owner.facingDirection, owner.MOVEMENT_INTERP_RATIO / 2);

        // Vertical Movement
        owner.scaleGravity(0.85, 0.65);
        // #endregion

        // #region Logic
        if (owner.playerAnimation.isOnLastFrame() && owner.playerAnimation.isAnAnimation(["uncrouching"]))
        {
            owner.actionSystem.setState(Normal);
        }
        // #endregion

        // #region Animations
        if (owner.actionSystem.hasChanged())
        {
            owner.playerAnimation.setAnimation("uncrouching");
        }
        // #endregion
    }



    override public function _State_Jumping() 
    {
        // #region Basics 
        // Facing Direction
        owner.canChangeDirections = true;

        // Horizontal movement
        owner.setHorizontalMovement(owner.IN_AIR_TARGET_SPEED, owner.facingDirection, owner.MOVEMENT_INTERP_RATIO);

        // Vertical Movement
        owner.scaleGravity(0.85, 0.65);
        // #endregion

        // #region Logic 
        // Jumping
        owner.jump();

        if (cast(owner, Kholu).canIdleOnWall())
            owner.actionSystem.setState(Walljump_Idle);
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
        // #region Basics 
        // Facing Direction
        owner.canChangeDirections = true;

        // Horizontal movement
        owner.setHorizontalMovement(owner.IN_AIR_TARGET_SPEED, owner.facingDirection, owner.MOVEMENT_INTERP_RATIO);

        // Vertical Movement
        owner.scaleGravity(0.85, 0.65);
        // #endregion

        // #region Logic 
        if (cast(owner, Kholu).canIdleOnWall() && owner.actionSystem.getPreviousState() != Walljump_Idle)
            owner.actionSystem.setState(Walljump_Idle);
        // #endregion

        // #region Animations
        if (owner.velocity.y >= 0)
            owner.playerAnimation.setAnimation("jump_fall");
        // #endregion
    }


    
    override public function _State_Sliding() 
    {
        // #region Basics 
        // Facing Direction
        owner.canChangeDirections = false;
        // #endregion

        // #region Logic
        // #endregion

        // #region Animations
        if (owner.actionSystem.hasChanged())
            owner.playerAnimation.setAnimation("crouching");
        // #endregion
    }



    public function _State_Walljump_Idle() 
    {
        // #region Basics 
        // Facing Direction
        owner.canChangeDirections = false;
        owner.facing = owner.onWall == -1? FlxObject.LEFT : FlxObject.RIGHT; // Change facing based on onWall only

        // Horizontal movement
        owner.setHorizontalMovement(1, owner.onWall, 1.0);
        
        // Vertical Movement
        owner.scaleGravity(0.1, 0.25);
        // #endregion

        // #region Logic 
        if (owner.onWall !=0 && owner.playerInput.getAxis("horizontalAxis") == -owner.onWall)
        {
            owner.sfx["wall_jump"].play(true);
            owner.setHorizontalMovement(owner.IN_AIR_TARGET_SPEED, -owner.onWall, 1);
            owner.velocity.y = owner.JUMP_SPEED;
            owner.facing = FlxMath.signOf(owner.xSpeed) == -1? FlxObject.LEFT : FlxObject.RIGHT;
            owner.actionSystem.setState(Walljumping);
        }
        else if (owner.velocity.y >= 120 || !owner.playerInput.isInputDown("up"))
        {
            owner.actionSystem.setState(Falling);
        }
        // #endregion

        // #region Animations
        if (owner.onWall != 0)
            owner.playerAnimation.setAnimation("idle_walljumping");
        else 
            owner.playerAnimation.setAnimation("jump_fall");
        // #endregion
    }



    public function _State_Walljumping() 
    {
        // #region Basics 
        // Facing Direction
        owner.canChangeDirections = false;
        if (owner.onWall != 0) 
            owner.facing = FlxMath.signOf(owner.xSpeed) == -1? FlxObject.LEFT : FlxObject.RIGHT; // Change facing based on xSpeed only

        // Horizontal Movement
        owner.setHorizontalMovement(owner.IN_AIR_TARGET_SPEED * 1.25, owner.facingDirection, owner.MOVEMENT_INTERP_RATIO);

        // Vertical Movement
        owner.scaleGravity(0.85, 0.65);
        // #endregion

        // #region Logic 
        if (owner.velocity.y >= 0)
            owner.actionSystem.setState(Falling);

        if (cast(owner, Kholu).canIdleOnWall())
            owner.actionSystem.setState(Walljump_Idle);
        // #endregion

        // #region Animations
        if (owner.actionSystem.hasChanged())
            owner.playerAnimation.setAnimation("walljumping");
        // #endregion
    }



    override public function _State_Damaged() 
    {
        // #region Basics 
        // Facing Direction
        owner.canChangeDirections = false;
        owner.facing = FlxMath.signOf(owner.xSpeed) == -1? FlxObject.LEFT : FlxObject.RIGHT; // Change facing based on xSpeed only

        // Horizontal Movement
        owner.setHorizontalMovement(owner.IN_AIR_TARGET_SPEED * 0.75, owner.facingDirection, owner.MOVEMENT_INTERP_RATIO);

        // Vertical Movement
        owner.scaleGravity(0.85, 0.65);
        // #endregion

        // #region Logic 

        // #endregion

        // #region Animations
        if (owner.actionSystem.hasChanged())
            owner.playerAnimation.setAnimation("damaged_frontside", false, false, true, 0, true);
        // #endregion
    }
}
