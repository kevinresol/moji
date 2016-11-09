package;

import moji.*;

using tink.CoreApi;

class MoveEvent implements Event {
	var engine:Engine<GameData>;
	var directions:Array<Direction> = [Left, Right, Up, Down];
	
	public function new(engine) {
		this.engine = engine;
	}
	
	public function run() {
		return engine.renderer.prompt(new Prompt(
			'Choose a direction to move (player: ${engine.data.player}, goal: ${engine.data.goal})',
			directions.map(function(d) return canMove(d).then(Some(d.getName()), None))
		)).map(function(i) {
			engine.data.player.move(directions[i]);
			return 1; // elapsed one step
		});
	}
	
	public function next():Future<Option<Event>>
		return Future.sync(engine.data.player == engine.data.goal ? None : Some(asEvent()));
		
	inline function asEvent():Event
		return this;
	
	inline function canMove(direction):Condition
		return new CanMove(direction, engine.data);
}