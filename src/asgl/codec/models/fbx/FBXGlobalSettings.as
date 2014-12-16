package asgl.codec.models.fbx {

	public class FBXGlobalSettings extends FBXNode {
		public var timeMode:uint;
		public var timeSpanStart:Number;
		public var timeSpanStop:Number;
		
		public function FBXGlobalSettings() {
			name = FBXNodeName.GLOBAL_SETTINGS;
		}
		public override function update():void {
			var len:uint = children.length;
			for (var i:uint = 0; i < len; i++) {
				var child:FBXNode = children[i];
				var name:String = child.name;
				if (name == FBXNodeName.PROPERTIES70) {
					_parseProperties70(child);
				}
			}
		}
		private function _parseProperties70(node:FBXNode):void {
			var len:uint = node.children.length;
			for (var i:uint = 0; i < len; i++) {
				var child:FBXNode = node.children[i];
				var name:String = child.name;
				if (name == FBXNodeName.P) {
					_parseP(child);
				}
			}
		}
		private function _parseP(node:FBXNode):void {
			if (node.properties.length > 0) {
				var p1:String = node.properties[0].stringValue;
				if (p1 == FBXNodePropertyValue.TIME_MODE) {
					timeMode = node.properties[4].intValue;
				} else if (p1 == FBXNodePropertyValue.TIME_SPAN_START) {
					timeSpanStart = node.properties[4].numberValue / FBXTime.SECOND;
				} else if (p1 == FBXNodePropertyValue.TIME_SPAN_STOP) {
					timeSpanStop = node.properties[4].numberValue / FBXTime.SECOND;
				}
			}
		}
	}
}