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