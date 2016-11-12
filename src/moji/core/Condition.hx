package moji.core;

using tink.CoreApi;

@:forward
abstract Condition(ConditionObject) from ConditionObject to ConditionObject {
	@:op(!A)
	public inline function negate():Condition
		return this.negate();
		
	@:op(A&&B)
	public inline function and(other:Condition):Condition
		return this.and(other);
		
	@:op(A||B)
	public inline function or(other:Condition):Condition
		return this.or(other);
		
	@:from
	public static inline function ofConst(v:Bool):Condition
		return ofAsync(Future.sync(v));
		
	@:from
	public static inline function ofAsync(v:Future<Bool>):Condition
		return new SimpleCondition(v);
		
	@:from
	public static inline function ofLazy(f:Void->Bool):Condition
		return ofLazyAsync(function() return Future.sync(f()));
		
	@:from
	public static inline function ofLazyAsync(f:Void->Future<Bool>):Condition
		return new LazyCondition(f);
		
}

class SimpleCondition extends ConditionBase {
	var value:Future<Bool>;
	
	public function new(value)
		this.value = value;
		
	override function resolve()
		return value;
}

class LazyCondition extends ConditionBase {
	var f:Void->Future<Bool>;
	
	public function new(f)
		this.f = f;
		
	override function resolve()
		return f();
		
}

class ConditionMap extends ConditionBase {
	var cond:Condition;
	var f:Bool->Bool;
	
	public function new(cond, f) {
		this.cond = cond;
		this.f = f;
	}
	
	override function resolve():Future<Bool>
		return cond.resolve().map(f);
}

class ConditionMapAsync extends ConditionBase {
	var cond:Condition;
	var f:Bool->Condition;
	
	public function new(cond, f) {
		this.cond = cond;
		this.f = f;
	}
	
	override function resolve():Future<Bool>
		return cond.resolve().flatMap(function(b) return f(b).resolve());
}

class ConditionCombine extends ConditionBase {
	var cond1:Condition;
	var cond2:Condition;
	var f:Bool->Bool->Bool;
	
	public function new(cond1, cond2, f) {
		this.cond1 = cond1;
		this.cond2 = cond2;
		this.f = f;
	}
	
	override function resolve():Future<Bool>
		return Future.ofMany([cond1.resolve(), cond1.resolve()]).map(function(v) return f(v[0], v[1]));
}

class ConditionBase implements ConditionObject {
	public function resolve():Future<Bool>
		return Future.sync(true);
	
	public function negate():Condition
		return new ConditionMap(this, function(b) return !b);
		
	public function and(other:Condition):Condition
		return new ConditionCombine(this, other, function(v1, v2) return v1 && v2);
		
	public function or(other:Condition):Condition
		return new ConditionCombine(this, other, function(v1, v2) return v1 || v2);
		
	public function map(f:Bool->Bool):Condition
		return new ConditionMap(this, f);
		
	public function flatMap(f:Bool->Condition):Condition
		return new ConditionMapAsync(this, f);
	
	public function then<T>(ifTrue:Conditional<T>, ifFalse:Conditional<T>):Conditional<T>
		return new Conditional(this, ifTrue, ifFalse);
	
}

interface ConditionObject {
	function resolve():Future<Bool>;
	function negate():Condition;
	function and(other:Condition):Condition;
	function or(other:Condition):Condition;
	function map(f:Bool->Bool):Condition;
	function flatMap(f:Bool->Condition):Condition;
	function then<T>(ifTrue:Conditional<T>, ifFalse:Conditional<T>):Conditional<T>;
}
