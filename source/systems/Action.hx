package systems;

// VERY dangerous attributes and paramters here. Something that will work for now
// but definetly will try to avoid using dynamic variables so freely in the future. 
// Will research other ways whenever possible. Only done so that this can be resued
// With any object needed this system with different enumerators.

class ActionSystem
{
	var previousState:Dynamic = null;
	var currentState:Dynamic = null;
	public var states:Dynamic = null;

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
		@return Current state
	**/
	public function setState(newState:Dynamic):Dynamic
	{
		previousState = currentState;
		currentState = newState;

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
    
}