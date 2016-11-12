package event;

import condition.*;
import data.*;

using moji.Moji;
using tink.CoreApi;

class Move implements Event {
	var engine:Engine<GameData>;
	var directions:Array<Direction> = [Left, Right, Up, Down];
	
	public function new(engine) {
		this.engine = engine;
	}
	
	public function run() {
		return engine.prompt(new Prompt(
			engine.elapsed + ': Choose a direction to move (player: ${engine.game.player}, goal: ${engine.game.goal})',
			[for(d in directions) canMove(d).then(Normal(d.getName()), Disabled(d.getName()))].concat([Normal('Back')])
		)).map(function(i) {
			if(i == directions.length) return Abort;
			engine.game.player.move(directions[i]);
			return Done(1, []);
		});
	}
	
	public function next():NextEvent
		return None;
	
	inline function canMove(direction):Condition
		return new CanMove(direction, engine.game);
}