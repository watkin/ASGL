package asgl.codec.models.obj {
	import asgl.geometries.MeshAsset;
	import asgl.geometries.MeshElement;
	import asgl.geometries.MeshElementType;
	
	public class OBJEncoder {
		public function OBJEncoder() {
		}
		/**
		 * @param meshAssets.</br>
		 * need meshAsset elenemts:</br>
		 * must:meshAsset.vertices, meshAsset.faceVertexIndices.</br>
		 */
		public function encode(meshAssets:Vector.<MeshAsset>, transformLRH:Boolean=false, generateTexCoords:Boolean=true, MTLname:String=null):String {
			var string:String = '# ASGL OBJENCODER EXPORT\n#';
			if (MTLname != null) string += '\nmtllib ./' + MTLname + '.mtl\ng';
			var length:int = meshAssets.length;
			var vertexOffset:int = 0;
			var uvOffset:int = 0;
			
			for (var i:int = 0; i < length; i++) {
				var mo:MeshAsset = meshAssets[i];
				string += '\n# object ' + mo.name + ' to come ...\n#\n';
				var vertexIndices:Vector.<uint>;
				var vertices:MeshElement = mo.elements[MeshElementType.VERTEX];
				var texCoordsIndices:Vector.<uint>;
				var total:int = vertices.values.length;
				for (var j:int = 0; j < total; j += 3) {
					if (transformLRH) {
						string += 'v ' + vertices.values[j] + ' ' + vertices.values[int(j + 2)] + ' ' + vertices.values[int(j + 1)] + '\n';
					} else {
						string += 'v ' + vertices.values[j] + ' ' + vertices.values[int(j + 1)] + ' ' + vertices.values[int(j + 2)] + '\n';
					}
				}
				string += '# ' + (total / 3).toString() + ' vertices\n';
				
				var texCoords:MeshElement = mo[MeshElementType.TEXCOORD];
				
				if (generateTexCoords && texCoords!= null) {
					string += '\n';
					total = texCoords.values.length;
					for (j = 0; j < total; j += 2) {
						string += 'vt ' + texCoords.values[j] + ' ' + texCoords.values[int(j + 1)] + ' 0\n';
					}
					string += '# ' + (total * 0.5).toString() + ' texture coords\n';
				}
				string += '\ng ' + mo.name + '\n';
				vertexIndices = mo.triangleIndices;
				total = vertexIndices.length;
				var k:int;
				
				if (generateTexCoords && texCoords != null) {
					if (texCoords.indices == null) {
						for (j = 0; j < total; j += 3) {
							string += 'f';
							var index:int;
							if (transformLRH) {
								index = vertexIndices[int(j + 1)] + 1;
								string += ' ' + (index + vertexOffset) + '/' + (index + uvOffset);
								index = vertexIndices[j] + 1;
								string += ' ' + (index + vertexOffset) + '/' + (index + uvOffset);
							} else {
								index = vertexIndices[j] + 1;
								string += ' ' + (index + vertexOffset) + '/' + (index + uvOffset);
								index = vertexIndices[int(j + 1)] + 1;
								string += ' ' + (index + vertexOffset) + '/' + (index + uvOffset);
							}
							index = vertexIndices[int(j + 2)] + 1;
							string += ' ' + (index + vertexOffset) + '/' + (index + uvOffset);
							string += '\n';
						}
					} else {
						texCoordsIndices = texCoords.indices;
						for (j = 0; j < total; j += 3) {
							string += 'f';
							if (transformLRH) {
								string += ' ' + (vertexIndices[int(j + 1)] + 1 + vertexOffset) + '/' + (texCoordsIndices[int(j + 1)] + 1 + uvOffset);
								string += ' ' + (vertexIndices[j] + 1 + vertexOffset) + '/' + (texCoordsIndices[j] + 1 + uvOffset);
							} else {
								string += ' ' + (vertexIndices[j] + 1 + vertexOffset) + '/' + (texCoordsIndices[j] + 1 + uvOffset);
								string += ' ' + (vertexIndices[int(j + 1)] + 1 + vertexOffset) + '/' + (texCoordsIndices[int(j + 1)] + 1 + uvOffset);
							}
							string += ' ' + (vertexIndices[int(j + 2)] + 1 + vertexOffset) + '/' + (texCoordsIndices[int(j + 2)] + 1 + uvOffset);
							string += '\n';
						}
					}
					
					vertexOffset += vertices.values.length / vertices.numDataPreElement;
					uvOffset += texCoords.values.length / texCoords.numDataPreElement;
				} else {
					for (j = 0; j < total; j += 3) {
						if (transformLRH){
							string += 'f ' + (vertexIndices[int(j + 1)] + 1 + vertexOffset) + ' ' + (vertexIndices[j] + 1 + vertexOffset) + ' ' + (vertexIndices[int(j + 2)] + 1 + vertexOffset) + '\n';
						} else {
							string += 'f ' + (vertexIndices[j] + 1 + vertexOffset) + ' ' + (vertexIndices[int(j + 1)] + 1 + vertexOffset) + ' ' + (vertexIndices[int(j + 2)] + 1 + vertexOffset) + '\n';
						}
					}
					
					vertexOffset += vertices.values.length / vertices.numDataPreElement;
				}
				string += '# '+(total / 3)+' faces\n\ng';
			}
			
			return string;
		}
	}
}