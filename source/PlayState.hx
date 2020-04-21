package;


import flixel.FlxObject;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import entities.player.PlayerParent;
import entities.launchers.Cannon;
import entities.collectables.Coin;
import entities.terrain.Wall;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.tile.FlxTilemap;
import systems.Hud;

class PlayState extends FlxState
{
	private var player:Player;
	private var hud:GameHUD;
	private var money:Int = 0;

	private var map:FlxOgmo3Loader;
	private var graphicTiles:FlxTilemap;
	private var solidTiles:FlxTypedGroup<Wall>;
	private var cannons:FlxTypedGroup<Cannon>;
	private var coins:FlxTypedGroup<Coin>;

	override public function create():Void
	{
		player = new Player();
		add(player);

		FlxG.camera.follow(player, PLATFORMER, 1/16);

		initOgmo3Map(AssetPaths.TestMap__ogmo, AssetPaths.TestMap__json);

		hud = new GameHUD();
 		add(hud);


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
			FlxG.overlap(player, solidTiles, player.onWallCollision, FlxObject.separateY);	
		}

		FlxG.overlap(player, coins, onCoinOverlap);

	}

	private function initOgmo3Map(projectPath:String, projectJson:String):Void 
	{
		map = new FlxOgmo3Loader(AssetPaths.TestMap__ogmo, AssetPaths.TestMap__json);	

		// Get the solid objects for collission
		var grid:Map<String, Array<flixel.math.FlxPoint>> = map.loadGridMap("solid");
		solidTiles = new FlxTypedGroup<Wall>();
		for (point in grid['1'])
		{
			solidTiles.add(new Wall(point.x, point.y, 48, 48));
		}

		// Get the graphical tilemaps
		// Note: When creating a tileset in a sprite editor, ALWAYS leave the first tile 
		//		 blank (0 alpha)! Will save you a lot of time and spared of the headache 
		// 		 trying to figure out why the tiles aren't rendering.
		graphicTiles = map.loadTilemap(AssetPaths.sprStationTileset__png, "graphics");
		graphicTiles.follow();
		// Disable collision for tiles 1-4 since we already established a collision grid
		graphicTiles.setTileProperties(1, FlxObject.NONE, null, null, 4);

		// Get all entities
		cannons = new FlxTypedGroup<Cannon>();
		coins = new FlxTypedGroup<Coin>();
		map.loadEntities(placeEntities, "entities");

		// Add groups for building
		add(solidTiles);
		add(graphicTiles);
		add(cannons);
		add(coins);
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
		}
	}

	public function onCoinOverlap(player:Player, coin:Coin)
	{
		if (player.alive && player.exists && coin.alive && coin.exists)
		{
			hud.updateHUD(coin.MAX_VALUE);

			coin.kill();
		}
	}

}
