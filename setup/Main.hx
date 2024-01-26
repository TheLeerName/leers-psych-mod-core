package;

import sys.io.File;
import sys.FileSystem;

import Sys.command as cmd;
import Sys.println as log;

class Main {
	public static function main() {
		var win = Sys.systemName() == "Windows";

		if (win)
			cmd('color 0a');

		log('[Setup] Installing dependencies...');
		for (xml in Xml.parse(File.getContent("Project.xml")).firstElement().elements()) if (xml.nodeName == 'haxelib') {
			var name = xml.get('name');
			var version = xml.get('version') ?? '';
			switch(version) {
				case 'git':
					var url = xml.get('url');
					var branch = xml.get('branch') ?? '';
					log(' - $name:$branch');
					cmd('haxelib --quiet --always --skip-dependencies git $name $url $branch >nul 2>&1');
				default:
					log(' - $name:$version');
					cmd('haxelib --quiet --always --skip-dependencies install $name $version >nul 2>&1');
			}
		}

		log('[Setup] Running lime setup via haxelib...');
		cmd('haxelib --quiet --always --skip-dependencies run lime setup >nul 2>&1');

		if (win) {
			log('[Setup] Installing VS Community libraries...');
			if (!FileSystem.exists('vs_Community.exe'))
				cmd('curl.exe -s https://download.visualstudio.microsoft.com/download/pr/3105fcfe-e771-41d6-9a1c-fc971e7d03a7/8eb13958dc429a6e6f7e0d6704d43a55f18d02a253608351b6bf6723ffdaf24e/vs_Community.exe -O');
			cmd('vs_Community.exe --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows10SDK.19041 -p');
		}

		log('[Setup] Finished!');

		Sys.exit(0);
	}
}