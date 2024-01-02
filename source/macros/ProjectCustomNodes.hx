package macros;

#if macro
import sys.io.File;

class ProjectCustomNodes {
	public static function init() {
		var output:String = Compiler.getOutput();
		output = output.substring(0, output.lastIndexOf('/') + 1) + 'bin';

		function defined(el:Xml) {
			var v:Bool = true;
			if (el.get('unless') != null)
				v = !Context.defined(el.get('unless'));
			if (el.get('if') != null)
				v = Context.defined(el.get('if'));

			return v;
		}

		function no(elements:Iterator<Xml>) {
			for (el in elements) {
				switch(el.nodeName) {
					#if windows
					case 'assets_windows':
						if (!defined(el)) continue;
						var path:String = el.get('path');
						if (path == null) continue;

						var rename:String = el.get('rename');
						if (rename != null)
							rename = rename.length == 0 ? '' : '/$rename';
						else
							rename = '/' + path;

						Sys.command('robocopy "$path" "${output + rename}" /S /NP /NFL /NDL /NJH /NJS');
					#end
					case 'section':
						if (defined(el))
							no(el.elements());
				}
			}
		}

		var xml = Xml.parse(File.getContent('Project.xml'));
		no(xml.firstElement().elements());
	}
}
#end