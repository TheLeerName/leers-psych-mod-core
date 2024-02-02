package backend.native;

#if windows
// some functions from here: https://github.com/FNF-CNE-Devs/CodenameEngine
@:buildXml('
<target id="haxe">
	<lib name="dwmapi.lib" if="windows" />
</target>
')
@:cppFileCode('
	#include <iostream>
	#include <Windows.h>
	#include <dwmapi.h>
	#include <winuser.h>
')
class Windows {
	@:functionCode('return SystemParametersInfo(SPI_SETDESKWALLPAPER, 0, (void*)path.c_str(), SPIF_UPDATEINIFILE);')
	public static function changeWallpaper(path:String):Bool
		return false;

	/** Allows drawing window frame in dark mode, works on Windows 10 build 17763 or greater. */
	@:functionCode('
		int darkMode = enable ? 1 : 0;
		if (S_OK != DwmSetWindowAttribute(GetActiveWindow(), 19, &darkMode, sizeof(darkMode)))
			DwmSetWindowAttribute(GetActiveWindow(), 20, &darkMode, sizeof(darkMode));
	') public static function allowDarkMode(enable:Bool = true) {}


	/** Changes window border color, works on Windows 11 build 22000 or greater. */
	public static function setBorderColor(color:FlxColor) {
		untyped __cpp__('COLORREF clr = RGB({0}, {1}, {2})', color.red, color.green, color.blue);
		untyped __cpp__('DwmSetWindowAttribute(GetActiveWindow(), 34, &clr, sizeof(clr))');
	}
	/** Resets window border color, works on Windows 11 build 22000 or greater. */
	@:functionCode('
		COLORREF clr = 0xffffffff;
		DwmSetWindowAttribute(GetActiveWindow(), 34, &clr, sizeof(clr));
	') public static function resetBorderColor() {}
	/** Suppresses drawing window border, works on Windows 11 build 22000 or greater. */
	@:functionCode('
		COLORREF clr = 0xfffffffe;
		DwmSetWindowAttribute(GetActiveWindow(), 34, &clr, sizeof(clr));
	') public static function suppressBorderColor() {}


	/** Changes window border color, works on Windows 11 build 22000 or greater. */
	public static function setCaptionColor(color:FlxColor) {
		untyped __cpp__('COLORREF clr = RGB({0}, {1}, {2})', color.red, color.green, color.blue);
		untyped __cpp__('DwmSetWindowAttribute(GetActiveWindow(), 35, &clr, sizeof(clr))');
	}
	/** Resets window border color, works on Windows 11 build 22000 or greater. */
	@:functionCode('
		COLORREF clr = 0xffffffff;
		DwmSetWindowAttribute(GetActiveWindow(), 35, &clr, sizeof(clr));
	') public static function resetCaptionColor() {}


	/** Changes window border color, works on Windows 11 build 22000 or greater. */
	public static function setTextColor(color:FlxColor) {
		untyped __cpp__('COLORREF clr = RGB({0}, {1}, {2})', color.red, color.green, color.blue);
		untyped __cpp__('DwmSetWindowAttribute(GetActiveWindow(), 36, &clr, sizeof(clr))');
	}
	/** Resets window border color, works on Windows 11 build 22000 or greater. */
	@:functionCode('
		COLORREF clr = 0xffffffff;
		DwmSetWindowAttribute(GetActiveWindow(), 36, &clr, sizeof(clr));
	') public static function resetTextColor() {}


	@:functionCode('ShowWindow(GetActiveWindow(), value);')
	public static function showWindow(value:Int) {}

	@:functionCode('
		system("CLS");
		std::cout<< "" <<std::flush;
	')
	public static function clearScreen() {}
	
	public static function activate()
		throw "bro just crack it";
}
#end