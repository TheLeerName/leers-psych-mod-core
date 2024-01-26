package macros;

#if macro
class Defines {
	public static function add():Array<Field> {
		var fields = Context.getBuildFields();

		var a = Context.getDefines();
		for (noleaks in ['ANDROID-NDK-ROOT', 'ANDROID-SDK', 'ANDROID_NDK_ROOT', 'ANDROID_SDK', 'HXCODEC-DIR', 'HXCODEC_DIR', 'JAVA-HOME', 'JAVA_HOME'])
			a.remove(noleaks);
		var d = macro $v{a};
		fields.push({
			pos: Context.currentPos(),
			name: 'defines',
			kind: FVar(macro:Map<String, String>, d),
			access: [APublic, AStatic]
		});
		return fields;
	}
}
#end