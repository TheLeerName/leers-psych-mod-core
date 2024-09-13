package backend;

import debug.GPUStats;
import haxe.Exception;
import haxe.CallStack;

import openfl.media.Sound;
import openfl.display.BitmapData;
import openfl.utils.Assets as OpenFlAssets;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;

#if sys
import sys.io.File;
import sys.FileSystem;
#end

@:access(Main)
@:access(openfl.display.BitmapData)
@:access(flixel.system.frontEnds.BitmapFrontEnd)
class Paths {
	inline public static function getMenuMusic(?name:String):String return 'freakyMenu';

	/** Contains `haxe.Exception` object which has last error occurred in some of methods in this class. Changes only if error was happened. */
	public static var lastError(default, null):Exception;

	public static function loadSong(songPath:String, vocalsP1:FlxSound, vocalsP2:FlxSound, vocalsP1Postfix:String, vocalsP2Postfix:String, ?printErrors:Bool = true, ?stackItem:StackItem):{inst:Bool, player:Bool, opponent:Bool} {
		stackItem = getStackItem(stackItem);
		var loaded = {inst: false, player: false, opponent: false};

		try {
			var path:String = instPath(songPath);
			if (path == null) throw CoolUtil.prettierNotFoundException(lastError);
			FlxG.sound.playMusic(soundAbsolute(path));
			loaded.inst = true;
		}
		catch(e) {
			callStackTrace(stackItem, 'Loading song audio "songs/$songPath/Inst.$SOUND_EXT" failed! '.toCMD(RED_BOLD) + e.toString().toCMD(RED));
			FlxG.sound.playMusic(Paths.openflSoundEmpty());
		}

		@:privateAccess vocalsP1.cleanup(true);
		@:privateAccess vocalsP2.cleanup(true);
		if (PlayState.SONG.needsVoices) {
			var postfix:String = vocalsP1Postfix.strNotEmpty() ? vocalsP1Postfix : 'Player';
			try {
				var path = Paths.voicesPath(songPath, postfix);
				if (path == null) throw CoolUtil.prettierNotFoundException(Paths.lastError);
				vocalsP1.loadEmbedded(Paths.soundAbsolute(path));
				loaded.player = true;
			}
			catch (e) {
				callStackTrace(stackItem, 'Loading song audio "songs/$songPath/Vocals-$postfix.$SOUND_EXT" failed! '.toCMD(RED_BOLD) + e.toString().toCMD(RED));
				try {
					var path = Paths.voicesPath(songPath);
					if (path == null) throw CoolUtil.prettierNotFoundException(Paths.lastError);
					vocalsP1.loadEmbedded(Paths.soundAbsolute(path));
					loaded.player = true;
				} catch (e)
					callStackTrace(stackItem, 'Loading song audio "songs/$songPath/Vocals.$SOUND_EXT" failed! '.toCMD(RED_BOLD) + e.toString().toCMD(RED));
			}

			postfix = vocalsP2Postfix.strNotEmpty() ? vocalsP2Postfix : 'Opponent';
			try {
				var path = Paths.voicesPath(songPath, postfix);
				if (path == null) throw CoolUtil.prettierNotFoundException(Paths.lastError);
				vocalsP2.loadEmbedded(Paths.soundAbsolute(path));
				loaded.opponent = true;
			} catch (e)
				callStackTrace(stackItem, 'Loading song audio "songs/$songPath/Vocals-$postfix.$SOUND_EXT" failed! '.toCMD(RED_BOLD) + e.toString().toCMD(RED));
		}

		return loaded;
	}

	/**
	 * Loads json file and parses it in haxe structure
	 * @param path **Absolute** file path
	 * @param errorName this name will be displayed in error message like: "Loading %errorName% failed! Not found"
	 * @return haxe structure or `null` if not found / parse error
	 */
	public static function loadJsonFromFile(path:String, ?errorName:String, ?stackItem:StackItem):Null<Dynamic> {
		stackItem = getStackItem(stackItem);
		errorName ??= path;

		var json = null;
		try {
			if (path == null) throw 'Not found';
			var rawJson = Paths.text(path);
			if (rawJson == null) throw CoolUtil.prettierNotFoundException(Paths.lastError);
			json = Json.parse(rawJson);
			if (json == null) throw Json.lastError;
		} catch(e)
			callStackTrace(stackItem, 'Loading $errorName failed! '.toCMD(RED_BOLD) + e.toString().toCMD(RED));
		return json;
	}

	/**
	 * Can get image with extension `.jpg`! If `.jpg` not found, then will try to get `.png`
	 * 
	 * @param key Relative path
	 * @return `FlxGraphic` object and caches it
	 * 
	 * @see `imagePath(key:String):String`
	 * @see `imageAbsolute(path:String):FlxGraphic`
	 */
	public static function image(key:String, ?stackItem:StackItem):FlxGraphic {
		stackItem = getStackItem(stackItem);
		var path:String = imagePath(key);
		return path != null ? imageAbsolute(path, stackItem) : ohNoAssetReturningNull(stackItem, 'image', key);
	}

	public static function sound(key:String, ?stackItem:StackItem):Sound {
		stackItem = getStackItem(stackItem);
		var path:String = soundPath(key);
		return path != null ? soundAbsolute(path, stackItem) : ohNoAssetReturningNull(stackItem, 'sound', key);
	}

	public static function music(key:String, ?stackItem:StackItem):Sound {
		stackItem = getStackItem(stackItem);
		var path:String = musicPath(key);
		return path != null ? soundAbsolute(path, stackItem) : ohNoAssetReturningNull(stackItem, 'music', key);
	}

	public static function voices(song:String, ?postfix:String, ?stackItem:StackItem):Sound {
		stackItem = getStackItem(stackItem);
		var path:String = voicesPath(song, postfix);
		return path != null ? soundAbsolute(path, stackItem) : ohNoAssetReturningNull(stackItem, 'voices', (song ?? 'undefined') + (postfix != null ? ' ($postfix)' : ''));
	}

	public static function inst(song:String, ?stackItem:StackItem):Sound {
		stackItem = getStackItem(stackItem);
		var path:String = instPath(song);
		return path != null ? soundAbsolute(path, stackItem) : ohNoAssetReturningNull(stackItem, 'inst', song);
	}

	inline public static function soundRandom(key:String, min:Int, max:Int):Sound
		return sound(key + FlxG.random.int(min, max));

	/** Returns `null` if not found */
	public static function getTextFromFile(key:String, ?ignoreMods:Bool = false):String
		return text(path(key, ignoreMods));
	public static function exists(key:String, ?ignoreMods:Bool = false):Bool
		return existsAbsolute(path(key, ignoreMods));

	public static function getAtlas(key:String):FlxAtlasFrames
		return Paths.exists('images/$key.xml') ? getSparrowAtlas(key) : (Paths.exists('images/$key.json') ? getAsepriteAtlas(key) : getPackerAtlas(key));
	public static function getSparrowAtlas(key:String, ?stackItem:StackItem):FlxAtlasFrames {
		stackItem = getStackItem(stackItem);
		return FlxAtlasFrames.fromSparrow(image(key, stackItem), getTextFromFile('images/$key.xml'));
	}
	public static function getPackerAtlas(key:String, ?stackItem:StackItem):FlxAtlasFrames {
		stackItem = getStackItem(stackItem);
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, stackItem), getTextFromFile('images/$key.txt'));
	}
	public static function getAsepriteAtlas(key:String, ?stackItem:StackItem):FlxAtlasFrames {
		stackItem = getStackItem(stackItem);
		return FlxAtlasFrames.fromTexturePackerJson(image(key, stackItem), getTextFromFile('images/$key.json'));
	}

	/**
	 * Returns absolute image path from relative path `key`
	 * 
	 * Can return image path with extension `.jpg`! If `.jpg` not found, then will try to get `.png`
	 */
	inline public static function imagePath(key:String):String
		return Paths.exists('images/$key.jpg') ? path('images/$key.jpg') : path('images/$key.png');

	inline static public function txtPath(key:String):String
		return path('data/$key.txt');
	inline static public function xmlPath(key:String):String
		return path('data/$key.xml');
	inline static public function jsonPath(key:String):String
		return path('data/$key.json');
	inline static public function iniPath(key:String):String
		return path('data/$key.ini');
	inline static public function luaPath(key:String):String
		return path('$key.lua');

	inline public static function soundPath(key:String):String
		return path('sounds/$key.$SOUND_EXT');
	inline public static function musicPath(key:String):String
		return path('music/$key.$SOUND_EXT');
	inline public static function voicesPath(songPath:String, ?postfix:String):String
		return path('songs/$songPath/Voices${postfix != null ? '-$postfix' : ''}.$SOUND_EXT');
	inline public static function instPath(songPath:String):String
		return path('songs/$songPath/Inst.$SOUND_EXT');

	inline public static function font(key:String):String
		return path('fonts/$key');
	#if VIDEOS_ALLOWED
	inline public static function video(key:String):String
		return path('videos/$key.$VIDEO_EXT');
	#end

	inline static public function formatToSongPath(path:String):String {
		final invalidChars = ~/[~&;:<>#\s]/g;
		final hideChars = ~/[.,'"%?!]/g;

		return hideChars.replace(invalidChars.replace(path, '-'), '').trim().toLowerCase();
	}

	/**
	 * Converts relative `key` path to absolute
	 * 
	 * WARNING: can return `null` if file not found
	 * 
	 * For example key = `"flixel.txt"`, then it will return in exists-order:
	 * - `"mods/<Mods.currentModDirectory>/flixel.txt"` (if `MODS_ALLOWED`)
	 * - `"mods/flixel.txt"` (if `MODS_ALLOWED`)
	 * - `"assets/<currentLevel>/flixel.txt"`
	 * - `"assets/shared/flixel.txt"` (if `SHARED_DIRECTORY`)
	 * - `"assets/flixel.txt"`
	 * 
	 * Also adds language prefix! For example: if language is pt-BR, `key` will be `translations/pt-BR/<key>`, if language is `en-US` then `key` will be not changed (if `TRANSLATIONS_ALLOWED`)
	 */
	public static function path(key:String, ?ignoreMods:Bool = false):Null<String> {
		var path:String = "";

		inline function checkPath(?folder:String):Null<String> {
			folder ??= '';

			#if TRANSLATIONS_ALLOWED
			path = folder + '/translations/' + Language.language + '/' + key;
			if (existsAbsolute(path))
				return path;
			#end
			path = folder + '/' + key;
			if (existsAbsolute(path))
				return path;

			return null;
		}

		#if MODS_ALLOWED
		if (!ignoreMods) {
			if (Mods.currentModDirectory != null) {
				path = checkPath(modsPath(Mods.currentModDirectory));
				if (path != null) return path;
			}

			path = checkPath(MODS_DIRECTORY);
			if (path != null) return path;
		}
		#end

		if (currentLevel != null) {
			path = checkPath(preloadPath(currentLevel));
			if (path != null) return path;
		}

		#if SHARED_DIRECTORY
		path = checkPath(preloadPath(SHARED_DIRECTORY));
		if (path != null) return path;
		#end

		return checkPath(ASSETS_DIRECTORY);
	}

	@:deprecated('Use dumpAsset instead')
	public static function removeFromMemory(graph:FlxGraphic)
		dumpAsset(FlxG.bitmap.findKeyForBitmap(graph.bitmap));

	/**
	 * Dumps from memory sound or image graphic
	 * 
	 * WARNING: can crash game if this graphic is used! Use `graph.useCount` variable to avoid this
	 */
	public static function dumpAsset(key:String) {
		if (key == null) return;

		if (currentTrackedSounds.remove(key)) {
			OpenFlAssets.cache.removeSound(key);
			currentTrackedSounds.remove(key);
		}

		var graph:FlxGraphic = FlxG.bitmap._cache.get(key);
		if (graph != null) {
			if (graph.bitmap?.__texture != null)
				graph.bitmap.__texture.dispose();
			OpenFlAssets.cache.removeBitmapData(key);
			FlxG.bitmap._cache.remove(key);
			currentTrackedImages.remove(key);
		}
	}

	/** Shortcut to call `openfl.system.System.gc()` */
	public static function gc()
		openfl.system.System.gc();

	/**
	 * Clears memory from all assets
	 * 
	 * WARNING: can crash game if some of bitmaps are used!
	 * @see `clearUnusedMemory(?_:Dynamic):Int`
	 */
	public static function clearStoredMemory(?_:Dynamic) {
		for (key in FlxG.bitmap._cache.keys()) dumpAsset(key);
		for (key in currentTrackedSounds.keys()) dumpAsset(key);
		gc();
	}

	/**
	 * Clears memory from unused assets
	 * 
	 * Currently cant clear unused sounds :(
	 * @return Count of cleared assets
	 */
	public static function clearUnusedMemory(?_:Dynamic):Int {
		var count:Int = 0;
		for (key => graph in FlxG.bitmap._cache) if (graph != null && graph.useCount <= 0) {
			dumpAsset(key);
			count++;
		}

		gc();
		return count;
	}

	#if flxanimate
	public static function loadAnimateAtlas(spr:FlxAnimate, folderOrImg:Dynamic, spriteJson:Dynamic = null, animationJson:Dynamic = null, ?stackItem:StackItem)
	{
		stackItem = getStackItem(stackItem);
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
						folderOrImg = Paths.image('$originalPath/spritemap$st', stackItem);
						break;
					}
				}
				else if(existsAbsolute(imagePath('$originalPath/spritemap$st')))
				{
					//trace('found Sprite PNG');
					changedImage = true;
					folderOrImg = Paths.image('$originalPath/spritemap$st', stackItem);
					break;
				}
			}

			if(!changedImage)
			{
				//trace('Changing folderOrImg to FlxGraphic');
				changedImage = true;
				folderOrImg = Paths.image(originalPath, stackItem);
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

	public static var imageReplacer:BitmapData;

	//inline static var IMAGE_EXT = "png"; // not used cuz it can load jpg lol
	inline static var SOUND_EXT = #if web "mp3" #else "ogg" #end;
	#if VIDEOS_ALLOWED
	inline static var VIDEO_EXT = "mp4";
	#end

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
			trace('Current asset folder:', currentLevel.toCMD(WHITE_BOLD));
		}
	}

	public static var currentTrackedImages:Array<String> = [];
	public static var currentTrackedSounds:Map<String, Sound> = [];

	public static function soundAbsolute(path:String, ?stackItem:StackItem):Sound {
		stackItem = getStackItem(stackItem);
		var cur = currentTrackedSounds.get(path);
		if (cur != null) return cur;

		if (existsAbsolute(path)) {
			var newSound = openflSound(path);
			OpenFlAssets.cache.setSound(path, newSound);
			currentTrackedSounds.set(path, newSound);
			#if TRACE_CACHED_ASSETS callStackTrace(stackItem, 'Cached sound: ' + path.toCMD(WHITE_BOLD)); #end
			return newSound;
		}

		ohNoAssetReturningNull(stackItem, 'sound', path);
		return openflSoundEmpty();
	}

	public static function getStackItem(?stackItem:StackItem):StackItem
		return stackItem ?? CallStack.callStack()[1];
	static function callStackTrace(stackItem:StackItem, str:String):Null<Any> {
		stackItem = getStackItem(stackItem);
		switch (stackItem) {
			case FilePos(s, file, line, column): Main.println(Main.startOfTrace(file, line) + str);
			default: trace(str);
		}
		return null;
	}
	inline static function ohNoAssetReturningNull(stackItem:StackItem, assetType:String, ?postfix:String):Null<Any>
		return callStackTrace(stackItem, 'oh no $assetType returning null NOOOO '.toCMD(RED_BOLD) + (postfix ?? 'undefined').toCMD(RED));

	inline public static function preloadPath(file:String = ''):String
		return '$ASSETS_DIRECTORY/$file';
	inline public static function modsPath(file:String = ''):String
		return #if MODS_ALLOWED '$MODS_DIRECTORY/$file' #else preloadPath(file) #end;

	public static function text(key:String):Null<String> {
		try {
			#if sys if (FileSystem.exists(key)) return File.getContent(key); #end
			return OpenFlAssets.getText(key);
		} catch(e) {
			lastError = e;
		}

		return null;
	}

	public static function imageAbsolute(path:String, ?stackItem:StackItem):FlxGraphic {
		stackItem = getStackItem(stackItem);
		var cur = FlxG.bitmap._cache.get(path);
		if (cur != null) return cur;

		if (existsAbsolute(path)) {
			var bitmap = imageReplacer != null ? imageReplacer : bitmapData(path);
			if (ClientPrefs.data.cacheOnGPU && bitmap.image != null #if windows && GPUStats.wasStarted && GPUStats.globalMemoryUsage / GPUStats.totalMemory < 0.75 #end) {
				bitmap.lock();
				if (bitmap.__texture == null) {
					bitmap.image.premultiplied = true;
					bitmap.getTexture(FlxG.stage.context3D);
				}
				bitmap.getSurface();
				bitmap.disposeImage();
				bitmap.image.data = null;
			}
			currentTrackedImages.push(path);
			var graphic = FlxGraphic.fromBitmapData(bitmap, false, path);
			graphic.persist = true;
			graphic.destroyOnNoUse = false;

			#if TRACE_CACHED_ASSETS callStackTrace(stackItem, 'Cached image: ' + path.toCMD(WHITE_BOLD)); #end
			return graphic;
		}

		return ohNoAssetReturningNull(stackItem, 'image', path);
	}

	public static function bitmapData(key:String):BitmapData {
		try {
			#if sys if (FileSystem.exists(key)) return BitmapData.fromFile(key); #end
			return OpenFlAssets.getBitmapData(key, false);
		} catch(e) {
			lastError = e;
		}

		return null;
	}

	public static function openflSoundEmpty():Sound
		return new Sound();

	public static function openflSound(key:String):Sound {
		try {
			#if sys if (FileSystem.exists(key)) return Sound.fromFile(key); #end
			return OpenFlAssets.getSound(key, false);
		} catch(e) {
			lastError = e;
		}

		return null;
	}

	public static function saveFile(path:String, content:String)
		return #if sys File.saveContent(path, content) #end;
	public static function deleteFile(path:String)
		return #if sys FileSystem.deleteFile(path) #end;
	public static function existsAbsolute(path:String):Bool
		return #if sys FileSystem.exists(path) || #end OpenFlAssets.exists(path);

	public static function createDirectory(path:String)
		return #if sys FileSystem.createDirectory(path) #end;
	public static function readDirectory(path:String):Array<String>
		return #if sys isDirectory(path) ? FileSystem.readDirectory(path) : #end [];
	public static function isDirectory(path:String):Bool
		return #if sys FileSystem.isDirectory(path) #else false #end;

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
		for (dir in dirs) if (!existsAbsolute(dir.endsWith('/') ? dir.substring(0, dir.length - 1) : dir))
			dirs.remove(dir);

		return dirs;
	}

	public static function mergeAllTextsNamed(path:String, allowDuplicates:Bool = false):Array<String> {
		var mergedList = [];
		for (file in Paths.getAllFolders()) for (value in CoolUtil.coolTextFile('$file/$path'))
			if((allowDuplicates || !mergedList.contains(value)) && value.length > 0)
				mergedList.push(value);
		return mergedList;
	}
}