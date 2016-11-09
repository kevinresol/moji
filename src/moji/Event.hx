package moji;

using tink.CoreApi;

interface Event {
	function run():Future<ElapsedTime>;
	function next():Option<Event>;
}

typedef ElapsedTime = Int;