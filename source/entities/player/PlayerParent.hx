package entities.player;

import flixel.system.FlxSound;
import misc.Hitbox;
import hazards.parents.Damager;
import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import systems.ExtendedAnimation;
import systems.Action;
import systems.Input;
import flixel.input.keyboard.FlxKey;
import entities.player.PlayerLogic;
import entities.collectables.parent.Powerup;
import LevelGlobals;
import systems.Hud;

class Player extends FlxSprite 
{
	// Systems
	public var playerLogic:PlayerStateLogics;
	public var actionSystem:ActionSystem;
	public var playerAnimation:ExtAnimationSystem;
	public var playerInput:InputSystem;
	public var playerSfx:Map<String, FlxSound>;

	// Input
	public var DEAD_ZONE(default, never):Float = 0.1;
	public var MOVEMENT_INTERP_RATIO(default, never):Float = 1/32;

	// Generals
	public var canChangeDirections:Bool = false;
	public var canResetState:Bool = true;
	public var inputDirection:Int = 0;
	public var facingDirection:Int = 1;
	public var grounded:Bool = false;
	public var onWall:Int = 0;
	public var invincibilityTimer:Int = 0;
	public var hitboxes:Map<String, Hitbox>;
	public var isAttacking:Bool = false;
	public var powerupStack:Map<String, Dynamic>;

	// Movement
	public var GRAVITY(default, never):Float = 981;
	public var TERMINAL_VELOCITY(default, never):Float = 1500;
	public var NORMAL_TARGET_SPEED(default, never):Float = 175;
	public var CROUCH_TARGET_SPEED(default, never):Float = 0;
	public var UNCROUCH_TARGET_SPEED(default, never):Float = 5;
	public var IN_AIR_TARGET_SPEED(default, never):Float = 200;

	public var xSpeed:Float = 0;
	public var ySpeed:Float = 0;
	
	// Jumping
	public var JUMP_SPEED:Float = -350;
	public var JUMP_ADDER:Float = 0;
	public var currentJumpCount:Int = 0;
	public var maxJumpCount:Int = 3;
	public var jumpBufferTimer:Float = 0;
	public var jumpBufferFrames:Int = 125;
	


	public function new(?X:Float = 0, ?Y:Float = 0) 
	{
		super(X, Y);

		hitboxes = new Map<String, Hitbox>();
		//createHitbox("Sliding", 64, 16, true); 

		// Set up the needed custom systems
		playerLogic = new PlayerStateLogics(this);
		actionSystem = new ActionSystem(playerLogic.states.Normal);
		playerAnimation = new ExtAnimationSystem(this);
		playerInput = new InputSystem();
		playerSfx = new Map<String, FlxSound>();

		powerupStack = new Map<String, Dynamic>();
		for (pwr in Type.allEnums(Powerups))
		{
			powerupStack[Std.string(pwr) + "_Value"] = 0;
			powerupStack[Std.string(pwr) + "_Timer"] = 0;
			powerupStack[Std.string(pwr) + "_MaxLifeTime"] = 0;
		}

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

		gatherSounds();

		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);
		
	}

	override function update(elapsed:Float) 
	{
		if (hitboxes != null && LevelGlobals.totalElapsed == 0)
		{
			LevelGlobals.combineMaps(LevelGlobals.currentState, [hitboxes]);
			LevelGlobals.combineMaps(LevelGlobals.allDamagers, [hitboxes]);  
			LevelGlobals.combineMaps(LevelGlobals.allHitboxes, [hitboxes]);  
		}
		
		// Set up nicer input-handling for movement.
		playerInput.poll();

		grounded = isTouching(FlxObject.DOWN);

		actionSystem.updateTimer(elapsed, !isOnGround() || isAttacking);

		onWall = (isTouching(FlxObject.RIGHT)? 1:0) - (isTouching(FlxObject.LEFT)? 1:0);

		tickPowerupTimers();

		// Update facing direction
		updateDirection();

		tickInvincibilityTimer();

		// Call the main logic states of the player
		callStates();

		// Apply velocity
		updateVelocity();

		super.update(elapsed);

		for (hb in hitboxes)
		{
			hb.positionBox("South", "South");
			hb.followOwner();
		}
	}

	/**
		Scale constants based on Y velocity
		@param gravityScale Unit scale to change `acceleration.y` with
		@param terminalScale Unit scale to change `maxVelocity.y` with
	**/
	public function scaleGravity(gravityScale:Float = 1, terminalScale:Float = 1):Void
	{
		acceleration.y = GRAVITY * gravityScale;
        maxVelocity.y = TERMINAL_VELOCITY * terminalScale;	
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
		Helper function to add all animations of the player
	**/
	private function gatherAnimations():Void 
	{
		animation.add("idle", [0], 45, false);
		animation.add("crouching", [1, 2, 3, 4, 5, 6], 45, false);
		animation.add("uncrouching", [6, 5, 4, 3, 2, 1], 45, false);
	}

	private function gatherSounds():Void
	{
		playerSfx["jump"] = FlxG.sound.load(AssetPaths.sndJumping__wav, 0.5);	
		playerSfx["long_jump"] = FlxG.sound.load(AssetPaths.sndLongJumping__wav, 0.15);	
		playerSfx["longer_jump"] = FlxG.sound.load(AssetPaths.sndLongerJumping__wav, 0.15);
		playerSfx["wall_jump"] = FlxG.sound.load(AssetPaths.sndWallJumping__wav, 0.65);	
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

	private function tickPowerupTimers() 
	{
		if (powerupStack != null)
		{
			for (pwr in Type.allEnums(Powerups))
			{
				if (powerupStack.exists(Std.string(pwr) + "_Value") &&
					powerupStack.exists(Std.string(pwr) + "_Timer") &&
					powerupStack.exists(Std.string(pwr) + "_MaxLifeTime"))
				{
					if (powerupStack[Std.string(pwr) + "_Timer"] > 0)
					{
						powerupStack[Std.string(pwr) + "_Timer"] -= Std.int(FlxG.elapsed * 1000);

						if (powerupStack[Std.string(pwr) + "_Timer"] <= (powerupStack[Std.string(pwr) + "_MaxLifeTime"] * (powerupStack[Std.string(pwr) + "_Value"] - 1)))
						{
							powerupStack[Std.string(pwr) + "_Value"] -= 1;
							trace(Std.string(pwr) + "- Value: ", powerupStack[Std.string(pwr) + "_Value"]);

							LevelGlobals.hudReference.removePowerElement(LevelGlobals.hudReference.powerupSprites[Std.string(pwr)]);
							trace("Removing: ", LevelGlobals.hudReference.powerupSprites.remove(Std.string(pwr)));
							LevelGlobals.hudReference.updatePowerElements();

							handlePowerups();
						}
					}
					else if (powerupStack[Std.string(pwr) + "_Timer"] < 0 && powerupStack[Std.string(pwr) + "_Timer"] != -1)
					{
						powerupStack[Std.string(pwr) + "_Value"] = 0;
						handlePowerups();
						powerupStack[Std.string(pwr) + "_Timer"] = -1;
					}
				}	

				
			}
		}
	}

	public function handlePowerups() 
	{
		JUMP_ADDER = ((JUMP_SPEED / 8) * (powerupStack.exists("JumpBoost_Value")? powerupStack["JumpBoost_Value"]:0)) + 
					 ((JUMP_SPEED / 4) * (powerupStack.exists("SuperJumpBoost_Value")? powerupStack["SuperJumpBoost_Value"]:0)) + 
					 ((JUMP_SPEED / 2) * (powerupStack.exists("MegaJumpBoost_Value")? powerupStack["MegaJumpBoost_Value"]:0));
					 
	}

	public function createHitbox(?hitboxName:String = null, ?w:Int = 0, ?h:Int = 0, initialExist:Bool = false) 
	{
		hitboxes[hitboxName] = new Hitbox(x, y, w, h, initialExist, this);
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
		Change the facing direction of the player based on the input
	**/
	private function updateDirection():Void
	{
		inputDirection = getMoveDirectionCoefficient(playerInput.getAxis("horizontalAxis"));

		if (inputDirection != 0 && canChangeDirections)
		{
			facing = (inputDirection == -1)? FlxObject.LEFT : FlxObject.RIGHT;
			facingDirection = inputDirection;
		}
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
				(!actionSystem.isAnAction([Crouching, Uncrouching, Damaged]));
	}

	/**
		Function for handling variable height, multi-buffer-jumping.
		Should be called in Update, not a single frame event. 
		Single frame handling is done within
	**/
	public function jump():Void 
	{
		// Reset jump count if grounded and strip one jump if off the ground
		if (isOnGround())
		{
			currentJumpCount = maxJumpCount;

			// Follow through with jump if jump buffer is within frames
			if (jumpBufferTimer < jumpBufferFrames)
			{
				playerSfx["jump"].play(true);
				if (powerupStack != null)
				{
					if (powerupStack["SuperJumpBoost_Value"] > 0 || powerupStack["MegaJumpBoost_Value"] > 0 || powerupStack["JumpBoost_Value"] >= 3)
					{
						playerSfx["longer_jump"].play(true);
						playerSfx["longer_jump"].fadeIn(0.25, 0, 0.35);
					}
					else if (powerupStack["JumpBoost_Value"] < 3 && powerupStack["JumpBoost_Value"] != 0)
					{
						playerSfx["long_jump"].play(true);
						playerSfx["long_jump"].fadeIn(0.25, 0, 0.35);
					}
				}

				currentJumpCount--;
				velocity.y = JUMP_SPEED + JUMP_ADDER;
				jumpBufferTimer = jumpBufferFrames;

				#if debug
				trace('Jump() || Buffer Jumping - Time:${LevelGlobals.totalElapsed}');
				#end
			}
		}
		else if (!isOnGround())
		{
			// Follow through with jump if jump buffer is within frames
			if (jumpBufferTimer < jumpBufferFrames)
			{
				if (currentJumpCount > 0)
				{
					playerSfx["jump"].play(true);
					if (powerupStack != null)
					{
						if (powerupStack["SuperJumpBoost_Value"] > 0 || powerupStack["MegaJumpBoost_Value"] > 0 || powerupStack["JumpBoost_Value"] >= 3)
						{
							playerSfx["longer_jump"].play(true);
							playerSfx["longer_jump"].fadeIn(0.25, 0, 0.35);
						}
						else if (powerupStack["JumpBoost_Value"] < 3 && powerupStack["JumpBoost_Value"] != 0)
						{
							playerSfx["long_jump"].play(true);
							playerSfx["long_jump"].fadeIn(0.25, 0, 0.35);
						}
					}

					currentJumpCount--;
					velocity.y = JUMP_SPEED + JUMP_ADDER;
					jumpBufferTimer = jumpBufferFrames;

					#if debug
					trace('Jump() || Buffer Jumping - Time:${LevelGlobals.totalElapsed}');
					#end
				}
			}
			else if (jumpBufferTimer >= jumpBufferFrames)
			{
				if (currentJumpCount == maxJumpCount) { currentJumpCount--; jumpBufferTimer = jumpBufferFrames;}
			}		
		}

		if (playerInput.isInputDown("jump_just_pressed"))
		{
			// Reset jump buffer for next jump (including floor jumping)
			jumpBufferTimer = 0;

			// Only jump if the player has jumps left
			if (currentJumpCount > 0)
			{
				playerSfx["jump"].play(true);
				if (powerupStack != null)
				{
					if (powerupStack["SuperJumpBoost_Value"] > 0 || powerupStack["MegaJumpBoost_Value"] > 0 || powerupStack["JumpBoost_Value"] >= 3)
					{
						playerSfx["longer_jump"].play(true);
						playerSfx["longer_jump"].fadeIn(0.25, 0, 0.35);
					}
					else if (powerupStack["JumpBoost_Value"] < 3 && powerupStack["JumpBoost_Value"] != 0)
					{
						playerSfx["long_jump"].play(true);
						playerSfx["long_jump"].fadeIn(0.25, 0, 0.35);
					}
				}

				currentJumpCount--;
				velocity.y = JUMP_SPEED + JUMP_ADDER;

				#if debug
				trace('Jump() || Pressed Jump - Time:${LevelGlobals.totalElapsed}');
				#end
			}	
		}

		// Allow for variable height jumping
		// Tapping = small jumps
		// Holding = max jump height
		if (velocity.y < 0 && !playerInput.isInputDown("jump"))
		{
			if (playerSfx["long_jump"].playing)
			{
				playerSfx["long_jump"].fadeOut(0.1, 0);
				if (playerSfx["long_jump"].volume == 0)
					playerSfx["long_jump"].stop();
			}
		
			if (playerSfx["longer_jump"].playing)
			{
				playerSfx["longer_jump"].fadeOut(0.5, 0);
				if (playerSfx["longer_jump"].volume == 0)
					playerSfx["longer_jump"].stop();
			}
				

			velocity.y = Math.max(velocity.y, (JUMP_SPEED + JUMP_ADDER) / 3);
		}

		jumpBufferTimer += FlxG.elapsed * 1000; // Increase buffer
	}

	/**
		Update `xSpeed` when approriate.
		Does NOT apply the value to the velocity. Call `updateVelocity()` in update aftwards.
		@param target Desired speed in the x direction
		@param interpRatio Ratio between 0 to 1 that determines how fast the player will reach `target`. 0 = Never, 1 = Instant, 0.01 to 0.99 = eventually
	**/
	public function setHorizontalMovement(target:Float, direction:Int = 1, interpRatio:Float):Void
	{
		// Player is not about to collide ahead so change xSpeed normally
		if (!willCollide(target * direction, 0))
			xSpeed = FlxMath.roundDecimal(FlxMath.lerp(xSpeed, target * direction, interpRatio), 3);
		
		// Player is about to collide ahead so change xSpeed to a minimal value (to keep isTouching working on walls)
		else 
			if (Math.abs(xSpeed) >= (target / 6))
				xSpeed = FlxMath.roundDecimal(FlxMath.lerp(xSpeed, (target / 6) * direction, 1/16), 3);

		// Just set xSpeed to 0 if it's becoming too small but not 0 (lerping fix)
		if (FlxMath.equal(xSpeed, 0.0, 1))
			xSpeed = 0;
	}

	/**
		Function that updates the actual velocity of the player
	**/
	public function updateVelocity():Void 
	{
		velocity.x = xSpeed;

		#if debug
		//trace('xSpeed: ${xSpeed}');
		#end
	}

	/**
		Function that updates the actual velocity of the player
	**/
	public function tickInvincibilityTimer():Void 
	{
		if (invincibilityTimer > 0)
		{
			invincibilityTimer -= Std.int(FlxG.elapsed * 1000);
		}

		if (FlxMath.equal(invincibilityTimer, 0.0, 1) || invincibilityTimer < 0)
			invincibilityTimer = 0;
	}

	/**
		Checks ahead to see if the player will collide if continuing with the desired velocity
		@param xVelocity Velocity in X direction to check future position with
		@param yVelocity Velocity in Y direction to check future position with
		@return **True** if the player will be overlapping a solid in the future
	**/
	public function willCollide(xVelocity:Float, yVelocity:Float):Bool
	{
		return overlapsAt(x + (xVelocity * FlxG.elapsed), y + (yVelocity * FlxG.elapsed), LevelGlobals.solidsReference);		
	}

	/**
		Function that's called to resolve floor related statements when object overlapping is invoked.
		@param player Object that collided with something.
		@param other Object that `player` has collided with.
	**/
	public function resolveFloorCollision(player:Player, other:FlxSprite):Void
	{
		var states = player.playerLogic.states;
		if (states != null)
		{
			if ((player.isOnGround() && canResetState) 
				&& 
				!player.actionSystem.isAnAction([
					states.Normal, 
					states.Crouching, 
					states.Uncrouching]
				))
			{
				player.actionSystem.setState(states.Normal);
			}
		}
	}

	/**
		Function that's called to resolve wall related statements when object overlapping is invoked.
		@param player Object that collided with something.
		@param other Object that `player` has collided with.
	**/
	public function resolveWallCollision(player:Player, other:FlxSprite):Void
	{
		player.onWall = -player.inputDirection;
	}

	/**
		Function that's called to resolve damage related statements when object overlapping is invoked.
		@param player Object that collided with something.
		@param other Object that `player` has collided with.
	**/
	public static function resolveDamagerCollision(player:Player, other:Damager):Void
	{
		var states = player.playerLogic.states;

		if (player.alive && player.exists && other.alive && other.exists)
		{
			// Exit function if hitbox collides with its owner
			if (Type.getClass(other) == Hitbox)
			{
				if (cast(other, Hitbox).owner == player) { return; }
			}

			if (player.invincibilityTimer == 0 && other.canInflictDamage && !player.isAttacking)
			{
				FlxG.camera.shake(0.005, 0.2);

				player.facingDirection = FlxMath.signOf(other.x - player.x);

				player.invincibilityTimer = 1500;

				player.health -= other.damgeValue;
				player.setHorizontalMovement(player.IN_AIR_TARGET_SPEED, -player.facingDirection, 1);
				player.velocity.y = player.JUMP_SPEED / 3;
				
				player.actionSystem.setState(states.Damaged);
			}
		}
	}

	

}