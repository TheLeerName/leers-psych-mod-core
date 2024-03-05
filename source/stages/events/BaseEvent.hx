package stages.events;

class BaseEvent extends BaseStageObject {
    var name:String;

	@:noCompletion var eventCount:Int;
    public function new() {
		name = Type.getClassName(Type.getClass(this));
		name = name.substring(name.lastIndexOf('.') + 1);
	
		for (e in game.eventNotes) if (e.event == name)
			eventCount++;

		super();

		onCreate();
	}

	override function getLoadTraceFormat()
		return 'Loaded event: ' + '%packagepath%'.toCMD(WHITE_BOLD) + ' ($eventCount found)'.toCMD(YELLOW);
}