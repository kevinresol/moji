package moji;

using tink.CoreApi;

class Engine<T> {
	
	public var game(default, null):T;
	public var elapsed(default, null):Int;
	var renderer:Renderer;
	
	public function new(game, renderer) {
		this.game = game;
		this.renderer = renderer;
	}
	
	public function prompt(content)
		return renderer.prompt(content);
	
	public function start(event:Event) {
		elapsed = 0;
		return runOne(event).map(function(_) {
			renderer.end();
			return Noise;
		});
	}
	
	public function run(events:EventList) {
		return switch events.asArray() {
			case []: Future.sync(0);
			case [e]: runOne(e);
			default:
				Future.async(function(cb) {
					var iter = events.iterator();
					var current = iter.next();
					var elapsed = 0;
					function next()
						runOne(current).handle(function(e) {
							elapsed += e;
							if(iter.hasNext()) {
								current = iter.next();
								next();
							} else {
								cb(elapsed);
							}
						});
						
					next();
				});
		}
	}
	
	function runOne(event:Event) 
		return Future.async(function(cb) {
			var currentElapsed = 0;
			var current = event;
			function execute() {
				current.run().handle(function(e) {
					elapsed += e;
					currentElapsed += e;
					current.next().resolve().handle(function(next) switch next {
						case Some(event):
							current = event;
							execute();
						case None:
							cb(currentElapsed);
					});
				});
			}
			execute();
		});
}

@:forward
abstract EventList(Array<Event>) from Array<Event> to Array<Event> {
	@:from
	public static inline function ofSingle(e:Event):EventList
		return [e];
	public inline function asArray():Array<Event>
		return this;
}