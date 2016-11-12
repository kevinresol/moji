package event;

import data.*;
using moji.Moji;
using tink.CoreApi;

class Stay implements Event {
	
	var engine:Engine<GameData>;
	
	public function new(engine) {
		this.engine = engine;
	}
	
	public function run() {
		return engine.prompt(new Prompt('Confirm stay?', [Normal('Confirm'), Normal('Cancel')])).map(function(i) {
			return i == 0 ? Done(1, []) : Abort;
		});
	}
	
	public function next():NextEvent
		return None;
}