package entities.player.characters;

import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil.LineStyle;
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
import entities.player.characters.KholuLogic;
import entities.player.PlayerParent;

class Kholu extends Player 
{

	override public function new(?X:Float = 0, ?Y:Float = 0) 
	{
		super(X, Y);

		// Set up the needed custom systems
		playerLogic = new KholuStateLogics(this);
		actionSystem = new ActionSystem(Normal, KholuLogic.PlayerStates);
		playerAnimation = new ExtAnimationSystem(this);
		playerInput = new InputSystem();

		gatherInputs();

		// Set up "gravity" (constant acceleration) and "terminal velocity" (max fall speed)
		acceleration.y = GRAVITY * 0.9;
		maxVelocity.y = TERMINAL_VELOCITY * 1;
		JUMP_SPEED = -375 * 1;
		maxJumpCount = 2;

		// Set up graphics and animations
		loadGraphic(AssetPaths.sprKholu__png, true, 32, 32);
		setSize(frameWidth / 2, frameHeight - 4);
		offset.set(width / 2, frameHeight - height);
		//updateHitbox();

        gatherAnimations();
		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);

		playerAnimation.setAnimation("jump_fall");
	}

	override function update(elapsed:Float) 
	{
		// Set up nicer input-handling for movement.
		playerInput.poll();

		trace('Prev: ${actionSystem.getPreviousState()} - Cur: ${actionSystem.getState()}');

		grounded = this.isTouching(FlxObject.DOWN);

		// Update facing direction
		facingDirection = getMoveDirectionCoefficient(playerInput.getAxis("horizontalAxis"));
		if (facingDirection != 0)
			facing = (facingDirection == -1)? FlxObject.LEFT : FlxObject.RIGHT;

		callStates();

		updateVelocity();

		super.update(elapsed);
	}

	/**
		Helper function responsible for interacting with HaxeFlixel systems to gather inputs 
		relevant to the Hero. Helps keep code clean by restricting FlxG.keys input to a single spot,
		which makes it much easier to change inputs, implement rebinding, etc. in the future.
	**/
	override private function gatherInputs():Void 
	{
		playerInput.bindInput("left", [FlxKey.LEFT]);
		playerInput.bindInput("right", [FlxKey.RIGHT]);
		playerInput.bindInput("jump", [FlxKey.Z]);
		playerInput.bindInput("crouch", [FlxKey.DOWN]);
		playerInput.bindAxis("horizontalAxis", "left", "right");
    }
    
    override private function gatherAnimations():Void 
    {
        playerAnimation.createAnimation("idle_normal", [1], 20, false);
		playerAnimation.createAnimation("idle_battle", [2,3,4,5], 20, true);
		playerAnimation.createAnimation("idle_holding", [6], 20, false);
		playerAnimation.createAnimation("crouching", [2,3,4,7], 60, false);
		playerAnimation.createAnimation("crouched", [7], 20, true);
		playerAnimation.createAnimation("crouched_holding", [8], 20, false);
		playerAnimation.createAnimation("uncrouching", [7,4,3,2], 60, false);
		playerAnimation.createAnimation("jumping", [9,10], 20, true);
		playerAnimation.createAnimation("falling_apex", [11,12], 20, true);
		playerAnimation.createAnimation("falling_down", [13,14], 15, true);
		playerAnimation.createAnimationChain("jump_fall", ["falling_apex", "falling_down"], 15, true, 2);
		playerAnimation.createAnimation("damaged", [15,16], 20, false);
		playerAnimation.createAnimation("walking", [17,18,19,20,21,22,23,24], 10, true);
		playerAnimation.createAnimation("walking_holding", [25,26,27,28,29,30,31,32], 20, true);
		playerAnimation.createAnimation("running", [33,34,35,36,37,38,39,40], 15, true);
		playerAnimation.createAnimation("running_holding", [41,42,43,44,45,46,47,48], 15, true);
		playerAnimation.createAnimation("sprinting", [49,50,51,52,53,54,55,56], 25, true);
		playerAnimation.createAnimation("sprinting_holding", [57,58,59,60,61,62,63,64], 25, true);
		playerAnimation.createAnimation("throwing", [65,66,67,68], 20, true);
		playerAnimation.createAnimation("arm_swing_ground_forward", [69,70,71,72], 20, true);
		playerAnimation.createAnimation("climbing_front", [73,74,75,76], 20, true);
		playerAnimation.createAnimation("climbed_front", [77], 20, false);
		playerAnimation.createAnimation("climbed_side", [78], 20, false);
		playerAnimation.createAnimation("tail_whip_R-L", [79,80,81,82], 20, false);
		playerAnimation.createAnimation("punch_slam_ground", [83,84,85,86,87,88], 20, false);
		playerAnimation.createAnimation("right_punch", [89,90,91,92], 20, false);
		playerAnimation.createAnimation("left_punch", [93,94,95,96], 20, false);
		playerAnimation.createAnimation("standing_uppercut_right_front", [97,98,99,100], 20, false);
		playerAnimation.createAnimation("standing_uppercut_left_front", [101,102,103,104], 20, false);
		playerAnimation.createAnimation("right_NE_punch", [105,106,107,108], 20, false);
		playerAnimation.createAnimation("left_NE_punch", [109,110,111,112], 20, false);
		playerAnimation.createAnimation("right_SE_punch", [113,114,115,116], 20, false);
		playerAnimation.createAnimation("left_SE_punch", [117,118,119,120], 20, false);
		playerAnimation.createAnimation("rising_uppercut_right_front", [121,122,123,124], 20, false);
		playerAnimation.createAnimation("rising_uppercut_left_front", [125,126,127,128], 20, false);
		playerAnimation.createAnimation("right_punch_overledge", [129,130,131,132], 20, false);
		playerAnimation.createAnimation("left_punch_overledge", [133,134,135,136], 20, false);
		playerAnimation.createAnimation("somersault", [142,143,144], 20, false);
		playerAnimation.createAnimation("headspin_slow", [145,146,147,148], 20, true);
		playerAnimation.createAnimation("arm_flailing", [149,150,151,152], 20, true);
		playerAnimation.createAnimation("sanic_ball", [153,154,155,156,157,158,159,160], 20, true);
		playerAnimation.createAnimation("leaping", [161,162], 20, true);
		playerAnimation.createAnimation("idle_walljumping", [163], 20, false);
		playerAnimation.createAnimation("leaping_walljumping", [164], 20, false);
		playerAnimation.createAnimation("headspin_fast", [165,166], 20, true);
		playerAnimation.createAnimation("damaged_backside", [167], 20, false);
		playerAnimation.createAnimation("damaged_frontside", [168], 20, false);
		playerAnimation.createAnimation("tailjump", [169,170,171,172], 20, true);
		playerAnimation.createAnimation("pull_midair", [173,174], 20, false);
		playerAnimation.createAnimation("idle_ledge", [175], 20, false);
		playerAnimation.createAnimation("idle_crisscross", [176], 20, false);
		playerAnimation.createAnimation("idle_spinning", [177,178,179,180,181,182,183], 20, true);
		playerAnimation.createAnimation("head_scratch", [184,185], 20, true);
		playerAnimation.createAnimation("mechaball_transform", [186,187], 20, false);
		playerAnimation.createAnimation("mechaball_roll_sides", [188,189,190,191], 20, true);
		playerAnimation.createAnimation("mechaball_roll_wall_N", [192,193,194,194,195], 20, true);
		playerAnimation.createAnimation("mechaball_roll_wall_NE", [196,197,198,199], 20, true);
		playerAnimation.createAnimation("mechaball_roll_wall_E", [200,201,202,203], 20, true);
		playerAnimation.createAnimation("mechaball_roll_floor_E", [204,205,206,207], 20, true);
		playerAnimation.createAnimation("critically_damaged", [208,209,210,211], 20, true);
		playerAnimation.createAnimation("climbing_sides", [212,213,214,215,214,213,212], 20, true);
		playerAnimation.createAnimation("ledge_hanging_sides", [216], 20, false);
		playerAnimation.createAnimation("arm_swing_midair_down", [217,218,219,220,221], 20, false);
		playerAnimation.createAnimation("monkeybars", [222,223,224,225,226,227], 20, true);
		playerAnimation.createAnimation("arm_swing_climbing_backward", [228,229,230,231], 20, false);
	}

	/**
		Function to handle what happens with each action state.
		See `HeroStates.hx`
	**/
	override public function callStates():Void
	{
        for (state in Type.allEnums(playerLogic.states))
        { 
            var fn = Reflect.field(playerLogic, "_State_" + Std.string(state));
            //trace(Std.string(state));
			if (fn != null && actionSystem.getState() == state)
			{
				//trace(Std.string(state));
				Reflect.callMethod(playerLogic, fn, []);
			}
                
        }
	}

	/**
		Function that's called to resolve collision overlaping with damage inducing objects when invoked.
		@param player Object that collided with something.
		@param other Object that `player` has collided with.
	**/
	override public function onDamageCollision(player:FlxSprite, other:FlxSprite):Void
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