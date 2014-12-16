package asgl.codec.models.asmesh {
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import asgl.animators.SkinnedMeshAsset;
	import asgl.animators.SkinnedVertex;
	import asgl.geometries.MeshAsset;
	import asgl.geometries.MeshElement;
	import asgl.geometries.MeshElementType;
	import asgl.geometries.MeshHelper;
	import asgl.math.Float3;
	import asgl.math.Float4;
	import asgl.math.Matrix4x4;

	public class ASMeshEncoder {
		public function ASMeshEncoder() {
		}
		/**
		 * @param skinnedMeshOffsetMatricesDataType 1 = matrix, 2 = quat and pos
		 */
		public function encode(meshAssets:Vector.<MeshAsset>, skinnedMeshAssets:Vector.<SkinnedMeshAsset>=null, transformLHorRH:Boolean=false, compress:Boolean=true, includeTexCoords:Boolean=true, includeNormals:Boolean=false, includeTangents:Boolean=false, includeBinormals:Boolean=false, skinnedMeshOffsetMatricesDataType:uint=1):ByteArray {
			if (skinnedMeshOffsetMatricesDataType != 1 && skinnedMeshOffsetMatricesDataType != 2) skinnedMeshOffsetMatricesDataType = 1;
			
			var bytes:ByteArray = new ByteArray();
			bytes.endian = Endian.LITTLE_ENDIAN;
			
			bytes.writeUTFBytes('ASMESH');
			
			var data:ByteArray = new ByteArray();
			data.endian = Endian.LITTLE_ENDIAN;
			var config:uint = skinnedMeshOffsetMatricesDataType << 1 | (compress ? 1: 0);
			data.writeByte(config);
			data.writeShort(2);
			
			_writeBlock(bytes, ASModelChunk.MAIN, data);
			
			data.length = 0;
			
			var temp:ByteArray = new ByteArray();
			temp.endian = Endian.LITTLE_ENDIAN;
			
			var j:uint;
			var index:uint;
			var max:uint;
			var bytesNum:uint;
			
			var length:uint = meshAssets.length;
			for (var i:uint = 0; i < length; i++) {
				var mo:MeshAsset = meshAssets[i];
				MeshHelper.format(mo);
				//
				var name:String = mo.name;
				if (name == null) name = '';
				data.writeUTF(name);
				
				_writeBlock(temp, ASModelChunk.MESH_GROUP, data);
				
				data.length = 0;
				
				var vertices:MeshElement = mo.elements[MeshElementType.VERTEX];
				max = vertices.values.length / 3;
				bytesNum = _getIntegerBits(max);
				//
				_writeBitsAndInteger(data, bytesNum, max);
				
				for (j = 0; j < max; j++) {
					index = j * 3;
					data.writeFloat(vertices.values[index]);
					if (transformLHorRH) {
						data.writeFloat(vertices.values[int(index + 2)]);
						data.writeFloat(vertices.values[int(index + 1)]);
					} else {
						data.writeFloat(vertices.values[int(index + 1)]);
						data.writeFloat(vertices.values[int(index + 2)]);
					}
				}
				
				_writeBlock(temp, ASModelChunk.VERTICES, data);
				
				data.length = 0;
				
				if (includeTexCoords) {
					var texCoords:MeshElement = mo.elements[MeshElementType.TEXCOORD];
					if (texCoords != null) {
						max = texCoords.values.length * 0.5;
						bytesNum = _getIntegerBits(max);
						//
						_writeBitsAndInteger(data, bytesNum, max);
						
						for (j = 0; j < max; j++) {
							index = j * 2;
							data.writeFloat(texCoords.values[index]);
							data.writeFloat(texCoords.values[int(index + 1)]);
						}
						
						_writeBlock(temp, ASModelChunk.TEX_COORDS, data);
						
						data.length = 0;
					}
				}
				
				var vertexIndices:Vector.<uint> = mo.triangleIndices;
				max = vertexIndices.length / 3;
				bytesNum = _getIntegerBits(max);
				//
				_writeBitsAndInteger(data, bytesNum, max);
				
				for (j = 0; j < max; j++) {
					index = j * 3;
					if (transformLHorRH) {
						_writeInteger(data, bytesNum, vertexIndices[int(index + 1)]);
						_writeInteger(data, bytesNum, vertexIndices[index]);
					} else {
						_writeInteger(data, bytesNum, vertexIndices[index]);
						_writeInteger(data, bytesNum, vertexIndices[int(index + 1)]);
					}
					_writeInteger(data, bytesNum, vertexIndices[int(index + 2)]);
				}
				
				_writeBlock(temp, ASModelChunk.TRI_INDICES, data);
				
				data.length = 0;
				
				var normals:MeshElement = mo.elements[MeshElementType.NORMAL];
				if (normals == null && (includeNormals || includeBinormals || includeTangents)){
					normals = new MeshElement();
					normals.values = MeshHelper.calculateVertexNormals(mo.triangleIndices, mo.getElement(MeshElementType.VERTEX).values);
				}
				
				if (includeNormals) {
					max = normals.values.length / 3;
					bytesNum = _getIntegerBits(max);
					//
					_writeBitsAndInteger(data, bytesNum, max);
					
					for (j = 0; j < max; j++) {
						index = j * 3;
						data.writeFloat(normals[index]);
						if (transformLHorRH) {
							data.writeFloat(normals[int(index + 2)]);
							data.writeFloat(normals[int(index + 1)]);
						} else {
							data.writeFloat(normals[int(index + 1)]);
							data.writeFloat(normals[int(index + 2)]);
						}
					}
					
					_writeBlock(temp, ASModelChunk.NORMALS, data);
					
					data.length = 0;
				}
				
				var tangents:MeshElement;
				
				if (includeTangents) {
					tangents = mo.elements[MeshElementType.TANGENT];
					if (tangents == null) {
						tangents = new MeshElement();
						tangents.values = MeshHelper.calculateVertexTangents(mo.triangleIndices, mo.getElement(MeshElementType.VERTEX).values, mo.getElement(MeshElementType.TEXCOORD).values);
					}
					
					max = tangents.values.length / 3;
					bytesNum = _getIntegerBits(max);
					//
					_writeBitsAndInteger(data, bytesNum, max);
					
					for (j = 0; j < max; j++) {
						index = j * 3;
						data.writeFloat(tangents.values[index]);
						if (transformLHorRH) {
							data.writeFloat(tangents.values[int(index + 2)]);
							data.writeFloat(tangents.values[int(index + 1)]);
						} else {
							data.writeFloat(tangents.values[int(index + 1)]);
							data.writeFloat(tangents.values[int(index + 2)]);
						}
					}
					
					_writeBlock(temp, ASModelChunk.TANGENTS, data);
					
					data.length = 0;
				}
				
				if (includeBinormals) {
					var binormals:MeshElement = mo.elements[MeshElementType.BINORMAL];
					if (binormals == null) {
						if (tangents == null) {
							tangents = new MeshElement();
							tangents.values = MeshHelper.calculateVertexTangents(mo.triangleIndices, mo.getElement(MeshElementType.VERTEX).values, mo.getElement(MeshElementType.TEXCOORD).values);
						}
						
						binormals = new MeshElement();
						binormals.values = MeshHelper.calculateBinormals(normals.values, tangents.values);
					}
					
					max = binormals.values.length / 3;
					bytesNum = _getIntegerBits(max);
					//
					_writeBitsAndInteger(data, bytesNum, max);
					
					for (j = 0; j < max; j++) {
						index = j * 3;
						data.writeFloat(binormals.values[index]);
						if (transformLHorRH) {
							data.writeFloat(binormals.values[int(index + 2)]);
							data.writeFloat(binormals.values[int(index + 1)]);
						} else {
							data.writeFloat(binormals.values[int(index + 1)]);
							data.writeFloat(binormals.values[int(index + 2)]);
						}
					}
					
					_writeBlock(temp, ASModelChunk.BINORMALS, data);
					
					data.length = 0;
				}
			}
			
			if (skinnedMeshAssets != null) {
				var rotation:Float4 = new Float4();
				var m:Matrix4x4 = new Matrix4x4();
				var scale:Float3 = new Float3();
				
				length = skinnedMeshAssets.length;
				for (i = 0; i < length; i++) {
					var sma:SkinnedMeshAsset = skinnedMeshAssets[i];
					
					_writeBlock(temp, ASModelChunk.SKINNED_MESH, data);
					
					data.length = 0;
					
					var offsetMatrices:Object = sma.preOffsetMatrices;
					max = sma.boneNames.length;
					bytesNum = _getIntegerBits(max);
					//
					_writeBitsAndInteger(data, bytesNum, max);
					
					for (j = 0; j < max; j++) {
						var boneName:String = sma.boneNames[j];
						data.writeUTF(boneName);
						
						var matrix:Matrix4x4 = offsetMatrices[boneName];
						if (transformLHorRH) {
							matrix = matrix.clone();
							matrix.transformLRH();
						}
						
						if (skinnedMeshOffsetMatricesDataType == 1) {
							data.writeFloat(matrix.m00);
							data.writeFloat(matrix.m01);
							data.writeFloat(matrix.m02);
							data.writeFloat(matrix.m03);
							data.writeFloat(matrix.m10);
							data.writeFloat(matrix.m11);
							data.writeFloat(matrix.m12);
							data.writeFloat(matrix.m13);
							data.writeFloat(matrix.m20);
							data.writeFloat(matrix.m21);
							data.writeFloat(matrix.m22);
							data.writeFloat(matrix.m23);
							data.writeFloat(matrix.m30);
							data.writeFloat(matrix.m31);
							data.writeFloat(matrix.m32);
							data.writeFloat(matrix.m33);
						} else {
							matrix.decomposition(m, scale);
							m.getQuaternion(rotation);
							
							data.writeFloat(matrix.m30);
							data.writeFloat(matrix.m31);
							data.writeFloat(matrix.m32);
							data.writeFloat(rotation.x);
							data.writeFloat(rotation.y);
							data.writeFloat(rotation.z);
							data.writeFloat(rotation.w);
							data.writeFloat(scale.x);
							data.writeFloat(scale.y);
							data.writeFloat(scale.z);
						}
					}
					
					max = sma.skinnedVertices.length;
					bytesNum = _getIntegerBits(max);
					//
					_writeBitsAndInteger(data, bytesNum, max);
					
					for (j = 0; j < max; j++) {
						var svd:SkinnedVertex = sma.skinnedVertices[j];
						
						var len:uint = svd == null ? 0 : svd.boneNameIndices.length;
						
						data.writeByte(len);
						
						for (var k:uint = 0; k < len; k++) {
							data.writeFloat(svd.weights[k]);
							_writeInteger(data, bytesNum, svd.boneNameIndices[k]);
						}
					}
					
					_writeBlock(temp, ASModelChunk.SKINNED_MESH, data);
					
					data.length = 0;
				}
			}
			
			if (compress) temp.compress();
			
			bytes.writeBytes(temp);
			bytes.position = 0;
			
			return bytes;
		}
		private function _getIntegerBits(num:uint):uint {
			if (num>0xFFFF) {
				return 4;
			} else if (num>0xFF) {
				return 2;
			} else {
				return 1;
			}
		}
		private function _writeBlock(bytes:ByteArray, chunk:uint, data:ByteArray):void {
			bytes.writeShort(chunk);
			bytes.writeUnsignedInt(data.length);
			bytes.writeBytes(data);
		}
		private function _writeInteger(bytes:ByteArray, num:uint, value:uint):void {
			if (num == 1) {
				bytes.writeByte(value);
			} else if (num == 2) {
				bytes.writeShort(value);
			} else {
				bytes.writeUnsignedInt(value);
			}
		}
		private function _writeBitsAndInteger(bytes:ByteArray, num:uint, value:uint):void {
			if (num == 1) {
				bytes.writeByte(1);
				bytes.writeByte(value);
			} else if (num == 2) {
				bytes.writeByte(2);
				bytes.writeShort(value);
			} else {
				bytes.writeByte(4);
				bytes.writeUnsignedInt(value);
			}
		}
	}
}