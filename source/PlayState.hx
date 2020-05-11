package;

import flixel.math.FlxMath;
import misc.Hitbox;
import entities.collectables.parent.Powerup;
import hazards.enemies.BasicBlob;
import entities.terrain.CloudSolid;
import Debug.DebugOverlay;
import flixel.util.FlxColor;
import flixel.FlxObject;
import flixel.FlxG;
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
import systems.Hud;
import misc.background.Parallax;
import LevelGlobals;


using flixel.util.FlxSpriteUtil;
class PlayState extends FlxState
{
	private var player:Kholu;
	private var hud:GameHUD;
	//private var bgParallax:Parallax;

	private var allCollectables:FlxTypedGroup<Collectable>;
	private var coins:FlxTypedGroup<Coin>;
	private var gems:FlxTypedGroup<Gem>;

	private var enemies:FlxTypedGroup<Enemy>;
	private var allAI:FlxTypedGroup<Enemy>;

	private var cannons:FlxTypedGroup<Cannon>;
	

	override public function create():Void
	{
		LevelGlobals.currentState = this;
		LevelGlobals.totalElapsed = 0;

		initBackground();


		player = new Kholu(96, 1120);
		

		FlxG.camera.fade(FlxColor.BLACK, 2, true);
		FlxG.camera.follow(player, PLATFORMER, 1/8);

		initOgmo3Map(AssetPaths.CrossLandsMaps__ogmo, AssetPaths.dusk_timberland_zone_1__json);

		
		
		hud = new GameHUD();
		

		if (FlxG.sound.music == null) // don't restart the music if it's already playing
		{
			FlxG.sound.playMusic(AssetPaths.ostDusk_Timberlands__ogg, 0, true);
			FlxG.sound.music.fadeIn(5, 0, 0.15);
		}

		var ambienceTrack = FlxG.sound.load(AssetPaths.ambForest__ogg, 0.05);
		if (ambienceTrack != null) // don't restart the music if it's already playing
		{
			ambienceTrack.looped = true;
			ambienceTrack.play();
			ambienceTrack.fadeIn(5, 0, 0.05);
	
		}

		assembleLevel();
		
		 
		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		LevelGlobals.deltaTime = elapsed;
		LevelGlobals.totalElapsed += elapsed * 1000;

		// Check for solid objects
		if (LevelGlobals.solidsReference != null)
		{
			//trace(LevelGlobals.solidsReference.length);

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

		if (LevelGlobals.allDamagers != null)
		{
			FlxG.overlap(player, LevelGlobals.allDamagers, Player.resolveDamagerCollision);
			if (allAI != null)
				FlxG.overlap(allAI, LevelGlobals.allHitboxes, Enemy.resolveDamagerCollision);
		}

		// Check for collectable objects
		if (allCollectables != null)
		{
			FlxG.overlap(player, allCollectables, resolveCollectableOverlap);
		}

		// Check for collectable objects
		if (LevelGlobals.allPowerups != null)
		{
			FlxG.overlap(player, LevelGlobals.allPowerups, resolvePowerupOverlap);
		}

		

	}

	private function initBackground() 
	{
		Parallax.init();

		Parallax.addElement("sky", AssetPaths.parSky__png, 783, 240, 0, 0, 1/64, 0, 1, false);
		Parallax.addElement("back_cloud", AssetPaths.parCloud__png, 458, 98, 0, 19, 1/64, 1/512);
		
		Parallax.addElement("mountains", AssetPaths.parMountain2__png, 688, 256, 0, 70, 1/32, 1/92);
		Parallax.addElement("front_cloud", AssetPaths.parCloud__png, 458, 98, 220, 54, 1/24, 1/86, 0.5);

		Parallax.addElement("pine_forest_1", AssetPaths.parPine1__png, 688, 148, 0, 136, 1/16, 1/48);
		Parallax.addElement("pine_forest_2", AssetPaths.parPine2__png, 688, 199, 0, 196, 1/8, 1/16);
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
		LevelGlobals.backgroundTiles = map.loadTilemap(AssetPaths.tsDuskTimberlands_back__png, "tiles_background");
		LevelGlobals.mainTiles = map.loadTilemap(AssetPaths.tsDuskTimberlands_main__png, "tiles_main");
		LevelGlobals.foregroundTiles = map.loadTilemap(AssetPaths.tsDuskTimberlands_front__png, "tiles_foreground");

		LevelGlobals.backgroundDecor = map.loadTilemap(AssetPaths.decDuskTimberlands_main__png, "decor_background");
    	LevelGlobals.mainDecor = map.loadTilemap(AssetPaths.decDuskTimberlands_main__png, "decor_main");
    	//LevelGlobals.foregroundDecor = map.loadTilemap(AssetPaths.decDuskTimberlands_main__png, "decor_background");


		LevelGlobals.backgroundTiles.follow();
		LevelGlobals.mainTiles.follow();
		LevelGlobals.foregroundTiles.follow();

		LevelGlobals.backgroundDecor.follow();
    	LevelGlobals.mainDecor.follow();
    	//LevelGlobals.foregroundDecor.follow();

		#if debug
		LevelGlobals.backgroundTiles.ignoreDrawDebug = true;
		LevelGlobals.mainTiles.ignoreDrawDebug = true;
		LevelGlobals.foregroundTiles.ignoreDrawDebug = true;

		LevelGlobals.backgroundDecor.ignoreDrawDebug = true;
		LevelGlobals.mainDecor.ignoreDrawDebug = true;
		//LevelGlobals.foregroundDecor.ignoreDrawDebug = true;
		#end
		
		// Get all entities
		cannons = new FlxTypedGroup<Cannon>();
		coins = new FlxTypedGroup<Coin>();
		gems = new FlxTypedGroup<Gem>();
		LevelGlobals.allPowerups = new FlxTypedGroup<Powerup>();

		enemies = new FlxTypedGroup<Enemy>();
		map.loadEntities(placeEntities, "entities");



		// Add groups for building
		allCollectables = new FlxTypedGroup<Collectable>();
		LevelGlobals.allDamagers = new FlxTypedGroup<Damager>();
		LevelGlobals.allHitboxes = new FlxTypedGroup<Hitbox>();
		
		allAI = new FlxTypedGroup<Enemy>();
		LevelGlobals.combineGroups(allCollectables, [coins, gems]);
		LevelGlobals.combineGroups(LevelGlobals.allDamagers, [enemies]);
		LevelGlobals.combineGroups(allAI, [enemies]);
		
	}

	private function assembleLevel()
	{
		add(LevelGlobals.solidsReference);
		add(LevelGlobals.platformsReference);

		add(LevelGlobals.backgroundTiles);
		add(LevelGlobals.backgroundDecor);
		add(allCollectables);
		add(cannons);
		add(LevelGlobals.allPowerups);
		
		add(LevelGlobals.mainTiles);
		add(LevelGlobals.mainDecor);
		add(LevelGlobals.allDamagers);
		add(player);
		add(LevelGlobals.foregroundTiles);

		add(hud);
		add(new DebugOverlay());
	}

	function placeEntities(entity:EntityData)
	{
		switch (entity.name)
		{
			case "player":
				player.setPosition(entity.x, entity.y);
				//Parallax.offsetElements(entity.x, entity.y);
			case "cannon":
				cannons.add(new Cannon(entity.x, entity.y, entity.values.facing_direction));
			case "coin":
				coins.add(new Coin(entity.x, entity.y));
			case "gem":
				gems.add(new Gem(entity.x, entity.y));
			case "basicBlob":
				enemies.add(new BasicBlob(entity.x, entity.y, 16, 16, player));
			case "powerup_jumpboost":
				LevelGlobals.allPowerups.add(new Powerup(entity.x, entity.y, 16, 16, AssetPaths.sprPowerupJumpBoost__png, JumpBoost, 4, 5, 10));
		}
	}

	public function resolveCollectableOverlap(player:Player, collectable:Collectable)
	{
		if (player.alive && player.exists && collectable.alive && collectable.exists)
		{
			hud.updateHUD(collectable.VALUE);
			collectable.kill();
		}
	}

	public function resolvePowerupOverlap(player:Player, object:Powerup)
	{
		if (player.alive && player.exists && object.alive && object.exists)
		{
			if (!player.powerupStack.exists(Std.string(object.power) + "_Value"))
				player.powerupStack[Std.string(object.power) + "_Value"] = 1;
			else
				if (player.powerupStack[Std.string(object.power) + "_Value"] < object.maxValue || object.maxValue == -1)
					player.powerupStack[Std.string(object.power) + "_Value"] += 1;

			player.powerupStack[Std.string(object.power) + "_MaxLifeTime"] = object.maxLifeTime;

			if (!player.powerupStack.exists(Std.string(object.power) + "_Timer"))
				player.powerupStack[Std.string(object.power) + "_Timer"] = object.maxLifeTime;
			else
				player.powerupStack[Std.string(object.power) + "_Timer"] += object.maxLifeTime;
			
			var minTimer = FlxMath.minInt(player.powerupStack[Std.string(object.power) + "_Timer"], player.powerupStack[Std.string(object.power) + "_Value"] * object.maxLifeTime);
			player.powerupStack[Std.string(object.power) + "_Timer"] = Std.int(minTimer);

			player.handlePowerups();
			object.kill();

			#if debug
			trace( 'Value: ${player.powerupStack[Std.string(object.power) + "_Value"]} - Timer: ${player.powerupStack[Std.string(object.power) + "_Timer"]} - MaxLifeTime: ${player.powerupStack[Std.string(object.power) + "_MaxLifeTime"]}\n');
			#end
		}
	}

}
