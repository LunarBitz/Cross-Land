package entities.terrain;

import flixel.FlxObject;

class CloudSolid extends Solid 
{
    public static var WIDTH(default, never) = 32;
    public static var HEIGHT(default, never) = 32;
    
    public function new(?X:Float = 0, ?Y:Float = 0, ?Width:Int = 1, ?Height:Int = 1) 
    {
        super(X, Y);
        makeGraphic(Width, Height, 0x00000000);
        visible = false;
        alpha = 0;

        // Set immovable to true, prevents this from getting pushed during FlxG.collide()
        allowCollisions = FlxObject.UP;
        immovable = true;
    }

}