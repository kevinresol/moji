package moji;

using tink.CoreApi;

typedef Prompt = {
	var message:Conditional<String>;
	var answers:Array<Conditional<Option<String>>>;
}