package asgl.bounds {
	import asgl.asgl_protected;
	import asgl.math.Matrix4x4;
	
	use namespace asgl_protected;

	public class BoundingOrientedBox extends AbstractBoundingBox {
		public var globalVertices:Vector.<Number>;
		
		public function BoundingOrientedBox(minX:Number=0, maxX:Number=0, minY:Number=0, maxY:Number=0, minZ:Number=0, maxZ:Number=0) {
			super(minX, maxX, minY, maxY, minZ, maxZ);
			
			_type = BoundingVolumeType.OBB;
			
			globalVertices = new Vector.<Number>(24);
		}
		public function clone():BoundingOrientedBox {
			return new BoundingOrientedBox(minX, maxX, minY, maxY, minZ, maxZ);
		}
		public override function updateGlobal(m:Matrix4x4):void {
			m.transform4x4Number3(minX, minY, minZ, _tempFloat3);
			globalVertices[0] = _tempFloat3.x;
			globalVertices[1] = _tempFloat3.y;
			globalVertices[2] = _tempFloat3.z;
			m.transform4x4Number3(maxX, minY, minZ, _tempFloat3);
			globalVertices[3] = _tempFloat3.x;
			globalVertices[4] = _tempFloat3.y;
			globalVertices[5] = _tempFloat3.z;
			m.transform4x4Number3(maxX, minY, maxZ, _tempFloat3);
			globalVertices[6] = _tempFloat3.x;
			globalVertices[7] = _tempFloat3.y;
			globalVertices[8] = _tempFloat3.z;
			m.transform4x4Number3(minX, minY, maxZ, _tempFloat3);
			globalVertices[9] = _tempFloat3.x;
			globalVertices[10] = _tempFloat3.y;
			globalVertices[11] = _tempFloat3.z;
			m.transform4x4Number3(minX, maxY, minZ, _tempFloat3);
			globalVertices[12] = _tempFloat3.x;
			globalVertices[13] = _tempFloat3.y;
			globalVertices[14] = _tempFloat3.z;
			m.transform4x4Number3(maxX, maxY, minZ, _tempFloat3);
			globalVertices[15] = _tempFloat3.x;
			globalVertices[16] = _tempFloat3.y;
			globalVertices[17] = _tempFloat3.z;
			m.transform4x4Number3(maxX, maxY, maxZ, _tempFloat3);
			globalVertices[18] = _tempFloat3.x;
			globalVertices[19] = _tempFloat3.y;
			globalVertices[20] = _tempFloat3.z;
			m.transform4x4Number3(minX, maxY, maxZ, _tempFloat3);
			globalVertices[21] = _tempFloat3.x;
			globalVertices[22] = _tempFloat3.y;
			globalVertices[23] = _tempFloat3.z;
		}
	}
}