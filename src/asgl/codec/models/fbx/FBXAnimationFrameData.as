package asgl.codec.models.fbx {
	import asgl.math.Float3;
	import asgl.math.Float4;

	public class FBXAnimationFrameData {
		public var position:Float3;
		public var rotationXYZ:Float3;
		public var rotationQuat:Float4;
		public var scale:Float3;
		
		public function FBXAnimationFrameData() {
		}
	}
}