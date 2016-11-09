package moji;

using tink.CoreApi;

interface Renderer {
	function prompt(content:Prompt):Future<Int>;
}