package misc;

import flixel.FlxSprite;

class Hitbox extends FlxSprite
{
    var owner:FlxSprite;
    var effectValue:Float;
    
    override public function new(?X:Float = 0, ?Y:Float = 0, ?newWidth:Int = 1, ?newHeight:Int = 1, ?newOwner:FlxSprite) 
    {
        super(X, Y);

        owner = newOwner;
        makeGraphic(newWidth, newHeight, 0xFF8D39CF);

        // Set immovable to true, prevents this from getting pushed during FlxG.collide()
        immovable = true;
    }
}