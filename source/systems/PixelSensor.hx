package systems;

import entities.terrain.Solid;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.FlxSprite;

class PixelSensor extends FlxSprite
{
    public var owner:FlxSprite;
    public var orginalPos:FlxPoint;
    public var _solids:Dynamic;
    private var pushing:Bool = false;
    public var pixelCol:Bool = false;
    private var yOff:Int = 0;

    private var xOrgOff:Float = 0;
    private var yOrgOff:Float = 0;

    override public function new(?X:Float = 0, ?Y:Float = 0, ?xOffset:Float = 0, ?yOffset:Float = 0, newOwner:FlxSprite) 
    {
        super(X, Y);
        orginalPos = new FlxPoint();
        xOrgOff = xOffset;
        yOrgOff = yOffset;

        owner = newOwner;
        orginalPos.set(X + xOffset, Y + yOffset);

        makeGraphic(1, 1, FlxColor.YELLOW);

    }

    override function update(elapsed:Float) 
    {
        follow();
        super.update(elapsed);
    }

    public function follow() 
    {
        setPosition(owner.x + xOrgOff, owner.y + yOrgOff + yOff);
        orginalPos.set(owner.x + xOrgOff, owner.y + yOrgOff);
    }

    public function pushDown(length:Int):FlxPoint
    {
        if (yOff < length && !pixelCol)
        {
            yOff++;
            //trace(y);
            y = orginalPos.y + yOff;

            FlxG.overlap(this, _solids, checkPixel);
        }
        else if (pixelCol)
        {
            yOff = 0;
            pixelCol = false;
            return FlxPoint.weak(x, y);
        }
        else 
        {
            yOff = 0;
            pixelCol = false;
        }

        return null;
        
    }

    public function checkPixel(sensor:FlxSprite, other:FlxSprite):Void
    {
        other.visible = true;
        other.alpha = 1;

        pixelCol = FlxG.pixelPerfectOverlap(sensor, other, 1);

        other.visible = false;
        other.alpha = 0;
    }
}