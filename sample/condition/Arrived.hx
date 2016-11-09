package condition;

import moji.Condition;
using tink.CoreApi;

class Arrived implements ConditionBase {
	
	var data:GameData;
	
	public function new(data:GameData) {
		this.data = data;
	}
	
	public function determine():Future<Bool> {
		return Future.sync(data.player == data.goal);
	}
}