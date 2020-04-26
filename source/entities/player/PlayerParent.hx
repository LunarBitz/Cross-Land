package entities.player;

import flixel.util.FlxColor;
import flixel.FlxBasic;
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
import systems.ExtendedAnimation;
import systems.Action;
import systems.Input;
import flixel.input.keyboard.FlxKey;
import entities.player.PlayerLogic;

class Player extends FlxSprite 
{
	// Systems
	public var playerLogic:PlayerStateLogics;
	public var actionSystem:ActionSystem;
	public var playerAnimation:ExtAnimationSystem;
	public var playerInput:InputSystem;

	// Input
	public var DEAD_ZONE(default, never):Float = 0.1;
	public var MOVEMENT_INTERP_RATIO(default, never):Float = 1/32;

	// Generals
	public var canChangeDirections:Bool = false;
	public var facingDirection:Int = 1;
	public var grounded:Bool = false;

	// Movement
	public var GRAVITY(default, never):Float = 981;
	public var TERMINAL_VELOCITY(default, never):Float = 1500;

	public var xSpeed:Float = 0;
	public var ySpeed:Float = 0;
	
	// Jumping
	public var JUMP_SPEED:Float = -350;
	public var currentJumpCount:Int = 0;
	public var maxJumpCount:Int = 3;
	private var _jumping:Bool = false;

	public var _solidsRef:Dynamic;

	private var timePassed:Float = 0;


	public function new(?X:Float = 0, ?Y:Float = 0) 
	{
		super(X, Y);

		// Set up the needed custom systems
		playerLogic = new PlayerStateLogics(this);
		actionSystem = new ActionSystem(PlayerLogic.PlayerStates.Normal, PlayerLogic.PlayerStates);
		playerAnimation = new ExtAnimationSystem(this);
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

		gatherAnimations();

		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);
		
	}

	override function update(elapsed:Float) 
	{
		// Set up nicer input-handling for movement.
		playerInput.poll();

		grounded = this.isTouching(FlxObject.DOWN);
		
		// Update facing direction
		updateDirection();

		// Call the main logic states of the player
		callStates();

		// Apply velocity
		updateVelocity();

		timePassed += elapsed;
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
		Helper to add all animations of the player
	**/
	private function gatherAnimations():Void 
	{
		animation.add("idle", [0], 45, false);
		animation.add("crouching", [1, 2, 3, 4, 5, 6], 45, false);
		animation.add("uncrouching", [6, 5, 4, 3, 2, 1], 45, false);
	}

	/**
		Function to handle what happens with each action state.
		See `[xx]Logic.hx`
	**/
	public function callStates():Void
	{
		for (state in Type.allEnums(playerLogic.states))
		{ 
			var fn = Reflect.field(playerLogic, "_State_" + Std.string(state));
			if (fn != null && actionSystem.getState() == state)
			{
				Reflect.callMethod(playerLogic, fn, []);
			}	
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

	private function updateDirection():Void
	{
		facingDirection = getMoveDirectionCoefficient(playerInput.getAxis("horizontalAxis"));
		if (facingDirection != 0 && canChangeDirections)
			facing = (facingDirection == -1)? FlxObject.LEFT : FlxObject.RIGHT;
	}

	/**
		Returns if the player is on the ground or not
		@return Returns `grounded` I.E; **True** when the player is touching the top surface of a solid.
	**/
	public function isOnGround():Bool 
	{ 
		return grounded; 
	}

	/**
		Returns if the player is allowed to jump
		@return Returns **True** only if `grounded` is **True** *or* `currentJumpCount` <= `maxJumpCount`.
	**/
	public inline function canJump() 
	{
		return  (isOnGround() || (currentJumpCount < maxJumpCount)) &&
				(!actionSystem.isAnAction([Crouching, Uncrouching]));
	}

	/**
		Function for handling variable height, multi-jumping.
		Should be called in Update, not a single frame event
	**/
	public function jump():Void 
	{
		// Allow a single burst of force
		if (playerInput.isInputDown("jump_just_pressed") && currentJumpCount > 0 && !_jumping)
		{
			_jumping = true;
			currentJumpCount--;
			velocity.y = JUMP_SPEED;
		}

		// Ensures that only a single burst happens
		// Function was being call twice in the same frame for some reason.
		// Tested with accumalting the `elapsed` time and notice that functions were being 
		//		called twice and showed the same timestamp.
		// Researched and found out that others were having the same problem and that
		//		using a second boolean was the best solution at the moment
		// Source: http://forum.haxeflixel.com/topic/159/flxbutton-justpressed-behavior
		if (playerInput.isInputDown("jump_released") && _jumping)
		{
			_jumping = false;
		}

		// Reset jump count if grounded and strip one jump if off the ground
		if (isOnGround())
		{
			currentJumpCount = maxJumpCount;
		}
		else 
		{
			if (currentJumpCount == maxJumpCount) { currentJumpCount--; }
		}

		// Allow for variable height jumping
		// Tapping = small jumps
		// Holding = max jump height
		if (velocity.y < 0 && !playerInput.isInputDown("jump"))
		{
			velocity.y = Math.max(velocity.y, JUMP_SPEED / 3);
		}
	}

	/**
		Update `xSpeed` when approriate.
		Does NOT apply the value to the velocity. Call `updateVelocity()` in update aftwards.
		@param target Desired speed in the x direction
		@param interpRatio Ratio between 0 to 1 that determines how fast the player will reach `target`. 0 = Never, 1 = Instant, 0.01 to 0.99 = eventually
	**/
	public function setHorizontalMovement(target:Float, interpRatio:Float):Void
	{
		if (!willCollide(target * facingDirection, 0))
            xSpeed = FlxMath.roundDecimal(FlxMath.lerp(xSpeed, target * facingDirection, interpRatio), 2);
        else 
            xSpeed = 0;
	}

	/**
		Function that updates the actual velocity of the player
	**/
	public function updateVelocity():Void 
	{
		if (willCollide(xSpeed, 0))
		{
			xSpeed = 0;
			velocity.x = 0;
		}
		else
			velocity.x = xSpeed;
	}

	/**
		Checks ahead to see if the player will collide if continuing with the desired velocity
		@param xVelocity Velocity in X direction to check future position with
		@param yVelocity Velocity in Y direction to check future position with
		@return **True** if the player will be overlapping a solid in the future
	**/
	public function willCollide(xVelocity:Float, yVelocity:Float):Bool
	{
		return overlapsAt(x + (xVelocity * FlxG.elapsed), y + (yVelocity * FlxG.elapsed), _solidsRef);		
	}

	/**
		Function that's called to resolve collision overlaping with solid objects when invoked.
		@param player Object that collided with something.
		@param other Object that `player` has collided with.
	**/
	public function onWallCollision(player:Player, other:FlxSprite):Void
	{
		if (player.playerLogic.states != null)
		{
				if ((player.isOnGround()) && 
					(player.actionSystem.isAnAction([player.playerLogic.states.Jumping, player.playerLogic.states.Falling])))
			{
				player.actionSystem.setState(player.playerLogic.states.Normal);
			}
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