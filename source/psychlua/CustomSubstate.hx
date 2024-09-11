package psychlua;

import flixel.FlxObject;

class CustomSubstate extends MusicBeatSubstate
{
	public static var name:String = 'unnamed';
	public static var instance:CustomSubstate;

	static var game(get, never):PlayState;
	static function get_game():PlayState return PlayState.instance;

	#if LUA_ALLOWED
	public static function implementLua(lua:FunkinLua)
	{
		lua.set("openCustomSubstate", openCustomSubstate);
		lua.set("closeCustomSubstate", closeCustomSubstate);
		lua.set("insertToCustomSubstate", insertToCustomSubstate);
	}
	#end
	
	public static function openCustomSubstate(name:String, ?pauseGame:Bool = false)
	{
		if(pauseGame)
		{
			FlxG.camera.followLerp = 0;
			game.persistentUpdate = false;
			game.persistentDraw = true;
			game.paused = true;
			if(FlxG.sound.music != null) {
				FlxG.sound.music.pause();
				game.vocals.pause();
			}
		}
		game.openSubState(new CustomSubstate(name));
		game.setOnHScript('customSubstate', instance);
		game.setOnHScript('customSubstateName', name);
	}

	public static function closeCustomSubstate()
	{
		if(instance != null)
		{
			game.closeSubState();
			instance = null;
			return true;
		}
		return false;
	}

	public static function insertToCustomSubstate(tag:String, ?pos:Int = -1)
	{
		if(instance != null)
		{
			var tagObject:FlxObject = cast (MusicBeatState.getVariables().get(tag), FlxObject);
			#if LUA_ALLOWED if(tagObject == null) tagObject = cast (MusicBeatState.getVariables().get(tag), FlxObject); #end

			if(tagObject != null)
			{
				if(pos < 0) instance.add(tagObject);
				else instance.insert(pos, tagObject);
				return true;
			}
		}
		return false;
	}

	override function create()
	{
		instance = this;

		game.callOnScripts('onCustomSubstateCreate', [name]);
		super.create();
		game.callOnScripts('onCustomSubstateCreatePost', [name]);
	}
	
	public function new(name:String)
	{
		CustomSubstate.name = name;
		super();
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}
	
	override function update(elapsed:Float)
	{
		game.callOnScripts('onCustomSubstateUpdate', [name, elapsed]);
		super.update(elapsed);
		game.callOnScripts('onCustomSubstateUpdatePost', [name, elapsed]);
	}

	override function destroy()
	{
		game.callOnScripts('onCustomSubstateDestroy', [name]);
		name = 'unnamed';

		game.setOnHScript('customSubstate', null);
		game.setOnHScript('customSubstateName', name);
		super.destroy();
	}
}
