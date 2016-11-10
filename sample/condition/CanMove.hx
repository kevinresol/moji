package condition;

import moji.Condition;
import data.*;
using tink.CoreApi;

class CanMove implements ConditionBase {
	
	var direction:Direction;
	var data:GameData;
	
	public function new(direction:Direction, data:GameData) {
		this.direction = direction;
		this.data = data;
	}
	
	public function determine():Future<Bool> {
		return Future.sync(switch direction {
			case Left: data.player.x > 0;
			case Right: data.player.x < data.boardSize - 1;
			case Up: data.player.y > 0;
			case Down: data.player.y < data.boardSize - 1;
		});
	}
}