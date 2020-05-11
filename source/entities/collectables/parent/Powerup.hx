package entities.collectables.parent;

import flixel.FlxSprite;

enum Powerups 
{
    JumpBoost;
    SuperJumpBoost;
}

class Powerup extends FlxSprite
{
    public var power:Powerups;
    public var respawnRate:Int = 0;
    public var maxLifeTime:Int = 0;
    public var maxValue:Int = 1;

    public function new(?X:Float = 0, ?Y:Float = 0, ?newWidth:Int = 0, ?newHeight:Int = 0, graphicAsset:String, initialPower:Powerups, ?valueLimit:Int = 1, ?lifeTime:Int = 5, ?respawnTime:Int = 10) 
    {
        super(X, Y);
        
        this.loadGraphic(graphicAsset, false, newWidth, newHeight);

        power = initialPower;
        maxLifeTime = lifeTime * 1000;
        maxValue = valueLimit;
        respawnRate = respawnTime * 1000;
    }

    override function kill()
    {
        alive = false;
        flixel.tweens.FlxTween.tween(this, {alpha: 0, y: y - 16}, 0.33, {ease: flixel.tweens.FlxEase.circOut, onComplete: tickRespawn});
    }
    
    function tickRespawn(_)
    {
        exists = false;

        if (respawnRate >= 0)
            new flixel.util.FlxTimer().start(respawnRate, revivePowerup, 1);
        else
            destroy();
    }

    private function revivePowerup(timer:flixel.util.FlxTimer):Void
    {
        y += 16;
        alpha = 1;
        alive = true;
        exists = true;
    }
}