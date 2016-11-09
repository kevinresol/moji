package;

abstract Position(PositionData) from PositionData to PositionData {
	public var x(get, never):Int;
	public var y(get, never):Int;
	
	public static function random(x:Int, y:Int)
		return new Position(Std.random(x), Std.random(y));
		
	public function new(x:Int, y:Int)
		return {x: x, y: y}
		
	public function move(direction:Direction)
		switch direction {
			case Left: this.x--;
			case Right: this.x++;
			case Up: this.y--;
			case Down: this.y++;
		}
		
	@:op(A==B)
	public inline function eq(other:Position)
		return this.x == other.x && this.y == other.y;
	
	@:op(A!=B)
	public inline function ineq(other:Position)
		return !eq(other);
		
	public function toString()
		return '[$x, $y]';
	
	inline function get_x()
		return this.x;
	inline function get_y()
		return this.y;
}

private typedef PositionData = {
	x:Int,
	y:Int,
}