package moji.core;

using tink.CoreApi;

@:forward
abstract Condition(ConditionObject) from ConditionObject to ConditionObject {
	
	@:op(!A)
	public function negate():Condition
		return map(false, true);
		
	@:op(A&&B)
	public function and(other:Condition):Condition
		return combine([this, other], function(b) return b[0] && b[1]);
		
	@:op(A||B)
	public function or(other:Condition):Condition
		return combine([this, other], function(b) return b[0] || b[1]);
		
	public function map(ifTrue:Condition, ifFalse:Condition):Condition
		return new ConditionMap(this, ifTrue, ifFalse);
	
	public function then<T>(ifTrue:Conditional<T>, ifFalse:Conditional<T>):Conditional<T>
		return new Conditional(this, ifTrue, ifFalse);
		
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
	
	public static function all(conds:Array<Condition>):Condition
		return combine(conds, function(bools) {
			for(bool in bools) if(!bool) return false;
			return true;
		});
		
	public static function any(conds:Array<Condition>):Condition
		return combine(conds, function(bools) {
			for(bool in bools) if(bool) return true;
			return false;
		});
}

class SimpleCondition implements ConditionObject {
	var value:Future<Bool>;
	
	public function new(value)
		this.value = value;
		
	public function check()
		return value;
}

class LazyCondition implements ConditionObject {
	var f:Void->Future<Bool>;
	
	public function new(f)
		this.f = f;
		
	public function check()
		return f();
		
}

class ConditionMap implements ConditionObject {
	var cond:Condition;
	var ifTrue:Condition;
	var ifFalse:Condition;
	
	public function new(cond, ifTrue, ifFalse) {
		this.cond = cond;
		this.ifTrue = ifTrue;
		this.ifFalse = ifFalse;
	}
	
	public function check():Future<Bool>
		return cond.check().flatMap(function(b) return (b ? ifTrue : ifFalse).check());
}

class ConditionCombine implements ConditionObject {
	var conds:Array<Condition>;
	var f:Array<Bool>->Bool;
	
	public function new(conds, f) {
		this.conds = conds;
		this.f = f;
	}
	
	public function check():Future<Bool>
		return Future.ofMany([for(c in conds) c.check()]).map(f);
}

interface ConditionObject {
	function check():Future<Bool>;
}
