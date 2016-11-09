package moji;

using tink.CoreApi;

class Engine {
	
	var renderer:Renderer;
	
	public function new(renderer) {
		this.renderer = renderer;
	}
	
	public function prompt(content:Prompt)
		return renderer.prompt(content);
		
}