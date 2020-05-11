package misc;

import flixel.FlxSprite;

class VictoryBox extends FlxSprite
{

    override public function new(?X:Float = 0, ?Y:Float = 0, ?Width:Int = 1, ?Height:Int = 1)
    {
        super(X, Y);
        makeGraphic(Width, Height, 0xFF00FFBB);
        immovable = true;
        alpha = 0;
        visible = false;
    }
    
}