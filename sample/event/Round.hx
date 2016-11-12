package event;

import condition.*;
import data.*;

using moji.Moji;
using tink.CoreApi;

class Round implements Event {
	var engine:Engine<GameData>;
	var arrived:Condition;
	
	public function new(engine) {
		this.engine = engine;
		arrived = function() return engine.game.player == engine.game.goal;
	}
	
	public function run() {
		return engine.prompt(new Prompt(
			engine.elapsed + ': Choose an action (player: ${engine.game.player}, goal: ${engine.game.goal})',
			[Normal('Move'), Normal('Stay')]
		)).map(function(i) {
			return Done(0, [i == 0 ? (new Move(engine):Event) : (new Stay(engine):Event)]);
		});
	}
	
	public function next()
		return arrived.then(None, Some((this:Event)));
	
	inline function canMove(direction):Condition
		return new CanMove(direction, engine.game);
}