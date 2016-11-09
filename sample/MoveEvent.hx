package;

import moji.*;

using tink.CoreApi;

class MoveEvent implements Event {
	var engine:Engine;
	var player:Position;
	var goal:Position;
	var boardSize:Int;
	var directions:Array<Direction> = [Left, Right, Up, Down];
	
	public function new(engine, player, goal, boardSize) {
		this.engine = engine;
		this.player = player;
		this.goal = goal;
		this.boardSize = boardSize;
	}
	
	public function run() {
		return engine.renderer.prompt(new Prompt(
			'Choose a direction to move (player: $player, goal: $goal)',
			directions.map(function(d) return canMove(d).then(Some(d.getName()), None))
		)).map(function(i) {
			player.move(directions[i]);
			return 1; // elapsed one step
		});
	}
	
	public function next():Future<Option<Event>>
		return Future.sync(player == goal ? None : Some(asEvent()));
		
	inline function asEvent():Event
		return this;
	
	inline function canMove(direction):Condition
		return new CanMove(direction, player, boardSize);
}