package;

import hazards.parents.Damager;
import flixel.tile.FlxTileblock;
import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;

import entities.terrain.Solid;
import entities.terrain.CloudSolid;



class LevelGlobals 
{

    static public var currentState:FlxState; 
    static public var solidsReference:FlxTypedGroup<Solid>;
    static public var platformsReference:FlxTypedGroup<CloudSolid>;

    public static var allDamagers:FlxTypedGroup<Damager>;
    
    static public var deltaTime:Float = 0;
    static public var totalElapsed:Float = 0;

    static public function screenOptimization(object:Solid) 
    {
        #if debug
        object.ignoreDrawDebug = object.isOnScreen();
        #end

        if (totalElapsed > 2000)
        {
            var outsideX = object.getScreenPosition().x < (-96) || object.getScreenPosition().x > (FlxG.camera.width + 96);
            var outsideY = object.getScreenPosition().y < (-96) || object.getScreenPosition().y > (FlxG.camera.height + 96);

            object.exists = !(outsideX || outsideY);
        }
    }

    static public function combineGroups(master:FlxTypedGroup<Dynamic>, groups:Array<FlxTypedGroup<Dynamic>>) 
    {
        for (subGroup in groups)
            for (item in subGroup)
                master.add(item);
    }

    static public function combineMaps(master:FlxTypedGroup<Dynamic>, groups:Array<Map<Dynamic, Dynamic>>) 
    {
        for (subGroup in groups)
            for (item in subGroup)
                master.add(item);
    }

}
