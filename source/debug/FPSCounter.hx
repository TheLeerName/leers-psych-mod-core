package debug;

import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.system.System;

import flixel.FlxG;
import flixel.util.FlxStringUtil;

/**
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
**/
class FPSCounter extends TextField
{
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):Int;

	/**
		The current RAM usage (WARNING: this is NOT your total program memory usage, rather it shows the garbage collector memory)
	**/
	public var memoryMegas(get, never):Float;

	/**
	 * `%fps%` replaces as `currentFPS`, `%ram%` replaces as `memoryMegas`, `%gpu%` replaces as `GPUMemory.usage`.
	 * 
	 * WARNING: Resets to default on calling `resetTextFormat()`.
	 */
	public var textFormat:String;

	@:noCompletion private var times:Array<Float> = [];

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();

		this.x = x;
		this.y = y;

		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat("_sans", 14, color);
		autoSize = LEFT;
		multiline = true;
		text = "";

		GPUMemory.init();
		resetTextFormat();
	}

	var deltaTimeout:Float = 0.0;

	// Event Handlers
	private override function __enterFrame(deltaTime:Float):Void
	{
		if (deltaTimeout > 1000) {
			deltaTimeout = 0.0;
			return;
		}

		var now:Float = haxe.Timer.stamp();
		times.push(now);
		while (times[0] < now - 1000)
			times.shift();

		currentFPS = currentFPS < FlxG.updateFramerate ? times.length : FlxG.updateFramerate;		
		updateText();
		deltaTimeout += deltaTime;
	}

	/**
	 * Resets `textFormat` variable to default.
	 * 
	 * Also calls `updateText()`
	 */
	public dynamic function resetTextFormat() {
		var lines:Array<String> = [];
		#if windows
		if (ClientPrefs.data.showFPS)
			lines.push('FPS: %fps%');

		switch(ClientPrefs.data.memoryCounter) {
			case 'Show used':
				lines.push(ClientPrefs.data.cacheOnGPU ? 'GPU: %gpu%' : 'RAM: %ram%');
			case 'Show both':
				lines.push('RAM: %ram%');
				lines.push('GPU: %gpu%');
			case 'Show RAM':
				lines.push('RAM: %ram%');
			case 'Show GPU':
				lines.push('GPU: %gpu%');
		}
		#else
		if (ClientPrefs.data.showFPS) {
			lines.push('FPS: %fps%');
			lines.push('Memory: %ram%');
		}
		#end
		lines.push('v' + states.MainMenuState.modVersion);
		textFormat = lines.join('\n');
		updateText();
	}

	public dynamic function updateText():Void { // so people can override it in hscript
		text = textFormat
		.replace('%fps%', currentFPS + '')
		.replace('%ram%', FlxStringUtil.formatBytes(memoryMegas))
		.replace('%gpu%', FlxStringUtil.formatBytes(GPUMemory.usage));

		textColor = currentFPS < FlxG.drawFramerate * 0.5 ? 0xFFFF0000 : 0xFFFFFFFF;
	}

	inline function get_memoryMegas():Float
		return cast(System.totalMemory, UInt);
}
