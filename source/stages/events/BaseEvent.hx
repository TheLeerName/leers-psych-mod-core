package stages.events;

class BaseEvent extends BaseStageObject {
    var name:String;

    public function new() {
		name = Type.getClassName(Type.getClass(this));
		name = name.substring(name.lastIndexOf('.') + 1);

		super();

		onCreate();
	}

	override function getLoadTraceFormat()
		return 'event loaded successfully: %packagepath%';
}