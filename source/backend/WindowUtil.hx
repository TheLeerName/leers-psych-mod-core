package backend;

/** @author TheLeerName */
@:publicFields
class WindowUtil {
	/**
	 * Changes size of game absolutely, i.e. without initial ratio
	 * 
	 * WARNING: Changes only game size, use `FlxG.resizeWindow` for resizing window BEFORE
	 */
	@:access(flixel.FlxCamera)
	@:access(flixel.FlxGame)
	static function resizeAbsolute(width:Int = 1280, height:Int = 720) {
		var initSize = {x: FlxG.width, y: FlxG.height};

		Reflect.setProperty(FlxG, 'width', width); // haha suck ballz
		Reflect.setProperty(FlxG, 'initialWidth', width);
		Reflect.setProperty(FlxG, 'height', height);
		Reflect.setProperty(FlxG, 'initialHeight', height);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);
		for (cam in FlxG.cameras.list) {
			cam.setSize(FlxG.width, FlxG.height);
			cam.updateScrollRect();
		}
		FlxG.game.onResize(null);

		trace('Changed game size to ' + '${width}x${height}'.toCMD(WHITE_BOLD));
	}

	static function forceWindowMode(gameWidth:Int, gameHeight:Int) {
		if (FlxG.width == gameWidth && FlxG.height == gameHeight) return;
		wasFullscreen = FlxG.fullscreen;
		wasBounds = [FlxG.stage.window.width, FlxG.stage.window.height];

		FlxG.game.resizeAbsolute(gameWidth, gameHeight);
		if (wasFullscreen) {
			FlxG.fullscreen = false; // no fullscren >:(
			FlxG.resizeWindow(960, 720);
			// display-centering window
			FlxG.stage.window.x = Std.int((FlxG.stage.window.display.bounds.width - FlxG.stage.window.width) / 2);
			FlxG.stage.window.y = Std.int((FlxG.stage.window.display.bounds.height - FlxG.stage.window.height) / 2);
		} else {
			FlxG.resizeWindow(960, 720);
			// centering window by previous bounds
			FlxG.stage.window.x += Std.int((wasBounds[0] - FlxG.stage.window.width) / 2);
			FlxG.stage.window.y += Std.int((wasBounds[1] - FlxG.stage.window.height) / 2);
		}

		FlxG.stage.window.resizable = false;
		#if windows backend.native.Windows.removeMaximizeMinimizeButtons(); #end
		Main.fullscreenAllowed = false;
	}

	static function disableForceWindowMode() {
		FlxG.game.resizeAbsolute(); // reverting back game size
		MusicBeatState.getState().skipNextTransIn = true; // looks strange without it

		if (wasFullscreen)
			FlxG.fullscreen = true; // go back
		else {
			// centering window by previous bounds
			FlxG.stage.window.x -= Std.int((wasBounds[0] - FlxG.stage.window.width) / 2);
			FlxG.stage.window.y -= Std.int((wasBounds[1] - FlxG.stage.window.height) / 2);
		}
		FlxG.resizeWindow(wasBounds[0], wasBounds[1]);

		FlxG.stage.window.resizable = true;
		#if windows backend.native.Windows.addMaximizeMinimizeButtons(); #end
		Main.fullscreenAllowed = true;
		@:privateAccess FlxG.stage.application.__backend.toggleFullscreen = true; // needs to set it to true to allow next toggle
	}

	@:noCompletion private static var wasFullscreen:Bool;
	@:noCompletion private static var wasBounds:Array<Int>;
}