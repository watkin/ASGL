package asgl.math {
	import flash.geom.Vector3D;

	public class Float4 {
		public var x:Number;
		public var y:Number;
		public var z:Number;
		public var w:Number;
		
		private var f4:Float4;
		
		public function Float4(x:Number=0, y:Number=0, z:Number=0, w:Number=1) {
			this.x = x;
			this.y = y;
			this.z = z;
			this.w = w;
			f4 = this;
		}
		public function get length():Number {
			var d:Number = x * x + y*y + z * z + w * w;
			if (d != 1) d = Math.sqrt(d);
			return d;
		}
		public function addFromFloat4(f:Float4):void {
			x += f.x;
			y += f.y;
			z += f.z;
			w += f.w;
		}
		public function clone():Float4 {
			return new Float4(x, y, z, w);
		}
		public function copyDataFromFloat4(f4:Float4):void {
			x = f4.x;
			y = f4.y;
			z = f4.z;
			w = f4.w;
		}
		public function divideFromNumber(div:Number):void {
			x /= div;
			y /= div;
			z /= div;
			w /= div;
		}
		public static function dotProduct(f1:Float4, f2:Float4):Number {
			return f1.x * f2.x + f1.y * f2.y + f1.z * f2.z + f1.w * f2.w;
		}
		public function equals(toCompare:Float4, tolerance:Number=0):Boolean {
			if (tolerance == 0) {
				return x == toCompare.x && y == toCompare.y && z == toCompare.z && w == toCompare.w;
			} else {
				if (tolerance<0) tolerance *= -1;
				tolerance *= tolerance;
				var x:Number = this.x - toCompare.x;
				var y:Number = this.y - toCompare.y;
				var z:Number = this.z - toCompare.z;
				var w:Number = this.w - toCompare.w;
				var d2:Number = x * x + y * y + z * z + w * w;
				
				return (d2 >= 0 && d2 <= tolerance) || (d2 <= 0 && d2 >= -tolerance);
			}
		}
		public function multiplyFromNumber(mul:Number):void {
			x *= mul;
			y *= mul;
			z *= mul;
			w *= mul;
		}
		public function subtractFromFloat4(f:Float4):void {
			x -= f.x;
			y -= f.y;
			z -= f.z;
			w -= f.w;
		}
		public function scaleFromNumber(s:Number):void {
			x *= s;
			y *= s;
			z *= s;
			w *= s;
		}
		
		public function calculateQuaternionW(neg:Boolean=true):void {
			w = 1 - x * x - y * y - z * z;
			if (w < 0) {
				w = 0;
			} else {
				w = Math.sqrt(w);
				if (neg) w = -w;
			}
		}
		public function conjugateQuaternion():void {
			x = -x;
			y = -y;
			z = -z;
		}
		public function invertQuaternion():void {
			x = -x;
			y = -y;
			z = -z;
			
			var d:Number = x * x + y*y + z * z + w * w;
			if (d != 1) d = Math.sqrt(d);
			
			x /= d;
			y /= d;
			z /= d;
			w /= d;
		}
		/**
		 * be equivalent to : this.toMatrix ~~ q.toMatrix
		 */
		public function multiplyQuaternion(quat:Float4):void {
			include 'Float4_multiplyQuaternion.define';
		}
		public function rotationFloat3FromQuaternion(f3:Float3, opFloat3:Float3=null):Float3 {
			if (opFloat3 == null) opFloat3 = new Float3();
			
			include 'Float4_rotationFloat3FromQuaternion.define';
			
			return opFloat3;
		}
		public function getMatrixFromQuaternion(opMatrix:Matrix4x4=null):Matrix4x4 {
			include 'Float4_getMatrixFromQuaternion.define';
			
			return opMatrix;;
		}
		/**
		 * euler use radian.
		 */
		public function getEulerFromQuaternion(op:Float3=null):Float3 {
			if (op == null) op = new Float3();
			
			op.x = Math.atan2(2 * (w * x + y * z), (1 - 2 * (x * x + y * y)));
			op.y = Math.asin(2 * (w * y - z * x));
			op.z = Math.atan2(2 * (w * z + x * y), (1 - 2 * (y * y + z * z)));
			
			return op;
		}
		public static function createEulerXQuaternion(radian:Number=0, op:Float4=null):Float4 {
			if (op == null) op = new Float4();
			
			radian *= 0.5;
			
			op.x = Math.sin(radian);
			op.y = 0;
			op.z = 0;
			op.w = Math.cos(radian);
			
			return op;
		}
		public static function createEulerYQuaternion(radian:Number=0, op:Float4=null):Float4 {
			if (op == null) op = new Float4();
			
			radian *= 0.5;
			
			op.x = 0;
			op.y = Math.sin(radian);
			op.z = 0;
			op.w = Math.cos(radian);
			
			return op;
		}
		public static function createEulerZQuaternion(radian:Number=0, op:Float4=null):Float4 {
			if (op == null) op = new Float4();
			
			radian *= 0.5;
			
			op.x = 0;
			op.y = 0;
			op.z = Math.sin(radian);
			op.w = Math.cos(radian);
			
			return op;
		}
		/**
		 * euler use radian.
		 */
		public static function createEulerXYZQuaternion(x:Number=0, y:Number=0, z:Number=0, op:Float4=null):Float4 {
			if (op == null) op = new Float4();
			
			x *= 0.5;
			y *= 0.5;
			z *= 0.5;
			
			var sinX:Number = Math.sin(x);
			var cosX:Number = Math.cos(x);
			var sinY:Number = Math.sin(y);
			var cosY:Number = Math.cos(y);
			var sinZ:Number = Math.sin(z);
			var cosZ:Number = Math.cos(z);
			
			var scXY:Number = sinX * cosY;
			var csXY:Number = cosX * sinY;
			var ccXY:Number = cosX * cosY;
			var ssXY:Number = sinX * sinY;
			
			op.x = scXY * cosZ - csXY * sinZ;
			op.y = csXY * cosZ + scXY * sinZ;
			op.z = ccXY * sinZ - ssXY * cosZ;
			op.w = ccXY * cosZ + ssXY * sinZ;
			
			return op;
		}
		/**
		 * @param axis the axis is a normalize vector3D.
		 */
		public static function createRotationAxisQuaternion(axis:Float3, radian:Number, opFloat4:Float4=null):Float4 {
			include 'Float4_createRotationAxisQuaternion.define';
			
			return opFloat4;
		}
		/**
		 * @param t the t is 0-1.
		 */
		public static function slerpQuaternion(q0:Float4, q1:Float4, t:Number, opFloat4:Float4=null):Float4 {
			include 'Float4_slerpQuaternion.define';
			
			return opFloat4;
		}
		public function transformLRHQuaternion():void {
			x *= -1;
			var temp:Number = y;
			y = -z;
			z = -y;
		}
		
		public function toFloat3(divW:Boolean=true, op:Float3=null):Float3 {
			if (op == null) {
				if (divW) {
					return new Float3(x / w, y / w, z / w);
				} else {
					return new Float3(x, y, z);
				}
			} else {
				if (divW) {
					op.x = x / w;
					op.y = y / w;
					op.z = z / w;
				} else {
					op.x = x;
					op.y = y;
					op.z = z;
				}
				return op;
			}
		}
		public function toString():String {
			return 'float4 (x=' + x + ', y=' + y + ', z=' + z + ', w=' + w + ')';
		}
		public function toVector3D(v:Vector3D=null):Vector3D {
			if (v == null) {
				return new Vector3D(x, y, z, w);
			} else {
				v.x = x;
				v.y = y;
				v.z = z;
				v.w = w;
				
				return v;
			}
		}
	}
}