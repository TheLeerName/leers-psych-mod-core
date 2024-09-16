# Leer's Psych Mod Core
- i guess now it works properly

## Built on [Psych Engine 1.0-prerelease](https://github.com/ShadowMario/FNF-PsychEngine/tree/1f15374)
### [CHANGES](setup/changes.md)
### [BUILDING](setup/building.md)
- tl;dr - upgrade haxe to 4.3 or higher and do `haxe setup.hxml`
- also u can use [this](COMPILE%20[DEV].bat) and [this](PE7.bat), but i dont recommend it lol - TheLeerName
- to show cached assets in cmd just do `lime test windows -debug -D TRACE_CACHED_ASSETS`
- to load song in game start just do `lime test windows -debug -DSONG=<song>`

## Known issues
- `[WARNING] Could not parse frame number of %nameSub% in frame named %name%` => try use full prefix name (before `0001` and etc) in animation.addByPrefix
- `Bind failed` => do in powershell: `Get-Process Powershell | Where-Object { $_.ID -ne $pid } | Stop-Process`
- `Type not found : openfl._internal.macros` => remove `export` folder and recompile again
- some of cpp errors => remove `export` folder and recompile again