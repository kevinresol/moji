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
		
	public static function combine(conds:Array<Condition>, f:Array<Bool>->Bool):Condition
		return new ConditionCombine(conds, f);
	
	public static function andAll(conds:Array<Condition>):Condition
		return new ConditionCombine(conds, function(bools) {
			for(bool in bools) if(!bool) return false;
			return true;
		});
		
	public static function orAll(conds:Array<Condition>):Condition
		return new ConditionCombine(conds, function(bools) {
			for(bool in bools) if(bool) return true;
			return false;
		});
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
	var ifTrue:Condition;
	var ifFalse:Condition;
	
	public function new(cond, ifTrue, ifFalse) {
		this.cond = cond;
		this.ifTrue = ifTrue;
		this.ifFalse = ifFalse;
	}
	
	override function resolve():Future<Bool>
		return cond.resolve().flatMap(function(b) return (b ? ifTrue : ifFalse).resolve());
}

class ConditionCombine extends ConditionBase {
	var conds:Array<Condition>;
	var f:Array<Bool>->Bool;
	
	public function new(conds, f) {
		this.conds = conds;
		this.f = f;
	}
	
	override function resolve():Future<Bool>
		return Future.ofMany([for(c in conds) c.resolve()]).map(f);
}

class ConditionBase implements ConditionObject {
	public function resolve():Future<Bool>
		return Future.sync(true);
	
	public function negate():Condition
		return new ConditionMap(this, false, true);
		
	public function and(other:Condition):Condition
		return new ConditionCombine([this, other], function(b) return b[0] && b[1]);
		
	public function or(other:Condition):Condition
		return new ConditionCombine([this, other], function(b) return b[0] || b[1]);
		
	public function map(ifTrue:Condition, ifFalse:Condition):Condition
		return new ConditionMap(this, ifTrue, ifFalse);
	
	public function then<T>(ifTrue:Conditional<T>, ifFalse:Conditional<T>):Conditional<T>
		return new Conditional(this, ifTrue, ifFalse);
	
}

interface ConditionObject {
	function resolve():Future<Bool>;
	function negate():Condition;
	function and(other:Condition):Condition;
	function or(other:Condition):Condition;
	function map(ifTrue:Condition, ifFalse:Condition):Condition;
	function then<T>(ifTrue:Conditional<T>, ifFalse:Conditional<T>):Conditional<T>;
}
