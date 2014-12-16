package asgl.codec.models.max3ds {
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import asgl.geometries.MeshAsset;
	import asgl.geometries.MeshElement;
	import asgl.geometries.MeshElementType;
	
	public class Max3DSEncoder {
		public function Max3DSEncoder() {
			
		}
		/**
		 * @param meshAssets.</br>
		 * need meshAsset elenemts:</br>
		 * must:meshAsset.vertices, meshAsset.vertexIndices.</br>
		 */
		public function encode(meshAssets:Vector.<MeshAsset>, transformLRH:Boolean=false, generateTexCoords:Boolean=true, generateMaterialInfo:Boolean=true):ByteArray {
			var bytes:ByteArray = new ByteArray();
			bytes.endian = Endian.LITTLE_ENDIAN;
			bytes.writeShort(Max3DSChunk.MAIN3DS);
			bytes.writeUnsignedInt(0);
			
			bytes.writeShort(Max3DSChunk.EDIT3DS);
			var edit3DSPos:uint = bytes.position;
			bytes.writeUnsignedInt(0);
			
			var length:int = meshAssets.length;
			var defaultNameCount:int = 0;
			for (var i:int = 0; i < length; i++) {
				var meshAsset:MeshAsset = meshAssets[i];
				
				bytes.writeShort(Max3DSChunk.EDIT_OBJECT);
				var editObjPos:uint = bytes.position;
				bytes.writeUnsignedInt(0);
				bytes.writeMultiByte(meshAsset.name == null ? 'Object' + (defaultNameCount++) : meshAsset.name, 'utf-8');
				bytes.writeByte(0);
				
				bytes.writeShort(Max3DSChunk.OBJ_TRIMESH);
				var objTriMeshPos:uint = bytes.position;
				bytes.writeUnsignedInt(0);
				
				bytes.writeShort(Max3DSChunk.TRI_VERTEX);
				var triVertexPos:uint = bytes.position;
				bytes.writeUnsignedInt(0);
				var vertices:MeshElement = meshAsset.elements[MeshElementType.VERTEX];
				var max:uint = vertices.values.length;
				bytes.writeShort(max / 3);
				for (var j:uint = 0; j < max; j += 3) {
					bytes.writeFloat(vertices.values[j]);
					if (transformLRH) {
						bytes.writeFloat(vertices.values[int(j + 2)]);
						bytes.writeFloat(vertices.values[int(j + 1)]);
					} else {
						bytes.writeFloat(vertices.values[int(j + 1)]);
						bytes.writeFloat(vertices.values[int(j + 2)]);
					}
				}
				bytes.position = triVertexPos;
				bytes.writeUnsignedInt(bytes.length - triVertexPos + 2);
				bytes.position = bytes.length;
				
				if (generateTexCoords && MeshElementType.TEXCOORD in meshAsset.elements) {
					bytes.writeShort(Max3DSChunk.TRI_UV);
					var triUVPos:uint = bytes.position;
					bytes.writeUnsignedInt(0);
					var texCoords:MeshElement = meshAsset.elements[MeshElementType.TEXCOORD];
					max = texCoords.values.length;
					bytes.writeShort(max * 0.5);
					for (j = 0; j < max; j += 2) {
						bytes.writeFloat(texCoords.values[j]);
						bytes.writeFloat(1 - texCoords.values[int(j + 1)]);
					}
					bytes.position = triUVPos;
					bytes.writeUnsignedInt(bytes.length - triUVPos + 2);
					bytes.position = bytes.length;
				}
				
				bytes.writeShort(Max3DSChunk.TRI_FACEVERT);
				var triFaceVertPos:uint = bytes.position;
				bytes.writeUnsignedInt(0);
				var vertexIndices:Vector.<uint> = meshAsset.triangleIndices;
				max = vertexIndices.length;
				bytes.writeShort(max / 3);
				for (j = 0; j < max; j += 3) {
					if (transformLRH) {
						bytes.writeShort(vertexIndices[int(j + 1)]);
						bytes.writeShort(vertexIndices[j]);
					} else {
						bytes.writeShort(vertexIndices[j]);
						bytes.writeShort(vertexIndices[int(j + 1)]);
					}
					bytes.writeShort(vertexIndices[int(j + 2)]);
					bytes.writeShort(5);
				}
				
				if (generateMaterialInfo && meshAsset.materialName != null) {
					bytes.writeShort(Max3DSChunk.TRI_FACEMAT);
					var triFaceMatPos:uint = bytes.position;
					bytes.writeUnsignedInt(0);
					max = meshAsset.triangleIndices.length / 3;
					bytes.writeMultiByte(meshAsset.materialName, 'utf-8');
					bytes.writeByte(0);
					bytes.writeShort(max);
					for (j = 0; j < max; j++) {
						bytes.writeShort(j);
					}
					bytes.position = triFaceMatPos;
					bytes.writeUnsignedInt(bytes.length - triFaceMatPos + 2);
					bytes.position = bytes.length;
				}
				
				bytes.position = triFaceVertPos;
				bytes.writeUnsignedInt(bytes.length - triFaceVertPos + 2);
				
				bytes.position = objTriMeshPos;
				bytes.writeUnsignedInt(bytes.length - objTriMeshPos + 2);
				
				bytes.position = editObjPos;
				bytes.writeUnsignedInt(bytes.length - editObjPos + 2);
				bytes.position = bytes.length;
			}
			
			bytes.position = edit3DSPos;
			bytes.writeUnsignedInt(bytes.length - edit3DSPos + 2);
			bytes.position = bytes.length;
			
			bytes.position = 2;
			bytes.writeUnsignedInt(bytes.length);
			
			return bytes;
		}
	}
}