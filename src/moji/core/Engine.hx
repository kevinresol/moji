package moji.core;

using tink.CoreApi;

class Engine<T> {
	
	public var game(default, null):T;
	public var elapsed(default, null):Int;
	var renderer:Renderer;
	var eventStack:Array<Event>;
	
	public function new(game, renderer) {
		this.game = game;
		this.renderer = renderer;
		eventStack = [];
	}
	
	public function prompt(content)
		return renderer.prompt(content);
	
	public function start(event:Event) {
		return Future.async(function(cb) {
			elapsed = 0;
			run(event).handle(function() {
				renderer.end();
				trace('end');
				cb(Noise);
			});
		});
	}
	
	function run(event:Event):Future<Noise> {
		return Future.async(function(cb) {
			eventStack.push(event);
			trace('push: ' + eventStack.map(function(e) return Type.getClassName(Type.getClass(e))));
			event.run().handle(function(result) {
				elapsed += result.elapsed;
				var iter = result.sub.iterator();
				function sub() {
					if(iter.hasNext()) {
						iter.next().resolve().handle(function(o) switch o {
							case Some(event): run(event).handle(sub);
							case None: sub();
						});
					} else {
						eventStack.pop();
						trace('pop: ' + eventStack.map(function(e) return Type.getClassName(Type.getClass(e))));
						event.next().resolve().handle(function(o) switch o {
							case Some(event): run(event).handle(cb);
							case None: cb(Noise);
						});
					}
				}
				sub();
			});
		});
	}
}
