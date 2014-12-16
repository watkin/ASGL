package asgl.bounds {
	import asgl.asgl_protected;
	import asgl.math.Float3;
	import asgl.math.Matrix4x4;
	import asgl.physics.Ray;
	
	use namespace asgl_protected;

	public class BoundingVolume {
		protected static var _tempFloat3:Float3 = new Float3();
		
		asgl_protected var _type:int;
		
		public function BoundingVolume() {
		}
		public function get type():int {
			return _type;
		}
		public function hitRay(ray:Ray):Boolean {
			return false;
		}
		public function intersectRay(ray:Ray):Number {
			return -1;
		}
		public function updateGlobal(m:Matrix4x4):void {
		}
	}
}