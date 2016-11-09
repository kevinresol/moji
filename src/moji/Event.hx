package moji;

using tink.CoreApi;

interface Event {
	function run():Future<ElapsedTime>;
	function prompt(content:Prompt):Future<AnswerIndex>;
}

typedef ElapsedTime = Int;
typedef AnswerIndex = Int;