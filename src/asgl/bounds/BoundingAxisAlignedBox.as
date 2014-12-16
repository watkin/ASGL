package asgl.bounds {
	import asgl.asgl_protected;
	import asgl.math.Matrix4x4;
	
	use namespace asgl_protected;

	public class BoundingAxisAlignedBox extends AbstractBoundingBox {
		public var globalMaxX:Number;
		public var globalMaxY:Number;
		public var globalMaxZ:Number;
		public var globalMinX:Number;
		public var globalMinY:Number;
		public var globalMinZ:Number;
		
		public function BoundingAxisAlignedBox(minX:Number=0, maxX:Number=0, minY:Number=0, maxY:Number=0, minZ:Number=0, maxZ:Number=0) {
			super(minX, maxX, minY, maxY, minZ, maxZ);
			
			_type = BoundingVolumeType.AABB;
		}
		public function clone():BoundingAxisAlignedBox {
			return new BoundingAxisAlignedBox(minX, maxX, minY, maxY, minZ, maxZ);
		}
		public override function updateGlobal(m:Matrix4x4):void {
			m.transform4x4Number3(minX, minY, minZ, _tempFloat3);
			globalMinX = _tempFloat3.x;
			globalMinY = _tempFloat3.y;
			globalMinZ = _tempFloat3.z;
			globalMaxX = globalMinX;
			globalMaxY = globalMinY;
			globalMaxZ = globalMinZ;
			m.transform4x4Number3(maxX, minY, minZ, _tempFloat3);
			if (globalMinX > _tempFloat3.x) {
				globalMinX = _tempFloat3.x;
			} else if (globalMaxX < _tempFloat3.x) {
				globalMaxX = _tempFloat3.x;
			}
			if (globalMinY > _tempFloat3.y) {
				globalMinY = _tempFloat3.y;
			} else if (globalMaxY < _tempFloat3.y) {
				globalMaxY = _tempFloat3.y;
			}
			if (globalMinZ > _tempFloat3.z) {
				globalMinZ = _tempFloat3.z;
			} else if (globalMaxZ < _tempFloat3.z) {
				globalMaxZ = _tempFloat3.z;
			}
			m.transform4x4Number3(maxX, minY, maxZ, _tempFloat3);
			if (globalMinX > _tempFloat3.x) {
				globalMinX = _tempFloat3.x;
			} else if (globalMaxX < _tempFloat3.x) {
				globalMaxX = _tempFloat3.x;
			}
			if (globalMinY > _tempFloat3.y) {
				globalMinY = _tempFloat3.y;
			} else if (globalMaxY < _tempFloat3.y) {
				globalMaxY = _tempFloat3.y;
			}
			if (globalMinZ > _tempFloat3.z) {
				globalMinZ = _tempFloat3.z;
			} else if (globalMaxZ < _tempFloat3.z) {
				globalMaxZ = _tempFloat3.z;
			}
			m.transform4x4Number3(minX, minY, maxZ, _tempFloat3);
			if (globalMinX > _tempFloat3.x) {
				globalMinX = _tempFloat3.x;
			} else if (globalMaxX < _tempFloat3.x) {
				globalMaxX = _tempFloat3.x;
			}
			if (globalMinY > _tempFloat3.y) {
				globalMinY = _tempFloat3.y;
			} else if (globalMaxY < _tempFloat3.y) {
				globalMaxY = _tempFloat3.y;
			}
			if (globalMinZ > _tempFloat3.z) {
				globalMinZ = _tempFloat3.z;
			} else if (globalMaxZ < _tempFloat3.z) {
				globalMaxZ = _tempFloat3.z;
			}
			m.transform4x4Number3(minX, maxY, minZ, _tempFloat3);
			if (globalMinX > _tempFloat3.x) {
				globalMinX = _tempFloat3.x;
			} else if (globalMaxX < _tempFloat3.x) {
				globalMaxX = _tempFloat3.x;
			}
			if (globalMinY > _tempFloat3.y) {
				globalMinY = _tempFloat3.y;
			} else if (globalMaxY < _tempFloat3.y) {
				globalMaxY = _tempFloat3.y;
			}
			if (globalMinZ > _tempFloat3.z) {
				globalMinZ = _tempFloat3.z;
			} else if (globalMaxZ < _tempFloat3.z) {
				globalMaxZ = _tempFloat3.z;
			}
			m.transform4x4Number3(maxX, maxY, minZ, _tempFloat3);
			if (globalMinX > _tempFloat3.x) {
				globalMinX = _tempFloat3.x;
			} else if (globalMaxX < _tempFloat3.x) {
				globalMaxX = _tempFloat3.x;
			}
			if (globalMinY > _tempFloat3.y) {
				globalMinY = _tempFloat3.y;
			} else if (globalMaxY < _tempFloat3.y) {
				globalMaxY = _tempFloat3.y;
			}
			if (globalMinZ > _tempFloat3.z) {
				globalMinZ = _tempFloat3.z;
			} else if (globalMaxZ < _tempFloat3.z) {
				globalMaxZ = _tempFloat3.z;
			}
			m.transform4x4Number3(maxX, maxY, maxZ, _tempFloat3);
			if (globalMinX > _tempFloat3.x) {
				globalMinX = _tempFloat3.x;
			} else if (globalMaxX < _tempFloat3.x) {
				globalMaxX = _tempFloat3.x;
			}
			if (globalMinY > _tempFloat3.y) {
				globalMinY = _tempFloat3.y;
			} else if (globalMaxY < _tempFloat3.y) {
				globalMaxY = _tempFloat3.y;
			}
			if (globalMinZ > _tempFloat3.z) {
				globalMinZ = _tempFloat3.z;
			} else if (globalMaxZ < _tempFloat3.z) {
				globalMaxZ = _tempFloat3.z;
			}
			m.transform4x4Number3(minX, maxY, maxZ, _tempFloat3);
			if (globalMinX > _tempFloat3.x) {
				globalMinX = _tempFloat3.x;
			} else if (globalMaxX < _tempFloat3.x) {
				globalMaxX = _tempFloat3.x;
			}
			if (globalMinY > _tempFloat3.y) {
				globalMinY = _tempFloat3.y;
			} else if (globalMaxY < _tempFloat3.y) {
				globalMaxY = _tempFloat3.y;
			}
			if (globalMinZ > _tempFloat3.z) {
				globalMinZ = _tempFloat3.z;
			} else if (globalMaxZ < _tempFloat3.z) {
				globalMaxZ = _tempFloat3.z;
			}
		}
	}
}