package asgl.math {
	import flash.geom.Vector3D;

	public class Float3 {
		public static const AXIS_NEGATIVE_X:Float3 = getAxisNegativeX();
		public static const AXIS_NEGATIVE_Y:Float3 = getAxisNegativeY();
		public static const AXIS_NEGATIVE_Z:Float3 = getAxisNegativeZ();
		public static const AXIS_POSITIVE_X:Float3 = getAxisPositiveX();
		public static const AXIS_POSITIVE_Y:Float3 = getAxisPositiveY();
		public static const AXIS_POSITIVE_Z:Float3 = getAxisPositiveZ();
		
		public var x:Number;
		public var y:Number;
		public var z:Number;
		
		private var f3:Float3;
		
		public function Float3(x:Number=0, y:Number=0, z:Number=0) {
			this.x = x;
			this.y = y;
			this.z = z;
			
			f3 = this;
		}
		public static function getAxisNegativeX():Float3 {
			return new Float3(-1);
		}
		public static function getAxisNegativeY():Float3 {
			return new Float3(0, -1);
		}
		public static function getAxisNegativeZ():Float3 {
			return new Float3(0, 0, -1);
		}
		public static function getAxisPositiveX():Float3 {
			return new Float3(1);
		}
		public static function getAxisPositiveY():Float3 {
			return new Float3(0, 1);
		}
		public static function getAxisPositiveZ():Float3 {
			return new Float3(0, 0, 1);
		}
		public function get isZero():Boolean {
			return x == 0 && y == 0 && z == 0;
		}
		/**
		 * length = vector modulo 
		 * @return 
		 */
		[Inline]
		public final function get length():Number {
			var d:Number = x * x + y * y + z * z;
			if (d != 1) d = Math.sqrt(d);
			return d;
		}
		public function addFromFloat3(f:Float3):void {
			x += f.x;
			y += f.y;
			z += f.z;
		}
		public static function angleBetween(f1:Float3, f2:Float3, clamp:Boolean=false):Number {
			var len:Number = f1.length * f2.length;
			var val:Number = f1.x * f2.x + f1.y * f2.y + f1.z * f2.z;
			if (len != 1) val /= len;
			
			if (clamp) {
				if (val > 1) {
					val = 1;
				} else if (val < -1) {
					val = -1;
				}
			}
			return Math.acos(val);
		}
		public function clone():Float3 {
			return new Float3(x, y, z);
		}
		public function copyDataFromFloat3(f3:Float3):void {
			x = f3.x;
			y = f3.y;
			z = f3.z;
		}
		public function copyDataFromNumber(x:Number, y:Number, z:Number):void {
			this.x = x;
			this.y = y;
			this.z = z;
		}
		/** 
		 * f1 ~~ f2 = -(f2 ~~ f1)<br>
		 * f1 ~~ (-f2) = -(f1 ~~ f2)<br>
		 * if (f1 is normalize && f2 is normalize && return vector(0, 0, 0)) parallel
		 * @param f1
		 * @param f2
		 * @return Float3
		 */
		public static function crossProduct(f1:Float3, f2:Float3, opFloat3:Float3=null):Float3 {
			include 'Float3_crossProduct.define';
			
			return opFloat3;
		}
		public static function distance(f1:Float3, f2:Float3):Number {
			var x:Number = f1.x - f2.x;
			var y:Number = f1.y - f2.y;
			var z:Number = f1.z - f2.z;
			return Math.sqrt(x * x + y * y + z * z);
		}
		public function divideFromNumber(div:Number):void {
			x /= div;
			y /= div;
			z /= div;
		}
		public static function dotProduct(f1:Float3, f2:Float3):Number {
			return f1.x * f2.x + f1.y * f2.y + f1.z * f2.z;
		}
		public function equals(toCompare:Float3, tolerance:Number=0):Boolean {
			if (tolerance == 0) {
				return x == toCompare.x && y == toCompare.y && z == toCompare.z;
			} else {
				if (tolerance<0) tolerance *= -1;
				tolerance *= tolerance;
				var x:Number = this.x-toCompare.x;
				var y:Number = this.y-toCompare.y;
				var z:Number = this.z-toCompare.z;
				var d2:Number = x * x + y * y + z * z;
				return (d2 >= 0 && d2 <= tolerance) || (d2 <= 0 && d2 >= -tolerance);
			}
		}
		public static function lerp(f1:Float3, f2:Float3, t:Number, op:Float3):Float3 {
			if (op == null) {
				return new Float3(f1.x + (f2.x - f1.x) * t, f1.y + (f2.y - f1.y) * t, f1.z + (f2.z - f1.z) * t);
			} else {
				op.x = f1.x + (f2.x - f1.x) * t;
				op.y = f1.y + (f2.y - f1.y) * t;
				op.z = f1.z + (f2.z - f1.z) * t;
				
				return op;
			}
		}
		public function multiplyFromNumber(mul:Number):void {
			x *= mul;
			y *= mul;
			z *= mul;
		}
		public function normalize():void {
			include 'Float3_normalize.define';
		}
		public static function normalizeFromVector3(v:Vector.<Number>, op:Vector.<Number>=null):Vector.<Number> {
			var length:int = v.length;
			
			if (op == null) {
				op = new Vector.<Number>(length);
			} else if (op.length != length) {
				if (op.fixed) {
					if (op.length < length) return null;
				} else {
					op.length = length;
				}
			}
			
			for (var i:int = 0; i<length; i+=3) {
				var i2:int = i + 1;
				var i3:int = i + 2;
				
				var x:Number = v[i];
				var y:Number = v[i2];
				var z:Number = v[i3];
				
				var len:Number = x * x + y * y + z * z;
				
				if (len == 0) {
					op[i] = 0;
					op[i2] = 0;
					op[i3] = 0;
				} else if (len == 1) {
					op[i] = x;
					op[i2] = y;
					op[i3] = z;
				} else {
					len = Math.sqrt(len);
					op[i] = x / len;
					op[i2] = y / len;
					op[i3] = z / len;
				}
			}
			
			return op;
		}
		public static function subtract(a:Float3, b:Float3, op:Float3=null):Float3 {
			if (op == null) {
				return new Float3(a.x - b.x, a.y - b.y, a.z - b.z);
			} else {
				op.x = a.x - b.x;
				op.y = a.y - b.y;
				op.z = a.z - b.z;
				return op;
			}
		}
		public function subtractFromFloat3(f:Float3):void {
			x -= f.x;
			y -= f.y;
			z -= f.z;
		}
		public function scaleFromNumber(s:Number):void {
			x *= s;
			y *= s;
			z *= s;
		}
		public function toString():String {
			return 'float3 (x=' + x + ', y=' + y + ', z=' + z + ')';
		}
		public function toVector3D():Vector3D {
			return new Vector3D(x, y, z);
		}
		public function transformLRH():void {
			var temp:Number = x;
			x = y;
			y = temp;
		}
	}
}