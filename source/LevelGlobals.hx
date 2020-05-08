package;

import flixel.group.FlxGroup.FlxTypedGroup;

import entities.terrain.Solid;
import entities.terrain.CloudSolid;

class LevelGlobals 
{
    static public var solidsReference:FlxTypedGroup<Solid>;
    static public var platformsReference:FlxTypedGroup<CloudSolid>;
    
    static public var totalElapsed:Float = 0;

    static public function screenOptimization(object:Solid) 
    {
        #if debug
        object.ignoreDrawDebug = object.isOnScreen();
        #end
        
        if (totalElapsed > 2000)
            object.exists = object.isOnScreen();
    }
}
