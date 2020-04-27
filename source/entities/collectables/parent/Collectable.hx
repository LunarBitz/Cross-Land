package entities.collectables.parent;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxSprite;

class Collectable extends FlxSprite
{
    public var VALUE(default, null):Int = 0; 

    public function new(?X:Float = 0, ?Y:Float = 0) 
    {
        super(X, Y);
        
        makeGraphic(16, 16, FlxColor.YELLOW);
    }

    override function kill()
    {
        alive = false;
        FlxTween.tween(this, {alpha: 0, y: y - 16}, 0.33, {ease: FlxEase.circOut, onComplete: finishKill});
    }
    
    function finishKill(_)
    {
        exists = false;
    }
}