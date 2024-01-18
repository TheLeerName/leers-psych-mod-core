package stages;

import stages.events.BaseEvent;
import stages.notetypes.BaseNoteType;

enum Countdown
{
	THREE;
	TWO;
	ONE;
	GO;
	START;
}

// IM TIRED FROM PLAYSTATE.HX 9000 LINES
// now without stupid buggy macro ehehe - Leer
@:allow(stages.objects.BaseStageObject)
@:allow(states.PlayState)
class BaseStage extends PlayState {
	var game(get, never):BaseStage;
	var isStoryMode(get, never):Bool;
	var seenCutscene(get, never):Bool;

	//Fix for the Chart Editor on Base Game stages
	function setDefaultGF(name:String) {
		var gfVersion:String = PlayState.SONG.gfVersion;
		if(gfVersion == null || gfVersion.length < 1) {
			gfVersion = name;
			PlayState.SONG.gfVersion = gfVersion;
		}
	}

	//start/end callback functions
	function setStartCallback(myfn:Void->Void) PlayState.instance.startCallback = myfn;
	function setEndCallback(myfn:Void->Void) PlayState.instance.endCallback = myfn;

	//precache functions
	function precacheImage(key:String) precache(key, 'image');
	function precacheSound(key:String) precache(key, 'sound');
	function precacheMusic(key:String) precache(key, 'music');

	function precache(key:String, type:String) {
		PlayState.instance.precacheList.set(key, type);
		switch(type) {
			case 'image': Paths.image(key);
			case 'sound': Paths.sound(key);
			case 'music': Paths.music(key);
		}
	}

	// init stuff
	function onCreate() {}
	function onStartCountdown() {} // set stopCountdown to true to stop it
	function onCountdownTick(tick:Countdown, counter:Int) {}
	function onCountdownStarted() {}
	function onSongStart() {}
	function onCreatePost() {}

	// event stuff
	function eventEarlyTrigger(event:String, value1:String, value2:String, strumTime:Float) {}
	function onEventPushed(event:String, value1:String, value2:String, strumTime:Float) {}
	function onEvent(event:String, value1:String, value2:String, strumTime:Float) {}

	// updatin stuff
	function onUpdate(elapsed:Float) {}
	function onUpdatePost(elapsed:Float) {}
	function preUpdateScore(miss:Bool) {}
	function onUpdateScore(miss:Bool) {}
	function onStepHit() {}
	function onBeatHit() {}
	function onSectionHit() {}
	function onRecalculateRating() {} // set stopRecalculateRating to true to stop it
	function onResume() {}
	function onPause() {} // set stopPause to true to stop it
	function onMoveCamera(char:String) {}

	// dialogue stuff
	function onNextDialogue(dialogueCount:Float) {}
	function onSkipDialogue(dialogueCount:Bool) {}

	// end stuff
	function onEndSong() {} // set stopEndSong to true to stop it
	function onGameOver() {} // set stopGameOver to true to stop it
	function onGameOverStart() {}
	function onGameOverConfirm(end:Bool) {}
	function onDestroy() {}

	// note pressing/missing stuff
	function onSpawnNote(note:Note) {}
	function onKeyPressPre(key:Int) {}
	function onKeyPress(key:Int) {}
	function onKeyReleasePre(key:Int) {}
	function onKeyRelease(key:Int) {}
	function opponentNoteHit(note:Note) {}
	function opponentNoteHitPost(note:Note) {}
	function goodNoteHit(note:Note) {}
	function goodNoteHitPost(note:Note) {}
	function onGhostTap(key:Int) {}
	function noteMissPress(noteData:Int) {}
	function noteMiss(note:Note) {}

	// useless functions but it need to be here cuz i using Reflect stuff in callStageFunction
	function onTimerCompleted(tag:String, loops:Int, loopsLeft:Int) {}
	function onTweenCompleted(tag:String) {}
	function onSoundFinished(tag:String) {}
	function onCustomSubstateCreate(name:String) {}
	function onCustomSubstateCreatePost(name:String) {}
	function onCustomSubstateUpdate(name:String, elapsed:Float) {}
	function onCustomSubstateUpdatePost(name:String, elapsed:Float) {}
	function onCustomSubstateDestroy(name:String) {}


	// backend shit
	static var instance:BaseStage;

	static var stageObjects:Array<BaseStageObject> = [];

	public function new() {
		super();
		instance = this;
	}

	static function initNoteType(noteType:String):BaseNoteType {
		var cl = Type.resolveClass('stages.notetypes.$noteType');
		return cl != null ? Type.createInstance(cl, []) : null;
	}

	static function initEvent(event:String):BaseEvent {
		var cl = Type.resolveClass('stages.events.$event');
		return cl != null ? Type.createInstance(cl, []) : null;
	}

	override function callStageFunction(event:String, args:Array<Dynamic>) {
		var stageFunc = Reflect.field(this, event);
		if (stageFunc != null) {
			for (obj in stageObjects) Reflect.callMethod(obj, Reflect.field(obj, event), args);
			Reflect.callMethod(this, stageFunc, args);
		}
		else trace('bro $event is null i cant call it!!!!');
	}

	inline function get_game():BaseStage return this;
	inline function get_isStoryMode():Bool return PlayState.isStoryMode;
	inline function get_seenCutscene():Bool return PlayState.seenCutscene;
}