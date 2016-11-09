package;

import moji.*;

class MoveEvent {
	var player:Position;
	var boardSize:Int;
	var engine:Engine;
	
	public function new(player, boardSize, engine) {
		this.player = player;
		this.boardSize = boardSize;
		this.engine = engine;
	}
	
	public function run() {
		engine.prompt({
			message: 'Choose a direction to move',
			answer: [
				canMove(Left).then(Some("Left"), None),
				canMove(Right).then(Some("Right"), None),
				canMove(Up).then(Some("Up"), None),
				canMove(Down).then(Some("Down"), None),
			]
		});
	}
	
	inline function canMove(direction)
		return new CanMove(direction, player, boardSize);
}