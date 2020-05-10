package misc;

import hazards.parents.Damager;
import flixel.FlxSprite;

class Hitbox extends Damager
{
    public var owner:FlxSprite;
    public var baseOffsetX:Float = 0;
    public var baseOffsetY:Float = 0;
    public var offsetX:Float = 0;
    public var offsetY:Float = 0;
    
    override public function new(?X:Float = 0, ?Y:Float = 0, ?newWidth:Int = 1, ?newHeight:Int = 1, ?initialExist:Bool = false, ?newOwner:FlxSprite) 
    {
        super(X, Y);

        owner = newOwner;
        makeGraphic(newWidth, newHeight, 0x808D39CF);

        damgeValue = 15;

        // Set immovable to true, prevents this from getting pushed during FlxG.collide()
        immovable = true;
        visible = true;
        alpha = 1;
        this.exists = initialExist;
    }

    public function positionBox(from:String = "Bottom", to:String = "South") 
    {
        var originX:Float = 0;
        var originY:Float = 0;
        var targetX:Float = 0;
        var targetY:Float = 0;

        switch (from)
        {
            case "Bottom","B","South","S":
                originX = width/2;
                originY = height;
            case "Bottom-Left","BL","South-West","SW":
                originX = 0;
                originY = height;
            case "Bottom-Right","BR","South-East","SE":
                originX = width;
                originY = height;
        }

        switch (to)
        {
            case "Bottom","B","South","S":
                targetX = owner.width/2;
                targetY = owner.height;
        }

        baseOffsetX = -(originX - targetX);
        baseOffsetY = -(originY - targetY);
        
    }

    public function followOwner() 
    {
        if (owner != null)
        {
            x = owner.x + baseOffsetX + offsetX;
            y = owner.y + baseOffsetY + offsetY;
        }
    }
}