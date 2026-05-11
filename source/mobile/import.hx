import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxInputText; 
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.atlas.FlxNode;
import flixel.graphics.frames.FlxTileFrames;
import flixel.input.FlxInput;
import flixel.input.FlxPointer;
import flixel.input.IFlxInput;
import flixel.text.FlxText;
import flixel.util.FlxDestroyUtil;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxTileFrames;
import flixel.input.touch.FlxTouchManager;

import mobile.*;
import mobile.controls.*;
import mobile.utils.*;

import funkin.backend.system.Controls;
import funkin.game.PlayState;
import funkin.options.Options;
import funkin.backend.assets.Paths; 

import openfl.Lib;

import flixel.util.FlxDestroyUtil.IFlxDestroyable;

#if (flixel >= "5.3.0")
import flixel.sound.FlxSound;
#else
import flixel.system.FlxSound;
#end

#if FLX_TOUCH
import flixel.input.touch.FlxTouch;
#end
