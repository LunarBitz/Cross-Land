package;

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

import entities.terrain.Wall;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.tile.FlxTilemap;
import systems.Hud;


using flixel.util.FlxSpriteUtil;
class PlayState extends FlxState
{
	private var player:Kholu;
	private var hud:GameHUD;
	private var money:Int = 0;

	private var map:FlxOgmo3Loader;
	private var graphicTiles:FlxTilemap;
	private var solidTiles:FlxTypedGroup<Wall>;
	private var cannons:FlxTypedGroup<Cannon>;
	private var allCollectables:FlxTypedGroup<Collectable>;
	private var coins:FlxTypedGroup<Coin>;
	private var gems:FlxTypedGroup<Gem>;
	

	override public function create():Void
	{
		player = new Kholu();
		add(player);
		/*
		add(player.leftSensor);
		add(player.rightSensor);
		*/

		FlxG.camera.follow(player, PLATFORMER, 1/16);

		initOgmo3Map(AssetPaths.CrossLandsMaps__ogmo, AssetPaths.dusk_timberland_zone_1__json);

		hud = new GameHUD();
		add(hud);

		add(new DebugOverlay());
		 
		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		if (solidTiles != null)
		{
			// Must handle x collisions before the y collisions or 
			// else the player will get stuck in the seams of solid object sprites
			FlxG.overlap(player, solidTiles, player.onWallCollision, FlxObject.separateX);
			FlxG.overlap(player, solidTiles, player.onFloorCollision, FlxObject.separateY);	
		}

		if (allCollectables != null)
		{
			FlxG.overlap(player, allCollectables, onCollectableOverlap);
		}

	}

	private function initOgmo3Map(projectPath:String, projectJson:String):Void 
	{
		map = new FlxOgmo3Loader(projectPath, projectJson);	

		// Get the solid objects for collission
		var grid:Map<String, Array<flixel.math.FlxPoint>> = map.loadGridMap("collision");
		solidTiles = new FlxTypedGroup<Wall>();
		for (point in grid['1'])
		{
			solidTiles.add(new Wall(point.x, point.y, 16, 16));
		}
		player._solidsRef = solidTiles;
		/*
		player.leftSensor._solids = solidTiles;
		player.rightSensor._solids = solidTiles;
		*/

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

	public function onCollectableOverlap(player:Player, collectable:Collectable)
	{
		if (player.alive && player.exists && collectable.alive && collectable.exists)
		{
			hud.updateHUD(collectable.VALUE);
			collectable.kill();
		}
	}

}
