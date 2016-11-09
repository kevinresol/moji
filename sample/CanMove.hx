package;

import moji.Condition;
using tink.CoreApi;

class CanMove implements ConditionBase {
	
	var direction:Direction;
	var player:Position;
	var boardSize:Int;
	
	public function new(direction:Direction, player:Position, boardSize:Int) {
		this.direction = direction;
		this.player = player;
		this.boardSize = boardSize;
	}
	
	public function check():Future<Bool> {
		return Future.sync(switch direction {
			case Left: player.x > 0;
			case Right: player.x < boardSize - 1;
			case Up: player.y > 0;
			case Down: player.y < boardSize - 1;
		});
	}
}