package systems;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

class InputSystem
{
	private var inputs:Map<String, Int>;
	private var inputKeys:Map<String, Array<FlxKey>>;
	private var axis:Map<String, Float>;
	private var axisKeys:Map<String, Array<String>>;

	public function new(defaultEntries:Bool = true)
	{
		inputs = new Map<String, Int>();
		inputKeys = new Map<String, Array<FlxKey>>();
		axis = new Map<String, Float>();
		axisKeys = new Map<String, Array<String>>();

		if (defaultEntries)
		{
			createInput("left");
			createInput("right");
			createInput("up");
			createInput("down");
			createInput("jump");
			createInput("crouch");
			createInput("action_1");
			createInput("action_2");

			createAxis("horizontalAxis");
		}
	}

	/**
		Creates the map entries for input binding later on.
		@param name Name of entry to make.
		@param incHeld Create the key held/pressed entry?
		@param incPressed Create the key just pressed entry?
		@param incReleased Create the key just released entry?
	**/
	public function createInput(name:String, incHeld:Bool = true, incPressed:Bool = true, incReleased:Bool = true):Void
	{
		if (!incHeld && !incPressed && !incReleased)
		{
			throw "No entry has been created within InputSystem.createInput(). Please set at least one of the booleans to true";
			return;
		}
		else if (incHeld || incPressed || incReleased)
		{
			inputKeys[name] = new Array<FlxKey>();
		}

		if (incHeld) { inputs[name] = -1; }
		if (incPressed) { inputs[name + "_just_pressed"] = -1; }
		if (incReleased) { inputs[name + "_released"] = -1; }
	}

	/**
		Creates the map entries for axis binding later on.
		@param name Name of entry to make.
	**/
	public function createAxis(name:String):Void
	{
		axis[name] = -1;
		axisKeys[name] = new Array<String>();
	}

	/**
		Binds a list of keys to the specified entry.
		Also binds the "_just_pressed" and "_released" entries if previously created so there's no need to bind them directly.
		```haxe
		bindInput("jump", [FlxKey.Z, FlxKey.SPACE]);
		bindInput("up", [FlxKey.UP]);
		```
		Automatically creates the input mapping using `createInput()` if the entered input didn't exist beforehand but we recommend that you create the input yourself for more control
		@param name Name of axis to bind.
		@param keys List of keys that will be used to bind.
	**/
	public function bindInput(name:String, keys:Array<FlxKey>):Void 
	{
		if (keys == null)
			return;

		if (inputs[name] == null)
			createInput(name);

		inputKeys[name] = keys;
	}

	/**
		Binds two given input values to the specified entry.
		Concatenate "_just_pressed" or "_released" if you want to access inputs 
		respective to the names. For example:
		```haxe
		bindAxis("horizontalAxis", "left", "right");
		```
		Automatically creates the axis using `createAxis()` if the entered axis didn't exist beforehand but we recommend that you create the axis yourself for more control
		@param name Name of axis to bind.
		@param negativeInputName Name of input that would normally lead to a negative input (such as moving left / up).
		@param positiveInputName Name of input that would normally lead to a positive input (such as moving right / down).
	**/
	public function bindAxis(name:String, negativeInputName:String, positiveInputName:String):Void
	{
		if (axis[name] == null)
			createAxis(name);

		axisKeys[name][0] = negativeInputName;
		axisKeys[name][1] = positiveInputName;
	}

	/**
		Gets the value from the `inputs` map with the specified `name` as the key.
		Concatenate "_just_pressed" or "_released" if you want to access inputs 
		respective to the names. For example:
		```haxe
		getInput("left"); // Similar to (FlxG.keys.pressed.Left)? 1 : 0;
		getInput("left_just_pressed"); // Similar to (FlxG.keys.justPressed.Left)? 1 : 0;
		getInput("left_released"); // Similar to (FlxG.keys.justReleased.Left)? 1 : 0;
		```
		@param name Name of input key to get.
		@return Int value from `inputs` map.
	**/
	public inline function getInput(name:String):Int
	{
		return inputs[name];
	}

	/**
		Gets the value from the `axis` map with the specified `name` as the key.
		@param name Name of axis key to get.
		@return Float value from `axis` map.
	**/
	public inline function getAxis(name:String):Float
	{
		return axis[name];
	}

	/**
		Gets the list of keys currently set for the specified input
		@param name Name of input key to get keys from.
		@return List of keys from `inputKeys`.
	**/
	public inline function getInputBinding(name:String):Array<FlxKey>
	{
		return inputKeys[name];
	}

	/**
		Gets the list of keys currently set for the specified axis
		@param name Name of axis key to get keys from.
		@param sign **-1** for the negative inputs, **1** for the positive inputs, **0** for all
		@return List of keys from `axisKeys`.
	**/
	public function getAxisBinding(name:String, sign:Int = 0):Array<FlxKey>
	{
		switch (sign)
		{
			case -1:
				return getInputBinding(axisKeys[name][0]);
			case 0:
				return getInputBinding(axisKeys[name][0]).concat(getInputBinding(axisKeys[name][1]));
			case 1:
				return getInputBinding(axisKeys[name][1]);
			default: 
				return null;
		}
	}

	public function poll():Void
	{
		// Run through all inputs
		if (inputs != null && inputKeys != null)
			for (name in inputs.keys())
			{
				if (name.indexOf("_just_pressed") != -1)
					inputs[name] = FlxG.keys.anyJustPressed(inputKeys[name.split("_just_pressed")[0]])? 1:0;
				else if (name.indexOf("_released") != -1)
					inputs[name] = FlxG.keys.anyJustReleased(inputKeys[name.split("_released")[0]])? 1:0;
				else
					inputs[name] = FlxG.keys.anyPressed(inputKeys[name])? 1:0;
			}

		// Run through all axis
		if (axis != null && axisKeys != null)
			for (name in axis.keys())
			{
				axis[name] = (getInput(axisKeys[name][1]) - getInput(axisKeys[name][0]));
			}
	}
	
}
