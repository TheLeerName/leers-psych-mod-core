package objects;

#if VIDEOS_ALLOWED
import flixel.graphics.FlxGraphic;

import hxvlc.openfl.Video;
import hxvlc.externs.Types;
import hxvlc.util.macros.Define;
import hxvlc.flixel.FlxVideoSprite;

import backend.Controls;

/**
 * Videos with this class could be skipped by pressing ACCEPT!
 * 
 * Recommended to use this class instead of `FlxVideoSprite` for this mod!
 */
class FunkinVideo extends FlxVideoSprite {

	/**
	 * Creates a `FunkinVideo` at a specified position.
	 *
	 * @param x The initial X position of the sprite.
	 * @param y The initial Y position of the sprite.
	 */
	public function new() {
		super();

		bitmap.onOpening.removeAll();
		bitmap.onOpening.add(onOpening);

		bitmap.onFormatSetup.removeAll();
		bitmap.onFormatSetup.add(onFormatSetup);

		camera = FlxG.cameras.list[FlxG.cameras.list.length - 1];
		FlxG.state.add(this);
	}

	function onOpening() {
		bitmap.role = LibVLC_Role_Game;

		#if FLX_SOUND_SYSTEM
		if (autoVolumeHandle)
			setVolume((FlxG.sound.muted ? 0 : 1) * FlxG.sound.volume);
		#end
	}

	function onFormatSetup() {
		if (bitmap?.bitmapData != null) {
			loadGraphic(FlxGraphic.fromBitmapData(bitmap.bitmapData, false, null, false));

			final scale:Float = Math.min(FlxG.width / bitmap.bitmapData.width, FlxG.height / bitmap.bitmapData.height);

			setGraphicSize(bitmap.bitmapData.width * scale, bitmap.bitmapData.height * scale);
			updateHitbox();
			screenCenter();
		}
	}

	#if FLX_SOUND_SYSTEM
	/** @param volume From 0.0 to 1.0 */
	function setVolume(volume:Float) {
		if (bitmap != null) bitmap.volume = Math.floor(FlxMath.bound(volume * Define.getFloat('HXVLC_FLIXEL_VOLUME_MULTIPLIER', 100), 0, 100));
	}
	#end

	override function update(elapsed:Float) {
		if (Controls.instance.ACCEPT)
			bitmap.time = bitmap.length; // to properly dispatch onEndReached: event used in psych engine as event when video finished

		#if FLX_SOUND_SYSTEM
		var s = autoVolumeHandle;
		autoVolumeHandle = false;
		#end
		super.update(elapsed);
		#if FLX_SOUND_SYSTEM
		autoVolumeHandle = s;

		if (autoVolumeHandle)
			setVolume((FlxG.sound.muted ? 0 : 1) * FlxG.sound.volume);
		#end
	}
}
#else
class FunkinVideo {}
#end