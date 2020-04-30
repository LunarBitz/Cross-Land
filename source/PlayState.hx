package;

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

import entities.terrain.Solid;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.tile.FlxTilemap;
import systems.Hud;


using flixel.util.FlxSpriteUtil;
class PlayState extends FlxState
{
	private var player:Kholu;
	private var hud:GameHUD;

	private var graphicTiles:FlxTilemap;
	private var solidTiles:FlxTypedGroup<Solid>;
	private var jumpThroughTiles:FlxTypedGroup<CloudSolid>;

	private var allCollectables:FlxTypedGroup<Collectable>;
	private var coins:FlxTypedGroup<Coin>;
	private var gems:FlxTypedGroup<Gem>;

	private var cannons:FlxTypedGroup<Cannon>;
	

	override public function create():Void
	{
		player = new Kholu();
		add(player);

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
		
		// Check for solid objects
		if (solidTiles != null)
		{
			// Handle x and y collisions seperately for specialized logic
			FlxG.overlap(player, solidTiles, player.resolveWallCollision, FlxObject.separateX);
			FlxG.overlap(player, solidTiles, player.resolveFloorCollision, FlxObject.separateY);	
		}

		// Check for jump through objects
		if (jumpThroughTiles != null)
		{
			FlxG.collide(player, jumpThroughTiles, player.resolveFloorCollision);	
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
		
		solidTiles = new FlxTypedGroup<Solid>();
		for (point in grid['1'])
			solidTiles.add(new Solid(point.x, point.y, 16, 16));

		jumpThroughTiles = new FlxTypedGroup<CloudSolid>();
		for (point in grid['P'])
			jumpThroughTiles.add(new CloudSolid(point.x, point.y, 16, 16));
		
		player._solidsRef = solidTiles;



		// Get the graphical tilemaps
		// Note: When creating a tileset in a sprite editor, ALWAYS leave the first tile 
		//		 blank (0 alpha)! Will save you a lot of time and spared of the headache 
		// 		 trying to figure out why the tiles aren't rendering.
		graphicTiles = map.loadTilemap(AssetPaths.tsGrasstop__png, "graphics");
		graphicTiles.follow();

		// Disable collision for tiles 1-4 since we already established a collision grid
		graphicTiles.setTileProperties(1, FlxObject.NONE, null, null, 318);
		

		
		// Get all entities
		cannons = new FlxTypedGroup<Cannon>();
		coins = new FlxTypedGroup<Coin>();
		gems = new FlxTypedGroup<Gem>();
		map.loadEntities(placeEntities, "entities");



		// Add groups for building
		allCollectables = new FlxTypedGroup<Collectable>();
		addToCollectables([coins, gems]);
		
		add(allCollectables);
		add(solidTiles);
		add(jumpThroughTiles);
		add(graphicTiles);
		add(cannons);
		
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
		}
	}

	function addToCollectables(uniqueCollectables:Array<FlxTypedGroup<Dynamic>>) 
	{
		for (collectable in uniqueCollectables)
			for (item in collectable)
				allCollectables.add(item);
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
