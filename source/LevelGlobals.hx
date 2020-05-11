package;

import systems.Hud.GameHUD;
import entities.collectables.parent.Powerup;
import misc.Hitbox;
import flixel.tile.FlxTilemap;
import flixel.FlxSprite;
import hazards.parents.Damager;
import flixel.tile.FlxTileblock;
import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;

import entities.terrain.Solid;
import entities.terrain.CloudSolid;



class LevelGlobals 
{
    public static var hudReference:GameHUD;

    static public var currentState:FlxState; 
    static public var solidsReference:FlxTypedGroup<Solid>;
    static public var platformsReference:FlxTypedGroup<CloudSolid>;

    static public var backgroundTiles:FlxTilemap;
    static public var mainTiles:FlxTilemap;
    static public var foregroundTiles:FlxTilemap;

    static public var backgroundDecor:FlxTilemap;
    static public var mainDecor:FlxTilemap;
    static public var foregroundDecor:FlxTilemap;

    public static var allDamagers:FlxTypedGroup<Damager>;
    public static var allHitboxes:FlxTypedGroup<Hitbox>;
    public static var allPowerups:FlxTypedGroup<Powerup>;
    
    static public var deltaTime:Float = 0;
    static public var totalElapsed:Float = 0;

    static public function init() 
    {
        hudReference = new GameHUD(null);
        currentState = new FlxState(); 
        solidsReference = new FlxTypedGroup<Solid>();
        platformsReference = new FlxTypedGroup<CloudSolid>();

        backgroundTiles = new FlxTilemap();
        mainTiles = new FlxTilemap();
        foregroundTiles = new FlxTilemap();

        backgroundDecor = new FlxTilemap();
        mainDecor = new FlxTilemap();
        foregroundDecor = new FlxTilemap();

        allDamagers = new FlxTypedGroup<Damager>();
        allHitboxes = new FlxTypedGroup<Hitbox>();
        allPowerups = new FlxTypedGroup<Powerup>();
        
        deltaTime = 0;
        totalElapsed = 0;
    }

    static public function screenOptimization(object:FlxSprite) 
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
