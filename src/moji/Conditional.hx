package moji;

import tink.CoreApi;

@:forward(get)
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
		
	public function get()
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
	
	public function get():Future<T> {
		return cond.check().flatMap(function(bool) return (bool ? ifTrue : ifFalse).get());
	}
}

interface ConditionalBase<T> {
	function get():Future<T>;
}