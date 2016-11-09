package moji;

using tink.CoreApi;

interface Renderer {
	function end():Void;
	function prompt(content:Prompt):Future<Int>;
}