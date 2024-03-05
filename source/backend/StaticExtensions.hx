package backend;

/** @see https://gist.githubusercontent.com/mlocati/fdabcaeb8071d5c75a2d51712db24011/raw/b710612d6320df7e146508094e84b92b34c77d48/win10colors.cmd */ 
enum CMDFormat {
	BOLD;
	UNDERLINE;
	INVERSE;
	BLACK;
	RED;
	GREEN;
	YELLOW;
	BLUE;
	MAGENTA;
	CYAN;
	WHITE;
	BLACK_BOLD;
	RED_BOLD;
	GREEN_BOLD;
	YELLOW_BOLD;
	BLUE_BOLD;
	MAGENTA_BOLD;
	CYAN_BOLD;
	WHITE_BOLD;
	RESET;
}

class StaticExtensions {
	#if !macro
	/** Shortcut of `FlxMath.roundDecimal` */
	public static function roundDecimal(n:Float, decimals:Int):Float return FlxMath.roundDecimal(n, decimals);

	/**
	 * Changes size of game absolutely, i.e. without initial ratio
	 * 
	 * WARNING: Changes only game size, use `FlxG.resizeWindow` for resizing window BEFORE
	 */
	public static function resizeAbsolute(game:flixel.FlxGame, width:Int = 1280, height:Int = 720)
		backend.WindowUtil.resizeAbsolute(width, height);
	#end

	/** Shortcut of `Std.parseInt()` (if `n` is `String`) or `Std.int` (if `n` is `Float`) */
	public static function toInt(n:flixel.util.typeLimit.OneOfTwo<String, Float>):Int return n is Float ? Std.int(n) : Std.parseInt(n);
	/** Shortcut of `Std.parseFloat()` */
	public static function toFloat(n:String):Float return Std.parseFloat(n);

	/** Formats this `str` as `format` in Windows cmd, on other platforms will return just `str` */
	public static function toCMD(str:String, format:CMDFormat) {
		#if windows
		switch(format) {
			case BOLD:      return '[1m$str[0m';
			case UNDERLINE: return '[4m$str[0m';
			case INVERSE:   return '[7m$str[0m';

			case BLACK:   return '[30m$str[0m';
			case RED:     return '[31m$str[0m';
			case GREEN:   return '[32m$str[0m';
			case YELLOW:  return '[33m$str[0m';
			case BLUE:    return '[34m$str[0m';
			case MAGENTA: return '[35m$str[0m';
			case CYAN:    return '[36m$str[0m';
			case WHITE:   return '[37m$str[0m';

			case BLACK_BOLD:   return '[30m[1m$str[0m';
			case RED_BOLD:     return '[31m[1m$str[0m';
			case GREEN_BOLD:   return '[32m[1m$str[0m';
			case YELLOW_BOLD:  return '[33m[1m$str[0m';
			case BLUE_BOLD:    return '[34m[1m$str[0m';
			case MAGENTA_BOLD: return '[35m[1m$str[0m';
			case CYAN_BOLD:    return '[36m[1m$str[0m';
			case WHITE_BOLD:   return '[37m[1m$str[0m';

			default: return '[0m$str[0m';
		}
		#end
		return str;
	}
}