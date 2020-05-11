package entities.collectables.parent;

import flixel.FlxSprite;

enum Powerups 
{
    JumpBoost;
}

class Powerup extends FlxSprite
{
    public var power:Powerups;

    public function new(?X:Float = 0, ?Y:Float = 0, ?newWidth:Int = 0, ?newHeight:Int = 0, initialPower:Powerups, graphicAsset:String) 
    {
        super(X, Y);
        
        this.loadGraphic(graphicAsset, false, newWidth, newHeight);

        power = initialPower;
    }

    override function kill()
    {
        alive = false;
        flixel.tweens.FlxTween.tween(this, {alpha: 0, y: y - 16}, 0.33, {ease: flixel.tweens.FlxEase.circOut, onComplete: finishKill});
    }
    
    function finishKill(_)
    {
        exists = false;
    }
}