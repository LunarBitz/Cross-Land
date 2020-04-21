package entities.projectiles;

import flixel.util.FlxColor;
import flixel.FlxSprite;

class Fireball extends FlxSprite {
    public function new(?X:Float = 0, ?Y:Float = 0) {
        super(X, Y);
        makeGraphic(10, 10, FlxColor.RED);

        velocity.x = 100;
    }
}