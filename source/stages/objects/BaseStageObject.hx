package stages.objects;

class BaseStageObject extends BaseStage {
	override function getLoadTraceFormat()
		return 'Loaded stage object: ' + '%packagepath%'.toCMD(WHITE_BOLD);

	public function new() {
		super();
		game.stageObjects.push(this);
	}
}