package;

import hazards.enemies.BasicBlob;
import lime.utils.Assets;
import entities.terrain.CloudSolid;
import Debug.DebugOverlay;
import flixel.util.FlxColor;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import entities.player.PlayerParent;
import entities.player.characters.Kholu;
import entities.launchers.Cannon;

import entities.collectables.Coin;
import entities.collectables.Gem;
import entities.collectables.parent.Collectable;

import hazards.parents.Enemy;
import hazards.parents.Damager;

import entities.terrain.Solid;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.tile.FlxTilemap;
import misc.Hitbox;
import systems.Hud;
import LevelGlobals;


using flixel.util.FlxSpriteUtil;
class PlayState extends FlxState
{
	private var player:Kholu;
	private var hud:GameHUD;

	private var graphicTiles:FlxTilemap;

	private var allCollectables:FlxTypedGroup<Collectable>;
	private var coins:FlxTypedGroup<Coin>;
	private var gems:FlxTypedGroup<Gem>;

	private var enemies:FlxTypedGroup<Enemy>;
	private var allDamagers:FlxTypedGroup<Damager>;
	private var allAI:FlxTypedGroup<Enemy>;

	private var cannons:FlxTypedGroup<Cannon>;
	

	override public function create():Void
	{
		player = new Kholu(96, 1120, ["attack"]);
		add(player);
		if (player.hitboxes != null)
			combineMaps(this, [player.hitboxes]);

		FlxG.camera.follow(player, PLATFORMER, 1/8);

		initOgmo3Map(AssetPaths.CrossLandsMaps__ogmo, AssetPaths.dusk_timberland_zone_1__json);

		hud = new GameHUD();
		add(hud);

		add(new DebugOverlay());
		 
		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		LevelGlobals.totalElapsed += elapsed * 1000;
		
		
		// Check for solid objects
		if (LevelGlobals.solidsReference != null)
		{
			trace(LevelGlobals.solidsReference.length);

			// Handle x and y collisions seperately for specialized logic
			FlxG.overlap(player, LevelGlobals.solidsReference, player.resolveWallCollision, FlxObject.separateX);
			FlxG.overlap(player, LevelGlobals.solidsReference, player.resolveFloorCollision, FlxObject.separateY);	

			FlxG.overlap(allAI, LevelGlobals.solidsReference, null, FlxObject.separateX);
			FlxG.overlap(allAI, LevelGlobals.solidsReference, null, FlxObject.separateY);

			LevelGlobals.solidsReference.forEach(LevelGlobals.screenOptimization);
		}

		// Check for jump through objects
		if (LevelGlobals.platformsReference != null)
		{
			FlxG.collide(player, LevelGlobals.platformsReference, player.resolveFloorCollision);	
			FlxG.collide(allAI, LevelGlobals.platformsReference);	

			LevelGlobals.platformsReference.forEach(LevelGlobals.screenOptimization);
		}

		if (allDamagers != null)
		{
			FlxG.overlap(player, allDamagers, player.resolveDamagerCollision);
		}


		// Check for collectable objects
		if (allCollectables != null)
		{
			FlxG.overlap(player, allCollectables, resolveCollectableOverlap);
		}

	}

	private function initOgmo3Map(projectPath:String, projectJson:String):Void 
	{
		var map = new FlxOgmo3Loader(projectPath, projectJson);

		// Get the solid objects for collission
		var grid:Map<String, Array<flixel.math.FlxPoint>> = map.loadGridMap("collision");
		
		LevelGlobals.solidsReference = new FlxTypedGroup<Solid>();
		for (point in grid['1'])
			LevelGlobals.solidsReference.add(new Solid(point.x, point.y, 16, 16));

		LevelGlobals.platformsReference = new FlxTypedGroup<CloudSolid>();
		for (point in grid['P'])
			LevelGlobals.platformsReference.add(new CloudSolid(point.x, point.y, 16, 16));



		// Get the graphical tilemaps
		// Note: When creating a tileset in a sprite editor, ALWAYS leave the first tile 
		//		 blank (0 alpha)! Will save you a lot of time and spared of the headache 
		// 		 trying to figure out why the tiles aren't rendering.
		graphicTiles = map.loadTilemap(AssetPaths.tsGrasstop__png, "graphics");
		graphicTiles.follow();

		// Disable collision for tiles 1-4 since we already established a collision grid
		graphicTiles.setTileProperties(1, FlxObject.NONE, null, null, 318);
		#if debug
		graphicTiles.ignoreDrawDebug = true;
		#end
		

		
		// Get all entities
		cannons = new FlxTypedGroup<Cannon>();
		coins = new FlxTypedGroup<Coin>();
		gems = new FlxTypedGroup<Gem>();

		enemies = new FlxTypedGroup<Enemy>();
		map.loadEntities(placeEntities, "entities");



		// Add groups for building
		allCollectables = new FlxTypedGroup<Collectable>();
		allDamagers = new FlxTypedGroup<Damager>();
		allAI = new FlxTypedGroup<Enemy>();
		combineGroups(allCollectables, [coins, gems]);
		combineGroups(allDamagers, [enemies]);
		combineGroups(allAI, [enemies]);
		
		add(allCollectables);
		add(LevelGlobals.solidsReference);
		add(LevelGlobals.platformsReference);
		add(graphicTiles);
		add(cannons);
		add(allDamagers);
		
	}

	function placeEntities(entity:EntityData)
	{
		switch (entity.name)
		{
			case "player":
				player.setPosition(entity.x, entity.y);
			case "cannon":
				cannons.add(new Cannon(entity.x, entity.y, entity.values.facing_direction));
			case "coin":
				coins.add(new Coin(entity.x, entity.y));
			case "gem":
				gems.add(new Gem(entity.x, entity.y));
			case "basicBlob":
				enemies.add(new BasicBlob(entity.x, entity.y, 16, 16, player));
		}
	}

	private function combineGroups(master:FlxTypedGroup<Dynamic>, groups:Array<FlxTypedGroup<Dynamic>>) 
	{
		for (subGroup in groups)
			for (item in subGroup)
				master.add(item);
	}

	private function combineMaps(master:FlxTypedGroup<Dynamic>, groups:Array<Map<Dynamic, Dynamic>>) 
	{
		for (subGroup in groups)
			for (item in subGroup)
				master.add(item);
	}

	public function resolveCollectableOverlap(player:Player, collectable:Collectable)
	{
		if (player.alive && player.exists && collectable.alive && collectable.exists)
		{
			hud.updateHUD(collectable.VALUE);
			collectable.kill();
		}
	}

}
