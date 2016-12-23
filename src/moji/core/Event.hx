package moji.core;

import moji.core.Conditional;
using tink.CoreApi;

interface Event {
	function run():Future<EventResult>;
	function next():NextEvent;
}

enum EventResult {
	Done(elapsed:Int, sub:SubEvents);
	Abort;
}

typedef SubEvents = Array<Maybe<Event>>;
typedef NextEvent = Maybe<Event>;

class BasicEvent<T> implements Event {
	var engine:Engine<T>;
	
	public function new(engine) {
		this.engine = engine;
	}
	
	public function run():Future<EventResult>
		return Future.sync(Done(0, []));
	
	public function next():NextEvent
		return None;
	
	inline function asEvent():Event
		return this;
} 