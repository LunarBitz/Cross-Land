package entities.collectables.parent;

import flixel.FlxSprite;

enum Powerups 
{
    JumpBoost;
}

class Powerup extends FlxSprite
{
    public var power:Powerups;
    public var maxLifeTime:Int = 0;

    public function new(?X:Float = 0, ?Y:Float = 0, ?newWidth:Int = 0, ?newHeight:Int = 0, initialPower:Powerups, lifeTime:Int = 0, graphicAsset:String) 
    {
        super(X, Y);
        
        this.loadGraphic(graphicAsset, false, newWidth, newHeight);

        power = initialPower;
        maxLifeTime = lifeTime;
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