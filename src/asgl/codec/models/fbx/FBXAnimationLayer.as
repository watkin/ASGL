package asgl.codec.models.fbx {
	public class FBXAnimationLayer extends FBXNode {
		public var id:Number;
		
		public function FBXAnimationLayer() {
			name = FBXNodeName.ANIMATION_LAYER;
		}
		public override function update():void {
			id = properties[0].numberValue;
		}
	}
}