package util;

#if !macro
import openfl.geom.ColorTransform;

import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.util.FlxDestroyUtil;
import flixel.group.FlxGroup.FlxTypedGroup;

import backend.CoolUtil;
#end

import util.WindowsCMDUtil;

/** 
 * To use:
 * ```haxe
 * using util.StaticExtensions;
 * ```
 */
class StaticExtensions {
	#if !macro
	/** Shortcut of `FlxMath.roundDecimal` */
	public static function roundDecimal(n:Float, decimals:Int):Float return FlxMath.roundDecimal(n, decimals);
	/** Shortcut of `CoolUtil.floorDecimal` */
	public static function floorDecimal(n:Float, decimals:Int):Float return CoolUtil.floorDecimal(n, decimals);
	/** `0.2423` to `0.24` / `0.2453` => `0.25` */
	public static function toDouble(n:Float):Float return roundDecimal(n, 2);

	/**
	 * Changes size of game absolutely, i.e. without initial ratio
	 * 
	 * WARNING: Changes only game size, use `FlxG.resizeWindow` for resizing window BEFORE
	 */
	public static function resizeAbsolute(game:flixel.FlxGame, width:Int = 1280, height:Int = 720)
		backend.WindowUtil.resizeAbsolute(width, height);

	/** Clears array and returns `null` */
	public static function clearArray<T:Any>(array:Array<T>):Array<T> {
		array.splice(0, array.length);
		return array;
	}
	/** Destroys each object in array, clears it and then returns `null` */
	public static function destroyArray<T:IFlxDestroyable>(array:Array<T>):Array<T> {
		for (a in array) a.destroy();
		clearArray(array);
		return array;
	}
	/** Destroys each object in group, clears it and then returns `null` */
	public static function destroyGroup<T:FlxBasic>(group:FlxTypedGroup<T>):FlxTypedGroup<T> {
		for (g in group) g.destroy();
		group.clear();
		return group;
	}

	/** Useful when you need to disable antialiasing of object which initialized and added in one line, like this: `add(new FlxSprite().disableAntialiasing());` */
	public static function disableAntialiasing<T:FlxSprite>(spr:T):T {
		spr.antialiasing = false; return spr;
	}
	/** Useful when you need to set ID of object which initialized and added in one line, like this: `add(new FlxBasic().setID(3));` */
	public static function setID<T:FlxBasic>(spr:T, id:Int):T {
		spr.ID = id; return spr;
	}

	/**
	 * One-liner of setting `ColorTransform` offset vars
	 * @param red redOffset
	 * @param green greenOffset
	 * @param blue blueOffset
	 */
	public static function setOffset(c:ColorTransform, red:Float = 0, green:Float = 0, blue:Float = 0) {
		c.redOffset = red; c.greenOffset = green; c.blueOffset = blue;
	}

	/**
	 * One-liner of setting `ColorTransform` multiplier vars
	 * @param red redMultiplier
	 * @param green greenMultiplier
	 * @param blue blueMultiplier
	 */
	public static function setMultiplier(c:ColorTransform, red:Float = 1, green:Float = 1, blue:Float = 1) {
		c.redMultiplier = red; c.greenMultiplier = green; c.blueMultiplier = blue;
	}
	#end

	/** Shortcut of `FlxMath.roundDecimal` */
	public static function pow(n:Float, ?exp:Float = 2):Float return Math.pow(n, exp);
	/** Shortcut of `Std.parseInt()` (if `n` is `String`) or `Std.int` (if `n` is `Float`) or `bool ? 1 : 0` (if `n` is `Bool`) */
	public static function toInt(n:flixel.util.typeLimit.OneOfThree<String, Float, Bool>):Int { return n is Float ? Std.int(n) : (n is Bool ? (n ? 1 : 0) : Std.parseInt(n)); }
	/** Shortcut of `Std.parseFloat()` */
	public static function toFloat(n:String):Float return Std.parseFloat(n);
	/** Returns `true` if `str` is empty string or `null` */
	public static function isEmpty(str:flixel.util.typeLimit.OneOfTwo<String, Array<Dynamic>>, ?length:Int = 1):Bool return str != null ? Reflect.getProperty(str is String ? Reflect.callMethod(str, Reflect.getProperty(str, 'trim'), []) : str, 'length') < length : true;

	/** Formats this `str` as `format` in Windows cmd, on other platforms will return just `str` */
	public static function toCMD(str:String, format:CMDFormat) return WindowsCMDUtil.toCMD(str, format);
}