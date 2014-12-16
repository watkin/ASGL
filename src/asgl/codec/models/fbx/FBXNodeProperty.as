package asgl.codec.models.fbx {
	public class FBXNodeProperty {
		public var type:uint;
		public var intValue:int;
		public var numberValue:Number;
		public var stringValue:String;
		public var arrayIntValue:Vector.<int>;
		public var arrayNumberValue:Vector.<Number>;
		
		public var value:*;
		
		public function FBXNodeProperty() {
		}
		public function update():void {
			if (type == FBXNodePropertyValueType.ARRAY_INT_PROPERTY) {
				value = arrayIntValue;
			} else if (type == FBXNodePropertyValueType.ARRAY_NUMBER_PROPERTY) {
				value = arrayNumberValue;
			} else if (type == FBXNodePropertyValueType.INT_PROPERTY) {
				value = intValue;
			} else if (type == FBXNodePropertyValueType.NUMBER_PROPERTY) {
				value = numberValue;
			} else if (type == FBXNodePropertyValueType.STRING_PROPERTY) {
				value = stringValue;
			}
		}
	}
}