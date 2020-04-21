package entities.player;

import flixel.animation.FlxAnimation;
import haxe.CallStack.StackItem;
import flixel.system.debug.watch.Watch;
import flixel.system.FlxSplash;
import haxe.macro.Expr.Case;
import flixel.math.FlxMath;
import flixel.FlxG;
import systems.Hud;
import flixel.FlxSprite;
import flixel.FlxObject;
import systems.Animation;
import systems.Action;
import systems.Input;
import flixel.input.keyboard.FlxKey;
import entities.player.PlayerStates;

class Player extends FlxSprite 
{
	// Systems
	public var playerLogic:HeroStateLogics;
	public var playerState:ActionSystem;
	public var playerAnimation:AnimationSystem;
	public var playerInput:InputSystem;

	// Input
	public var DEAD_ZONE(default, never):Float = 0.1;
	public var MOVEMENT_INTERP_RATIO(default, never):Float = 1/16;

	// Generals
	public var facingDirection:Int = 1;
	public var grounded:Bool = false;

	// Movement
	public var GRAVITY(default, never):Float = 981;
	public static var TERMINAL_VELOCITY(default, never):Float = 1500;

	public var xSpeed:Float = 0;
	public var ySpeed:Float = 0;
	
	// Jumping
	public var JUMP_SPEED(default, never):Float = -350;
	public var currentJumpCount:Int = 0;
	public var maxJumpCount:Int = 2;



	public function new(?X:Float = 0, ?Y:Float = 0) 
	{
		super(X, Y);

		// Set up the needed custom systems
		playerLogic = new HeroStateLogics(this);
		playerState = new ActionSystem(Normal);
		playerAnimation = new AnimationSystem(this);
		playerInput = new InputSystem();

		gatherInputs();

		// Set up "gravity" (constant acceleration) and "terminal velocity" (max fall speed)
		acceleration.y = GRAVITY;
		maxVelocity.y = TERMINAL_VELOCITY;

		// Set up graphics and animations
		loadGraphic("assets/images/sprPlayer.png", true, 32, 32);

		// Custom hitbox ignoring the transparent pixels
		// Hard-coded because offset was so finicky when updating
		setSize(20, 32);
		offset.set(6, 0);
		centerOrigin(); 

		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);

		animation.add("idle", [0], 45, false);
		animation.add("crouching", [1, 2, 3, 4, 5, 6], 45, false);
		animation.add("uncrouching", [6, 5, 4, 3, 2, 1], 45, false);
		
	}

	override function update(elapsed:Float) 
	{
		// Set up nicer input-handling for movement.
		playerInput.poll();

		// Update facing direction
		facingDirection = getMoveDirectionCoefficient(playerInput.getAxis("horizontalAxis"));
		if (facingDirection != 0)
			facing = (facingDirection == -1)? FlxObject.LEFT : FlxObject.RIGHT;

		handleStates();

		super.update(elapsed);
	}

	/**
		Helper function responsible for interacting with HaxeFlixel systems to gather inputs 
		relevant to the Hero. Helps keep code clean by restricting FlxG.keys input to a single spot,
		which makes it much easier to change inputs, implement rebinding, etc. in the future.
	**/
	private function gatherInputs():Void 
	{
		playerInput.bindInput("left", [FlxKey.LEFT, FlxKey.DELETE]);
		playerInput.bindInput("right", [FlxKey.RIGHT, FlxKey.PAGEDOWN]);
		playerInput.bindInput("jump", [FlxKey.Z, FlxKey.NUMPADSEVEN]);
		playerInput.bindInput("crouch", [FlxKey.DOWN, FlxKey.END]);
		playerInput.bindAxis("horizontalAxis", "left", "right");
	}

	/**
		Function to handle what happens with each action state.
		See `HeroStates.hx`
	**/
	public function handleStates():Void
	{
		switch (playerState.getState())
		{
			case (PlayerStates.Normal):
				playerLogic._State_Normal();

			case (PlayerStates.Crouching):
				playerLogic._State_Crouching();

			case (PlayerStates.Jumping):
				playerLogic._State_Jumping();

			case (PlayerStates.Sliding):
				playerLogic._State_Sliding();
				
			case (PlayerStates.Null):
			default:
		}
	}

	/**
		Uses player input to determine if movement should occur in a positive or negative X 
		direction. If no movement inputs are detected, 0 is returned instead.
		@param axis Float representing an axis of input.
		@return Returns **1**, **0**, or **-1**. Multiply movement speed by this to set movement direction.
	**/
	private inline function getMoveDirectionCoefficient(axis:Float):Int 
	{      
		return (Math.abs(axis) <= DEAD_ZONE)? 0 : FlxMath.signOf(axis);
	}

	/**
		Returns if the player is on the ground or not
		@return Returns `grounded`.
	**/
	public function isOnGround():Bool 
	{ 
		return this.isTouching(FlxObject.DOWN); 
	}

	/**
		Returns if the player is allowed to jump
		@return Returns **True** only if `grounded` is **True** *or* `currentJumpCount` <= `maxJumpCount`.
	**/
	public inline function canJump() 
	{
		return  (isOnGround() || (currentJumpCount < maxJumpCount)) &&
				(playerState.getState() != Crouching);
	}

	/**
		Simple function for handling jump logic.
		@param jumpCount Number of jumps allowed.
		@return Returns **True** if jumping.
	**/
	public function jump(jumpCount:Int):Void 
	{
		velocity.y = JUMP_SPEED;
		currentJumpCount++;
	}

	/**
		Function that's called to resolve collision overlaping with solid objects when invoked.
		@param player Object that collided with something.
		@param other Object that `player` has collided with.
	**/
	public function onWallCollision(player:FlxSprite, other:FlxSprite):Void
	{
		if (playerState.getState() == Jumping && isOnGround())
		{
			currentJumpCount = 0;

			playerState.setState(Normal);
		}
	}

	/**
		Function that's called to resolve collision overlaping with damage inducing objects when invoked.
		@param player Object that collided with something.
		@param other Object that `player` has collided with.
	**/
	public function onDamageCollision(player:FlxSprite, other:FlxSprite):Void
	{
		// We ONLY do a pixel perfect check if the object in question has collided with our simplified hitbox.
		//
		// Checking perfectly since we have a character that can crouch
		// WAY easier than calculating and updating the hitbox. 
		// It really is, since HaxeFlixel doesn't do a good job scaling with the set origin
		//	which was resulting in glitchy floor detection
		if (FlxG.pixelPerfectOverlap(player, other))
		{
			trace("We have really collided with the object");

			other.kill();
		}
	}

	

}