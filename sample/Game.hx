package;

import moji.*;
using tink.CoreApi;

/**
	A sample game to demonstrate the game engine.
	This game happens on a NxN chess board, where N is defined by boardSize
	The player starts at a random position and there is a goal spawned at another random position
	The player needs to choose the direction to move until he reaches the goal
**/
class Game {
	static function main() {
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

