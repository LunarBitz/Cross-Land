package systems;

class ActionSystem
{
	var previousState:Dynamic = null;
	var currentState:Dynamic = null;
	public var delayTimer:Float = 0;

	public function new(?defaultAction:Dynamic = null) 
	{
		currentState = defaultAction;
		previousState = currentState;
    }

	/**
        Return if the previous animation is different from the current one
        @return `True` if there was a change.
    **/
	public function hasChanged():Bool
	{
		return !(previousState == currentState);
	}

	/**
		Update the previous and current state
		@param newState Desired state to change to
		@param delay Delay time in milliseconds 
		@return Current state
	**/
	public function setState(newState:Dynamic, ?delay:Float = 0):Dynamic
	{
		if (delayTimer >= delay)
		{
			previousState = currentState;
			currentState = newState;
		}

		return currentState;
	}

	/**
		Get the current state
		@return Current state
	**/
	public function getState():Dynamic
	{
		return currentState;
    }
	
	/**
		Get the previous state
		@return Previous state
	**/
    public function getPreviousState():Dynamic
    {
        return previousState;
	}
	
	/**
		Checks if the current state equals any of the specified states.
        Use to clean up long if statements
        @param actions List of states that you wish to compare with the current state
        @return True if the current animation is equal to any entry from  `actions`.
	**/
	public function isAnAction(?actions:Array<Dynamic> = null):Bool
	{
		for (act in actions)
		{
			if (getState() == act)
				return true;
		}

		return false;
	}

	/**
		Update the delay threshold  for actions setting that utilizes it
		@param dT Change value that increments `delayTimer`
		@param condition Boolean that allows increments or resets (Set **True** to increment only)
	**/
	public function updateTimer(dT:Float, ?condition:Bool):Void
	{
		if (condition)
			this.delayTimer += dT * 1000;
		else 
			this.delayTimer = 0;
		
	}
    
}