package mobile.utils;

#if android
import extension.androidtools.content.Context;
import extension.androidtools.os.Build;
#end

import openfl.Assets;
import haxe.io.Bytes;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

import lime.system.System;
import haxe.io.Path;

using StringTools;

class Files
{
	public static function getAssetsDir():String
	{
		#if android
		if (extension.androidtools.os.VERSION.SDK_INT >= extension.androidtools.os.VERSION_CODES.R) 
		{
			return Context.getObbDir() + "/";
		} 
		else 
		{
			return Context.getExternalFilesDir() + "/";
		}
		#elseif ios
		return System.applicationStorageDirectory;
		#else
		return Sys.getCwd();
		#end
	}

	public static function getModsDir():String
	{
		#if android
		var dirs = Context.getExternalMediaDirs();
		if (dirs != null && dirs.length > 0) {
			return dirs[0] + "/";
		}
		return Context.getExternalFilesDir() + "/";
		#elseif ios
		return System.applicationStorageDirectory;
		#else
		return Sys.getCwd();
		#end
	}
	
	public static function init():Void
	{
		var assetsBase = Path.addTrailingSlash(getAssetsDir());
		var modsBase = Path.addTrailingSlash(getModsDir());

		trace("Assets target path: " + assetsBase);
		trace("Mods target path: " + modsBase);

		copyFolderOnce("assets", assetsBase + "assets/");
		copyFolderOnce("mods", modsBase + "mods/");
	}

	static function copyFolderOnce(folder:String, target:String):Void
	{
		#if sys
		if (FileSystem.exists(target))
		{
			trace(folder + " already exists, skipping.");
			return;
		}
		#end

		trace("Copying " + folder + "...");
		copyAssets(folder, target);
	}

	static function copyAssets(source:String, target:String):Void
	{
		var list = Assets.list();

		for (asset in list)
		{
			if (!asset.startsWith(source)) continue;

			var relative = asset.substr(source.length);
			if (relative.startsWith("/")) relative = relative.substr(1);

			var outPath = Path.addTrailingSlash(target) + relative;

			createDirRecursive(Path.directory(outPath));

			try {
				var bytes:Bytes = Assets.getBytes(asset);

				if (bytes != null)
					File.saveBytes(outPath, bytes);
				else
					File.saveContent(outPath, Assets.getText(asset));

			} catch (e:Dynamic) {
				trace("Failed: " + asset + " -> " + e);
			}
		}

		trace("Finished copying " + source);
	}

	static function createDirRecursive(path:String):Void
	{
		#if sys
		if (path == null || path == "") return;

		path = Path.normalize(path);

		if (!FileSystem.exists(path))
			FileSystem.createDirectory(path);
		#end
	}
}
