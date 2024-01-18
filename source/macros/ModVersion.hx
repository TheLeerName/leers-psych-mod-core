package macros;

#if macro
import sys.io.File;
import sys.FileSystem;

class ModVersion {
	public static function add():Array<Field> {
		var curDate = Date.now();
		var ymd = DateTools.format(curDate, "%Y%m%d");
		var buildDir = #if debug 'export/debug/' #else 'export/release/' #end;
		var buildNumber:Int = 1;
		if (FileSystem.exists(buildDir + '.build'))
			buildNumber = Std.parseInt(File.getContent(buildDir + '.build'));

		if (!FileSystem.exists(buildDir + '.builddate'))
			File.saveContent(buildDir + '.builddate', ymd + '');
		var buildDate = File.getContent(buildDir + '.builddate');
		if (buildDate != ymd) {
			File.saveContent(buildDir + '.build', '1');
			FileSystem.deleteFile(buildDir + '.builddate');
			buildNumber = 1;
		}

		// its like yearmonthday.build_number
		trace('$ymd.$buildNumber');
		return MacroUtils.addString('modVersion', '$ymd.$buildNumber', 'public static');
	}
}
#end