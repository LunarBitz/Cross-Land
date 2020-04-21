package systems;

// VERY dangerous attributes and paramters here. Something that will work for now
// but definetly will try to avoid using dynamic variables so freely in the future. 
// Will research other ways whenever possible. Only done so that this can be resued
// With any object needed this system with different enumerators.

class ActionSystem
{
	var previousState:Dynamic = null;
	var currentState:Dynamic = null;

	public function new(defaultAction:Dynamic = null) 
	{
		currentState = defaultAction;
		previousState = currentState;
    }

	public function hasChanged():Bool
	{
		return !(previousState == currentState);
	}

	public function setState(newState:Dynamic):Dynamic
	{
		previousState = currentState;
		currentState = newState;

		return currentState;
	}

	public function getState():Dynamic
	{
		return currentState;
    }
    
    public function getPreviousState():Dynamic
    {
        return previousState;
    }
    
}