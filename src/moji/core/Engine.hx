package moji.core;

using tink.CoreApi;

class Engine<T> {
	
	public var game(default, null):T;
	public var elapsed(default, null):Int;
	var renderer:Renderer;
	var eventStack:Array<Event>;
	var started:Bool;
	
	public function new(game, renderer) {
		this.game = game;
		this.renderer = renderer;
		started = false;
	}
	
	public function prompt(content)
		return renderer.prompt(content);
	
	public function start(event:Event) {
		if(started) return Future.sync(Failure(new Error('Already Started')));
		started = true;
		elapsed = 0;
		eventStack = [];
		return run(event).map(function(v) {
			started = false;
			renderer.end();
			return Success(v);
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
