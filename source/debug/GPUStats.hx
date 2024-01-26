package debug;

import lime.app.Future;

/**
 * To start tracking GPU stats, call `init()` function.
 * 
 * Works only on Windows target.
 * @author TheLeerName
 */
#if windows
@:cppInclude('windows.h')
#end
@:publicFields
class GPUStats {
	/** Current dedicated GPU memory usage of this application. */
	static var memoryUsage(default, null):Int;

	// goes unused for now
	//static var globalMemoryUsage(get, never):Int;

	/** Current GPU utilization percentage of this application. */
	static var usage(default, null):Float;
	/** Current GPU utilization percentage of all applications on PC. */
	static var globalUsage(default, null):Float;

	/** Will be called on update of variables. Usually called each second. */
	static var onUpdate:Void->Void = () -> {};

	/** `true` if GPU stats tracking is running. */
	static var wasStarted:Bool = false;

	/**
	 * Starts tracking GPU stats, can be gotten with static variables in this class.
	 * 
	 * @return `1` if successfully initialized.
	 */
	static function init():Int {
		#if windows
		wasStarted = true;

		// very cool thing!!!
		// https://stackoverflow.com/a/73496338
		var pid = Std.string(untyped __cpp__('GetCurrentProcessId()'));
		new FlxTimer().start(FlxG.elapsed, tmr -> {
			new Future(() -> {
				var tr = new Process('powershell', ['((Get-Counter -Counter @("\\GPU Process Memory(pid_$pid*)\\Dedicated Usage", "\\GPU Engine(pid_$pid*engtype_3d)\\Utilization Percentage", "\\GPU Engine(*engtype_3D)\\Utilization Percentage")).CounterSamples | where CookedValue).CookedValue']);

				var err:String = tr.stderr.readAll().toString();
				if (err.length > 0) {
					err = err.substring(err.indexOf('CategoryInfo          : ') + 24);
					err = err.substring(0, err.indexOf('\r\n'));
					trace('GPU stats tracking failed');
					trace(err);
					wasStarted = false;
					return;
				}

				var num:Array<String> = tr.stdout.readAll().toString().replace(',', '.').split('\r\n');
				var sum:Float = 0;

				for (i in 1...num.length - 1)
					sum += Std.parseFloat(num[i]);

				memoryUsage = Std.parseInt(num[0]);
				usage = Std.parseInt(num[1]);
				globalUsage = sum;

				onUpdate();

				if (wasStarted) tmr.reset();
			}, true);
		});

		trace('GPU stats tracking started');
		return 1;
		#end
		return 0;
	}

	/**
	 * Terminates tracking GPU stats.
	 */
	static function close() {
		if (!wasStarted) return;
		trace('GPU stats tracking stopped');
		wasStarted = false;
	}
}