package misc.background;

import flixel.util.FlxColor;
import openfl.geom.ColorTransform;
import openfl.display.BitmapData;
import flixel.FlxG;
import flixel.tile.FlxTileblock;

class Parallax 
{
    public static var elements:Map<String, FlxTileblock>;
    public static var globalXOffset:Int = 0;
    public static var globalYOffset:Int = 0;

    public static function init()
    {
        elements = new Map<String, FlxTileblock>();
    }

    public static function addElement(name:String, assetPath:String, ?elementWidth:Int = 0, ?elementHeight:Int = 0, ?initialX:Int = 0, ?initialY:Int = 0, ?scrollXSpeed:Float = 1, ?scrollYSpeed:Float = 0, ?opacity:Float = 1, ?canOffset:Bool = true):FlxTileblock
    {
        elements[name] = new FlxTileblock(initialX, initialY, elementWidth, elementHeight);

        elements[name].loadTiles(assetPath, elementWidth, elementHeight, 0);
        elements[name].alpha = opacity;
        elements[name].scrollFactor.set(scrollXSpeed, scrollYSpeed);

        // We're just repuposing the health attribute as a means to handle offset permissions instead of making a another variable
        elements[name].health = canOffset? 1:0;
        
        LevelGlobals.currentState.add(elements[name]);

		return elements[name];
    }

    public static function offsetElements(?xOff:Int = 0, ?yOff:Int = 0) 
    {
        for (ele in elements)
        {
            if (ele.health == 1)
                ele.setPosition(xOff, yOff);
        }
    }
}