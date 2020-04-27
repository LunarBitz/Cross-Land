package entities.collectables;

import entities.collectables.parent.Collectable;

class Gem extends Collectable
{
    private var totalTime:Float = 0;
    public function new(?X:Float = 0, ?Y:Float = 0) 
    {
        super(X, Y);

        VALUE = 2500;

        loadGraphic(AssetPaths.sprGem_2__png, true, 16, 16);
        animation.add("idle", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23], 15, true);
        animation.play("idle");
    }

    override function update(elapsed:Float) 
    {
        totalTime += elapsed;

        var dy:Float = Math.sin(totalTime * 2.5) * 8.0;
        velocity.set(0, dy);
        
        super.update(elapsed);
    }
}