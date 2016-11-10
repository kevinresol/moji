package moji.core;

import moji.core.Conditional;
using tink.CoreApi;

interface Event {
	function run():Future<EventResult>;
	function next():NextEvent;
}

typedef EventResult = {
	elapsed:Int,
	sub:SubEvents,
}

typedef SubEvents = Array<ConditionalOption<Event>>;
typedef NextEvent = ConditionalOption<Event>;


class BasicEvent<T> implements Event {
	var engine:Engine<T>;
	
	public function new(engine) {
		this.engine = engine;
	}
	
	public function run():Future<EventResult>
		return Future.sync({
			elapsed: 0,
			sub: [],
		});
	
	public function next():NextEvent
		return None;
	
	inline function asEvent():Event
		return this;
} 