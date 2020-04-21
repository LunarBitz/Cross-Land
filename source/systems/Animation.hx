package systems;

import flixel.FlxSprite;

class AnimationSystem
{
    var owner:FlxSprite;
	var previousAnimation:String = "";
	var currentAnimation:String = "";

	public function new(sprite:FlxSprite, defaultAnimation:String = "") 
	{
        owner = sprite;
		currentAnimation = defaultAnimation;
		previousAnimation = currentAnimation;
    }

	public function hasChanged():Bool
	{
		return !(previousAnimation == currentAnimation);
	}

	public function setAnimation(newAnimation:String, forcePlay:Bool = false, playReversed:Bool = false, startingFrame:Int = 0, holdOnLastFrame = false):String
	{
        previousAnimation = currentAnimation;
        owner.animation.play(newAnimation, forcePlay, playReversed, startingFrame);

        if (owner.animation.curAnim != null)
        {
            currentAnimation = owner.animation.curAnim.name;

            if (holdOnLastFrame && isOnLastFrame())
                owner.animation.curAnim.pause();   
        }

		return currentAnimation;
	}

	public function getCurrentAnimation():String
	{
		return currentAnimation;
    }
    
    public function getPreviousAnimation():String
    {
        return previousAnimation;
    }

    public function isOnLastFrame():Bool
    {
        if (owner.animation.curAnim != null)
        {
            var i = owner.animation.curAnim.frames.length - 1;
            return (owner.animation.frameIndex == owner.animation.curAnim.frames[i]);
        }

        return false;
    }

    public function isOnFirstFrame():Bool
    {
        if (owner.animation.curAnim != null)
        {
            return (owner.animation.frameIndex == owner.animation.curAnim.frames[0]);
        }

        return false;
    }

    public function isFinished():Bool
    {
        if (owner.animation.curAnim != null)
            return owner.animation.curAnim.finished;
        else
            return false;
    }
}