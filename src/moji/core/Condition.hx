package moji.core;

using tink.CoreApi;

@:forward
abstract Condition(ConditionBase) from ConditionBase to ConditionBase {
	
	public function negate():Condition
		return this.determine().map(function(b) return !b);
		
	public function then<T>(ifTrue:Conditional<T>, ifFalse:Conditional<T>):Conditional<T>
		return new Conditional(this, ifTrue, ifFalse);
		 
	@:from
	public static inline function ofConst(v:Bool):Condition
		return Future.sync(v);
		
	@:from
	public static inline function ofFate(v:Future<Bool>):Condition
		return new SimpleCondition(v);
		
	@:from
	public static inline function ofSimple(f:Void->Bool):Condition
		return function() return Future.sync(f());
		
	@:from
	public static inline function ofAsync(f:Void->Future<Bool>):Condition
		return new AsyncCondition(f);
		
}

class SimpleCondition implements ConditionBase {
	
	var value:Future<Bool>;
	
	public function new(value)
		this.value = value;
		
	public function determine()
		return value;
		
}

class AsyncCondition implements ConditionBase {
	
	var f:Void->Future<Bool>;
	
	public function new(f)
		this.f = f;
		
	public function determine()
		return f();
		
}

interface ConditionBase {
	function determine():Future<Bool>;
}
