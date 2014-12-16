package asgl.codec.models.obj {
	import asgl.geometries.MeshAsset;
	import asgl.geometries.MeshElement;
	import asgl.geometries.MeshElementType;
	import asgl.geometries.MeshElementValueMappingType;
	
	public class OBJDecoder {
		public var meshAssets:Vector.<MeshAsset>;
		
		public function OBJDecoder(bytes:String=null, transformLRH:Boolean=false) {
			if (bytes == null) {
				clear();
			} else {
				decode(bytes, transformLRH);
			}
		}
		public function clear():void {
			meshAssets = null;
		}
		public function decode(file:String, transformLRH:Boolean=false):void {
			clear();
			
			meshAssets = new Vector.<MeshAsset>();
			var fileList:Array = file.split('\n');
			var length:int = fileList.length;
			var meshAsset:MeshAsset;
			var list:Array;
			var max:int;
			var j:int;
			var vn:int;
			var uvn:int;
			var len:uint;
			
			var texCoords:MeshElement;
			
			for (var i:int = 0; i < length; i++) {
				var line:String = fileList[i];
				if (line.indexOf('#') != -1) {
					if (line.indexOf(' object ') != -1) {
						meshAsset = new MeshAsset();
						meshAssets[meshAssets.length] = meshAsset;
						meshAsset.name = line.substr(9, line.lastIndexOf(' to come ...') - 9);
					} else if (line.indexOf(' texture coords') != -1) {
						max = int(line.substring(2, line.length - 15));
						texCoords = new MeshElement();
						texCoords.numDataPreElement = 2;
						texCoords.values = new Vector.<Number>(max * 2);
						meshAsset.elements[MeshElementType.TEXCOORD] = texCoords;
						len = 0;
						for (j = 0; j < max; j++) {
							line = fileList[int(i - max + j)];
							list = line.split(' ');
							texCoords.values[len++] = list[2];
							texCoords.values[len++] = list[3];
						}
					} else if (line.indexOf(' vertices') != -1) {
						max = int(line.substr(2, line.length - 11));
						var vertices:MeshElement = new MeshElement();
						vertices.numDataPreElement = 3;
						vertices.values = new Vector.<Number>(max * 3);
						vertices.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
						meshAsset.elements[MeshElementType.VERTEX] = vertices;
						len = 0;
						for (j = 0; j < max; j++) {
							line = fileList[int(i - max + j)];
							list = line.split(' ');
							
							vertices.values[len++] = list[2];
							
							if (transformLRH) {
								vertices.values[len++] = list[4];
								vertices.values[len++] = list[3];
							} else {
								vertices.values[len++] = list[3];
								vertices.values[len++] = list[4];
							}
						}
					} else if (line.indexOf(' faces') != -1) {
						max = int(line.substr(2, line.length - 8));
						var vertexIndices:Vector.<uint> = new Vector.<uint>();
						meshAsset.triangleIndices = vertexIndices;
						
						texCoords = meshAsset.elements[MeshElementType.TEXCOORD];
						if (texCoords != null) {
							texCoords.valueMappingType = MeshElementValueMappingType.SELF_TRIANGLE_INDEX;
							texCoords.indices = new Vector.<uint>();
						}
						
						var index:int = 0;
						len = 0;
						var len2:uint = 0;
						
						for (j = 0; j < max; j++) {
							while (true) {
								index++;
								line = fileList[int(i - index)];
								if (line.indexOf('f ') == 0) {
									list = line.substr(2).split(' ');
									
									var list0:Array = list[0].split('/');
									var list1:Array = list[1].split('/');
									var list2:Array = list[2].split('/');
									
									if (transformLRH) {
										vertexIndices[len++] = int(list1[0]) - vn - 1;
										vertexIndices[len++] = int(list0[0]) - vn - 1;
										
										if (texCoords != null) {
											texCoords.indices[len2++] = int(list1[1]) - uvn - 1;
											texCoords.indices[len2++] = int(list0[1]) - uvn - 1;
											texCoords.indices[len2++] = int(list2[1]) - uvn - 1;
										}
									} else {
										vertexIndices[len++] = int(list0[0]) - vn - 1;
										vertexIndices[len++] = int(list1[0]) - vn - 1;
										
										if (texCoords != null) {
											texCoords.indices[len2++] = int(list0[1]) - uvn - 1;
											texCoords.indices[len2++] = int(list1[1]) - uvn - 1;
											texCoords.indices[len2++] = int(list2[1]) - uvn - 1;
										}
									}
									
									vertexIndices[len++] = int(list2[0]) - vn - 1;
									
									break;
								}
							}
						}
						
						var element:MeshElement = meshAsset.elements[MeshElementType.VERTEX];
						vn += element.values.length / element.numDataPreElement;
						if (texCoords != null) {
							element = meshAsset.elements[MeshElementType.TEXCOORD];
							uvn += element.values.length / element.numDataPreElement;
						}
					}
				}
			}
		}
	}
}