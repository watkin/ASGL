package asgl.codec.models.fbx {
	public class FBXAnimationCurveNode extends FBXNode {
		public var id:Number;
		
		public function FBXAnimationCurveNode() {
			name = FBXNodeName.ANIMATION_CURVE_NODE;
		}
		public override function update():void {
			id = properties[0].numberValue;
		}
	}
}