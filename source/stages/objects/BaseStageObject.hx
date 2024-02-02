package stages.objects;

class BaseStageObject extends BaseStage {
	override function getLoadTraceFormat()
		return 'stage object loaded successfully: %packagepath%';

	public function new() {
		super();
		game.stageObjects.push(this);
	}
}