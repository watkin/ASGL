package asgl.entities {
	
	public class EntityAsset {
		public var entities:Vector.<Object3D>;
		public var rootEntities:Vector.<Object3D>;
		
		/**
		 * entityIndicesByNameMap[enityName:String] = index:uint
		 */
		public var entityIndicesByNameMap:Object;
		public var entityByNamesOrder:Vector.<String>;
		
		public function EntityAsset() {
		}
		public function createEntityOrderData():void {
			if (entities != null && (entityIndicesByNameMap == null || entityByNamesOrder == null)) {
				var length:int = entities.length;
				
				entityIndicesByNameMap = {};
				entityByNamesOrder = new Vector.<String>(length);
				
				for (var i:int = 0; i < length; i++) {
					var name:String = entities[i].name;
					entityByNamesOrder[i] = name;
					entityIndicesByNameMap[name] = i;
				}
			}
		}
	}
}

