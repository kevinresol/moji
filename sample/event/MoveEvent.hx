package event;

import moji.*;
import moji.Prompt;
import condition.*;
import data.*;

using tink.CoreApi;

class MoveEvent implements Event {
	var engine:Engine<GameData>;
	var directions:Array<Direction> = [Left, Right, Up, Down];
	var arrived:Condition;
	
	public function new(engine) {
		this.engine = engine;
		arrived = function() return engine.data.player == engine.data.goal;
	}
	
	public function run() {
		return engine.renderer.prompt(new Prompt(
			'Choose a direction to move (player: ${engine.data.player}, goal: ${engine.data.goal})',
			[for(d in directions) canMove(d).then(Normal(d.getName()), Disabled(d.getName()))]
		)).map(function(i) {
			engine.data.player.move(directions[i]);
			return 1; // elapsed one step
		});
	}
	
	public function next()
		return arrived.then(None, Some(asEvent()));
		
	inline function asEvent():Event
		return this;
	
	inline function canMove(direction):Condition
		return new CanMove(direction, engine.data);
}