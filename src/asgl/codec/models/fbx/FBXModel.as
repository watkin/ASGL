package asgl.codec.models.fbx {
	import asgl.entities.Object3D;
	import asgl.math.Float3;
	import asgl.math.Float4;

	public class FBXModel extends FBXNode {
		public var id:Number;
		
		public var modelName:String;
		public var type:String;
		
		public var position:Float3;
		public var rotation:Float3;
		public var scale:Float3;
		
		public function FBXModel() {
			name = FBXNodeName.MODEL;
		}
		public function createObject3D(transformLRH:Boolean):Object3D {
			var obj:Object3D = new Object3D();
			obj.name = modelName;
			
			if (position != null) {
				if (transformLRH) {
					obj.setLocalPosition(position.x, position.z, position.y);
				} else {
					obj.setLocalPosition(position.x, position.y, position.z);
				}
			}
			
			if (scale != null) {
				if (transformLRH) {
					obj.setLocalScale(scale.x, scale.z, scale.y);
				} else {
					obj.setLocalScale(scale.x, scale.y, scale.z);
				}
			}
			
			if (rotation != null) {
				var quat:Float4;
				if (transformLRH) {
					quat = Float4.createEulerXYZQuaternion(rotation.x, rotation.z, rotation.y);
				} else {
					quat = Float4.createEulerXYZQuaternion(rotation.x, rotation.y, rotation.z);
				}
				
				obj.setLocalRotation(quat);
			}
			
			return obj;
		}
		public override function update():void {
			id = properties[0].numberValue;
			//modelName = properties[1].stringValue;
			if (properties.length > 2) type = properties[2].stringValue;
			
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
				if (p1 == FBXNodePropertyValue.LCL_TRANSLATION) {
					position = new Float3(node.properties[4].numberValue, node.properties[5].numberValue, node.properties[6].numberValue);
				} else if (p1 == FBXNodePropertyValue.LCL_SCALING) {
					scale = new Float3(node.properties[4].numberValue, node.properties[5].numberValue, node.properties[6].numberValue);
				} else if (p1 == FBXNodePropertyValue.LCL_ROTATION) {
					rotation = new Float3(node.properties[4].numberValue, node.properties[5].numberValue, node.properties[6].numberValue);
				} else {
					//trace(node);
				}
			}
		}
	}
}