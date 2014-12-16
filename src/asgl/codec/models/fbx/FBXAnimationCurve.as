package asgl.codec.models.fbx {
	public class FBXAnimationCurve extends FBXNode {
		public var id:Number;
		public var keyTime:Vector.<Number>;
		public var keyValueFloat:Vector.<Number>;
		
		public function FBXAnimationCurve() {
			name = FBXNodeName.ANIMATION_CURVE;
		}
		public override function update():void {
			id = properties[0].numberValue;
			
			var len:uint = children.length;
			for (var i:uint = 0; i < len; i++) {
				var child:FBXNode = children[i];
				var name:String = child.name;
				if (name == FBXNodeName.KEY_TIME) {
					keyTime = child.properties[0].arrayNumberValue;
				} else if (name == FBXNodeName.KEY_VALUE_FLOAT) {
					keyValueFloat = child.properties[0].arrayNumberValue;
				}
			}
		}
	}
}