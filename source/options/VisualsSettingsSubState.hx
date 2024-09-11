package options;

import objects.Note;
import objects.StrumNote;

class VisualsSettingsSubState extends BaseOptionsMenu
{
	var noteOptionID:Int = -1;
	var notes:FlxTypedGroup<StrumNote>;
	var notesTween:Array<FlxTween> = [];
	var noteY:Float = 90;
	public function new()
	{
		title = Language.getPhrase('visuals_menu', 'Visuals Settings');
		rpcTitle = 'In the Visuals Settings Menu'; //for Discord Rich Presence

		// for note skins
		notes = new FlxTypedGroup<StrumNote>();
		for (i in 0...Note.colArray.length)
		{
			var note:StrumNote = new StrumNote(370 + (560 / Note.colArray.length) * i, -200, i, 0);
			note.centerOffsets();
			note.centerOrigin();
			note.playAnim('static');
			notes.add(note);
		}

		// options

		#if VIDEOS_ALLOWED
		var option:Option = new Option('Show Videos',
			"If checked, shows videos.",
			'showVideos',
			BOOL);
		addOption(option);
		#end

		var noteSkins:Array<String> = Paths.mergeAllTextsNamed('images/noteSkins/list.txt');
		if(noteSkins.length > 0)
		{
			if(!noteSkins.contains(prefs.noteSkin))
				prefs.noteSkin = ClientPrefs.defaultData.noteSkin; //Reset to default if saved noteskin couldnt be found

			noteSkins.insert(0, ClientPrefs.defaultData.noteSkin); //Default skin always comes first
			var option:Option = new Option('Note Skins:',
				"Select your prefered Note skin.",
				'noteSkin',
				STRING,
				noteSkins);
			addOption(option);
			option.onChange = onChangeNoteSkin;
			noteOptionID = optionsArray.length - 1;
		}

		/*var noteSplashes:Array<String> = Paths.mergeAllTextsNamed('images/noteSplashes/list.txt');
		if(noteSplashes.length > 0)
		{
			if(!noteSplashes.contains(prefs.splashSkin))
				prefs.splashSkin = ClientPrefs.defaultData.splashSkin; //Reset to default if saved splashskin couldnt be found

			noteSplashes.insert(0, ClientPrefs.defaultData.splashSkin); //Default skin always comes first
			var option:Option = new Option('Note Splashes:',
				"Select your prefered Note Splash variation or turn it off.",
				'splashSkin',
				STRING,
				noteSplashes);
			addOption(option);
		}*/

		var option:Option = new Option('Note Splash Opacity',
			'How much transparent should the Note Splashes be.\nAlso affects to Hold Splashes!',
			'splashAlpha',
			PERCENT);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);

        //have to do the american spelling ugh
		var option:Option = new Option('Colored Note Splashes',
			"If checked, Note Splashes will be colored with your notes.",
			'colSplashes',
			BOOL);
		addOption(option);

		var option:Option = new Option('Hold Cover for Opponent',
			"If checked, Hold Covers will appear for the opponent.",
			'holdCoverOpponent',
			BOOL);
		addOption(option);

		var option:Option = new Option('Hold Cover BPM Speed',
			"If checked, Hold Cover speed is based on BPM, rather than a set speed.",
			'holdCoverBpmSpeed',
			BOOL);
		addOption(option);

		var option:Option = new Option('Gore',
			"If unchecked, Gore will not be displayed.",
			'gore',
			BOOL);
		addOption(option);

		var option:Option = new Option('Hide HUD',
			'If checked, hides most HUD elements.',
			'hideHud',
			BOOL);
		addOption(option);
		
		var option:Option = new Option('Time Bar:',
			"What should the Time Bar display?",
			'timeBarType',
			STRING,
			['Time Left', 'Time Elapsed', 'Song Name', 'Disabled']);
		addOption(option);

		var option:Option = new Option('logo style:',
			"What should the logo be?",
			'logoState',
			STRING,
			['v1', /*'v1.5', 'v2','v2-beat-a-kid',*/ 'revisited','revisitedtroll']);
		addOption(option);
		option.onChange = changeMMusic;

		var option:Option = new Option('Flashing Lights',
			"Uncheck this if you're sensitive to flashing lights!",
			'flashing',
			BOOL);
		addOption(option);

		var option:Option = new Option('Camera Zooms',
			"If unchecked, the camera won't zoom in on a beat hit.",
			'camZooms',
			BOOL);
		addOption(option);

		var option:Option = new Option('Score Text Zoom on Hit',
			"If unchecked, disables the Score text zooming\neverytime you hit a note.",
			'scoreZoom',
			BOOL);
		addOption(option);

		var option:Option = new Option('Health Bar Opacity',
			'How much transparent should the health bar and icons be.',
			'healthBarAlpha',
			PERCENT);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);

		var option:Option = new Option('Note Size',
			'Notes size shit default is 70%',
			'noteSize',
			PERCENT);
		addOption(option);

		#if !mobile
		var option:Option = new Option('FPS Counter',
			'If unchecked, hides FPS Counter.',
			'showFPS',
			BOOL);
		option.onChange = Main.fpsVar.resetTextFormat;
		addOption(option);
		#end

		#if windows
		var option:Option = new Option('Memory Counter',
			"If unchecked, hides Memory Counter.",
			'memoryCounter',
			BOOL);
		option.onChange = Main.fpsVar.resetTextFormat;
		addOption(option);
		#end

		var option:Option = new Option('Pause Music:',
			"What song do you prefer for the Pause Screen?",
			'pauseMusic',
			STRING,
			['None', 'Tea Time', 'Breakfast']);
		addOption(option);
		option.onChange = onChangePauseMusic;

		#if DISCORD_ALLOWED
		var option:Option = new Option('Discord Rich Presence',
			"Uncheck this to prevent accidental leaks, it will hide the Application from your \"Playing\" box on Discord",
			'discordRPC',
			BOOL);
		option.onChange = onChangeDiscordRPC;
		addOption(option);
		#end

		var option:Option = new Option('Combo Stacking',
			"If unchecked, Ratings and Combo won't stack, saving on System Memory and making them easier to read",
			'comboStacking',
			BOOL);
		addOption(option);

		super();
		add(notes);
	}

	override function changeSelection(change:Int = 0)
	{
		super.changeSelection(change);
		
		if(noteOptionID < 0) return;

		for (i in 0...Note.colArray.length)
		{
			var note:StrumNote = notes.members[i];
			if(notesTween[i] != null) notesTween[i].cancel();
			if(curSelected == noteOptionID)
				notesTween[i] = FlxTween.tween(note, {y: noteY}, Math.abs(note.y / (200 + noteY)) / 3, {ease: FlxEase.quadInOut});
			else
				notesTween[i] = FlxTween.tween(note, {y: -200}, Math.abs(note.y / (200 + noteY)) / 3, {ease: FlxEase.quadInOut});
		}
	}

	var changedMusic:Bool = false;
	function onChangePauseMusic()
	{
		if(prefs.pauseMusic == 'None')
			FlxG.sound.music.volume = 0;
		else
			FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(prefs.pauseMusic)));

		changedMusic = true;
	}

	function changeMMusic()
		FlxG.sound.playMusic(Paths.music(Paths.getMenuMusic('MainMenu')));

	function onChangeNoteSkin()
	{
		notes.forEachAlive(function(note:StrumNote) {
			changeNoteSkin(note);
			note.centerOffsets();
			note.centerOrigin();
		});
	}

	function onChangeDiscordRPC()
		DiscordClient.check();

	function changeNoteSkin(note:StrumNote)
	{
		var skin:String = Note.defaultNoteSkin;
		var customSkin:String = skin + Note.getNoteSkinPostfix();
		if(Paths.existsAbsolute(Paths.imagePath(customSkin))) skin = customSkin;

		note.texture = skin; //Load texture and anims
		note.reloadNote();
		note.playAnim('static');
	}

	override function destroy() {
		if(changedMusic && !OptionsState.onPlayState) FlxG.sound.playMusic(Paths.music(Paths.getMenuMusic('MainMenu')), 1, true);
		super.destroy();
	}
}