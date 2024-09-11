# Leer's Psych Mod Core
Currently uses [Psych Engine 1.0-prerelease](https://github.com/ShadowMario/FNF-PsychEngine/tree/1f15374)

## Changes
- Changed building guide to be a MORE better
1. Uses libs from project.xml as hmm.json
2. Warns or throws error if your haxe is outdated
- Removed useless files like `assets/exclude` and things from `art`
- Libs uses only one specific version
- Fully rewritten Paths.hx
- `SHARED_DIRECTORY` define
- `assets/shared` moved to `assets`
- `manifest` folder fully eliminated on Windows
- Uses own [hxvlc 1.7.1](hxvlc), to get rid of `manifest` folder
- Rewritted method for getting dominant color in char editor health icon (GPU caching issues)
- Added some watches to debug menu in debug build
- Changed FPS Counter to display GPU memory usage
- CompileTime macro as mod version
- DISCORD_ALLOWED define
- changed discord rpc
- set specific ver of lime and openfl
- using my stage system instead psych 0.7+ / states.stages now in stages package
- CoolUtil.getPackagePath function
- using tjson.TJSON instead of haxe.Json
- support of loading .jpg images
- allow compilation and work without MODS_ALLOWED
- removed hxcpp-debug-server lib
- press F3 everywhere to see more info in fps counter
- GPUStats class
- Main.defines map
- allows drawing window border in dark mode
- has cool api for Windows things like: changing border/caption/text color, removing maximize/minimize buttons, see backend.native.Windows (will work only if player has windows 11 tho)
- improved `trace`: uses colors of cmd, prints time
- default audio device switch fix, also traces connected audio device, has some bugs in song but on restart of song all fine!
- you can access to `ClientPrefs.data` with `prefs` in states/substates/stages!
- you can access to `ClientPrefs.data.gameplaySettings` with `gameplayPrefs` in states/substates/stages!
- `Paths.imageReplacer` for your own loading screen things :)
- `"0.43434".toFloat()` thing, check out static extensions haxe in google
- `backend.WindowUtil` class
- antialiasing sets in all sprites by default, i.e. you dont need `sprite.antialiasing = ClientPrefs.data.antialiasing;` shit
- `Main.fpsVar.normalColor` / `Main.fpsVar.lowFPSColor`
- fixed `Warning : Potential typo detected (expected similar values are flixel.addons.ui.SortMethod.ID)` shit
- `shaders.Shaders.BaseEffect` class for simple adding shaders to source
- enables dark mode of window if it was enabled in system
- `Clear cache on song start` option in Graphics
- clears cache on switching to song
- `skipNextTransOut` / `skipNextTransIn` vars in states
- added description to all vars in `ClientPrefs.data` / `ClientPrefs.gameplaySettings`
- rewritten `ClientPrefs.gameplaySettings`: now you can use `ClientPrefs.gameplaySettings.scrollspeed`

### [BUILDING](setup/building.md)
- tl;dr - do `haxe setup.hxml`
- also u can use [this](COMPILE%20[DEV].bat) and [this](PE7.bat), but i dont recommend it lol - TheLeerName
- to show cached assets in cmd just do `lime test windows -debug -D TRACE_CACHED_ASSETS`
- to load song in game start just do `lime test windows -debug -DSONG=<song>`

## Known issues
- `[WARNING] Could not parse frame number of %nameSub% in frame named %name%` => try use full prefix name (before `0001` and etc) in animation.addByPrefix
- `Bind failed` => do in powershell: `Get-Process Powershell | Where-Object { $_.ID -ne $pid } | Stop-Process`
- `Type not found : openfl._internal.macros` => remove `export` folder and recompile again
- some of cpp errors => remove `export` folder and recompile again