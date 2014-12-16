package asgl.codec.models.ase {
	import asgl.geometries.MeshAsset;
	import asgl.geometries.MeshElement;
	import asgl.geometries.MeshElementType;
	import asgl.geometries.MeshElementValueMappingType;
	
	public class ASEDecoder {
		public var meshAssets:Vector.<MeshAsset>;
		
		public function ASEDecoder(data:String=null, transformLHorRH:Boolean=false) {
			if (data == null) {
				clear();
			} else {
				decode(data, transformLHorRH);
			}
		}
		public function clear():void {
			meshAssets = null;
		}
		public function decode(data:String, transformLRH:Boolean=false):void {
			clear();
			
			meshAssets = new Vector.<MeshAsset>();
			
			data = data.replace(/\r/, '\n');
			var list:Array = data.split('\n');
			var length:int = list.length;
			var line:String;
			var materialArray:Array = [];
			
			while ((line = list.shift()) != null) {
				var content:String;
				line = line.substr(line.indexOf('*') + 1);
				if(line.indexOf('}') >= 0) line = '';
				var meshAsset:MeshAsset;
				switch (line.substr(0,line.indexOf(' '))) {
					case 'GEOMOBJECT' : {
						break;
					}
					case 'MATERIAL_NAME' : {
						materialArray[materialArray.length] = line.substr(15, line.length - 1);
						break;
					}
					case 'MATERIAL_REF' : {
						var materialFaceIndexList:Object = meshAsset.materialIndicesMap;
						if (materialFaceIndexList == null) {
							materialFaceIndexList = {};
							meshAsset.materialIndicesMap = materialFaceIndexList;
						}
						var materialFaceIndex:Vector.<uint> = new Vector.<uint>();
						materialFaceIndexList[materialArray[int(line.substr(13))]] = materialFaceIndex;
						var totalFaces:int = meshAsset.triangleIndices.length / 3;
						for (var i:int = 0; i < totalFaces; i++) {
							materialFaceIndex[i] = i;
						}
						break;
					}
					case 'MESH_VERTEX_LIST' : {
						meshAsset = new MeshAsset();
						meshAssets[meshAssets.length] = meshAsset;
						var vertexList:MeshElement = new MeshElement();
						vertexList.numDataPreElement = 3;
						vertexList.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
						vertexList.values = new Vector.<Number>();
						meshAsset.elements[MeshElementType.VERTEX] = vertexList;
						
						var vertexListIndex:uint = 0;
						
						while(String(content = list.shift()).indexOf('}') < 0) {
							content = content.split('*')[1];
							var vcl:Array = content.split('\t');
							
							vertexList.values[vertexListIndex++] = vcl[1];
							
							if (transformLRH) {
								vertexList.values[vertexListIndex++] = vcl[3];
								vertexList.values[vertexListIndex++] = vcl[2];
							} else {
								vertexList.values[vertexListIndex++] = vcl[2];
								vertexList.values[vertexListIndex++] = vcl[3];
							}
						}
						break;
					}
					case 'MESH_FACE_LIST' : {
						var faceVertexIndexList:Vector.<uint> = new Vector.<uint>();
						meshAsset.triangleIndices = faceVertexIndexList;
						
						var faceVertexIndex:uint = 0;
						
						while(String(content = list.shift()).indexOf('}') < 0) {
							content = content.split('*')[1];
							var fvil:Array = content.split('\t')[0].split(':');
							
							if (transformLRH) {
								faceVertexIndexList[faceVertexIndex++] = int(fvil[3].substr(0, fvil[3].lastIndexOf(' ')));
								faceVertexIndexList[faceVertexIndex++] = int(fvil[2].substr(0, fvil[2].lastIndexOf(' ')));
							} else {
								faceVertexIndexList[faceVertexIndex++] = int(fvil[2].substr(0, fvil[2].lastIndexOf(' ')));
								faceVertexIndexList[faceVertexIndex++] = int(fvil[3].substr(0, fvil[3].lastIndexOf(' ')));
							}
							
							faceVertexIndexList[faceVertexIndex++] = int(fvil[4].substr(0, fvil[4].lastIndexOf(' ')));
						}
						break;
					}
					case 'MESH_TVERTLIST' : {
						var uvList:MeshElement = new MeshElement();
						uvList.numDataPreElement = 2;
						uvList.values = new Vector.<Number>();
						meshAsset.elements[MeshElementType.TEXCOORD] = uvList;
						
						var uvCount:int = 0;
						
						while(String(content = list.shift()).indexOf('}') < 0) {
							content = content.split('*')[1];
							var uvl:Array = content.split('\t');
							
							uvList[uvCount++] = uvl[1];
							uvList[uvCount++] = uvl[2];
						}
						
						break;
					}
					case 'MESH_TFACELIST' : {
						var texCoords:MeshElement = meshAsset.elements[MeshElementType.TEXCOORD];
						if (texCoords != null) {
							texCoords.valueMappingType = MeshElementValueMappingType.SELF_TRIANGLE_INDEX;
							texCoords.indices = new Vector.<uint>();
							
							var ftuvCount:int = 0;
							
							while(String(content = list.shift()).indexOf('}') < 0) {
								content = content.split('*')[1];
								var ftil:Array = content.split('\t');
								if (transformLRH) {
									texCoords.indices[ftuvCount++] = ftil[2];
									texCoords.indices[ftuvCount++] = ftil[1];
								} else {
									texCoords.indices[ftuvCount++] = ftil[1];
									texCoords.indices[ftuvCount++] = ftil[2];
								}
								
								texCoords.indices[ftuvCount++] = ftil[3];
							}
						}
						
						break;
					}
					case 'MESH_ANIMATION' : {
						var count:int = 0;
						while (true) {
							content = list.shift();
							if (content == null) break;
							var index:int = content.indexOf('}');
							if (index < 0 || count != 0) {
								if (index >= 0) count--;
								content = content.substr(content.indexOf('*') + 1);
								content = content.substr(0, content.indexOf(' '));
								if (content == 'MESH' || content == 'MESH_VERTEX_LIST' || content == 'MESH_FACE_LIST' || content == 'MESH_TVERTLIST' || content == 'MESH_TFACELIST' || content == 'MESH_NORMALS') count++;
							} else {
								break;
							}
						}
						break;
					}
				}
			}
		}
	}
}