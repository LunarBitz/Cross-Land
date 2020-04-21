package systems;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;

class GameHUD extends FlxTypedGroup<FlxSprite>
{
    var scoreCounter:FlxText;
    var scoreIcon:FlxSprite;
    var totalScore:Int = 0;

    public function new()
    {
        super();
        scoreCounter = new FlxText(0, 2, 0, "0", 16);
        scoreCounter.setBorderStyle(SHADOW, FlxColor.GRAY, 1, 1);
        scoreIcon = new FlxSprite(16, 16, AssetPaths.sprCoin_Icon__png);
        
        scoreIcon.scale.set(1.5, 1.5);
        scoreIcon.updateHitbox();
        scoreCounter.alignment = LEFT;
        
        scoreCounter.x = (scoreIcon.x + scoreIcon.width) + (scoreIcon.width / 2);
        scoreCounter.y = scoreIcon.y;

        add(scoreIcon);
        add(scoreCounter);
        forEach(function(sprite) sprite.scrollFactor.set(0, 0));
    }

    public function updateHUD(money:Int)
    {
        totalScore += money;
        scoreCounter.text = Std.string(totalScore);
    }
}