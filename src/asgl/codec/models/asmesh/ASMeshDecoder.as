package asgl.codec.models.asmesh {
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import asgl.animators.SkinnedMeshAsset;
	import asgl.animators.SkinnedVertex;
	import asgl.geometries.MeshAsset;
	import asgl.geometries.MeshElement;
	import asgl.geometries.MeshElementType;
	import asgl.geometries.MeshElementValueMappingType;
	import asgl.math.Float3;
	import asgl.math.Float4;
	import asgl.math.Matrix4x4;

	public class ASMeshDecoder {
		public var meshAssets:Vector.<MeshAsset>;
		public var skinnedMeshAssets:Vector.<SkinnedMeshAsset>;
		
		public function ASMeshDecoder() {
		}
		public function clear():void {
			meshAssets = null;
			skinnedMeshAssets = null;
		}
		public function decode(bytes:ByteArray, transformLHorRH:Boolean=false):void {
			clear();
			
			bytes.position = 0;
			bytes.endian = Endian.LITTLE_ENDIAN;
			
			bytes.readUTFBytes(6);
			
			var matricesDataType:uint;
			var mo:MeshAsset;
			var smo:SkinnedMeshAsset;
			var bytesNum:uint;
			var max:uint;
			var j:uint;
			var index:uint;
			var number:Number;
			var float3_1:Float3 = new Float3();
			var float3_2:Float3 = new Float3();
			var float4:Float4 = new Float4();
			
			while (bytes.bytesAvailable > 0) {
				var chunk:uint = bytes.readUnsignedShort();
				var length:uint = bytes.readUnsignedInt();
				
				if (chunk == ASModelChunk.MAIN) {
					var config:uint = bytes.readUnsignedByte();
					var version:uint = bytes.readUnsignedShort();
					
					var isCompress:Boolean = (config & 0x1) == 1;
					matricesDataType = config >>> 1 & 0x3;
					
					if (isCompress) {
						var data:ByteArray = new ByteArray();
						data.endian = Endian.LITTLE_ENDIAN;
						bytes.readBytes(data);
						data.uncompress();
						data.position = 0;
						bytes = data;
					}
				} else if (chunk == ASModelChunk.MESH_GROUP) {
					if (meshAssets == null) meshAssets = new Vector.<MeshAsset>();
					mo = new MeshAsset();
					meshAssets[meshAssets.length] = mo;
					mo.name = bytes.readUTF();
				} else if (chunk == ASModelChunk.VERTICES) {
					bytesNum = bytes.readUnsignedByte();
					max = _readInteger(bytes, bytesNum);
					
					var vertices:MeshElement = new MeshElement();
					vertices.numDataPreElement = 3;
					vertices.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
					vertices.values = new Vector.<Number>(max * 3);
					mo.elements[MeshElementType.VERTEX] = vertices;
					
					index = 0;
					
					for (j = 0; j < max; j++) {
						vertices.values[index++] = bytes.readFloat();
						if (transformLHorRH) {
							var tempFloat:Number = bytes.readFloat();
							vertices.values[index++] = bytes.readFloat();
							vertices.values[index++] = tempFloat;
						} else {
							vertices.values[index++] = bytes.readFloat();
							vertices.values[index++] = bytes.readFloat();
						}
					}
				} else if (chunk == ASModelChunk.TEX_COORDS) {
					bytesNum = bytes.readUnsignedByte();
					max = _readInteger(bytes, bytesNum);
					
					var texCoords:MeshElement = new MeshElement();
					texCoords.numDataPreElement = 2;
					texCoords.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
					texCoords.values = new Vector.<Number>(max * 2);
					mo.elements[MeshElementType.TEXCOORD] = texCoords;
					
					index = 0;
					
					for (j = 0; j < max; j++) {
						texCoords.values[index++] = bytes.readFloat();
						texCoords.values[index++] = bytes.readFloat();
					}
				} else if (chunk == ASModelChunk.TRI_INDICES) {
					bytesNum = bytes.readUnsignedByte();
					max = _readInteger(bytes, bytesNum);
					
					var vertexIndices:Vector.<uint> = new Vector.<uint>(max * 3);
					mo.triangleIndices = vertexIndices;
					
					index = 0;
					
					for (j = 0; j < max; j++) {
						if (transformLHorRH) {
							var tempUint:uint = _readInteger(bytes, bytesNum);
							vertexIndices[index++] = _readInteger(bytes, bytesNum);
							vertexIndices[index++] = tempUint;
						} else {
							vertexIndices[index++] = _readInteger(bytes, bytesNum);
							vertexIndices[index++] = _readInteger(bytes, bytesNum);
						}
						vertexIndices[index++] = _readInteger(bytes, bytesNum);
					}
				} else if (chunk == ASModelChunk.NORMALS) {
					bytesNum = bytes.readUnsignedByte();
					max = _readInteger(bytes, bytesNum);
					
					var normals:MeshElement = new MeshElement();
					normals.numDataPreElement = 3;
					normals.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
					normals.values = new Vector.<Number>(max * 3);
					mo.elements[MeshElementType.NORMAL] = normals;
					
					index = 0;
					
					for (j = 0; j < max; j++) {
						normals.values[index++] = bytes.readFloat();
						if (transformLHorRH) {
							number = bytes.readFloat();
							normals.values[index++] = bytes.readFloat();
							normals.values[index++] = number;
						} else {
							normals.values[index++] = bytes.readFloat();
							normals.values[index++] = bytes.readFloat();
						}
					}
				}  else if (chunk == ASModelChunk.TANGENTS) {
					bytesNum = bytes.readUnsignedByte();
					max = _readInteger(bytes, bytesNum);
					
					var tangents:MeshElement = new MeshElement();
					tangents.numDataPreElement = 3;
					tangents.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
					tangents.values = new Vector.<Number>(max * 3);
					mo.elements[MeshElementType.TANGENT] = tangents;
					
					index = 0;
					
					for (j = 0; j < max; j++) {
						tangents.values[index++] = bytes.readFloat();
						if (transformLHorRH) {
							number = bytes.readFloat();
							tangents.values[index++] = bytes.readFloat();
							tangents.values[index++] = number;
						} else {
							tangents.values[index++] = bytes.readFloat();
							tangents.values[index++] = bytes.readFloat();
						}
					}
				}  else if (chunk == ASModelChunk.BINORMALS) {
					bytesNum = bytes.readUnsignedByte();
					max = _readInteger(bytes, bytesNum);
					
					var binormals:MeshElement = new MeshElement();
					binormals.numDataPreElement = 3;
					binormals.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
					binormals.values = new Vector.<Number>(max * 3);
					mo.elements[MeshElementType.BINORMAL] = binormals;
					
					index = 0;
					
					for (j = 0; j < max; j++) {
						binormals.values[index++] = bytes.readFloat();
						if (transformLHorRH) {
							number = bytes.readFloat();
							binormals.values[index++] = bytes.readFloat();
							binormals.values[index++] = number;
						} else {
							binormals.values[index++] = bytes.readFloat();
							binormals.values[index++] = bytes.readFloat();
						}
					}
				} else if (chunk == ASModelChunk.SKINNED_MESH) {
					if (skinnedMeshAssets == null) skinnedMeshAssets = new Vector.<SkinnedMeshAsset>();
					smo = new SkinnedMeshAsset();
					skinnedMeshAssets[skinnedMeshAssets.length] = smo;
					
					bytesNum = bytes.readUnsignedByte();
					max = _readInteger(bytes, bytesNum);
					
					var offsetMatrices:Object = {};
					var boneNames:Vector.<String> = new Vector.<String>(max);
					smo.preOffsetMatrices = offsetMatrices;
					smo.boneNames = boneNames;
					
					index = 0;
					
					var pos:Float3 = new Float3();
					
					for (j = 0; j < max; j++) {
						var boneName:String = bytes.readUTF();
						boneNames[index++] = boneName;
						
						var matrix:Matrix4x4 = new Matrix4x4();
						if (matricesDataType == 1) {
							matrix.copyDataFromBytes4x4(bytes);
						} else {
							float3_1.x = bytes.readFloat();
							float3_1.y = bytes.readFloat();
							float3_1.z = bytes.readFloat();
							float4.x = bytes.readFloat();
							float4.y = bytes.readFloat();
							float4.z = bytes.readFloat();
							float4.w = bytes.readFloat();
							float3_1.x = bytes.readFloat();
							float3_1.y = bytes.readFloat();
							float3_1.z = bytes.readFloat();
							Matrix4x4.createTRSMatrix(float3_1, float4, float3_2, matrix);
						}
						if (transformLHorRH) matrix.transformLRH();
						
						offsetMatrices[boneName] = matrix;
					}
					
					bytesNum = bytes.readUnsignedByte();
					max = _readInteger(bytes, bytesNum);
					
					var skinnedVdertices:Vector.<SkinnedVertex> = new Vector.<SkinnedVertex>(max);
					smo.skinnedVertices = skinnedVdertices;
					
					for (j = 0; j < max; j++) {
						var len:uint = bytes.readUnsignedByte();
						if (len > 0) {
							var svd:SkinnedVertex = new SkinnedVertex();
							svd.boneNameIndices = new Vector.<uint>(len);
							svd.weights = new Vector.<Number>(len);
							skinnedVdertices[j] = svd;
							
							for (var k:uint = 0; k < len; k++) {
								svd.weights[k] = bytes.readFloat();
								svd.boneNameIndices[k] = _readInteger(bytes, bytesNum);
							}
						}
					}
				} else {
					bytes.position += length;
				}
			}
		}
		private function _readInteger(bytes:ByteArray, num:uint):uint {
			if (num == 1) {
				return bytes.readUnsignedByte();
			} else if (num == 2) {
				return bytes.readUnsignedShort();
			} else {
				return bytes.readUnsignedInt();
			}
		}
	}
}