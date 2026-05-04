package funkin.backend.system;

import flixel.FlxG;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFieldAutoSize;
import openfl.system.System;
import openfl.events.Event;
import openfl.Lib;
import openfl.filters.DropShadowFilter;
import openfl.utils.Assets;

import funkin.options.Options;

class FPSMemCounter extends TextField
{
	var times:Array<Float> = [];

	var lastUpdate:Float = 0;
	var cachedFPS:Int = 0;
	var cachedMem:Float = 0;

	public var offsetX:Float;
	public var offsetY:Float;

	public function new(x:Float = 10, y:Float = 10)
	{
		super();

		this.offsetX = x;
		this.offsetY = y;
		this.x = x;
		this.y = y;

		selectable = false;
		mouseEnabled = false;
		multiline = true;
		autoSize = TextFieldAutoSize.LEFT;

		var fontName:String = "_sans";
		var customFontLoaded:Bool = false;

		try
		{
			var font = Assets.getFont("fonts/milkchoco.otf");

			if (font != null)
			{
				fontName = font.fontName;
				customFontLoaded = true;
			}
		}
		catch (e:Dynamic) {}

		defaultTextFormat = new TextFormat(fontName, 14, 0xFFFFFF);

		embedFonts = customFontLoaded; 

		filters = [
			new DropShadowFilter(1, 45, 0x000000, 1, 2, 2, 10)
		];

		updateScale();
  
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
		addEventListener(Event.RESIZE, onResize);
        
		addEventListener(Event.REMOVED_FROM_STAGE, onRemove); 
	}

	function onRemove(_)
	{
		removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		removeEventListener(Event.RESIZE, onResize);
		removeEventListener(Event.REMOVED_FROM_STAGE, onRemove);
	}

	function onResize(_)
	{
		updateScale();
	}

	function updateScale()
	{
		var userScale:Float = Options.fpsSize;

		var stageWidth = Lib.current.stage.stageWidth;
		var stageHeight = Lib.current.stage.stageHeight;

		var scaleXRatio = stageWidth / 1280;
		var scaleYRatio = stageHeight / 720;

		var screenScale = Math.min(scaleXRatio, scaleYRatio);

		scaleX = userScale * screenScale;
		scaleY = userScale * screenScale;
	}
	
	function onEnterFrame(_)
	{
		if (!visible) return; 

		if (FlxG.game != null) {
			this.x = FlxG.game.x + (offsetX * this.scaleX);
			this.y = FlxG.game.y + (offsetY * this.scaleY);
		}

		var now = Lib.getTimer();

		times.push(now);

		while (times.length > 0 && times[0] < now - 1000)
		{
			times.shift();
		}

		cachedFPS = times.length;

		if (now - lastUpdate >= 100)
		{
			lastUpdate = now;

			cachedMem = Math.round(
				(System.totalMemory / 1024 / 1024) * 100
			) / 100;

			text =
				"FPS: " + cachedFPS +
				"\nMEM: " + cachedMem + " MB";
		}
	}
}
