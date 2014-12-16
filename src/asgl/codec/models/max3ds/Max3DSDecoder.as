package asgl.codec.models.max3ds {
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import asgl.geometries.MeshAsset;
	import asgl.geometries.MeshElement;
	import asgl.geometries.MeshElementType;
	import asgl.geometries.MeshElementValueMappingType;
	
	public class Max3DSDecoder {
		public var meshAssets:Vector.<MeshAsset>;
		private var _bytes:ByteArray;
		private var _totalFaces:int;
		private var _totalFrames:int;
		private var _version:int;
		
		public function Max3DSDecoder(bytes:ByteArray=null, transformLHorRH:Boolean=false) {
			if (bytes == null) {
				clear();
			} else {
				decode(bytes, transformLHorRH);
			}
		}
		public function get totalFaces():int {
			return _totalFaces;
		}
		public function get totalFrames():int {
			return _totalFrames;
		}
		public function get version():int {
			return _version;
		}
		public function clear():void {
			meshAssets = null;
			_totalFaces = 0;
			_totalFrames = 0;
			_version = 0;
		}
		public function decode(bytes:ByteArray, transformLRH:Boolean=false):void {
			clear();
			
			meshAssets = new Vector.<MeshAsset>();
			bytes.position = 0;
			_bytes = bytes;
			_bytes.endian = Endian.LITTLE_ENDIAN;
			var max:int;
			var i:int;
			var str:String;
			var postiion:int;
			var index:uint;
			var meshAsset:MeshAsset;
			var maxLength:int = _bytes.length;
			
			while(_bytes.position < maxLength) {
				var header:uint = _bytes.readUnsignedShort();
				var length:uint = _bytes.readUnsignedInt();
				switch (header) {
					case Max3DSChunk.MAIN3DS: {
						break;
					}
					case Max3DSChunk.EDIT3DS: {
						break;
					}
					case Max3DSChunk.VERSION: {
						postiion = _bytes.position;
						_version = _bytes.readUnsignedShort();
						_bytes.position = postiion + length - 6;
						break;
					}
					case Max3DSChunk.LIGHT: {
//						meshObject.type = MeshObjectType.LIGHT;
						_bytes.readFloat();
						_bytes.readFloat();
						_bytes.readFloat();
						break;
					}
					case Max3DSChunk.EDIT_MATERIAL: {
						break;
					}
					case Max3DSChunk.MAT_NAME: {
						str = _readString();
						break;
					}
					case Max3DSChunk.MAT_MAP: {
						break;
					}
					case Max3DSChunk.MAT_PATH: {
						str = _readString();
						break;
					}
					case Max3DSChunk.OBJ_TRIMESH: {
						break;
					}
					case Max3DSChunk.OBJ_CAMERA: {
//						meshObject.type = MeshObjectType.CAMERA;
//						var cameraInfo:Camera3DInfo = new Camera3DInfo();
						/*sourceX = */_bytes.readFloat();
						/*sourceY = */_bytes.readFloat();
						/*sourceZ = */_bytes.readFloat();
//						if (transformLHorRH) {
//							cameraInfo.origin = new Vertex3D(sourceX, sourceZ, sourceY);
//						} else {
//							cameraInfo.origin = new Vertex3D(sourceX, sourceY, sourceZ);
//						}
						/*sourceX = */_bytes.readFloat();
						/*sourceY = */_bytes.readFloat();
						/*sourceZ = */_bytes.readFloat();
//						if (transformLHorRH) {
//							cameraInfo.target = new Vertex3D(sourceX, sourceZ, sourceY);
//						} else {
//							cameraInfo.target = new Vertex3D(sourceX, sourceY, sourceZ);
//						}
						/*cameraInfo.angle = */_bytes.readFloat();
						/*cameraInfo.viewAngle = */_bytes.readFloat();
//						meshObject.cameraInfo = cameraInfo;
						break;
					}
					case Max3DSChunk.EDIT_OBJECT: {
						meshAsset = new MeshAsset();
						meshAsset.name = _readString()
						meshAssets.push(meshAsset);
						break;
					}
					//EDIT_OBJECT START:
					case Max3DSChunk.TRI_VERTEX: {
						max = _bytes.readUnsignedShort();
						
						var vertices:MeshElement = new MeshElement();
						vertices.numDataPreElement = 3;
						vertices.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
						vertices.values = new Vector.<Number>(max * 3);
						meshAsset.elements[MeshElementType.VERTEX] = vertices;
						index = 0;
						
						for (i = 0; i < max; i++) {
							vertices.values[index++] =  _bytes.readFloat();
							if (transformLRH) {
								var y:Number = _bytes.readFloat();
								vertices.values[index++] =  _bytes.readFloat();
								vertices.values[index++] =  y;
							} else {
								vertices.values[index++] =  _bytes.readFloat();
								vertices.values[index++] =  _bytes.readFloat();
							}
						}
						break;
					}
					case Max3DSChunk.TRI_FACEVERT: {
						max = _bytes.readUnsignedShort();
						
						var vertexIndices:Vector.<uint> = new Vector.<uint>(max * 3);
						meshAsset.triangleIndices = vertexIndices;
						index = 0;
						
						_totalFaces += max;
						for (i = 0; i < max; i++) {
							var index1:uint = _bytes.readUnsignedShort();
							if (transformLRH) {
								vertexIndices[index++] = _bytes.readUnsignedShort();
								vertexIndices[index++] = index1;
							} else {
								vertexIndices[index++] = _bytes.readUnsignedShort();
								vertexIndices[index++] = _bytes.readUnsignedShort();
							}
							vertexIndices[index++] = _bytes.readUnsignedShort();
							_bytes.readUnsignedShort();
						}
						break;
					}
					case Max3DSChunk.TRI_FACEMAT: {
						max = _bytes.readUnsignedShort();
							
						var materialIndicesMap:Object = meshAsset.materialIndicesMap;
						if (materialIndicesMap == null) {
							materialIndicesMap = {};
							meshAsset.materialIndicesMap = materialIndicesMap;
						}
						var materialName:String = _readString();
						
						var faceIndices:Vector.<uint> = new Vector.<uint>(max);
						materialIndicesMap[materialName] = faceIndices;
						
						for (i = 0; i < max; i++) {
							faceIndices[i] = _bytes.readUnsignedShort();
						}
						break;
					}
					case Max3DSChunk.TRI_UV: {
						max = _bytes.readUnsignedShort();
//						meshObject.type = MeshObjectType.OBJECT;
						
						var texCoords:MeshElement = new MeshElement();
						texCoords.numDataPreElement = 2;
						texCoords.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
						texCoords.values = new Vector.<Number>(max * 2);
						meshAsset.elements[MeshElementType.TEXCOORD] = texCoords;
						index = 0;
						
						for (i = 0; i < max; i++) {
							texCoords.values[index++] = _bytes.readFloat();
							texCoords.values[index++] = 1 - _bytes.readFloat();
						}
						
						break;
					}
					case Max3DSChunk.TRI_LOCAL: {
						_bytes.readFloat();
						_bytes.readFloat();
						_bytes.readFloat();
						_bytes.readFloat();
						_bytes.readFloat();
						_bytes.readFloat();
						_bytes.readFloat();
						_bytes.readFloat();
						_bytes.readFloat();
						_bytes.readFloat();
						_bytes.readFloat();
						_bytes.readFloat();
						break;
					}
					//EDIT_OBJECT END:
					case Max3DSChunk.KEYF3DS: {
						break;
					}
					//KEYF3DS START:
					case Max3DSChunk.KEYF_OBJDES: {
						break;
					}
					case Max3DSChunk.KEYF_FRAMES: {
						_bytes.readUnsignedInt();
						_totalFrames = _bytes.readUnsignedInt();
						break;
					}
					case Max3DSChunk.KEYF_OBJHIERARCH: {
						_readString();
						//not use
						_bytes.readUnsignedShort();
						_bytes.readUnsignedShort();
						//
						_bytes.readUnsignedShort();
						break;
					}
					case 0xb011: {
						//trace('0xb011');
						break;
					}
					case Max3DSChunk.KEYF_PIVOTPOINT: {
						_bytes.readFloat();
						_bytes.readFloat();
						_bytes.readFloat();
						break;
					}
					case 0xb014: {
						//trace('0xb014');
						break;
					}
					case 0xb015: {
						//trace('0xb015');
						break;
					}
					case Max3DSChunk.KEYF_OBJPIVOT: {
						//not use
						_bytes.readUnsignedShort();
						_bytes.readUnsignedShort();
						_bytes.readUnsignedShort();
						_bytes.readUnsignedShort();
						_bytes.readUnsignedShort();
						//
						max = _bytes.readUnsignedShort();
						for (i = 0; i < max; i++) {
							_bytes.readUnsignedShort();
							_bytes.readUnsignedInt();
							_bytes.readFloat();
							_bytes.readFloat();
							_bytes.readFloat();
						}
						break;
					}
					case 0xb021: {
						//trace('0xb021');
						break;
					}
					case 0xb022: {
						//trace('0xb022');
						break;
					}
					case 0xb030: {
						_bytes.readUnsignedShort();
						break;
					}
					//KEYF3DS END:
					default : {
						//trace(header.toString(16));
						//trace(_byteArray.readUTFBytes(length-6));
						_bytes.position += length - 6;
					}
				}
			}
		}
		private function _readString():String {
			var n:int;
			var str:String = '';
			do {
				n = _bytes.readByte();
				if (n == 0) {
					break;
				}
				str += String.fromCharCode(n);
			} while (true);
			return str;
		}
	}
}