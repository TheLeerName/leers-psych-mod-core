package stages.notetypes;

class BaseNoteType extends BaseStageObject {
	var name:String;

	@:noCompletion var notesToChange:Array<Note> = [];
	public function new() {
		name = Type.getClassName(Type.getClass(this));
		name = name.substring(name.lastIndexOf('.') + 1);

		for (note in game.unspawnNotes) if (note.noteType == name)
			notesToChange.push(note);

		super();

		onCreate();
	}

	override function getLoadTraceFormat()
		return 'Loaded note type: ' + '%packagepath%'.toCMD(WHITE_BOLD) + ' (${notesToChange.length} found)'.toCMD(YELLOW);

	function setupNote(cb:Note->Void) {
		for (note in notesToChange)
			cb(note);
	}
}