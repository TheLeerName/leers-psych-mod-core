# Leer's Psych Mod Core
Currently uses Psych Engine 0.7.2h

# Changes
- Changed building guide to be better
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

## Builded on [Psych Engine 0.7.2h](https://github.com/ShadowMario/FNF-PsychEngine/tree/0.7.2h)

## Building
1. Install Haxe [4.3.2](https://haxe.org/download/version/4.3.2/) 
2. Run command: `haxe setup.hxml`
3. Profit!