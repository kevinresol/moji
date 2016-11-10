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
		return ofFortune(v.map(function(v) return Some(v)));
}

@:forward(resolve)
abstract Conditional<T>(ConditionalBase<T>) from ConditionalBase<T> to ConditionalBase<T> {
	
	public inline function new(cond, ifTrue, ifFalse)
		this = new Branch(cond, ifTrue, ifFalse);
	@:from
	public static function ofConst<V>(v:V):Conditional<V>
		return new Certain(Future.sync(v));
	@:from
	public static function ofFate<V>(v:Future<V>):Conditional<V>
		return new Certain(v);
}

class Certain<T> implements ConditionalBase<T>{
	
	var value:Future<T>;
	
	public function new(value)
		this.value = value;
		
	public function resolve()
		return value;
}

class Branch<T> implements ConditionalBase<T> {
	var cond:Condition;
	var ifTrue:Conditional<T>;
	var ifFalse:Conditional<T>;
	
	public function new(cond, ifTrue, ifFalse) {
		this.cond = cond;
		this.ifTrue = ifTrue;
		this.ifFalse = ifFalse;
	}
	
	public function resolve():Future<T> {
		return cond.determine().flatMap(function(bool) return (bool ? ifTrue : ifFalse).resolve());
	}
}

interface ConditionalBase<T> {
	function resolve():Future<T>;
}