#if !macro
//Discord API
import backend.Discord;

//Psych
#if LUA_ALLOWED
import llua.*;
import llua.Lua;
#end

#if ACHIEVEMENTS_ALLOWED
import backend.Achievements;
#end

#if tjson
import tjson.TJSON as Json;
#else
import haxe.Json;
#end

#if sys
import sys.*;
import sys.io.*;
#elseif js
import js.html.*;
#end

import backend.Paths;
import backend.Controls;
import backend.CoolUtil;
import backend.MusicBeatState;
import backend.MusicBeatSubstate;
import backend.CustomFadeTransition;
import backend.ClientPrefs;
import backend.Conductor;
import backend.Difficulty;
import backend.Mods;

import objects.Note;
import objects.Alphabet;
import objects.BGSprite;

import states.PlayState;

import stages.BaseStage.Countdown;

#if flxanimate
import flxanimate.*;
#end

//Flixel
import flixel.sound.FlxSound;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;

using shaders.Shaders;
import shaders.Shaders;
#end

using StringTools;
using backend.StaticExtensions;
import backend.StaticExtensions;