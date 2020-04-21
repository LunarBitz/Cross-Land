package entities.collectables;

import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class Coin extends FlxSprite
{
    public var MAX_VALUE(default, null):Int = 100; 
    public function new(?X:Float = 0, ?Y:Float = 0) 
    {
        super(X, Y);
        
        loadGraphic(AssetPaths.sprCoin__png, true, 16, 16);
        animation.add("idle", [0, 1, 2, 3, 4, 5], 15, true);
        animation.play("idle");
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