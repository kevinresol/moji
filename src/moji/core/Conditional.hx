package moji.core;

import tink.CoreApi;

@:forward
abstract Maybe<T>(Conditional<Option<T>>) from Conditional<Option<T>> to Conditional<Option<T>> {
		
	@:from
	public inline static function ofOption<V>(v:Option<V>):Maybe<V>
		return new Certain(Future.sync(v));
	@:from
	public inline static function ofConst<V>(v:V):Maybe<V>
		return ofOption(Some(v));
	@:from
	public inline static function ofFortune<V>(v:Future<Option<V>>):Maybe<V>
		return new Certain(v);
	@:from
	public inline static function ofFate<V>(v:Future<V>):Maybe<V>
		return ofFortune(v.map(Some));
}

@:forward
abstract Conditional<T>(ConditionalObject<T>) from ConditionalObject<T> to ConditionalObject<T> {
	
	public inline function new(cond, ifTrue, ifFalse)
		this = new Branch(cond, ifTrue, ifFalse);
		
	public inline function map<A>(f:T->A):Conditional<A>
		return this.evaluate().map(f);
		
	public function flatMap<A>(f:T->Conditional<A>):Conditional<A>
		return this.evaluate().flatMap(function(v) return f(v).evaluate());
		
	@:from
	public static function ofConst<V>(v:V):Conditional<V>
		return new Certain(Future.sync(v));
	
	@:from
	public static function ofFate<V>(v:Future<V>):Conditional<V>
		return new Certain(v);
	
	@:from
	public static function flatten<V>(v:Future<Conditional<V>>):Conditional<V>
		return new LazyCertain(function() return v.flatMap(function(c) return c.evaluate()));
		
	@:from
	public static function ofLazy<V>(v:Lazy<Conditional<V>>):Conditional<V>
		return new LazyCertain(function() return v.get().evaluate());
}

class Certain<T> implements ConditionalObject<T> {
	var value:Future<T>;
	
	public function new(value)
		this.value = value;
		
	public function evaluate()
		return value;
}

class LazyCertain<T> implements ConditionalObject<T> {
	var f:Void->Future<T>;
	
	public function new(f)
		this.f = f;
		
	public function evaluate()
		return f();
}

class Branch<T> implements ConditionalObject<T> {
	var cond:Condition;
	var ifTrue:Conditional<T>;
	var ifFalse:Conditional<T>;
	
	public function new(cond, ifTrue, ifFalse) {
		this.cond = cond;
		this.ifTrue = ifTrue;
		this.ifFalse = ifFalse;
	}
	
	public function evaluate():Future<T>
		return cond.check().flatMap(function(bool) return (bool ? ifTrue : ifFalse).evaluate());
}

interface ConditionalObject<T> {
	function evaluate():Future<T>;
}