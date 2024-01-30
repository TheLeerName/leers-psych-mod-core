package backend;

import openfl.media.Sound;
import openfl.system.System;
import openfl.display.BitmapData;
import openfl.utils.Assets as OpenFlAssets;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;

@:access(flixel.system.frontEnds.BitmapFrontEnd)
class Paths {
	/**
	 * Returns and caches `FlxGraphic` object from relative `key` path
	 * 
	 * Can get image with extension `.jpg`! If `.jpg` not found, then will try to get `.png`
	 * @see `imagePath(key:String):String`
	 * @see `imageAbsolute(path:String):FlxGraphic`
	 */
	public static function image(key:String):FlxGraphic {
		var path = imagePath(key);

		var img = imageAbsolute(path);
		if (img == null)
			trace('oh no image $key returning null NOOOO');

		return img;
	}

	public static function sound(key:String):Sound
		return returnSoundAbsolute(soundPath(key));
	public static function music(key:String):Sound
		return returnSoundAbsolute(musicPath(key));
	public static function voices(song:String, postfix:String = null):Sound
		return returnSoundAbsolute(voicesPath(song, postfix));
	public static function inst(song:String):Sound
		return returnSoundAbsolute(instPath(song));

	inline public static function soundRandom(key:String, min:Int, max:Int):Sound
		return sound(key + FlxG.random.int(min, max));

	/**
	 * Returns `null` if not found
	 */
	public static function getTextFromFile(key:String, ?ignoreMods:Bool = false):String
		return text(path(key, ignoreMods));
	public static function fileExists(key:String, ?ignoreMods:Bool = false):Bool
		return fileExistsAbsolute(path(key, ignoreMods));

	public static function getAtlas(key:String):FlxAtlasFrames {
		if (Paths.fileExists('images/$key.xml')) return getSparrowAtlas(key); 
		if (Paths.fileExists('images/$key.json')) return getAsepriteAtlas(key);
		return getPackerAtlas(key);
	}
	public static function getSparrowAtlas(key:String):FlxAtlasFrames
		return FlxAtlasFrames.fromSparrow(image(key), getTextFromFile('images/$key.xml'));
	public static function getAsepriteAtlas(key:String):FlxAtlasFrames
		return FlxAtlasFrames.fromTexturePackerJson(image(key), getTextFromFile('images/$key.json'));
	public static function getPackerAtlas(key:String):FlxAtlasFrames
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key), getTextFromFile('images/$key.txt'));

	/**
	 * Returns absolute image path from relative path `key`
	 * 
	 * Can return image path with extension `.jpg`! If `.jpg` not found, then will try to get `.png`
	 */
	inline public static function imagePath(key:String):String
		return Paths.fileExists('images/$key.jpg') ? path('images/$key.jpg') : path('images/$key.png');

	inline static public function txtPath(key:String):String
		return path('data/$key.txt');
	inline static public function xmlPath(key:String):String
		return path('data/$key.xml');
	inline static public function jsonPath(key:String):String
		return path('data/$key.json');
	inline static public function luaPath(key:String):String
		return path('$key.lua');

	inline public static function soundPath(key:String):String
		return path('sounds/$key.$SOUND_EXT');
	inline public static function musicPath(key:String):String
		return path('music/$key.$SOUND_EXT');
	inline public static function voicesPath(song:String, postfix:String = null):String
		return path('songs/${formatToSongPath(song)}/Voices' + (postfix == null ? '' : '-$postfix') + '.$SOUND_EXT');
	inline public static function instPath(song:String):String
		return path('songs/${formatToSongPath(song)}/Inst.$SOUND_EXT');

	inline public static function font(key:String):String
		return path('fonts/$key');
	inline public static function video(key:String):String
		return path('videos/$key.$VIDEO_EXT');

	inline static public function formatToSongPath(path:String):String {
		var invalidChars = ~/[~&\\;:<>#]/;
		var hideChars = ~/[.,'"%?!]/;

		var path = invalidChars.split(path.replace(' ', '-')).join("-");
		return hideChars.split(path).join("").toLowerCase();
	}

	/** Firstly trying to find Voices-Player.ogg, if not found returns Voices.ogg as openfl.media.Sound, if not found returns null */
	public static function getVoicesPlayer(songName:String, vocalsP:String):Sound {
		var path = voicesPath(songName, (vocalsP == null || vocalsP.length < 1) ? 'Player' : vocalsP);
		if (fileExistsAbsolute(path))
			return returnSoundAbsolute(path);

		path = voicesPath(songName);
		if (fileExistsAbsolute(path))
			return returnSoundAbsolute(path);
		return null;
	}

	/** * Firstly trying to find Voices-Opponent.ogg, if not found returns null */
	public static function getVoicesOpponent(songName:String, vocalsP:String):Sound {
		var path = voicesPath(songName, (vocalsP == null || vocalsP.length < 1) ? 'Opponent' : vocalsP);
		if (fileExistsAbsolute(path))
			return returnSoundAbsolute(path);
		return null;
	}

	/**
	 * Converts relative `key` path to absolute
	 * 
	 * For example key = `"flixel.txt"`, then it will return in exists-order:
	 * - `"mods/<Mods.currentModDirectory>/flixel.txt"` (if `MODS_ALLOWED`)
	 * - `"mods/flixel.txt"` (if `MODS_ALLOWED`)
	 * - `"assets/<currentLevel>/flixel.txt"`
	 * - `"assets/shared/flixel.txt"` (if `SHARED_DIRECTORY`)
	 * - `"assets/flixel.txt"`
	 */
	public static function path(file:String, ?ignoreMods:Bool = false):String {
		var levelPath:String = "";

		#if MODS_ALLOWED
		if (!ignoreMods) {
			levelPath = modsPath(Mods.currentModDirectory + '/' + file);
			if (Mods.currentModDirectory != null && fileExistsAbsolute(levelPath))
				return levelPath;

			levelPath = modsPath(file);
			if (fileExistsAbsolute(levelPath))
				return levelPath;
		}
		#end

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
			if (!dumpExclusions.contains(key) && graph != null)
				removeFromMemory(graph);

		for (key => sound in currentTrackedSounds)
			if (!dumpExclusions.contains(key) && OpenFlAssets.cache.hasSound(key))
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
			if (!dumpExclusions.contains(key) && graph != null && graph.useCount <= 0) {
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
			spriteJson = Paths.text(spriteJson);
		}

		if(animationJson != null) 
		{
			changedAnimJson = true;
			animationJson = Paths.text(animationJson);
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
				else if(fileExistsAbsolute(imagePath('$originalPath/spritemap$st')))
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
		if(#if sys FileSystem.exists(path) || #end (onAssets = true && Assets.exists(path, TEXT)))
		{
			//trace('Found text: $path');
			return !onAssets ? File.getContent(path) : Assets.getText(path);
		}
		return null;
	}*/
	#end

	public static var dumpExclusions:Array<String> = [
		'assets/music/freakyMenu.$SOUND_EXT'
	];

	//inline static var IMAGE_EXT = "png"; // not used cuz it can load jpg lol
	inline static var SOUND_EXT = #if web "mp3" #else "ogg" #end;
	inline static var VIDEO_EXT = "mp4";

	inline static var ASSETS_DIRECTORY:String = "assets";
	#if SHARED_DIRECTORY
	inline static var SHARED_DIRECTORY:String = "shared";
	#end
	#if MODS_ALLOWED
	inline static var MODS_DIRECTORY:String = "mods";
	#end

	public static var currentLevel:String;

	public static function setCurrentLevel(lvl:String) {
		currentLevel = null;
		if (lvl != null && lvl.length > 0 #if SHARED_DIRECTORY && lvl != SHARED_DIRECTORY #end) {
			currentLevel = lvl;
			trace('Current asset folder: $currentLevel');
		}
	}

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

	inline public static function preloadPath(file:String = ''):String
		return '$ASSETS_DIRECTORY/$file';
	inline public static function modsPath(file:String = ''):String
		return #if MODS_ALLOWED '$MODS_DIRECTORY/$file' #else preloadPath(file) #end;

	public static function text(key:String):String {
		#if sys
		if (FileSystem.exists(key))
			return File.getContent(key);
		#end
		if (OpenFlAssets.exists(key))
			return OpenFlAssets.getText(key);

		return null;
	}

	public static function imageAbsolute(path:String):FlxGraphic {
		if (FlxG.bitmap._cache.exists(path))
			return FlxG.bitmap._cache.get(path);

		if (fileExistsAbsolute(path)) {
			var bitmap = bitmapData(path);
			if (ClientPrefs.data.cacheOnGPU) {
				var texture = FlxG.stage.context3D.createRectangleTexture(bitmap.width, bitmap.height, BGRA, true);
				texture.uploadFromBitmapData(bitmap);
				bitmap.image.data = null;
				bitmap.dispose();
				bitmap.disposeImage();
				bitmap = BitmapData.fromTexture(texture);
			}
			var graphic = FlxG.bitmap.add(bitmap, false, path);
			graphic.persist = true;
			return graphic;
		}

		return null;
	}

	public static function bitmapData(key:String):BitmapData {
		#if sys
		if (FileSystem.exists(key))
			return BitmapData.fromFile(key);
		#end
		if (OpenFlAssets.exists(key))
			return OpenFlAssets.getBitmapData(key, false);

		return null;
	}

	public static function openflSound(key:String):Sound {
		#if sys
		if (FileSystem.exists(key))
			return Sound.fromFile(key);
		#end
		if (OpenFlAssets.exists(key))
			return OpenFlAssets.getSound(key, false);

		return null;
	}

	public static function fileExistsAbsolute(key:String):Bool {
		try {
			#if sys
			if(FileSystem.exists(key)) return true;
			#end
			if(OpenFlAssets.exists(key)) return true;
		}
		return false;
	}

	public static function readDirectory(path:String):Array<String>
		return #if sys fileExistsAbsolute(path) ? FileSystem.readDirectory(path) : #end [];

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

	public static function mergeAllTextsNamed(path:String, allowDuplicates:Bool = false):Array<String> {
		var mergedList = [];
		for (file in Paths.getAllFolders()) for (value in CoolUtil.coolTextFile(file + path))
			if((allowDuplicates || !mergedList.contains(value)) && value.length > 0)
				mergedList.push(value);
		return mergedList;
	}
}