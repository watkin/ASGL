package asgl.codec.models.asentity {
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import asgl.asgl_protected;
	import asgl.codec.models.asmesh.ASModelChunk;
	import asgl.entities.Coordinates3D;
	import asgl.entities.Coordinates3DIterator;
	import asgl.math.Float3;
	import asgl.math.Float4;
	import asgl.math.Matrix4x4;
	
	use namespace asgl_protected;

	public class ASEntityEncoder {
		private var _bonesNum:uint;
		
		public function ASEntityEncoder() {
		}
		/**
		 * @param matricesDataType 0 = none, 1 = matrix, 2 = pos rotation scale
		 */
		public function encode(rootEntities:Vector.<Coordinates3D>, transformLRH:Boolean=false, compress:Boolean=true, matricesDataType:uint=1):ByteArray {
			if (matricesDataType>2) matricesDataType = 1;
			
			var bytes:ByteArray = new ByteArray();
			bytes.endian = Endian.LITTLE_ENDIAN;
			
			bytes.writeUTFBytes('ASENTITY');
			
			var data:ByteArray = new ByteArray();
			data.endian = Endian.LITTLE_ENDIAN;
			var config:uint = matricesDataType << 1 | (compress ? 1 : 0);
			data.writeByte(config);
			data.writeShort(1);
			
			_writeBlock(bytes, ASModelChunk.MAIN, data);
			
			data.length = 0;
			
			var temp:ByteArray = new ByteArray();
			temp.endian = Endian.LITTLE_ENDIAN;
			
			var length:uint = rootEntities.length;
			for (var i:uint = 0; i < length; i++) {
				data.writeShort(0);
				
				_bonesNum = 0;
				var boneMap:Object = {};
				_writeBones(data, rootEntities[i], boneMap, matricesDataType, transformLRH);
				
				data.position = 0;
				data.writeShort(_bonesNum);
				data.position = data.length;
				
				_writeBlock(temp, ASModelChunk.BONES, data);
				
				data.length = 0;
			}
			
			if (compress) temp.compress();
			
			bytes.writeBytes(temp);
			bytes.position = 0;
			
			return bytes;
		}
		private function _writeBlock(bytes:ByteArray, chunk:uint, data:ByteArray):void {
			bytes.writeShort(chunk);
			bytes.writeUnsignedInt(data.length);
			bytes.writeBytes(data);
		}
		private function _writeBones(bytes:ByteArray, bone:Coordinates3D, map:Object, matricesDataType:uint, transformLRH:Boolean):void {
			var id:uint = _bonesNum++;
			var parentID:int;
			
			var parent:Coordinates3D = bone._parent;
			if (parent == null) {
				parentID = -1;
			} else {
				parentID = map[parent.name];
			}
			
			map[bone.name] = id;
			
			bytes.writeUTF(bone.name);
			bytes.writeShort(id);
			bytes.writeShort(parentID);
			if (matricesDataType == 1) {
				var matrix:Matrix4x4 = bone.getLocalMatrix();
				if (transformLRH) matrix.transformLRH();
				
				bytes.writeFloat(matrix.m00);
				bytes.writeFloat(matrix.m01);
				bytes.writeFloat(matrix.m02);
				bytes.writeFloat(matrix.m10);
				bytes.writeFloat(matrix.m11);
				bytes.writeFloat(matrix.m12);
				bytes.writeFloat(matrix.m20);
				bytes.writeFloat(matrix.m21);
				bytes.writeFloat(matrix.m22);
				bytes.writeFloat(matrix.m30);
				bytes.writeFloat(matrix.m31);
				bytes.writeFloat(matrix.m32);
			} else if (matricesDataType == 2) {
				var pos:Float3 = bone.getLocalPosition();
				var rotation:Float4 = bone.getLocalRotation();
				var scale:Float3 = bone.getLocalScale();
				if (transformLRH) {
					pos.transformLRH();
					rotation.transformLRHQuaternion();
					scale.transformLRH();
				}
				
				bytes.writeFloat(pos.x);
				bytes.writeFloat(pos.y);
				bytes.writeFloat(pos.z);
				bytes.writeFloat(rotation.x);
				bytes.writeFloat(rotation.y);
				bytes.writeFloat(rotation.z);
				bytes.writeFloat(rotation.w);
				bytes.writeFloat(scale.x);
				bytes.writeFloat(scale.y);
				bytes.writeFloat(scale.z);
			}
			
			var iterator:Coordinates3DIterator = new Coordinates3DIterator(bone);
			iterator.begin();
			
			var c:Coordinates3D;
			while ((c = iterator.next()) != null) {
				_writeBones(bytes, c, map, matricesDataType, transformLRH);
			}
		}
	}
}