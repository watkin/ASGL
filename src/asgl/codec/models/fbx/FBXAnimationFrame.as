package asgl.codec.models.fbx {
	public class FBXAnimationFrame {
		public var time:Number;
		
		/**
		 * bones[boneName:String] = FBXAnimationFrameData;
		 */
		public var bones:Object;
		
		public function FBXAnimationFrame() {
			bones = {};
		}
	}
}