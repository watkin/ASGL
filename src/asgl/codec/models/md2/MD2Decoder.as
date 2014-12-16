package asgl.codec.models.md2 {
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import asgl.animators.KeyFrameAnimationAsset;
	import asgl.geometries.MeshAsset;
	import asgl.geometries.MeshElement;
	import asgl.geometries.MeshElementType;
	import asgl.geometries.MeshElementValueMappingType;
	
	public class MD2Decoder {
		public var keyFrames:Vector.<KeyFrameAnimationAsset>;
		
		private var _ident:int;
		private var _version:int;
		private var _skinWidth:int;
		private var _skinHeight:int;
		private var _frameSize:int;
		private var _totalSkins:int;
		private var _totalVertices:int;
		private var _totalTextureUVes:int;
		private var _totalFaces:int;
		private var _totalFrames:int;
		private var _ofs_skins:int;
		private var _offsetTextureUVes:int;
		private var _offsetFace:int;
		private var _offsetFrames:int;
		
		public function MD2Decoder(bytes:ByteArray=null, transformLRH:Boolean=false):void {
			if (bytes == null) {
				clear();
			} else {
				deocde(bytes, transformLRH);
			}
		}
		public function get skinHeight():int {
			return _skinHeight;
		}
		public function get skinWidth():int {
			return _skinWidth;
		}
		public function get totalFaces():int {
			return _totalFaces;
		}
		public function get totalFrames():int {
			return _totalFrames;
		}
		public function get totalSkins():int {
			return _totalSkins;
		}
		public function get totalVertices():int {
			return _totalVertices;
		}
		public function get version():int {
			return _version;
		}
		public function clear():void {
			keyFrames = null;
			_skinHeight = 0;
			_skinWidth = 0;
			_totalFaces = 0;
			_totalFrames = 0;
			_totalSkins = 0;
			_totalVertices = 0;
			_version = 0;
		}
		public function deocde(bytes:ByteArray, transformLRH:Boolean=false):void {
			clear();
			
			keyFrames = new Vector.<KeyFrameAnimationAsset>();
			bytes.endian = Endian.LITTLE_ENDIAN;
			bytes.position = 0;
			_ident = bytes.readUnsignedInt();
			_version = bytes.readUnsignedInt();
			_skinWidth = bytes.readUnsignedInt();
			_skinHeight = bytes.readUnsignedInt();
			_frameSize = bytes.readUnsignedInt();
			_totalSkins = bytes.readUnsignedInt();
			_totalVertices = bytes.readUnsignedInt();
			_totalTextureUVes = bytes.readUnsignedInt();
			_totalFaces = bytes.readUnsignedInt();
			bytes.readUnsignedInt();
			_totalFrames = bytes.readUnsignedInt();
			_ofs_skins = bytes.readUnsignedInt();
			_offsetTextureUVes = bytes.readUnsignedInt();
			_offsetFace = bytes.readUnsignedInt();
			_offsetFrames = bytes.readUnsignedInt();
			bytes.readUnsignedInt();
			bytes.readUnsignedInt();
			
			var triangleIndices:Vector.<uint> = new Vector.<uint>();
			var texCoords:MeshElement = new MeshElement();
			texCoords.numDataPreElement = 2;
			texCoords.valueMappingType = MeshElementValueMappingType.SELF_TRIANGLE_INDEX;
			texCoords.values = new Vector.<Number>(_totalTextureUVes * 2);
			texCoords.indices = new Vector.<uint>(_totalFaces * 3);
			
			var vertexIndex1:int;
			var vertexIndex2:int;
			var vertexIndex3:int;
			var uvIndex1:int;
			var uvIndex2:int;
			var sourceX:Number;
			var sourceY:Number;
			var sourceZ:Number;
			
			var index:uint = 0;
			
			bytes.position = _offsetTextureUVes;
			for (var i:int = 0; i < _totalTextureUVes; i++) {
				texCoords.values[index++] = bytes.readUnsignedShort() / _skinWidth;
				texCoords.values[index++] = bytes.readUnsignedShort() / _skinHeight;
			}
			
			index = 0;
			var index2:uint = 0;
			
			bytes.position = _offsetFace;
			for (i = 0; i < _totalFaces; i++) {
				vertexIndex1 = bytes.readUnsignedShort();
				vertexIndex2 = bytes.readUnsignedShort();
				vertexIndex3 = bytes.readUnsignedShort();
				uvIndex1 = bytes.readUnsignedShort();
				uvIndex2 = bytes.readUnsignedShort();
				
				if (transformLRH) {
					triangleIndices[index++] = vertexIndex2;
					triangleIndices[index++] = vertexIndex1;
					
					texCoords.indices[index2++] = uvIndex2;
					texCoords.indices[index2++] = uvIndex1;
				} else {
					triangleIndices[index++] = vertexIndex1;
					triangleIndices[index++] = vertexIndex2;
					
					texCoords.indices[index2++] = uvIndex1;
					texCoords.indices[index2++] = uvIndex2;
				}
				
				triangleIndices[index++] = vertexIndex3;
				texCoords.indices[index2++] = bytes.readUnsignedShort();
			}
			
			bytes.position = _offsetFrames;
			for (i = 0; i < _totalFrames; i++) {
				var frame:KeyFrameAnimationAsset = new KeyFrameAnimationAsset();
				frame.meshAssets = new Vector.<MeshAsset>();
				var meshAsset:MeshAsset = new MeshAsset();
//				meshObject.type = MeshObjectType.OBJECT;
				frame.meshAssets.push(meshAsset);
				meshAsset.triangleIndices = triangleIndices;
				meshAsset.elements[MeshElementType.TEXCOORD] = texCoords;
				
				var sx:Number = bytes.readFloat();
				var sy:Number = bytes.readFloat();
				var sz:Number = bytes.readFloat();
				var tx:Number = bytes.readFloat();
				var ty:Number = bytes.readFloat();
				var tz:Number = bytes.readFloat();
				
				frame.name = bytes.readMultiByte(16, 'utf-8');
				keyFrames.push(frame);
				var verteices:MeshElement = new MeshElement();
				verteices.numDataPreElement = 3;
				verteices.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
				verteices.values = new Vector.<Number>(_totalVertices * 3);
				meshAsset.elements[MeshElementType.VERTEX] = verteices;
				
				index = 0;
				
				for (var j:int = 0; j < _totalVertices; j++) {
					sourceX = bytes.readUnsignedByte() * sx + tx;
					sourceY = bytes.readUnsignedByte() * sy + ty;
					sourceZ = bytes.readUnsignedByte() * sz + tz;
					
					verteices[index++] = sourceX;
					
					if (transformLRH) {
						verteices[index++] = sourceZ;
						verteices[index++] = sourceY;
					} else {
						verteices[index++] = sourceY;
						verteices[index++] = sourceZ;
					}
					
					bytes.readUnsignedByte();
				}
			}
		}
	}
}