# Leer's Psych Mod Core
Currently uses [Psych Engine 0.7.3](https://github.com/ShadowMario/FNF-PsychEngine/tree/0.7.3)

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
- Uses own [hxCodec 3.0.2](hxCodec), to get rid of `manifest` folder
- Rewritted method for getting dominant color in char editor health icon (GPU caching issues)
- Added some watches to debug menu in debug build
- Changed FPS Counter to display GPU memory usage
- CompileTime macro as mod version
- DISCORD_ALLOWED define
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
- has cool api for changing border/caption/text color of window, see backend.native.Windows (will work only if player has windows 11 tho)

### [BUILDING](setup/building.md)