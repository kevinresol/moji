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
		engine.prompt({
			message: 'Choose a direction to move (current: $player)' ,
			answers: [
				canMove(player, boardSize, Left).then(Some("Left"), None),
				canMove(player, boardSize, Right).then(Some("Right"), None),
				canMove(player, boardSize, Up).then(Some("Up"), None),
				canMove(player, boardSize, Down).then(Some("Down"), None),
			]
		}).handle(function(o) trace(o));
	}
	
	static inline function canMove(player, boardSize, direction):Condition
		return new CanMove(direction, player, boardSize);
}

