package entities.terrain;

import flixel.util.FlxColor;
import flixel.FlxSprite;

class Wall extends FlxSprite {
    public static var WIDTH(default, never) = 32;
    public static var HEIGHT(default, never) = 32;
    
    public function new(?X:Float = 0, ?Y:Float = 0, ?Width:Int = 48, ?Height:Int = 48) 
    {
        super(X, Y);
        makeGraphic(Width, Height, FlxColor.GRAY);
        visible = false;
        alpha = 0;

        // Set immovable to true, prevents this from getting pushed during FlxG.collide()
        immovable = true;
    }
}