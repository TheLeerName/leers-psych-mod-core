package macros;

#if macro
import sys.io.File;
import sys.FileSystem;

class ModVersion {
	public static function add():Array<Field> {
		var curDate = Date.now();
		var ymd = DateTools.format(curDate, "%Y%m%d");
		var buildNumber:Int = 0;

		if (Context.getDefines().exists('no_console')) {
			var buildDir = #if debug 'export/debug/' #else 'export/release/' #end;
			if (!FileSystem.exists(buildDir))
				FileSystem.createDirectory(buildDir);

			var build = FileSystem.exists(buildDir + '.builddate') ? File.getContent(buildDir + '.builddate').split('\n') : [ymd, buildNumber + ''];

			buildNumber = Std.parseInt(build[1]) ?? 0;
			if (build[0] == ymd)
				buildNumber++;
			else {
				buildNumber = 0;
				build[0] = ymd;
			}

			File.saveContent(buildDir + '.builddate', build[0] + '\n' + buildNumber);

			// its like yearmonthday.build_number
			trace('$ymd.$buildNumber');
		}
		return MacroUtils.addString('modVersion', '$ymd.$buildNumber', 'public static');
	}
}
#end