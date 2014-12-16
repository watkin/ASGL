package asgl.codec.models.fbx {
	public class FBXNode {
		public var name:String;
		public var properties:Vector.<FBXNodeProperty>;
		public var children:Vector.<FBXNode>;
		
		public function FBXNode() {
			properties = new Vector.<FBXNodeProperty>();
			children = new Vector.<FBXNode>();
		}
		public function getNode(name:String):FBXNode {
			var len:uint = children.length;
			for (var i:uint = 0; i < len; i++) {
				var child:FBXNode = children[i];
				if (child.name == name) return child;
			}
			
			return null;
		}
		public function hasNode(name:String):Boolean {
			var len:uint = children.length;
			for (var i:uint = 0; i < len; i++) {
				var child:FBXNode = children[i];
				if (child.name == name) return true;
			}
			
			return false;
		}
		public function toString(indent:String=''):String {
			var j:uint;
			var max:uint;
			
			var op:String = indent + 'FBX Node \n' +
				indent + '  name : ' + name + '\n';
			
			var len:uint = properties.length;
			for (var i:uint = 0; i < len; i++) {
				var p:FBXNodeProperty = properties[i];
				
				op += indent + '  property' + (i + 1) + ' : ';
				if (p.type == FBXNodePropertyValueType.INT_PROPERTY) {
					op += p.intValue;
				} else if (p.type == FBXNodePropertyValueType.NUMBER_PROPERTY) {
					op += p.numberValue;
				} else if (p.type == FBXNodePropertyValueType.STRING_PROPERTY) {
					op += '"' + p.stringValue + '"';
				} else if (p.type == FBXNodePropertyValueType.ARRAY_INT_PROPERTY) {
					op += '(' + p.arrayIntValue.length + ')[';
					max = 9;
					if (max > p.arrayIntValue.length) max = p.arrayIntValue.length;
					
					for (j = 0; j < max; j++) {
						if (j != 0) op += ', ';
						op += p.arrayIntValue[j];
					}
					
					if (max < p.arrayIntValue.length) op += '......';
					op += ']';
				} else if (p.type == FBXNodePropertyValueType.ARRAY_NUMBER_PROPERTY) {
					op += '(' + p.arrayNumberValue.length + ')[';
					max = 9;
					if (max > p.arrayNumberValue.length) max = p.arrayNumberValue.length;
					
					for (j = 0; j < max; j++) {
						if (j != 0) op += ', ';
						op += p.arrayNumberValue[j];
					}
					
					if (max < p.arrayNumberValue.length) op += '......';
					op += ']';
				}
				
				op += '\n';
			}
			
			len = children.length;
			for (i = 0; i < len; i++) {
				op += children[i].toString(indent + '  ');
			}
			
			return op;
		}
		public function update():void {
		}
	}
}