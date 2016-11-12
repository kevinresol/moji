package moji.core;

import tink.CoreApi;


@:forward
abstract ConditionalOption<T>(Conditional<Option<T>>) from Conditional<Option<T>> to Conditional<Option<T>> {
	@:from
	public static function ofOption<V>(v:Option<V>):ConditionalOption<V>
		return new Certain(Future.sync(v));
	@:from
	public static function ofConst<V>(v:V):ConditionalOption<V>
		return ofOption(Some(v));
	@:from
	public static function ofFortune<V>(v:Future<Option<V>>):ConditionalOption<V>
		return new Certain(v);
	@:from
	public static function ofFate<V>(v:Future<V>):ConditionalOption<V>
		return ofFortune(v.map(Some));
}

@:forward
abstract Conditional<T>(ConditionalObject<T>) from ConditionalObject<T> to ConditionalObject<T> {
	
	public inline function new(cond, ifTrue, ifFalse)
		this = new Branch(cond, ifTrue, ifFalse);
		
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

class Certain<T> extends ConditionalBase<T> {
	var value:Future<T>;
	
	public function new(value)
		this.value = value;
		
	override function evaluate()
		return value;
}

class LazyCertain<T> extends ConditionalBase<T> {
	var f:Void->Future<T>;
	
	public function new(f)
		this.f = f;
		
	override function evaluate()
		return f();
}

class Branch<T> extends ConditionalBase<T> {
	var cond:Condition;
	var ifTrue:Conditional<T>;
	var ifFalse:Conditional<T>;
	
	public function new(cond, ifTrue, ifFalse) {
		this.cond = cond;
		this.ifTrue = ifTrue;
		this.ifFalse = ifFalse;
	}
	
	override function evaluate():Future<T>
		return cond.resolve().flatMap(function(bool) return (bool ? ifTrue : ifFalse).evaluate());
}

class ConditionalMap<T, A> extends ConditionalBase<A> {
	var cond:Conditional<T>;
	var f:T->A;
	
	public function new(cond, f) {
		this.cond = cond;
		this.f = f;
	}
	
	override function evaluate():Future<A>
		return cond.evaluate().map(f);
}

class ConditionalMapAsync<T, A> extends ConditionalBase<A> {
	var cond:Conditional<T>;
	var f:T->Conditional<A>;
	
	public function new(cond, f) {
		this.cond = cond;
		this.f = f;
	}
	
	override function evaluate():Future<A>
		return cond.evaluate().flatMap(function(v) return f(v).evaluate());
}

class ConditionalBase<T> implements ConditionalObject<T> {
	public function evaluate():Future<T>
		return Future.sync(null);
	
	public function map<A>(f:T->A):Conditional<A>
		return new ConditionalMap(asConditional(), f);
		
	public function flatMap<A>(f:T->Conditional<A>):Conditional<A>
		return new ConditionalMapAsync(asConditional(), f);
	
	inline function asConditional():Conditional<T>
		return this;
}

interface ConditionalObject<T> {
	function evaluate():Future<T>;
	function map<A>(f:T->A):Conditional<A>;
	function flatMap<A>(f:T->Conditional<A>):Conditional<A>;
}