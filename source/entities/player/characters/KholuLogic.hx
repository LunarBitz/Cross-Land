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
    Damaged;
    Walljump_Idle;
    Walljumping;
    Hurt;
    Tailwhip_R_L;
    Victory;
    Dead;
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
        owner.canResetState = false;
        owner.isAttacking = false;

        owner.hitboxes["tailwhip"].exists = false;

        // Horizontal Movement
        if (owner.playerAnimation.getCurrentAnimation() != "uncrouching")
            owner.setHorizontalMovement(owner.NORMAL_TARGET_SPEED, owner.inputDirection, owner.MOVEMENT_INTERP_RATIO * 3);

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
            owner.jumpBufferTimer = 0;
            owner.actionSystem.setState(Falling, 50);
        }
            
        // Crouch
        if (owner.playerInput.isInputDown("crouch"))
            owner.actionSystem.setState(Crouching);

        if (owner.playerInput.isInputDown("attack_1_just_pressed"))
        {
            owner.actionSystem.resetTimer();
            owner.actionSystem.setState(Tailwhip_R_L);
        }

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
            owner.playerAnimation.transition("tail_whip_R-L", "idle_normal");
        }
        // #endregion
    }



    override public function _State_Crouching() 
    {
        // #region Basics
        // Facing Direction
        owner.canChangeDirections = false;
        owner.canResetState = false;
        owner.isAttacking = false;

        // Horizontal movement
        owner.setHorizontalMovement(owner.CROUCH_TARGET_SPEED, owner.inputDirection, owner.MOVEMENT_INTERP_RATIO * 4);
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
        owner.canResetState = false;
        owner.isAttacking = false;

        // Horizontal movement
        owner.setHorizontalMovement(owner.UNCROUCH_TARGET_SPEED, owner.inputDirection, owner.MOVEMENT_INTERP_RATIO / 2);

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
        owner.canResetState = true;
        owner.isAttacking = false;

        // Horizontal movement
        owner.setHorizontalMovement(owner.IN_AIR_TARGET_SPEED, owner.inputDirection, owner.MOVEMENT_INTERP_RATIO);

        // Vertical Movement
        owner.scaleGravity(0.85, 0.65);
        // #endregion

        // #region Logic 
        // Jumping
        owner.jump();

        if (cast(owner, Kholu).canIdleOnWall())
            owner.actionSystem.setState(Walljump_Idle);

        if (owner.playerInput.isInputDown("attack_1_just_pressed"))
        {
            owner.actionSystem.resetTimer();
            owner.actionSystem.setState(Tailwhip_R_L);
        }
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
        owner.canResetState = true;
        owner.isAttacking = false;

        owner.hitboxes["tailwhip"].exists = false;

        // Horizontal movement
        owner.setHorizontalMovement(owner.IN_AIR_TARGET_SPEED, owner.inputDirection, owner.MOVEMENT_INTERP_RATIO);

        // Vertical Movement
        owner.scaleGravity(0.85, 0.65);
        // #endregion

        // #region Logic 
        if (owner.playerInput.isInputDown("jump_just_pressed"))
            owner.actionSystem.setState(Jumping);

        if (cast(owner, Kholu).canIdleOnWall() && owner.actionSystem.getPreviousState() != Walljump_Idle)
            owner.actionSystem.setState(Walljump_Idle);

        if (owner.playerInput.isInputDown("attack_1_just_pressed"))
        {
            owner.actionSystem.resetTimer();
            owner.actionSystem.setState(Tailwhip_R_L);
        }

        owner.jumpBufferTimer += FlxG.elapsed * 1000; // Increase buffer
        // #endregion

        // #region Animations
        if (owner.velocity.y >= 0)
            owner.playerAnimation.setAnimation("jump_fall");
        // #endregion
    }



    public function _State_Walljump_Idle() 
    {
        // #region Basics 
        // Facing Direction
        owner.canChangeDirections = false;
        owner.canResetState = true;
        owner.isAttacking = false;
        owner.facing = owner.onWall == -1? FlxObject.LEFT : FlxObject.RIGHT; // Change facing based on onWall only

        // Horizontal movement
        owner.setHorizontalMovement(1, owner.onWall, 1.0);
        
        // Vertical Movement
        owner.scaleGravity(0.1, 0.25);
        // #endregion

        // #region Logic 
        if (owner.onWall !=0 && owner.playerInput.getAxis("horizontalAxis") == -owner.onWall)
        {
            owner.playerSfx["wall_jump"].play(true);
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
        owner.canResetState = true;
        owner.isAttacking = false;

        if (owner.onWall != 0) 
            owner.facing = FlxMath.signOf(owner.xSpeed) == -1? FlxObject.LEFT : FlxObject.RIGHT; // Change facing based on xSpeed only

        // Horizontal Movement
        owner.setHorizontalMovement(owner.IN_AIR_TARGET_SPEED * 1.25, owner.inputDirection, owner.MOVEMENT_INTERP_RATIO);

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
        owner.canResetState = true;
        owner.isAttacking = false;

        owner.facing = FlxMath.signOf(owner.xSpeed) == -1? FlxObject.LEFT : FlxObject.RIGHT; // Change facing based on xSpeed only

        // Horizontal Movement
        owner.setHorizontalMovement(owner.IN_AIR_TARGET_SPEED * 0.75, owner.inputDirection, owner.MOVEMENT_INTERP_RATIO);

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

    public function _State_Tailwhip_R_L() 
    {
        // #region Basics
        // Facing Direction
        owner.canChangeDirections = false;
        owner.canResetState = false;
        owner.isAttacking = true;
        

        owner.hitboxes["tailwhip"].exists = true;

        // Horizontal Movement
        owner.setHorizontalMovement(owner.NORMAL_TARGET_SPEED * 1.1, owner.inputDirection, owner.MOVEMENT_INTERP_RATIO);
        //owner.setHorizontalMovement(owner.NORMAL_TARGET_SPEED * 1.1, owner.facing == FlxObject.LEFT?  -1:1, 1);
        
        // Vertical Movement
        //owner.velocity.y = 0;
        owner.scaleGravity(0.85, 0.65);
        // #endregion  

        // #region Logic
        // Falling

        owner.playerSfx["swish_1"].play();
        if (owner.playerAnimation.isAnimationFinished() && owner.playerAnimation.getCurrentAnimation() == "tail_whip_R-L")
        {
            if (owner.isOnGround())
                owner.actionSystem.setState(Normal, 250);
            else
                owner.actionSystem.setState(Falling, 250);
        }
            
        
        // #endregion

        // #region Animations
        // Only allow an animation change if there has been a state change
        if (owner.actionSystem.hasChanged())
        {
            // To uncrouching animation if previously crouching
            owner.playerAnimation.setAnimation("tail_whip_R-L", false, false, true, 0, true);

            //if (owner.playerAnimation.)
        }
        // #endregion
    }

    override public function _State_Victory() 
    {
        // #region Basics 
        // Facing Direction
        owner.canChangeDirections = false;
        owner.canResetState = false;
        owner.isAttacking = false;

        owner.facing = FlxMath.signOf(owner.xSpeed) == -1? FlxObject.LEFT : FlxObject.RIGHT; // Change facing based on xSpeed only

        // Horizontal Movement
        owner.setHorizontalMovement(0, owner.facingDirection, 1/64);

        // Vertical Movement
        owner.scaleGravity(0.85, 0.65);
        // #endregion

        // #region Logic 
        owner.hasWonStage = true;

        if (FlxG.sound.music != null) // don't restart the music if it's already playing
        {
            FlxG.sound.music.fadeOut(1, 0);
            LevelGlobals.ambienceTrack.fadeOut(1, 0);
        }

        new flixel.util.FlxTimer().start(3, 
            function(_)
            {
                LevelGlobals.hudReference.clear();
                LevelGlobals.hudReference.drawVictory();
                owner.actionSystem.setState(Null);
            }
        , 1);
        
        
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
                owner.playerAnimation.transition("tail_whip_R-L", "idle_normal");
            }
            // #endregion
    }

    override public function _State_Dead() 
    {
        // #region Basics 
        // Facing Direction
        owner.canChangeDirections = false;
        owner.canResetState = false;
        owner.isAttacking = false;

        owner.invincibilityTimer = 500;

        owner.facing = FlxMath.signOf(owner.xSpeed) == -1? FlxObject.LEFT : FlxObject.RIGHT; // Change facing based on xSpeed only

        // Horizontal Movement
        owner.setHorizontalMovement(0, owner.facingDirection, 1/16);

        // Vertical Movement
        owner.scaleGravity(0.85, 0.65);
        // #endregion

        // #region Logic 
        if (FlxG.sound.music != null) // don't restart the music if it's already playing
        {
            FlxG.sound.music.fadeOut(1, 0);
            LevelGlobals.ambienceTrack.fadeOut(1, 0);
        }

        new flixel.util.FlxTimer().start(3, 
            function(_)
            {
                LevelGlobals.hudReference.clickReplay();
            }
        , 1);
        // #endregion

        // #region Animations
        if (owner.actionSystem.hasChanged())
            owner.playerAnimation.setAnimation("critically_damaged", false, false, true, 0, false);
        // #endregion
    }
}
