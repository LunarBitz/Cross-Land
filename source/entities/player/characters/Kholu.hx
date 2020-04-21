package entities.player.characters;

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
import entities.player.characters.KholuStates;
import entities.player.PlayerParent;

class Kholu extends Player 
{

	override public function new(?X:Float = 0, ?Y:Float = 0) 
	{
		super(X, Y);

		// Set up the needed custom systems
		playerLogic = new KholuStateLogics(this);
		playerState = new ActionSystem(Normal);
		playerAnimation = new AnimationSystem(this);
		playerInput = new InputSystem();

		gatherInputs();

		// Set up "gravity" (constant acceleration) and "terminal velocity" (max fall speed)
		acceleration.y = GRAVITY;
		maxVelocity.y = TERMINAL_VELOCITY;

		// Set up graphics and animations
		loadGraphic(AssetPaths.sprKholu__png, true, 32, 32);

        gatherAnimations();
		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);

		
	}

	override function update(elapsed:Float) 
	{
		// Set up nicer input-handling for movement.
		playerInput.poll();

		// Update facing direction
		facingDirection = getMoveDirectionCoefficient(playerInput.getAxis("horizontalAxis"));
		if (facingDirection != 0)
			facing = (facingDirection == -1)? FlxObject.LEFT : FlxObject.RIGHT;

		//callStates();

		super.update(elapsed);
	}

	/**
		Helper function responsible for interacting with HaxeFlixel systems to gather inputs 
		relevant to the Hero. Helps keep code clean by restricting FlxG.keys input to a single spot,
		which makes it much easier to change inputs, implement rebinding, etc. in the future.
	**/
	override private function gatherInputs():Void 
	{
		playerInput.bindInput("left", [FlxKey.LEFT, FlxKey.DELETE]);
		playerInput.bindInput("right", [FlxKey.RIGHT, FlxKey.PAGEDOWN]);
		playerInput.bindInput("jump", [FlxKey.Z, FlxKey.NUMPADSEVEN]);
		playerInput.bindInput("crouch", [FlxKey.DOWN, FlxKey.END]);
		playerInput.bindAxis("horizontalAxis", "left", "right");
    }
    
    override private function gatherAnimations():Void 
    {
        playerAnimation.createAnimation("normal_idle", [1], 45, true);
        playerAnimation.createAnimation("normal_idle", [1], 45, true);
    }

	/**
		Function to handle what happens with each action state.
		See `HeroStates.hx`
	**/
	override public function callStates():Void
	{
        for (state in Type.allEnums(playerLogic.enumerator))
        {
            
            var fn = Reflect.field(playerLogic, "_State_" + Std.string(state));
            trace(Std.string(state));
            if (fn != null)
                Reflect.callMethod(playerLogic, fn, []);
        }
	}

}