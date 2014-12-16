package asgl.codec.models.fbx {
	public class FBXSubConnection extends FBXNode {
		public var currentID:Number;
		public var parentID:Number;
		public var param:String;
		
		public function FBXSubConnection() {
			name = FBXNodeName.C;
		}
		public override function update():void {
			currentID = properties[1].numberValue;
			parentID = properties[2].numberValue;
			param = properties.length > 3 ? properties[3].stringValue : null;
		}
	}
}