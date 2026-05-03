package backend;

import openfl.ui.Mouse;
import openfl.ui.MouseCursor;
import flixel.util.typeLimit.OneOfTwo;
import flixel.util.typeLimit.OneOfThree;
import flixel.util.FlxColor;

#if android
import extension.androidtools.Tools;
#end

#if (windows && !macro)
@:cppFileCode('
#include <windows.h>
#include <iostream>
#include <dwmapi.h>
#pragma comment(lib, "Dwmapi.lib")
')
#end
class NativeAPI {
	
	public static function allocConsole() {
		#if (windows && !macro)
		untyped __cpp__('
			AllocConsole();
			freopen("CONIN$", "r", stdin);
			freopen("CONOUT$", "w", stdout);
			freopen("CONOUT$", "w", stderr);
		');
		#elseif android
		// not doing it..
		#end
	}

	public static function getFileAttributesRaw(path:String, useAbsolute:Bool = true):Int {
		#if (windows && !macro)
		return untyped __cpp__('GetFileAttributesA({0}.c_str())', path);
		#else
		return -1;
		#end
	}

	public static function getFileAttributes(path:String, useAbsolute:Bool = true):FileAttributeWrapper {
		return new FileAttributeWrapper(getFileAttributesRaw(path, useAbsolute));
	}

	public static function setFileAttributes(path:String, attrib:OneOfThree<NativeAPI.FileAttribute, FileAttributeWrapper, Int>, useAbsolute:Bool = true):Int {
		#if (windows && !macro)
		var attrInt:Int = cast(attrib, Int);
		return untyped __cpp__('SetFileAttributesA({0}.c_str(), {1})', path, attrInt) ? 1 : 0;
		#else
		return 0;
		#end
	}

	public static function addFileAttributes(path:String, attrib:OneOfTwo<NativeAPI.FileAttribute, Int>, useAbsolute:Bool = true):Int {
		#if (windows && !macro)
		return setFileAttributes(path, getFileAttributesRaw(path, useAbsolute) | cast(attrib, Int), useAbsolute);
		#else
		return 0;
		#end
	}

	public static function removeFileAttributes(path:String, attrib:OneOfTwo<NativeAPI.FileAttribute, Int>, useAbsolute:Bool = true):Int {
		#if (windows && !macro)
		return setFileAttributes(path, getFileAttributesRaw(path, useAbsolute) & ~cast(attrib, Int), useAbsolute);
		#else
		return 0;
		#end
	}

	public static function setDarkMode(title:String, enable:Bool) {
		#if (windows && !macro)
		var val:Int = enable ? 1 : 0;
		untyped __cpp__('
			HWND window = GetActiveWindow();
			int darkVal = {0};
			DwmSetWindowAttribute(window, 20, &darkVal, sizeof(darkVal));
		', val);
		#end
	}

	public static function setWindowBorderColor(title:String, color:FlxColor, setHeader:Bool = true, setBorder:Bool = true) {
		#if (windows && !macro)
		var c:Int = (color.b << 16) | (color.g << 8) | color.r;
		untyped __cpp__('
			HWND window = GetActiveWindow();
			int colorVal = {0};
			if ({1}) DwmSetWindowAttribute(window, 35, &colorVal, sizeof(colorVal));
			if ({2}) DwmSetWindowAttribute(window, 34, &colorVal, sizeof(colorVal));
		', c, setHeader, setBorder);
		#end
	}

	public static function resetWindowBorderColor(title:String, setHeader:Bool = true, setBorder:Bool = true) {
		#if (windows && !macro)
		untyped __cpp__('
			HWND window = GetActiveWindow();
			int defaultColor = 0xFFFFFFFF;
			if ({0}) DwmSetWindowAttribute(window, 35, &defaultColor, sizeof(defaultColor));
			if ({1}) DwmSetWindowAttribute(window, 34, &defaultColor, sizeof(defaultColor));
		', setHeader, setBorder);
		#end
	}

	public static function setWindowTitleColor(title:String, color:FlxColor) {
		#if (windows && !macro)
		var c:Int = (color.b << 16) | (color.g << 8) | color.r; 
		untyped __cpp__('
			HWND window = GetActiveWindow();
			int colorVal = {0};
			DwmSetWindowAttribute(window, 36, &colorVal, sizeof(colorVal));
		', c);
		#end
	}

	public static function resetWindowTitleColor(title:String) {
		#if (windows && !macro)
		untyped __cpp__('
			HWND window = GetActiveWindow();
			int defaultColor = 0xFFFFFFFF; 
			DwmSetWindowAttribute(window, 36, &defaultColor, sizeof(defaultColor)); 
		');
		#end
	}

	public static function redrawWindowHeader() {
		#if desktop
		flixel.FlxG.stage.window.borderless = true;
		flixel.FlxG.stage.window.borderless = false;
		#end
	}

	public static function hasVersion(vers:String)
		return lime.system.System.platformLabel.toLowerCase().indexOf(vers.toLowerCase()) != -1;

	public static function showMessageBox(caption:String, message:String, buttonName:String = "OK", icon:MessageBoxIcon = MSG_WARNING)
{
    #if android
    extension.androidtools.Tools.showAlertDialog(caption, message, {name: buttonName, func: null});
    #elseif (windows && !macro)
    var iconInt:Int = cast(icon, Int);
    untyped __cpp__('MessageBoxA(GetActiveWindow(), {0}.c_str(), {1}.c_str(), {2})', message, caption, iconInt);
    #else
    lime.app.Application.current.window.alert(message, caption);
    #end
}
	
	public static function showToast(message:String)
	{
		#if android
		//extension.androidtools.Tools.showToast(message);
		#else
		//trace("Toast: " + message);
		#end
	}

	public static function setConsoleColors(foregroundColor:ConsoleColor = NONE, ?backgroundColor:ConsoleColor = NONE) {
		#if (sys && !android)
		Sys.print("\x1b[0m");
		if(foregroundColor != NONE)
			Sys.print("\x1b[" + Std.int(consoleColorToANSI(foregroundColor)) + "m");
		if(backgroundColor != NONE)
			Sys.print("\x1b[" + Std.int(consoleColorToANSI(backgroundColor) + 10) + "m");
		#end
	}

	public static function setCursorIcon(icon:CodeCursor) {
		#if desktop
		Mouse.cursor = icon.toOpenFL();
		#end
	}

	public static function consoleColorToANSI(color:ConsoleColor) {
		return switch(color) {
			case BLACK:			30;
			case DARKBLUE:		34;
			case DARKGREEN:		32;
			case DARKCYAN:		36;
			case DARKRED:		31;
			case DARKMAGENTA:	35;
			case DARKYELLOW:	33;
			case LIGHTGRAY:		37;
			case GRAY:			90;
			case BLUE:			94;
			case GREEN:			92;
			case CYAN:			96;
			case RED:			91;
			case MAGENTA:		95;
			case YELLOW:		93;
			case WHITE | _:		97;
		}
	}

	public static function consoleColorToOpenFL(color:ConsoleColor) {
		return switch(color) {
			case BLACK:			0xFF000000;
			case DARKBLUE:		0xFF000088;
			case DARKGREEN:		0xFF008800;
			case DARKCYAN:		0xFF008888;
			case DARKRED:		0xFF880000;
			case DARKMAGENTA:	0xFF880000;
			case DARKYELLOW:	0xFF888800;
			case LIGHTGRAY:		0xFFBBBBBB;
			case GRAY:			0xFF888888;
			case BLUE:			0xFF0000FF;
			case GREEN:			0xFF00FF00;
			case CYAN:			0xFF00FFFF;
			case RED:			0xFFFF0000;
			case MAGENTA:		0xFFFF00FF;
			case YELLOW:		0xFFFFFF00;
			case WHITE | _:		0xFFFFFFFF;
		}
	}
}

class FileAttributeWrapper {
	var value:Int;
	public function new(val:Int) {
		this.value = val;
	}
	public function getValue():Int {
		return value;
	}
}

enum abstract FileAttribute(Int) from Int to Int {
	var ARCHIVE = 0x20;
	var HIDDEN = 0x2;
	var NORMAL = 0x80;
	var NOT_CONTENT_INDEXED = 0x2000;
	var OFFLINE = 0x1000;
	var READONLY = 0x1;
	var SYSTEM = 0x4;
	var TEMPORARY = 0x100;
	var COMPRESSED = 0x800;
	var DEVICE = 0x40;
	var DIRECTORY = 0x10;
	var ENCRYPTED = 0x4000;
	var REPARSE_POINT = 0x400;
	var SPARSE_FILE = 0x200;
}

enum abstract ConsoleColor(Int) {
	var BLACK = 0;
	var DARKBLUE = 1;
	var DARKGREEN = 2;
	var DARKCYAN = 3;
	var DARKRED = 4;
	var DARKMAGENTA = 5;
	var DARKYELLOW = 6;
	var LIGHTGRAY = 7;
	var GRAY = 8;
	var BLUE = 9;
	var GREEN = 10;
	var CYAN = 11;
	var RED = 12;
	var MAGENTA = 13;
	var YELLOW = 14;
	var WHITE = 15;
	var NONE = -1;
}

enum abstract MessageBoxIcon(Int) {
	var MSG_ERROR = 0x00000010;
	var MSG_QUESTION = 0x00000020;
	var MSG_WARNING = 0x00000030;
	var MSG_INFORMATION = 0x00000040;
}

enum abstract CodeCursor(String) {
	var CUSTOM;
	var ARROW;
	var CLICK;
	var CROSSHAIR;
	var HAND;
	var IBEAM;
	var MOVE;
	var RESIZE_H;
	var RESIZE_V;
	var RESIZE_TL;
	var RESIZE_TR;
	var RESIZE_BL;
	var RESIZE_BR;
	var RESIZE_T;
	var RESIZE_B;
	var RESIZE_L;
	var RESIZE_R;
	var RESIZE_TLBR;
	var RESIZE_TRBL;
	var WAIT;
	var WAIT_ARROW;
	var DISABLED;
	var DRAG;
	var DRAG_OPEN;

	@:to public function toOpenFL():MouseCursor {
		return @:privateAccess switch(cast this) {
			case ARROW: MouseCursor.ARROW;
			case CROSSHAIR: MouseCursor.__CROSSHAIR;
			case CLICK: MouseCursor.BUTTON;
			case IBEAM: MouseCursor.IBEAM;
			case MOVE: MouseCursor.__MOVE;
			case HAND: MouseCursor.HAND;
			case DRAG: MouseCursor.HAND;
			case DRAG_OPEN: MouseCursor.ARROW; 
			case WAIT: MouseCursor.__WAIT;
			case WAIT_ARROW: MouseCursor.__WAIT_ARROW;
			case DISABLED: MouseCursor.ARROW;
			case RESIZE_TR: MouseCursor.__RESIZE_NESW;
			case RESIZE_BL: MouseCursor.__RESIZE_NESW;
			case RESIZE_TL: MouseCursor.__RESIZE_NWSE;
			case RESIZE_BR: MouseCursor.__RESIZE_NWSE;
			case RESIZE_H: MouseCursor.__RESIZE_WE;
			case RESIZE_V: MouseCursor.__RESIZE_NS;
			case RESIZE_T: MouseCursor.__RESIZE_NS;
			case RESIZE_B: MouseCursor.__RESIZE_NS;
			case RESIZE_L: MouseCursor.__RESIZE_WE;
			case RESIZE_R: MouseCursor.__RESIZE_WE;
			case RESIZE_TLBR: MouseCursor.__RESIZE_NWSE;
			case RESIZE_TRBL: MouseCursor.__RESIZE_NESW;
			case CUSTOM: MouseCursor.__CUSTOM;
		}
	}

	@:to public function toInt():Int {
		return switch(cast this) {
			case ARROW: 0;
			case CROSSHAIR: 1;
			case CLICK: 2;
			case IBEAM: 3;
			case MOVE: 4;
			case HAND: 5;
			case DRAG: 6;
			case DRAG_OPEN: 7;
			case WAIT: 8;
			case WAIT_ARROW: 9;
			case DISABLED: 10;
			case RESIZE_TR: 11;
			case RESIZE_BL: 12;
			case RESIZE_TL: 13;
			case RESIZE_BR: 14;
			case RESIZE_H: 15;
			case RESIZE_V: 16;
			case RESIZE_T: 17;
			case RESIZE_B: 18;
			case RESIZE_L: 19;
			case RESIZE_R: 20;
			case RESIZE_TLBR: 21;
			case RESIZE_TRBL: 22;
			case CUSTOM: -1;
		}
	}
}
