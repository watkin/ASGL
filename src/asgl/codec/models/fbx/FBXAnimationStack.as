package asgl.codec.models.fbx {
	public class FBXAnimationStack extends FBXNode {
		public var id:Number;
		public var animName:String;
		
		public function FBXAnimationStack() {
			name = FBXNodeName.ANIMATION_STACK;
		}
		public override function update():void {
			id = properties[0].numberValue;
			animName = properties[1].stringValue;
		}
	}
}