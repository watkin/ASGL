package asgl.geometries {
	public class MeshElement {
		public var values:Vector.<Number>;
		public var indices:Vector.<uint>;
		public var valueMappingType:int;
		public var numDataPreElement:uint;
		
		public function MeshElement() {
		}
		public function clone():MeshElement {
			var op:MeshElement = new MeshElement();
			
			op.valueMappingType = valueMappingType;
			op.numDataPreElement = numDataPreElement;
			
			if (values != null) op.values = values.concat();
			if (indices != null) op.indices = indices.concat();
			
			return op;
		}
		public function appendValues(data:Vector.<Number>):void {
			values = values.concat(data);
		}
		public function transformLRH():void {
			if (numDataPreElement == 3) {
				var i:int;
				var i2:int;
				var y:Number;
				var len:int = values.length;
				
				for (i = 1; i < len; i += 3) {
					i2 = i + 1;
					
					y = values[i];
					values[i] = values[i2];
					values[i2] = y;
				}
				
				if (valueMappingType == MeshElementValueMappingType.SELF_TRIANGLE_INDEX) {
					len = indices.length;
					for (i = 0; i < len; i += 3) {
						var i0:uint = indices[i];
						
						if (transformLRH) {
							indices[i] = indices[int(i + 1)];
							indices[int(i + 1)] = i0;
						}
					}
				} else if (valueMappingType == MeshElementValueMappingType.EACH_TRIANGLE_INDEX) {
					for (i = 0; i < len; i += 9) {
						var i1:int = i + 1;
						i2 = i + 2;
						var i3:int = i + 3;
						var i4:int = i + 4;
						var i5:int = i + 5;
						
						var x:Number = values[i];
						y = values[i1];
						var z:Number = values[i2];
						
						values[i] = values[i3];
						values[i1] = values[i4];
						values[i2] = values[i5];
						
						values[i3] = x;
						values[i4] = y;
						values[i5] = z;
					}
				}
			}
		}
	}
}