package asgl.codec.models.fbx {
	import asgl.math.Matrix4x4;

	public class FBXDeformer extends FBXNode {
		public var id:Number;
		public var type:String;
		
		public var indices:Vector.<uint>;
		public var weights:Vector.<Number>;
		
		public var transformMatrix:Matrix4x4;
		public var transformLinkMatrix:Matrix4x4;
		
		public function FBXDeformer() {
			name = FBXNodeName.DEFORMER;
		}
		public override function update():void {
			id = properties[0].numberValue;
			if (properties.length > 2) type = properties[2].stringValue;
			
			var len:uint = children.length;
			for (var i:uint = 0; i < len; i++) {
				var child:FBXNode = children[i];
				var name:String = child.name;
				if (name == FBXNodeName.INDEXES) {
					if (child.properties[0].arrayIntValue == null) {
						indices = new Vector.<uint>(child.properties.length);
						_pushValueToVector(indices, child.properties);
					} else {
						indices = Vector.<uint>(child.properties[0].arrayIntValue);
					}
				} else if (name == FBXNodeName.WEIGHTS) {
					if (child.properties[0].arrayNumberValue == null) {
						weights = new Vector.<Number>(child.properties.length);
						_pushValueToVector(weights, child.properties);
					} else {
						weights = child.properties[0].arrayNumberValue.concat();
					}
				} else if (name == FBXNodeName.TRANSFORM) {
					transformMatrix = new Matrix4x4();
					if (child.properties[0].arrayNumberValue == null) {
						_pushValueToMatrix(transformMatrix, child.properties);
					} else {
						transformMatrix.copyDataFromVector(child.properties[0].arrayNumberValue);
					}
				} else if (name == FBXNodeName.TRANSFORM_LINK) {
					transformLinkMatrix = new Matrix4x4();
					if (child.properties[0].arrayNumberValue == null) {
						_pushValueToMatrix(transformLinkMatrix, child.properties);
					} else {
						transformLinkMatrix.copyDataFromVector(child.properties[0].arrayNumberValue);
					}
				}
			}
		}
		private function _pushValueToMatrix(m:Matrix4x4, properties:Vector.<FBXNodeProperty>):void {
			m.m00 = properties[0].value;
			m.m01 = properties[1].value;
			m.m02 = properties[2].value;
			m.m03 = properties[3].value;
			
			m.m10 = properties[4].value;
			m.m11 = properties[5].value;
			m.m12 = properties[6].value;
			m.m13 = properties[7].value;
			
			m.m20 = properties[8].value;
			m.m21 = properties[9].value;
			m.m22 = properties[10].value;
			m.m23 = properties[11].value;
			
			m.m30 = properties[12].value;
			m.m31 = properties[13].value;
			m.m32 = properties[14].value;
			m.m33 = properties[15].value;
		}
		private function _pushValueToVector(arr:Object, properties:Vector.<FBXNodeProperty>):void {
			var len:uint = properties.length;
			for (var i:uint = 0; i < len; i++) {
				var p:FBXNodeProperty = properties[i];
				arr[i] = properties[i].value;
			}
		}
	}
}