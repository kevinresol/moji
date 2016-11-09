package moji;

using tink.CoreApi;

interface Event {
	function run():Future<ElapsedTime>;
	function next():Conditional<Option<Event>>;
}

typedef ElapsedTime = Int;
