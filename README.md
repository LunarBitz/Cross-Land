# Cross-Land
This is a simple 2D platformer game created by LunarBitz / TeaLBiTZ (Marcus S.), a student at Missouri State University. 

The main purpose of this project was to familiarize myself with [HaxeFlixel](http://www.haxeflixel.com) and make a playable game!

## Overview

In a realm filled with friendly creatures, your on vacation hoping to relax. Little do you know that your rest would come to an end. While catching some shut-eye, pandemonium suddenly strikes as the land quakes and the natives scream in fear. Not knowing what's causing panic, you need answers and unbeknownst, save the natives from the new terror. Travel across the land's terrain, collect valuables, and figure out what suddenly interrupted your vacation.

![CrossLand Screenshot](/docs/CrossLandScreenShot.png?raw=true)

*Version 1.0* - [Try Me!](https://lunarbitz.github.io/Cross-Land/)

## Getting Started

To build and run Cross-Land, follow the steps below:

1. Ensure you have [Haxe](http://www.haxe.org/download), [HaxeFlixel](http://www.haxeflixel.com), [HaxeFlixel Addons](https://haxeflixel.com/documentation/flixel-addons/) (4.2.0 +), and [OpenFL](http://www.openfl.org/download/) installed on your computer.
2. Open a command prompt in `\Cross-Land`.
3. Run the command `lime test html5` to build and run the executable.
	- To run in debug mode, run the command `lime test -debug html5`. Then access the debug console with the backquote key
	- Highly advised to avoid building with Neko for this project as this build is incredibly demanding and poor performing under Neko. Please use HTML5 only for the time being

## Controls
* The levels restars if the mechanic runs out of health.
* All controls are keyboard-based. 
* Use the [LEFT] and [RIGHT] arrow keys to move the the player.
* * Hold the [UP] key and push towards a wall to slide on a wall
* * * Press the opposite direction arrow key while still holding [UP] to wall jump
* Hold [DOWN] to crouch
* Press [Z] to jump
* * Tapping [Z] will let you jump lightly
* * Holding the [Z] key will let you jump higher
* Press [X] to attack

## Enemies
#### Basic Blob:
* Starts off sleeping
* When a player is too close, a yellow caution sign will appear above it
* * Sleeping enemies will still inflict damage onto you
* When awake and the player is still too close, a red caution sign will appear
* * This means that a spin attack from it is comming

## Colectables
#### Coins & Gems
* They only contribute to your score

## Powerups
* Each powerup dynamically appears on the HUD in the order collected
#### Jump Boosts
* Increases your max jump height

## Future Developments
This project is very rough under the hood.
Below are listed some of the changes I'd like to make to this when I have the time to come back to it.

* Reorganize, clean up and document code
* Extend levels
* Add checkpoints
* Add more enemies
* Finish HUD
* Add lives


## Due Credit (Copyrights/Attributions)
This project was assembled with various CC BY 4.0 assets avaialable on [OpenGameArt](https://opengameart.org/) and [Itch.io](https://itch.io/game-assets). The following mentioned are the creators / contributors of the following assets:
* [Khoulu / Midi-Waffle Playable character](https://opengameart.org/content/midi-waffle)
* * [Kelvin Shadewing](http://www.patreon.com/kelvin) | [Home Site](kelvinshadewing.net)
* [Grasstop Tiles](https://opengameart.org/content/grasstop-tiles)
* * [Kelvin Shadewing](http://www.patreon.com/kelvin) | [Home Site](kelvinshadewing.net)
* * Additional tiles were created by me to accomodate for special cases
* [Forest Lite Pixel Art Tileset](https://sanctumpixel.itch.io/forest-lite-pixel-art-tileset)
* * [sanctumpixel](https://sanctumpixel.itch.io/) | [Home Site (Twitter)](https://twitter.com/sanctumpixel)
* * Only used the parallaxes and decor which were slightly scaled up per pixel and extended by me
* [Slime Character](https://kvsr.itch.io/slime-character)
* * [NYKNCK](https://kvsr.itch.io/) | [Home Site](http://nyknck.com/)
