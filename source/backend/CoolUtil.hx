package backend;

@:publicFields
class CoolUtil {
	static function quantize(f:Float, snap:Float):Float
		return Math.fround(f * snap) / snap;

	static function capitalize(text:String):String
		return text.charAt(0).toUpperCase() + text.substr(1).toLowerCase();

	inline static function coolTextFile(path:String):Array<String>
		return listFromString(Paths.text(path));

	static function colorFromString(colorStr:String):FlxColor {
		static var colorRegex:EReg = ~/[\t\n\r]/g;

		colorStr = colorRegex.replace(colorStr, '');

		if (colorStr.length == 6 || colorStr.length == 8)
			colorStr = '#$colorStr';

		return FlxColor.fromString(colorStr) ?? FlxColor.WHITE;
	}

	static function listFromString(string:String):Array<String>
		return string == null ? [] : string.trim().split('\n').map((i:String) -> {i.trim();});

	static function floorDecimal(value:Float, decimals:Int):Float {
		var mult:Float = 10.pow(decimals);
		return Math.ffloor(value * mult) / mult;
	}

	static function dominantColor(path:String):Int {
		var pixels:openfl.display.BitmapData = Paths.bitmapData(path);
		var countByColor:Map<Int, Int> = [];
		for (col in 0...pixels.width) {
			for (row in 0...pixels.height) {
				var i:Int = pixels.getPixel32(col, row);
				if (i != 0) {
					if (countByColor.exists(i)) {
						countByColor[i]++;
					} else if (countByColor[i] != -13520687) {
						countByColor[i] = 1;
					}
				}
			}
		}
		pixels.image.data = null;
		pixels.dispose();
		pixels.disposeImage();
		var maxCount = 0;
		var maxKey:Int = 0;
		countByColor[FlxColor.BLACK] = 0;
		for (key in countByColor.keys()) {
			if (countByColor[key] >= maxCount) {
				maxCount = countByColor[maxKey = key];
			}
		}
		countByColor.clear();
		return maxKey;
	}

	inline static function numberArray(max:Int, ?min:Int = 0):Array<Int>
		return [for (i in min...max) {i;}];

	inline static function browserLoad(site:String)
		#if linux
		Sys.command('/usr/bin/xdg-open', [site]);
		#else
		FlxG.openURL(site);
		#end

	static function openFolder(folder:String, ?absolute:Bool = false):Void {
		#if sys
		if (!absolute) folder = Sys.getCwd() + folder;
		folder = folder.replace('/', '\\');
		if (folder.endsWith('/')) folder.substr(0, folder.length - 1);
		var command:String = #if linux '/usr/bin/xdg-open' #else 'explorer.exe' #end;
		Sys.command(command, [folder]);
		trace('$command $folder');
		#else
		FlxG.error('Platform is not supported for CoolUtil.openFolder');
		#end
	}

	/**
		Helper Function to Fix Save Files for Flixel 5

		-- EDIT: [November 29, 2023] --

		this function is used to get the save path, period.
		since newer flixel versions are being enforced anyways.
		@crowplexus
	**/
	@:access(flixel.util.FlxSave.validate)
	static function getSavePath():String
		return '${FlxG.stage.application.meta.get('company')}/${flixel.util.FlxSave.validate(FlxG.stage.application.meta.get('file'))}';

	static function setTextBorderFromString(text:FlxText, border:String):Void {
		switch (border.toLowerCase().trim()) {
			case 'shadow':
				text.borderStyle = SHADOW;
			case 'outline':
				text.borderStyle = OUTLINE;
			case 'outline_fast', 'outlinefast':
				text.borderStyle = OUTLINE_FAST;
			default:
				text.borderStyle = NONE;
		}
	}

	/**
	 * Works like `FlxTween.color` and `FlxTween.tween`, but it can tween colors in every structure (`FlxTween.color` can work only with `FlxSprite`)
	 *
	 * @param	Object		The object containing the properties to tween.
	 * @param	Values		An object containing key/value pairs of properties and target values.
	 * @param	Duration	Duration of the tween in seconds.
	 * @param	Options		A structure with tween options.
	 * @return	The added `NumTween` object.
	 */
	static function tweenColor(Object:Dynamic, Values:Dynamic, ?Duration:Float = 1, ?Options:Null<TweenOptions>):flixel.tweens.misc.NumTween {
		var initValues = {};
		var fields = Reflect.fields(Values);
		for (field in fields)
			Reflect.setField(initValues, field, Reflect.getProperty(Object, field));

		return FlxTween.num(0, 1, Duration, Options, scale -> {
			for (field in fields)
				Reflect.setProperty(Object, field, FlxColor.interpolate(Reflect.field(initValues, field), Reflect.field(Values, field), scale));
		});
	}

	static function getClassNameWithoutPath(obj:Dynamic):String {
		var name = Type.getClassName(Type.getClass(obj));
		return name.substring(name.lastIndexOf('.') + 1);
	}

	static function getPackagePath(cl:Dynamic):String {
		if (!(cl is Class)) cl = cast (Type.getClass(cl), Class<Dynamic>);
		var typeof:String = cast Type.typeof(cl);
		return typeof.substring(typeof.indexOf('(') + 1, typeof.indexOf(')'));
	}

	static function prettierNotFoundException(e:haxe.Exception):String {
		var str:String = e.toString();
		return str.startsWith('[lime.utils.Assets]') ? 'Not found' : str;
	}

	static function changeVarLooped(arr:Array<Dynamic>, varr:String, value:Dynamic) {
		if (arr.isEmpty()) return;
		for (o in arr) {
			if (o == null) continue;

			if(Reflect.getProperty(o, varr) != null)
				Reflect.setProperty(o, varr, value);

			var meme = Reflect.getProperty(o, 'members');
			if (meme?.length > 0)
				changeVarLooped(meme, varr, value);
		}
	}
}
