package backend;

import haxe.Json;

import openfl.media.Sound;
import openfl.system.System;
import openfl.display.BitmapData;
import openfl.utils.Assets as OpenFlAssets;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;

import sys.io.File;
import sys.FileSystem;

using StringTools;

@:access(flixel.system.frontEnds.BitmapFrontEnd)
class Paths {
	/**
	 * Returns and caches `FlxGraphic` object from relative `key` path
	 * @see `imagePath(key:String):String`
	 */
	public static function image(key:String, ?allowGPU:Bool = true):FlxGraphic {
		var path = imagePath(key);

		var img = imageAbsolute(path);
		if (img == null)
			trace('oh no image $key returning null NOOOO');

		return img;
	}

	public static function sound(key:String) {
		var sound = returnSoundAbsolute(soundPath(key));
		return sound;
	}

	public static function music(key:String) {
		var sound = returnSoundAbsolute(musicPath(key));
		return sound;
	}

	public static function voices(song:String) {
		var path = path('songs/${formatToSongPath(song)}/Voices.$SOUND_EXT');
		var sound = returnSoundAbsolute(path);
		return sound;
	}

	public static function inst(song:String) {
		var path = path('songs/${formatToSongPath(song)}/Inst.$SOUND_EXT');
		var sound = returnSoundAbsolute(path);
		return sound;
	}

	inline public static function soundRandom(key:String, min:Int, max:Int):Sound {
		return sound(key + FlxG.random.int(min, max));
	}

	/**
	 * Returns `null` if not found
	 */
	public static function getTextFromFile(key:String, ?ignoreMods:Bool = false):String {
		var path = path(key, ignoreMods);
		return text(path);
	}

	public static function fileExists(key:String, ?ignoreMods:Bool = false) {
		var path = path(key, ignoreMods);
		return fileExistsAbsolute(path);
	}

	public static function getAtlas(key:String, ?allowGPU:Bool = true):FlxAtlasFrames {
		return Paths.fileExists('images/$key.xml') ? getSparrowAtlas(key) : getPackerAtlas(key);
	}

	public static function getSparrowAtlas(key:String):FlxAtlasFrames {
		var image = image(key);
		var xml = getTextFromFile('images/$key.xml');
		return FlxAtlasFrames.fromSparrow(image, xml);
	}

	public static function getPackerAtlas(key:String):FlxAtlasFrames {
		var image = image(key);
		var txt = getTextFromFile('images/$key.txt');
		return FlxAtlasFrames.fromSpriteSheetPacker(image, txt);
	}

	inline static public function txtPath(key:String)
		return path('data/$key.txt');
	inline static public function xmlPath(key:String)
		return path('data/$key.xml');
	inline static public function jsonPath(key:String)
		return path('data/$key.json');
	inline static public function luaPath(key:String)
		return path('$key.lua');
	inline public static function soundPath(key:String)
		return path('sounds/$key.$SOUND_EXT');
	inline public static function musicPath(key:String)
		return path('music/$key.$SOUND_EXT');
	inline public static function imagePath(key:String)
		return path('images/$key.$IMAGE_EXT');
	inline public static function font(key:String)
		return path('fonts/$key');
	inline public static function video(key:String)
		return path('videos/$key.$VIDEO_EXT');

	inline static public function formatToSongPath(path:String) {
		var invalidChars = ~/[~&\\;:<>#]/;
		var hideChars = ~/[.,'"%?!]/;

		var path = invalidChars.split(path.replace(' ', '-')).join("-");
		return hideChars.split(path).join("").toLowerCase();
	}

	#if SHARED_DIRECTORY
	/**
	 * Converts relative `key` path to absolute
	 * 
	 * For example key = `"flixel.txt"`, then it will return in exists-order:
	 * - `"mods/<Mods.currentModDirectory>/flixel.txt"`
	 * - `"mods/flixel.txt"`
	 * - `"assets/<currentLevel>/flixel.txt"`
	 * - `"assets/shared/flixel.txt"`
	 * - `"assets/flixel.txt"` (if others not found)
	 */
	#else
	/**
	 * Converts relative `key` path to absolute
	 * 
	 * For example key = `"flixel.txt"`, then it will return in exists-order:
	 * - `"mods/<Mods.currentModDirectory>/flixel.txt"`
	 * - `"mods/flixel.txt"`
	 * - `"assets/<currentLevel>/flixel.txt"`
	 * - `"assets/flixel.txt"` (if others not found)
	 */
	#end
	public static function path(file:String, ?ignoreMods:Bool = false):String {
		var levelPath:String = "";

		if (!ignoreMods) {
			levelPath = modsPath(Mods.currentModDirectory + '/' + file);
			if (Mods.currentModDirectory != null && fileExistsAbsolute(levelPath))
				return levelPath;

			levelPath = modsPath(file);
			if (fileExistsAbsolute(levelPath))
				return levelPath;
		}

		levelPath = preloadPath(currentLevel + '/' + file);
		if (currentLevel != null && fileExistsAbsolute(levelPath))
			return levelPath;

		#if SHARED_DIRECTORY
		levelPath = preloadPath(SHARED_DIRECTORY + '/' + file);
		if (fileExistsAbsolute(levelPath))
			return levelPath;
		#end

		return preloadPath(file);
	}

	/**
	 * Removes from memory specific `FlxGraphic` object
	 * 
	 * WARNING: can crash game if this graphic is used! Use `graph.useCount` variable to avoid this
	 */
	public static function removeFromMemory(graph:FlxGraphic) {
		var key = FlxG.bitmap.findKeyForBitmap(graph.bitmap);
		OpenFlAssets.cache.removeBitmapData(key);
		FlxG.bitmap._cache.remove(key);
		graph.destroy();
	}

	/**
	 * Clears memory from all assets
	 * 
	 * WARNING: can crash game if some of bitmaps are used!
	 * @see `clearUnusedMemory()`
	 */
	public static function clearStoredMemory() {
		for (key => graph in FlxG.bitmap._cache)
			if (graph != null)
				removeFromMemory(graph);

		for (key => sound in currentTrackedSounds)
			if (OpenFlAssets.cache.hasSound(key))
				OpenFlAssets.cache.removeSound(key);

		currentTrackedSounds.clear();

		System.gc();
	}

	/**
	 * Clears memory from unused assets
	 * 
	 * Currently cant clear unused sounds :(
	 * @return Count of cleared assets
	 */
	public static function clearUnusedMemory():Int {
		var count:Int = 0;
		for (key => graph in FlxG.bitmap._cache)
			if (graph != null && graph.useCount <= 0) {
				removeFromMemory(graph);
				count++;
			}

		System.gc();
		return count;
	}

	#if flxanimate
	public static function loadAnimateAtlas(spr:FlxAnimate, folderOrImg:Dynamic, spriteJson:Dynamic = null, animationJson:Dynamic = null)
	{
		var changedAnimJson = false;
		var changedAtlasJson = false;
		var changedImage = false;
		
		if(spriteJson != null)
		{
			changedAtlasJson = true;
			spriteJson = File.getContent(spriteJson);
		}

		if(animationJson != null) 
		{
			changedAnimJson = true;
			animationJson = File.getContent(animationJson);
		}

		// is folder or image path
		if(Std.isOfType(folderOrImg, String))
		{
			var originalPath:String = folderOrImg;
			for (i in 0...10)
			{
				var st:String = '$i';
				if(i == 0) st = '';

				if(!changedAtlasJson)
				{
					spriteJson = getTextFromFile('images/$originalPath/spritemap$st.json');
					if(spriteJson != null)
					{
						//trace('found Sprite Json');
						changedImage = true;
						changedAtlasJson = true;
						folderOrImg = Paths.image('$originalPath/spritemap$st');
						break;
					}
				}
				else if(Paths.fileExists('images/$originalPath/spritemap$st.png'))
				{
					//trace('found Sprite PNG');
					changedImage = true;
					folderOrImg = Paths.image('$originalPath/spritemap$st');
					break;
				}
			}

			if(!changedImage)
			{
				//trace('Changing folderOrImg to FlxGraphic');
				changedImage = true;
				folderOrImg = Paths.image(originalPath);
			}

			if(!changedAnimJson)
			{
				//trace('found Animation Json');
				changedAnimJson = true;
				animationJson = getTextFromFile('images/$originalPath/Animation.json');
			}
		}

		//trace(folderOrImg);
		//trace(spriteJson);
		//trace(animationJson);
		spr.loadAtlasEx(folderOrImg, spriteJson, animationJson);
	}

	/*private static function getContentFromFile(path:String):String
	{
		var onAssets:Bool = false;
		var path:String = Paths.getPath(path, TEXT, true);
		if(FileSystem.exists(path) || (onAssets = true && Assets.exists(path, TEXT)))
		{
			//trace('Found text: $path');
			return !onAssets ? File.getContent(path) : Assets.getText(path);
		}
		return null;
	}*/
	#end


	inline static var IMAGE_EXT = "png";
	inline static var SOUND_EXT = #if web "mp3" #else "ogg" #end;
	inline static var VIDEO_EXT = "mp4";

	inline static var ASSETS_DIRECTORY:String = "assets";
	#if SHARED_DIRECTORY
	inline static var SHARED_DIRECTORY:String = "shared";
	#end
	inline static var MODS_DIRECTORY:String = "mods";

	public static var currentLevel:String;

	public static function setCurrentLevel(lvl:String) {
		currentLevel = null;
		if (lvl != null && lvl.length > 0 #if SHARED_DIRECTORY && lvl != SHARED_DIRECTORY #end) {
			currentLevel = lvl;
			trace('Current asset folder: $currentLevel');
		}
	}

	public static var ignoreModFolders:Array<String> = [
		'characters',
		'custom_events',
		'custom_notetypes',
		'data',
		'songs',
		'music',
		'sounds',
		'shaders',
		'videos',
		'images',
		'stages',
		'weeks',
		'fonts',
		'scripts',
		'achievements'
	];

	public static var currentTrackedSounds:Map<String, Sound> = [];

	public static function returnSoundAbsolute(path:String):Sound {
		if (currentTrackedSounds.exists(path))
			return currentTrackedSounds.get(path);

		if (fileExistsAbsolute(path)) {
			var newSound = openflSound(path);
			OpenFlAssets.cache.setSound(path, newSound);
			currentTrackedSounds.set(path, newSound);
			return newSound;
		}

		trace('oh no sound $path returning null NOOOO');
		return openflSound('$ASSETS_DIRECTORY/sounds/error.ogg');
	}

	inline public static function preloadPath(file:String = '') {
		return '$ASSETS_DIRECTORY/$file';
	}

	inline public static function modsPath(file:String = '') {
		return '$MODS_DIRECTORY/$file';
	}

	public static function text(key:String) {
		if (FileSystem.exists(key))
			return File.getContent(key);
		if (OpenFlAssets.exists(key))
			return OpenFlAssets.getText(key);

		return null;
	}

	public static function imageAbsolute(path:String) {
		if (FlxG.bitmap._cache.exists(path))
			return FlxG.bitmap._cache.get(path);

		if (fileExistsAbsolute(path)) {
			var newBitmap:BitmapData = bitmapData(path);
			var newGraphic:FlxGraphic = FlxG.bitmap.add(newBitmap, false, path);
			newGraphic.persist = true;
			return newGraphic;
		}

		return null;
	}

	public static function bitmapData(key:String) {
		if (FileSystem.exists(key))
			return BitmapData.fromFile(key);
		if (OpenFlAssets.exists(key))
			return OpenFlAssets.getBitmapData(key, false);

		return null;
	}

	public static function openflSound(key:String):Sound {
		if (FileSystem.exists(key))
			return Sound.fromFile(key);
		if (OpenFlAssets.exists(key))
			return OpenFlAssets.getSound(key, false);

		return null;
	}

	public static function fileExistsAbsolute(key:String) {
		try {
			if(FileSystem.exists(key))
				return true;
			if(OpenFlAssets.exists(key))
				return true;
		}
		return false;
	}

	public static function readDirectory(path:String):Array<String>
		return fileExistsAbsolute(path) ? FileSystem.readDirectory(path) : [];

	public static function getAllFolders(?add:String = ''):Array<String> {
		var dirs:Array<String> = [
			#if MODS_ALLOWED
			Paths.modsPath(add),
			#end
			#if SHARED_DIRECTORY
			Paths.preloadPath(SHARED_DIRECTORY + '/' + add),
			#end
			Paths.preloadPath(add),
		];

		// adding specific folders
		if (currentLevel != null)
			dirs.push(Paths.preloadPath(currentLevel + '/' + add));
		#if MODS_ALLOWED
		if (Mods.currentModDirectory != null)
			dirs.push(Paths.modsPath(Mods.currentModDirectory + '/' + add));
		#end

		// adding global mods
		#if MODS_ALLOWED
		for (mod in Mods.parseList().enabled)
			dirs.push(Paths.modsPath(mod) + add);
		#end

		// removing nonexistent folders
		for (dir in dirs) if (!fileExistsAbsolute(dir.endsWith('/') ? dir.substring(0, dir.length - 1) : dir))
			dirs.remove(dir);

		return dirs;
	}

	public static function mergeAllTextsNamed(path:String, allowDuplicates:Bool = false) {
		var mergedList = [];
		for (file in Paths.getAllFolders()) {
			var list:Array<String> = CoolUtil.coolTextFile('$file/$path');
			for (value in list)
				if((allowDuplicates || !mergedList.contains(value)) && value.length > 0)
					mergedList.push(value);
		}
		return mergedList;
	}
}