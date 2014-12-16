package asgl.math {
	import flash.geom.Vector3D;

	public class Float2 {
		public var x:Number;
		public var y:Number;
		
		public function Float2(x:Number=0, y:Number=0) {
			this.x = x;
			this.y = y;
		}
		public function get isZero():Boolean {
			return x == 0 && y == 0;
		}
		/**
		 * length = vector modulo 
		 * @return 
		 */
		[Inline]
		public final function get length():Number {
			var d:Number = x * x + y * y;
			if (d != 1) d = Math.sqrt(d);
			return d;
		}
		public function addFromFloat2(f:Float2):void {
			x += f.x;
			y += f.y;
		}
		public static function angleBetween(f1:Float2, f2:Float2):Number {
			return Math.acos((f1.x * f2.x + f1.y * f2.y) / (f1.length * f2.length));
		}
		public function clone():Float2 {
			return new Float2(x, y);
		}
		public static function distance(f1:Float2, f2:Float2):Number {
			var x:Number = f1.x - f2.x;
			var y:Number = f1.y - f2.y;
			return Math.sqrt(x * x + y * y);
		}
		public function divideFromNumber(div:Number):void {
			x /= div;
			y /= div;
		}
		public static function dotProduct(f1:Float2, f2:Float2):Number {
			return f1.x * f2.x + f1.y * f2.y;
		}
		public function equals(toCompare:Float2, tolerance:Number=0):Boolean {
			if (tolerance == 0) {
				return x == toCompare.x && y == toCompare.y;
			} else {
				if (tolerance<0) tolerance *= -1;
				tolerance *= tolerance;
				var x:Number = this.x - toCompare.x;
				var y:Number = this.y - toCompare.y;
				var d2:Number = x * x + y * y;
				return (d2 >= 0 && d2 <= tolerance) || (d2 <= 0 && d2 >= -tolerance);
			}
		}
		public function multiplyFromNumber(mul:Number):void {
			x *= mul;
			y *= mul;
		}
		public function normalize():void {
			var d:Number = this.length;
			x /= d;
			y /= d;
		}
		public function subtractFromFloat2(f:Float2):void {
			x -= f.x;
			y -= f.y;
		}
		public function scaleFromNumber(s:Number):void {
			x *= s;
			y *= s;
		}
		public function toString():String {
			return 'float2 (x=' + x + ', y=' + y + ')';
		}
		public function toVector3D():Vector3D {
			return new Vector3D(x, y);
		}
	}
}