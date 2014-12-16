package asgl.bounds {
	import asgl.asgl_protected;
	import asgl.math.Float3;
	import asgl.math.Matrix4x4;
	import asgl.physics.Ray;
	
	use namespace asgl_protected;

	public class BoundingSphere extends BoundingVolume {
		public var origin:Float3;
		asgl_protected var _radius:Number;
		asgl_protected var _radius2:Number;
		
		public var globalOrigin:Float3;
		public var globalRadius:Number;
		
		public function BoundingSphere(origin:Float3=null, radius:Number=0) {
			_type = BoundingVolumeType.SPHERE;
			
			this.origin = origin;
			_radius = radius;
			_radius2 = _radius * _radius;
			
			globalOrigin = new Float3();
		}
		public function get radius():Number {
			return _radius;
		}
		public function set radius(value:Number):void {
			_radius = value;
			_radius2 = _radius * _radius;
		}
		public override function hitRay(ray:Ray):Boolean {
			var rayOrigin:Float3 = ray.origin;
			var rayDir:Float3 = ray.direction;
			
			if (rayOrigin == null || rayDir == null || origin == null) return false;
			
			var dx:Number = rayOrigin.x - origin.x;
			var dy:Number = rayOrigin.y - origin.y;
			var dz:Number = rayOrigin.z - origin.z;
			
			var a:Number = (rayDir.x * dx + rayDir.y * dy + rayDir.z * dz) * 2;
			
			var b:Number = a * a - 4 * (dx * dx + dy * dy + dz * dz - _radius2);
			
			if (b < 0) {
				return false;
			} else {
				a *= -a;
				
				return (a + b >= 0) || (a - b >= 0);
			}
		}
		public override function intersectRay(ray:Ray):Number {
			var rayOrigin:Float3 = ray.origin;
			var rayDir:Float3 = ray.direction;
			
			if (rayOrigin == null || rayDir == null || origin == null) return -1;
			
			var dx:Number = rayOrigin.x - origin.x;
			var dy:Number = rayOrigin.y - origin.y;
			var dz:Number = rayOrigin.z - origin.z;
			
			var a:Number = (rayDir.x * dx + rayDir.y * dy + rayDir.z * dz) * 2;
			
			var b:Number = a * a - 4 * (dx * dx + dy * dy + dz * dz - _radius2);
			
			if (b < 0) {
				return -1;
			} else {
				b = Math.sqrt(b);
				
				var t0:Number = b - a;
				var t1:Number = -a - b;
				
				if (t0 >= 0) {
					if (t1 >= 0) {
						if (t1 < t0) t0 = t1;
						return t0 / 2;
					} else {
						return t0 / 2;
					}
				} else if (t1 >= 0) {
					return  t1 / 2;
				} else {
					return -1;
				}
			}
		}
		public function clone():BoundingSphere {
			var bs:BoundingSphere = new BoundingSphere(null, _radius);
			if (origin != null) bs.origin = origin.clone();
			return bs;
		}
		public override function updateGlobal(m:Matrix4x4):void {
			globalOrigin = m.transform3x4Float3(origin, globalOrigin);
			
			globalRadius = m.getAxisX(_tempFloat3).length;
			var s:Number = m.getAxisY(_tempFloat3).length;
			if (globalRadius < s) globalRadius = s;
			s = m.getAxisZ(_tempFloat3).length;
			if (globalRadius < s) globalRadius = s;
			globalRadius *= _radius;
		}
	}
}