package;

import haxe.Json;
import sys.FileSystem;
import sys.io.File;

typedef Library = {
	name:String, type:String,
	version:String, dir:String,
	ref:String, url:String
}

class Main {
	public static function main():Void {
		// brief explanation: first we parse a json containing the library names, data, and such
		final libs:Array<Library> = Json.parse(File.getContent('./hmm.json')).dependencies;

		#if windows
		Sys.command('color 0a');
		#end

		// now we loop through the data we currently have
		Sys.println('Installing dependencies.');
		for (data in libs) {
			// and install the libraries, based on their type
			switch (data.type) {
				case "install", "haxelib": // for libraries only available in the haxe package manager
					var version:String = data.version == null ? "" : data.version;
					Sys.command('haxelib --quiet install ${data.name} ${version}');
				case "git": // for libraries that contain git repositories
					var ref:String = data.ref == null ? "" : data.ref;
					Sys.command('haxelib --quiet git ${data.name} ${data.url} ${data.ref}');
				default: // and finally, throw an error if the library has no type
					Sys.println('[PSYCH ENGINE SETUP]: Unable to resolve library of type "${data.type}" for library "${data.name}"');
			}
		}

		#if windows
		if (!FileSystem.exists('./vs_Community.exe'))
			Sys.command('curl -# -O https://download.visualstudio.microsoft.com/download/pr/3105fcfe-e771-41d6-9a1c-fc971e7d03a7/8eb13958dc429a6e6f7e0d6704d43a55f18d02a253608351b6bf6723ffdaf24e/vs_Community.exe');
		Sys.command('vs_Community.exe --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows10SDK.19041 -p');
		#end

		Sys.println('Finished!');

		// after the loop, we can leave
		Sys.exit(0);
	}
}
