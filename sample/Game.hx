package;

import moji.*;
using tink.CoreApi;

class Game {
	static function main() {
		moji.Condition;
		var boardSize = 5;
		var player = Position.random(boardSize, boardSize);
		var goal = Position.random(boardSize, boardSize);
		while(goal == player) goal = Position.random(boardSize, boardSize);
		
		var engine = new Engine(new HtmlRenderer(js.Browser.document.getElementById('app')));
		engine.start(new MoveEvent(engine, player, goal, boardSize)).handle(function(o) {
			trace('Steps used: ' + engine.elapsed);
			engine.renderer.end();
		});
	}
}

