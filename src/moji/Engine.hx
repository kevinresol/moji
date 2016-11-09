package moji;

using tink.CoreApi;

class Engine {
	
	public var renderer(default, null):Renderer;
	public var elapsed(default, null):Int;
	var current:Event;
	var end:FutureTrigger<Noise>;
	
	public function new(renderer) {
		this.renderer = renderer;
	}
	
	public function start(event:Event) {
		elapsed = 0;
		end = Future.trigger();
		current = event;
		execute();
		return end.asFuture();
	}
		
	function execute() {
		current.run().handle(function(e) {
			elapsed += e;
			current.next().handle(function(next) switch next {
				case Some(event):
					current = event;
					execute();
				case None:
					end.trigger(Noise);
			});
		});
	}
		
}