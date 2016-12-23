package condition;

import data.*;

using moji.Moji;
using tink.CoreApi;

class CanMove implements ConditionObject {
	
	var direction:Direction;
	var data:GameData;
	
	public function new(direction:Direction, data:GameData) {
		this.direction = direction;
		this.data = data;
	}
	
	public function check():Future<Bool> {
		return Future.sync(switch direction {
			case Left: data.player.x > 0;
			case Right: data.player.x < data.boardSize - 1;
			case Up: data.player.y > 0;
			case Down: data.player.y < data.boardSize - 1;
		});
	}
}