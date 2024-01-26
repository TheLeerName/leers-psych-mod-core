package stages.objects;

/**
 * 1. For access to PlayState things u need do `game.` (in classes extended by BaseStage u can access to it directly)
 * 2. idk
 */
@:allow(stages.BaseStage)
class BaseStageObject {
	var game(get, never):BaseStage;

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
	function getLoadTraceFormat()
		return 'stage object loaded successfully: %packagepath%';

	public function new() {
		BaseStage.stageObjects.push(this);
		trace(getLoadTraceFormat().replace('%packagepath%', CoolUtil.getPackagePath(this)));
	}

	inline function get_game():BaseStage return BaseStage.instance;
}