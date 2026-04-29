package mobile.utils;

#if android
import extension.androidtools.content.Context;
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
	public static var useObbDir:Bool = false;

	public static function getBase():String
	{
		#if android
		if (useObbDir) 
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

	public static function init(useObb:Bool = false):Void  
	{  
		useObbDir = useObb; 
		
		var base = getBase();  
		base = Path.addTrailingSlash(base);  

		trace("Base path: " + base);  

		copyFolderOnce("assets", base + "files/");  
		copyFolderOnce("mods", base + "media/");  
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
