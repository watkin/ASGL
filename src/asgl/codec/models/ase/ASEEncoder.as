package asgl.codec.models.ase {
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import asgl.geometries.MeshAsset;
	import asgl.geometries.MeshElement;
	import asgl.geometries.MeshElementType;

	public class ASEEncoder {
		/**
		 * @param meshAssets.</br>
		 * need meshAsset elenemts:</br>
		 * must:meshAsset.vertices, meshAsset.vertexIndices.</br>
		 */
		public function encode(meshAssets:Vector.<MeshAsset>, transformLRH:Boolean=false, generateTexCoords:Boolean=true, generateMaterialInfo:Boolean=true):ByteArray {
			var string:String = '*ASGL ASEENCODER EXPORT';
			var length:int = meshAssets.length;
			var temp:String = '';
			var materialArray:Array = [];
			var j:int;
			for (var i:int = 0; i < length; i++) {
				var mo:MeshAsset = meshAssets[i];
				temp += '\n*GEOMOBJECT {'
				temp += '\n	*NODE_NAME "' + mo.name+'"';
				temp += '\n	*MESH {';
				var vertices:MeshElement = mo.elements[MeshElementType.VERTEX];
				var totalVertices:int = vertices.values.length;
				temp += '\n		*MESH_NUMVERTEX ' + totalVertices;
				var vertexIndices:Vector.<uint> = mo.triangleIndices;
				var totalFaces:int = vertexIndices.length;
				temp += '\n		*MESH_NUMFACES ' + totalFaces;
				temp += '\n		*MESH_VERTEX_LIST {';
				for (j = 0; j<totalVertices; j+=3){
					if (transformLRH) {
						temp += '\n			*MESH_VERTEX    ' + j + '	' + vertices.values[j] + '	' + vertices.values[int(j + 2)] + '	' + vertices.values[int(j + 1)];
					} else {
						temp += '\n			*MESH_VERTEX    ' + j + '	' + vertices.values[j] + '	' + vertices.values[int(j + 1)] + '	' + vertices.values[int(j + 2)];
					}
				}
				temp += '\n		}';//vertexList end
				temp += '\n		*MESH_FACE_LIST {';
				for (j = 0; j < totalFaces; j += 3) {
					if (transformLRH) {
						temp += '\n			*MESH_FACE    ' + j + ':    A:    ' + vertexIndices[j] + ' B:    ' + vertexIndices[int(j + 2)] + ' C:    ' + vertexIndices[int(j + 1)] + ' AB:    1 BC:    0 CA:    1	 *MESH_SMOOTHING 1 	*MESH_MTLID 0';
					} else {
						temp += '\n			*MESH_FACE    ' + j + ':    A:    ' + vertexIndices[j] + ' B:    ' + vertexIndices[int(j + 1)] + ' C:    ' + vertexIndices[int(j + 2)] + ' AB:    1 BC:    0 CA:    1	 *MESH_SMOOTHING 1 	*MESH_MTLID 0';
					}
				}
				temp += '\n		}';//faceList end
				
				if (generateTexCoords && mo.elements[MeshElementType.TEXCOORD] != null) {
					var texCoords:MeshElement = mo.elements[MeshElementType.TEXCOORD];
					var totalUV:int = texCoords.values.length;
					temp += '\n		*MESH_NUMTVERTEX ' + totalUV;
					temp += '\n		*MESH_TVERTLIST {';
					for (j = 0; j < totalUV; j += 2) {
						temp += '\n			*MESH_TVERT ' + j + '	' + texCoords.values[j] + '	' + texCoords.values[int(j + 1)] + '	0';
					}
					temp += '\n		}';//tvertList end
					temp += '\n		*MESH_NUMTVFACES ' + totalFaces;
					var list:Vector.<uint> = texCoords.indices;
					if (list == null) list = mo.triangleIndices;
					for (j = 0; j < totalFaces; j += 3) {
						if (transformLRH) {
							temp += '\n			*MESH_TFACE ' + j + '	' + list[j] + '	' + list[int(j + 2)] + '	' + list[int(j + 1)];
						} else {
							temp += '\n			*MESH_TFACE ' + j + '	' + list[j] + '	' + list[int(j + 1)] + '	' + list[int(j + 2)];
						}
					}
					temp += '\n		}';
				}
				temp += '\n	}'//mesh end
				if (generateMaterialInfo && mo.materialName != null) {
					var index:int = materialArray.indexOf(mo.materialName);
					if (index == -1) {
						index = materialArray.length;
						materialArray[index] = mo.materialName;
						
					}
					temp += '\n	*MATERIAL_REF ' + index;
				}
				temp += '\n}';
			}
			if (materialArray.length != 0) {
				string += '\n*MATERIAL_LIST {';
				var totalMaterials:int = materialArray.length;
				string += '\n	*MATERIAL_COUNT ' + totalMaterials;
				for (j = 0; j < totalMaterials; j++){
					string += '\n	*MATERIAL ' + j + ' {';
					string += '\n		*MATERIAL_NAME "' + materialArray[j] + '"';
					string += '\n	}';
				}
				string += '\n}';
			}
			string += temp;
			
			var bytes:ByteArray = new ByteArray();
			bytes.endian = Endian.LITTLE_ENDIAN;
			bytes.writeMultiByte(string, 'utf-8');
			
			return bytes;
		}
	}
}