package stages;

import flixel.FlxBasic;
import flixel.FlxObject;

import objects.Character;

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
@:access(backend.MusicBeatState)
class BaseStage {
	var game(get, never):PlayState;

	var curBeat(get, never):Int;
	var curStep(get, never):Int;
	var curSection(get, never):Int;

	var controls(get, never):Controls;

	var paused(get, never):Bool;
	var songName(get, never):String;
	var isStoryMode(get, never):Bool;
	var seenCutscene(get, never):Bool;
	var inCutscene(get, set):Bool;
	var canPause(get, set):Bool;
	var members(get, never):Dynamic;

	var boyfriend(get, never):Character;
	var dad(get, never):Character;
	var gf(get, never):Character;
	var boyfriendGroup(get, never):FlxSpriteGroup;
	var dadGroup(get, never):FlxSpriteGroup;
	var gfGroup(get, never):FlxSpriteGroup;
	
	var camGame(get, never):FlxCamera;
	var camHUD(get, never):FlxCamera;
	var camOther(get, never):FlxCamera;

	var defaultCamZoom(get, set):Float;
	var camFollow(get, never):FlxObject;

	var stopCountdown(get, set):Bool;
	var stopRecalculateRating(get, set):Bool;
	var stopPause(get, set):Bool;
	var stopEndSong(get, set):Bool;
	var stopGameOver(get, set):Bool;

	function add(object:FlxBasic) game.add(object);
	function remove(object:FlxBasic) game.remove(object);
	function insert(position:Int, object:FlxBasic) game.insert(position, object);

	function addBehindGF(obj:FlxBasic) insert(members.indexOf(game.gfGroup), obj);
	function addBehindBF(obj:FlxBasic) insert(members.indexOf(game.boyfriendGroup), obj);
	function addBehindDad(obj:FlxBasic) insert(members.indexOf(game.dadGroup), obj);

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

	function startCountdown() return PlayState.instance.startCountdown();
	function endSong() return PlayState.instance.endSong();
	function moveCameraSection() moveCameraSection();
	function moveCamera(isDad:Bool) moveCamera(isDad);

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
		return 'stage loaded successfully: %packagepath%';

	public function new() {
		trace(getLoadTraceFormat().replace('%packagepath%', CoolUtil.getPackagePath(this).replace('stages.', '')));
	}

	inline function get_game():PlayState return PlayState.instance;

	inline function get_curBeat():Int return game.curBeat;
	inline function get_curStep():Int return game.curStep;
	inline function get_curSection():Int return game.curSection;

	inline function get_controls():Controls return Controls.instance;

	inline function get_paused() return game.paused;
	inline function get_songName() return game.songName;
	inline function get_isStoryMode() return PlayState.isStoryMode;
	inline function get_seenCutscene() return PlayState.seenCutscene;
	inline function get_inCutscene() return game.inCutscene;
	inline function set_inCutscene(value:Bool) return game.inCutscene = value;
	inline function get_canPause() return game.canPause;
	inline function set_canPause(value:Bool) return game.canPause = value;
	inline function get_members() return game.members;

	inline function get_boyfriend():Character return game.boyfriend;
	inline function get_dad():Character return game.dad;
	inline function get_gf():Character return game.gf;

	inline function get_boyfriendGroup():FlxSpriteGroup return game.boyfriendGroup;
	inline function get_dadGroup():FlxSpriteGroup return game.dadGroup;
	inline function get_gfGroup():FlxSpriteGroup return game.gfGroup;
	
	inline function get_camGame():FlxCamera return game.camGame;
	inline function get_camHUD():FlxCamera return game.camHUD;
	inline function get_camOther():FlxCamera return game.camOther;

	inline function get_defaultCamZoom():Float return game.defaultCamZoom;
	inline function set_defaultCamZoom(value:Float):Float return game.defaultCamZoom = value;
	inline function get_camFollow():FlxObject return game.camFollow;

	inline function get_stopCountdown():Bool return game.stopCountdown;
	inline function set_stopCountdown(v:Bool):Bool return game.stopCountdown = v;
	inline function get_stopRecalculateRating():Bool return game.stopRecalculateRating;
	inline function set_stopRecalculateRating(v:Bool):Bool return game.stopRecalculateRating = v;
	inline function get_stopPause():Bool return game.stopPause;
	inline function set_stopPause(v:Bool):Bool return game.stopPause = v;
	inline function get_stopEndSong():Bool return game.stopEndSong;
	inline function set_stopEndSong(v:Bool):Bool return game.stopEndSong = v;
	inline function get_stopGameOver():Bool return game.stopGameOver;
	inline function set_stopGameOver(v:Bool):Bool return game.stopGameOver = v;
}