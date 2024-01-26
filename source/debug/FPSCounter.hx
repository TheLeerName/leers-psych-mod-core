package debug;

import openfl.system.System;
import openfl.text.TextField;
import openfl.text.TextFormat;

import flixel.FlxG;
import flixel.util.FlxStringUtil;

import states.MainMenuState;

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

		GPUStats.init();
		resetTextFormat();
	}

	var deltaTimeout:Float = 0.0;

	@:noCompletion var pressedF3(default, set):Bool = false;
	@:noCompletion inline function set_pressedF3(pressedF3:Bool):Bool {
		this.pressedF3 = pressedF3;
		resetTextFormat();
		return pressedF3;
	}

	// Event Handlers
	private override function __enterFrame(deltaTime:Float):Void
	{
		if (FlxG.keys.justPressed.F3) pressedF3 = !pressedF3;

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
		if (pressedF3)
			lines = [
				'%file% v%modVer% (%modVer%/%psychVer%)',
				'%fps% fps T: %maxFPS% %quality% %antialiasing%',
				'RAM: %ram% GPU: %gpuUsgMem% %caching%',
				'GPU: %gpuUsg%% (%gpuUsgGlobal%%) %shaders%',
				'',
				'XY: %mouseX% / %mouseY%',
				'',
				'haxe: %haxe%',
				'lime: %lime%',
				'openfl: %openfl%',
				'flixel: %flixel%',
				'flixel-ui: %flixel-ui%',
				'flixel-addons: %flixel-addons%',
				#if tjson
				'tjson: %tjson%',
				#end
				#if LUA_ALLOWED
				'linc_luajit: %linc_luajit%',
				'%lua%',
				'%luajit%',
				#end
				#if HSCRIPT_ALLOWED
				'SScript: %SScript%',
				#end
				#if VIDEOS_ALLOWED
				'hxCodec: %hxCodec%',
				#end
				#if DISCORD_ALLOWED
				'hxdiscord_rpc: %hxdiscord_rpc%',
				#end
				#if flxanimate
				'flxanimate: %flxanimate%'
				#end
			];
		else {
			if (ClientPrefs.data.showFPS)
				lines.push('FPS: %fps%');

			switch(ClientPrefs.data.memoryCounter) {
				case 'Show used':
					lines.push(ClientPrefs.data.cacheOnGPU ? 'GPU: %gpu%' : 'RAM: %gpuUsgMem%');
				case 'Show both':
					lines.push('RAM: %ram%');
					lines.push('GPU: %gpuUsgMem%');
				case 'Show RAM':
					lines.push('RAM: %ram%');
				case 'Show GPU':
					lines.push('GPU: %gpuUsgMem%');
			}
			lines.push('v' + states.MainMenuState.modVersion);
			lines.push('F3 to expand');
		}
		#else
		if (ClientPrefs.data.showFPS) {
			lines.push('FPS: %fps%');
			lines.push('Memory: %ram%');
		}
		#end

		textFormat = lines.join('\n');
		updateText();
	}

	public dynamic function updateText():Void { // so people can override it in hscript

		var d = Main.defines;
		var replaces = [
			'fps' => currentFPS + '',
			'ram' => FlxStringUtil.formatBytes(memoryMegas),
			#if windows
			'gpuUsgMem' => FlxStringUtil.formatBytes(GPUStats.memoryUsage),
			'file' => FlxG.stage.application.meta.get('file'),
			'modVer' => MainMenuState.modVersion,
			'psychVer' => MainMenuState.psychEngineVersion,
			'maxFPS' => ClientPrefs.data.framerate + '',
			'quality' => (ClientPrefs.data.lowQuality ? 'low' : 'high') + 'Quality',
			'antialiasing' => (ClientPrefs.data.antialiasing ? 'a' : 'noA') + 'ntialiasing',
			'shaders' => (ClientPrefs.data.shaders ? 's' : 'noS') + 'haders',
			'caching' => (ClientPrefs.data.cacheOnGPU ? 'gpu' : 'ram') + 'Caching',
			'gpuUsg' => Std.int(GPUStats.usage) + '',
			'gpuUsgGlobal' => Std.int(GPUStats.globalUsage) + '',
			'mouseX' => FlxG.mouse.screenX + '',
			'mouseY' => FlxG.mouse.screenY + '',
			'haxe' => d.get('haxe'),
			'lime' => d.get('lime'),
			'openfl' => d.get('openfl'),
			'flixel' => d.get('flixel'),
			'flixel-ui' => d.get('flixel-ui'),
			'flixel-addons' => d.get('flixel-addons'),
			#if tjson
			'tjson' => d.get('tjson'),
			#end
			#if LUA_ALLOWED
			'linc_luajit' => d.get('linc_luajit'),
			'lua' => llua.Lua.version(),
			'luajit' => llua.Lua.versionJIT(),
			#end
			#if HSCRIPT_ALLOWED
			'SScript' => d.get('SScript'),
			#end
			#if VIDEOS_ALLOWED
			'hxCodec' => d.get('hxCodec'),
			#end
			#if DISCORD_ALLOWED
			'hxdiscord_rpc' => d.get('hxdiscord_rpc'),
			#end
			#if flxanimate
			'flxanimate' => d.get('flxanimate'),
			#end
			#end
		];

		text = textFormat;
		for (f => r in replaces) text = text.replace('%$f%', r);

		textColor = (currentFPS < FlxG.drawFramerate * 0.5 && !pressedF3) ? 0xFFFF0000 : 0xFFFFFFFF;
	}

	inline function get_memoryMegas():Float
		return cast(System.totalMemory, UInt);
}
