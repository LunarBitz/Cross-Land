package systems;

import flixel.ui.FlxButton;
import flixel.util.FlxAxes;
import flixel.system.FlxAssets.FlxGraphicAsset;
import entities.collectables.parent.Powerup.Powerups;
import entities.player.PlayerParent.Player;
import flixel.addons.plugin.FlxScrollingText.ScrollingTextData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.ui.FlxBar;

using flixel.util.FlxSpriteUtil;

class GameHUD extends FlxTypedGroup<FlxSprite>
{
    var hudVariableTracker:Player;
    var scoreCounter:FlxText;
    var scoreIcon:FlxSprite;
    var totalScore:Int = 0;
    var healthBar:FlxSprite;
    public var powerupSprites:Map<String, FlxSprite>;
    var hudPowerSprites:FlxTypedGroup<FlxSprite>;
    var replayButton:FlxButton;

    public function new(variableTarget:Player)
    {
        super();
        hudPowerSprites = new FlxTypedGroup<FlxSprite>();
        powerupSprites = new Map<String, FlxSprite>();
        
        hudVariableTracker = variableTarget;
        scoreCounter = new FlxText(0, 2, 0, "0", 16);
        scoreCounter.setBorderStyle(SHADOW, FlxColor.GRAY, 1, 1);
        scoreIcon = new FlxSprite(32, 64, AssetPaths.sprCoin_Icon__png);
        
        healthBar = new FlxSprite(65, 17);
		healthBar.loadGraphic(AssetPaths.sprHUDHealthBarTick__png, false, 1, 7);
		healthBar.origin.x = healthBar.origin.y = 0; //Zero out the origin
		healthBar.scale.x = 90; //Fill up the health bar all the way
        
    
        scoreIcon.scale.set(1.5, 1.5);
        scoreIcon.updateHitbox();
        scoreCounter.alignment = LEFT;
        
        scoreCounter.x = (scoreIcon.x + scoreIcon.width) + (scoreIcon.width / 2);
        scoreCounter.y = scoreIcon.y;

        drawBase();

    }

    public function drawBase() 
    {
        add(new FlxSprite(0,0,AssetPaths.sprHudBase__png));
        add(healthBar);
        add(scoreIcon);
        add(scoreCounter);
        add(healthBar);
        
        forEach(function(sprite) sprite.scrollFactor.set(0, 0));
    }

    public function drawVictory() 
    {
        var winText = new FlxText(0,32, 240, "Level Complete!", 32);
        winText.setBorderStyle(SHADOW, FlxColor.GRAY, 1, 1);
        winText.screenCenter(FlxAxes.X);
        add(winText);

        replayButton = new FlxButton(0, 0, "Replay", clickReplay);
        replayButton.x = (FlxG.width / 2) - replayButton.width - 10;
        replayButton.y = FlxG.height - replayButton.height - 10;
        add(replayButton);

        forEach(function(sprite) sprite.scrollFactor.set(0, 0));
        
    }

    public function clickReplay():Void
    {
        trace("fffff");
        FlxG.camera.fade(FlxColor.BLACK, 2, false, restartState);
            
    }

    public function restartState() 
    {
        FlxG.resetState();
    }

    override public function update(elapese:Float)
    {
        healthBar.scale.x = (hudVariableTracker.health / 100) * 90;
        scoreCounter.text = Std.string(totalScore);

        if (replayButton != null)
            if (FlxG.keys.anyJustPressed([SPACE, ENTER, C]))
                clickReplay();
    }

    public function updatePowerElements() 
    {
        var i = 0;

        clear();
        drawBase();
        for (key in powerupSprites.keys())
        {
            var spr = new FlxSprite(64 + (i * 16), 32);
            spr.loadGraphicFromSprite(powerupSprites[key]);
            powerupSprites[key] = spr;
            powerupSprites[key].scrollFactor.set(0,0);
            add(powerupSprites[key]);
            i += 1;
        }
        
    }

    public function removePowerElement(element:FlxSprite) 
    {
        remove(element);
    }
    

    public function updateScore(value:Int)
    {
        totalScore += value;
    }
}