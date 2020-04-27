package entities.collectables;

import entities.collectables.parent.Collectable;

class Coin extends Collectable
{
    public function new(?X:Float = 0, ?Y:Float = 0) 
    {
        super(X, Y);

        VALUE = 250;

        loadGraphic(AssetPaths.sprCoin__png, true, 16, 16);
        animation.add("idle", [0, 1, 2, 3, 4, 5], 15, true);
        animation.play("idle");
    }
}