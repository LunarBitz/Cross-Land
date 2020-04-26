package;

import flixel.addons.plugin.FlxScrollingText.ScrollingTextData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;

class DebugOverlay extends FlxTypedGroup<FlxSprite>
{
    public static var debug:Map<String, Dynamic>;
    private static var debugText:FlxText;

    override public function new()
    {
        super();
        
        debug = new Map<String, Dynamic>();
        debugText = new FlxText(0, 48, 0, "|", 8);
        debugText.setBorderStyle(SHADOW, FlxColor.GRAY, 1, 1);
        add(debugText);
        forEach(function(sprite) sprite.scrollFactor.set(0, 0));
    }

    override function update(elapsed:Float)
    {
        debugText.text = "";
        var txt:String = "";
        for (name => value in debug) 
        {
            txt += '${name}: ${value}\n';    
        }
        debugText.text = txt;

        super.update(elapsed);
    }

    /**
        Add a variable to watch
    **/
    static public function watchValue(name:String, value:Dynamic):String 
    {
        if (debug != null)
            debug[name] = value;

        return name;
    }
}