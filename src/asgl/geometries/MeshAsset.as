package asgl.geometries {
	public class MeshAsset {
		public var triangleIndices:Vector.<uint>;
		
		public var elements:Object;
		
		/**
		 * materialIndicesMap[materialName:String] = triangleFaceIndices:Vector.<uint>.
		 */
		public var materialIndicesMap:Object;
		public var materialName:String;
		
		public var name:String;
		
		public function MeshAsset() {
			elements = {};
		}
		public function clear():void {
			triangleIndices = null;
			
			for (var any:* in elements) {
				elements = {};
				break;
			}
		}
		public function getElement(type:*):MeshElement {
			return elements[type];
		}
	}
}