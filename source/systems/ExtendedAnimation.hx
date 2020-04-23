package systems;

import flixel.FlxSprite;
import flixel.util.FlxTimer;

class ExtAnimationSystem
{
    var owner:FlxSprite;

	private var _previousAnimation:String = "";
    private var _currentAnimation:String = "";
    private var _previousFrame:Int = 0;
    private var _currentFrame:Int = 0;
    private var _animationLoopPoints:Map<String, Int> = null;

	public function new(sprite:FlxSprite, defaultAnimation:String = "") 
	{
        owner = sprite;
        
		_currentAnimation = defaultAnimation;
        _previousAnimation = _currentAnimation;
        
        _animationLoopPoints = new Map<String, Int>();
    }

    /**
        Return if the previous animation is different from the current animation
        @return `True` if there was a change.
    **/
	public inline function animationChanged():Bool
	{
		return !(_previousAnimation == _currentAnimation);
    }

    /**
        Return if the previous frame withing the current animation is different from the current frame
        @return `True` if there was a change.
    **/
    public inline function frameChanged():Bool
    {
        return !(_previousFrame == _currentFrame);
    }
    
    /**
        Creates a sub-animation of name inside the owning FlxSprite, `owner`. Example:
        ```haxe
            createAnimation("jumping", [10,11,12,13,14], 30, true, 3); // Will loop on the forth frame (13) at 30 FPS
            createAnimation("tumble", [15,16,18,26], 37, true); // Will loop on the first frame (15) at 37 FPS
        ```
        @param animName Name of sub-animation to create.
        @param frames List of frame indices that define the sub-animation.
        @param frameRate Rate that the sub-animation will play at.
        @param loop Whether the sub-animation should loop after it's finished.
        @param loopFrame Frame to set back to for looping. Frames are relative per sub-animation (Does NOT use the real frame indices / starts with 0 as the first frame). Set to 0, leave blank, or null to loop from start.
    **/
    public function createAnimation(animName:String, frames:Array<Int>, frameRate:Int = 30, loop:Bool = false, loopFrame:Int = null) 
    {
        if (loopFrame == null)
        {
            owner.animation.add(animName, frames, frameRate, loop);
            _animationLoopPoints[animName] = 0;//frames[0];
        }
        else 
        {
            owner.animation.add(animName, frames, frameRate, false);
            _animationLoopPoints[animName] = loopFrame;
        }
        
    }

    /**
        Creates a chain-animation of name inside the owning FlxSprite, `owner`.
        ```haxe
            createAnimation("walk", [30,31,32,33,34], 30, true, 3);
            createAnimation("roll", [38,39,40,41], 37, true);

            // Combines [30,31,32,33,34] and [38,39,40,41]
            createAnimationChain("superCoolChain", ["walk", "roll"], 30, true, 6) // Will loop on the seventh frame (38 from "roll" sub animation) at 30 FPS
        ```
        @param animName Name of chain-animation to create.
        @param animations List of sub-animations that define the chain-animation.
        @param frameRate Rate that the sub-animation will play at.
        @param loop Whether the sub-animation should loop after it's finished.
        @param loopFrame Frame to set back to for looping. Frames are relative per sub-animation (Does NOT use the real frame indices / starts with 0 as the first frame).
    **/
    public function createAnimationChain(animName:String, animations:Array<String>, frameRate:Int, loop:Bool, loopFrame:Int = null) 
    {
        var table:Array<Int> = new Array<Int>();
        for (anim in animations)
            if (owner.animation.getByName(anim) != null)
                table = table.concat(owner.animation.getByName(anim).frames);
        
        if (loopFrame == null)
        {
            owner.animation.add(animName, table, frameRate, loop);
            _animationLoopPoints[animName] = 0;//table[0];
        }
        else 
        {
            owner.animation.add(animName, table, frameRate, false);
            _animationLoopPoints[animName] = loopFrame;
        }
        
    }

    /**
        Change the animation to a sub-animation or chain-animation
        @param animName The string name of the animation you want to play.
        @param forcePlay Whether to force the animation to restart.
        @param playReversed Whether to play animation backwards or not.
        @param startingFrame The frame number in the animation you want to start from. If a negative value is passed, a random frame is used.
        @param holdOnLastFrame Whether to pause the animation on the last frame.
    **/
	public function setAnimation(animName:String, forcePlay:Bool = false, playReversed:Bool = false, startingFrame:Int = 0, holdOnLastFrame = false):String
	{
        _previousAnimation = _currentAnimation;
        _previousFrame = _currentFrame;

        owner.animation.play(animName, forcePlay, playReversed, startingFrame);

        if (owner.animation.curAnim != null)
        {
            _currentAnimation = owner.animation.curAnim.name;
            _currentFrame = owner.animation.frameIndex;

            if (isOnLastFrame())
            {
                owner.animation.curAnim.pause();  

                if (!holdOnLastFrame && _animationLoopPoints[animName] != null && frameChanged())
                {
                    new FlxTimer().start(owner.animation.curAnim.delay, _setToLoopFrame, 1);
                }
            }
        }

		return _currentAnimation;
	}

    /**
        Timer resolve for ensuring a true frame looping with a custom loop index
    **/
    private function _setToLoopFrame(timer:FlxTimer):Void
    {
        if (owner.animation.curAnim != null)
        {
            owner.animation.curAnim.curFrame = _animationLoopPoints[owner.animation.curAnim.name];
        }
    }

    /**
        Returns the current animation as a string
        @return Current animation name
    **/
	public function getCurrentAnimation():String
	{
		return _currentAnimation;
    }
    
    /**
        Returns the previous animation as a string
        @return Previous animation name
    **/
    public function getPreviousAnimation():String
    {
        return _previousAnimation;
    }

    /**
        Checks if the current animation is on it's first index
        @return True if frame index equals first animation frame
    **/
    public function isOnFirstFrame():Bool
    {
        if (owner.animation.curAnim != null)
        {
            return (owner.animation.frameIndex == owner.animation.curAnim.frames[0]);
        }

        return false;
    }

    /**
        Checks if the current animation is on its last index
        @return True if frame index equals last animation frame
    **/
    public function isOnLastFrame():Bool
    {
        if (owner.animation.curAnim != null)
        {
            var i = owner.animation.curAnim.frames.length - 1;
            return (owner.animation.frameIndex == owner.animation.curAnim.frames[i]);
        }

        return false;
    }

    /**
        Checks if the current animation is finished
        @return True if `finished` flag is up (raised with `stop()` ).
    **/
    public function isFinished():Bool
    {
        if (owner.animation.curAnim != null)
            return owner.animation.curAnim.finished;
        else
            return false;
    }
}