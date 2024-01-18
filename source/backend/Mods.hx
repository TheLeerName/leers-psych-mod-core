package backend;

#if MODS_ALLOWED
typedef ModsList = {
	enabled:Array<String>,
	disabled:Array<String>,
	all:Array<String>
};

@:access(backend.Paths)
class Mods
{
	static public var currentModDirectory:String;
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

	private static var globalMods:Array<String> = [];

	inline public static function getGlobalMods()
		return globalMods;

	inline public static function pushGlobalMods() // prob a better way to do this but idc
	{
		globalMods = [];
		for(mod in parseList().enabled)
		{
			var pack:Dynamic = getPack(mod);
			if(pack != null && pack.runsGlobally) globalMods.push(mod);
		}
		return globalMods;
	}

	inline public static function getModDirectories():Array<String> {
		var list:Array<String> = [];
		if(Paths.fileExistsAbsolute(Paths.MODS_DIRECTORY)) {
			for (folder in Paths.readDirectory(Paths.MODS_DIRECTORY)) {
				var path = haxe.io.Path.join([Paths.MODS_DIRECTORY, folder]);
				if (sys.FileSystem.isDirectory(path) && !ignoreModFolders.contains(folder) && !list.contains(folder)) {
					list.push(folder);
				}
			}
		}
		return list;
	}

	public static function getPack(?folder:String = null):Dynamic
	{
		if(folder == null) folder = Mods.currentModDirectory;

		var path = Paths.modsPath(folder + '/pack.json');
		if (Paths.fileExistsAbsolute(path)) {
			try {
				var rawJson:String = Paths.text(path);
				if(rawJson != null && rawJson.length > 0) return Json.parse(rawJson);
			} catch(e:Dynamic) {
				trace(e);
			}
		}
		return null;
	}

	public static var updatedOnState:Bool = false;
	inline public static function parseList():ModsList {
		if(!updatedOnState) updateModList();
		var list:ModsList = {enabled: [], disabled: [], all: []};

		try {
			for (mod in CoolUtil.coolTextFile('modsList.txt'))
			{
				//trace('Mod: $mod');
				if(mod.trim().length < 1) continue;

				var dat = mod.split("|");
				list.all.push(dat[0]);
				if (dat[1] == "1")
					list.enabled.push(dat[0]);
				else
					list.disabled.push(dat[0]);
			}
		} catch(e) {
			trace(e);
		}
		return list;
	}
	
	private static function updateModList()
	{
		// Find all that are already ordered
		var list:Array<Array<Dynamic>> = [];
		var added:Array<String> = [];
		try {
			for (mod in CoolUtil.coolTextFile('modsList.txt'))
			{
				var dat:Array<String> = mod.split("|");
				var folder:String = dat[0];
				if(folder.trim().length > 0 && Paths.fileExistsAbsolute(Paths.modsPath(folder)) && FileSystem.isDirectory(Paths.modsPath(folder)) && !added.contains(folder))
				{
					added.push(folder);
					list.push([folder, (dat[1] == "1")]);
				}
			}
		} catch(e) {
			trace(e);
		}
		
		// Scan for folders that aren't on modsList.txt yet
		for (folder in getModDirectories())
		{
			if(folder.trim().length > 0 && Paths.fileExistsAbsolute(Paths.modsPath(folder)) && FileSystem.isDirectory(Paths.modsPath(folder)) &&
			!ignoreModFolders.contains(folder.toLowerCase()) && !added.contains(folder))
			{
				added.push(folder);
				list.push([folder, true]); //i like it false by default. -bb //Well, i like it True! -Shadow Mario (2022)
				//Shadow Mario (2023): What the fuck was bb thinking
			}
		}

		// Now save file
		var fileStr:String = '';
		for (values in list)
		{
			if(fileStr.length > 0) fileStr += '\n';
			fileStr += values[0] + '|' + (values[1] ? '1' : '0');
		}

		File.saveContent('modsList.txt', fileStr);
		updatedOnState = true;
		//trace('Saved modsList.txt');

	}

	public static function loadTopMod()
	{
		Mods.currentModDirectory = null;
		
		var list:Array<String> = Mods.parseList().enabled;
		if(list != null && list[0] != null)
			Mods.currentModDirectory = list[0];
	}
}
#end