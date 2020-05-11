# Cross-Land
This is a simple 2D platformer game created by LunarBitz / TeaLBiTZ (Marcus S.), a student at Missouri State University. 

The main purpose of this project was to familiarize myself with [HaxeFlixel](http://www.haxeflixel.com) and make a playable game!

## Overview

In a realm filled with friendly creatures, your on vacation hoping to relax. Little do you know that your rest would come to an end. While catching some shut-eye, pandemonium suddenly strikes as the land quakes and the natives scream in fear. Not knowing what's causing panic, you need answers and unbeknownst, save the natives from the new terror. Travel across the land's terrain, collect valuables, and figure out what suddenly interrupted your vacation.

![CrossLand Screenshot](/docs/CrossLandScreenShot.png?raw=true)

*Version 1.0* - [Try Me!](https://lunarbitz.github.io/Cross-Land/)

## Getting Started

To build and run Shield-Game, follow the steps below:

1. Ensure you have [Haxe](http://www.haxe.org/download), [HaxeFlixel](http://www.haxeflixel.com), HaxeFlixel Addons 4.2.0, and [OpenFL](http://www.openfl.org/download/) installed on your computer.
2. Open a command prompt in `\Cross-Land`.
3. Run the command `lime test html5` to build and run the executable.
  * Neko build is incredibly demanding and poor performing
  * To run in debug mode, run the command `lime test -debug html5`. Then access the debug console with the backquote key.

## Useful Notes

* The levels restars if the mechanic runs out of health.
* All controls are keyboard-based. 
 * Use the arrow keys to move the the player.
 * Hold up and push towards a wall to slide on a wall
  * Press the opposite direction arrow key to wall jump
* Press Z to jump.
 * Tapping Z will let you jump lightly
 * Holding the Z key will let you jump higher
* Press C to attack
* Enemy information:
 * Sleeping enemies can still damage you.
 * when too close, a yellow caution sign will appear.
  * when awake and close, a red caution sign will appear, meaning a spin attack is comming
* There are collecables and powerups that show on your HUD

## Future Developments

This project is very rough under the hood.
Below are listed some of the changes I'd like to make to this when I have the time to come back to it.

* Reorganize, clean up and document code
* Extend levels
* Add checkpoints
* Add more enemies
* Finish HUD
* Add lives
