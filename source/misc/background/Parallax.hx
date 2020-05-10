package misc.background;

import flixel.addons.display.FlxBackdrop;

class Parallax 
{
    public static var elements:Map<String, FlxBackdrop>;

    public static function init()
    {
        elements = new Map<String, FlxBackdrop>();
    }

    public static function addElement(  name:String,        assetPath:String,   ?elementWidth:Int = 0,      ?elementHeight:Int = 0, 
                                        ?initialX:Int = 0,  ?initialY:Int = 0,  ?scrollXSpeed:Float = 1,    ?scrollYSpeed:Float = 0, 
                                        ?opacity:Float = 1, ?canOffset:Bool = true
                                     ):FlxBackdrop
    {
        elements[name] = new FlxBackdrop(assetPath, scrollXSpeed, scrollYSpeed, true, false);

        elements[name].setPosition(initialX, initialY);
        elements[name].alpha = opacity;
        elements[name].scrollFactor.set(scrollXSpeed, scrollYSpeed);

        // We're just repuposing the health attribute as a means to handle offset permissions instead of making a another variable
        elements[name].health = canOffset? 1:0;
        
        LevelGlobals.currentState.add(elements[name]);

		return elements[name];
    }

    public static function shiftAllElements(?xOff:Int = 0, ?yOff:Int = 0):Void
    {
        for (ele in elements)
        {
            if (ele.health == 1)
                ele.setPosition(xOff, yOff);
        }
    }
}