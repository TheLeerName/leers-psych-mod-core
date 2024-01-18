package stages.notetypes;

class BaseNoteType extends BaseStageObject {
	var name:String;

	public function new() {
		name = Type.getClassName(Type.getClass(this));
		name = name.substring(name.lastIndexOf('.') + 1);

		super();

		onCreate();
	}

	override function getLoadTraceFormat()
		return 'note type loaded successfully: %packagepath%';

	function setupNote(cb:Note->Void) {
		for (note in game.unspawnNotes) if (note.noteType == name)
			cb(note);
	}
}