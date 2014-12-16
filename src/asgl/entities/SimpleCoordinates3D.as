package asgl.entities {
	import asgl.math.Float3;
	import asgl.math.Float4;
	import asgl.math.Matrix4x4;
	
	public class SimpleCoordinates3D {
		private static var _tempMatrix:Matrix4x4 = new Matrix4x4();
		
		public var scale:Float3;
		public var rotation:Float4;
		public var matrix:Matrix4x4;
		
		public function SimpleCoordinates3D() {
			scale = new Float3(1, 1, 1);
			rotation = new Float4();
			matrix = new Matrix4x4();
		}
		public function clone():SimpleCoordinates3D {
			var op:SimpleCoordinates3D = new SimpleCoordinates3D();
			
			op.scale.copyDataFromFloat3(scale);
			op.rotation.copyDataFromFloat4(rotation);
			op.matrix.copyDataFromMatrix4x4(matrix);
			
			return op;
		}
		public function copy(sc:SimpleCoordinates3D):void {
			scale.copyDataFromFloat3(sc.scale);
			rotation.copyDataFromFloat4(sc.rotation);
			matrix.copyDataFromMatrix4x4(sc.matrix);
		}
		public static function slerp(sc1:SimpleCoordinates3D, sc2:SimpleCoordinates3D, t:Number, op:SimpleCoordinates3D=null):SimpleCoordinates3D {
			op ||= new SimpleCoordinates3D();
			
			Matrix4x4.slerp(sc1.matrix, sc2.matrix, t, op.matrix);
			Float3.lerp(sc1.scale, sc2.scale, t, op.scale);
			Float4.slerpQuaternion(sc1.rotation, sc2.rotation, t, op.rotation);
			
			return op;
		}
		public function updateMatrix():void {
			var x2:Number = rotation.x * 2;
			var y2:Number = rotation.y * 2;
			var z2:Number = rotation.z * 2;
			var xx:Number = rotation.x * x2;
			var xy:Number = rotation.x * y2;
			var xz:Number = rotation.x * z2;
			var yy:Number = rotation.y * y2;
			var yz:Number = rotation.y * z2;
			var zz:Number = rotation.z * z2;
			var wx:Number = rotation.w * x2;
			var wy:Number = rotation.w * y2;
			var wz:Number = rotation.w * z2;
			matrix.m00 = (1 - yy - zz) * scale.x;
			matrix.m01 = (xy + wz) * scale.x;
			matrix.m02 = (xz - wy) * scale.x;
			
			matrix.m10 = (xy - wz) * scale.y;
			matrix.m11 = (1 - xx - zz) * scale.y;
			matrix.m12 = (yz + wx) * scale.y;
			
			matrix.m20 = (xz + wy) * scale.z;
			matrix.m21 = (yz - wx) * scale.z;
			matrix.m22 = (1 - xx - yy) * scale.z;
		}
		public function updateTRS():void {
			matrix.decomposition(_tempMatrix, scale);
			
			var m:Matrix4x4 = _tempMatrix;
			var opFloat4:Float4 = rotation;
			
			include '../math/Matrix4x4_getQuaternion.define';
		}
	}
}