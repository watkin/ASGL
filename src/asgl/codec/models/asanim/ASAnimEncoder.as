package asgl.codec.models.asanim {
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import asgl.animators.SkeletonData;
	import asgl.math.Float4;
	import asgl.codec.models.asmesh.ASModelChunk;

	public class ASAnimEncoder {
		public function ASAnimEncoder() {
		}
		public function encode(animationMatricesByNameMap:Object, transformLRH:Boolean=false, compress:Boolean=true):ByteArray {
			var bytes:ByteArray = new ByteArray();
			bytes.endian = Endian.LITTLE_ENDIAN;
			
			bytes.writeUTFBytes('ASANIM');
			
			var data:ByteArray = new ByteArray();
			data.endian = Endian.LITTLE_ENDIAN;
			var config:uint = (compress ? 1: 0);
			data.writeByte(config);
			data.writeShort(1);
			
			_writeBlock(bytes, ASModelChunk.MAIN, data);
			
			data.length = 0;
			
			var temp:ByteArray = new ByteArray();
			temp.endian = Endian.LITTLE_ENDIAN;
			
			var opFloat4:Float4 = new Float4();
			
			for (var name:String in animationMatricesByNameMap) {
				var matrices:Vector.<SkeletonData> = animationMatricesByNameMap[name];
				var length:uint = matrices.length;
				
				data.writeUTF(name);
				data.writeShort(length);
				
				for (var i:int = 0; i < length; i++) {
					var sd:SkeletonData = matrices[i];
					if (transformLRH) {
						sd.local.matrix.transformLRH();
						sd.local.rotation.transformLRHQuaternion();
						sd.local.scale.transformLRH();
					}
					
					data.writeFloat(sd.local.matrix.m30);
					data.writeFloat(sd.local.matrix.m31);
					data.writeFloat(sd.local.matrix.m32);
					data.writeFloat(sd.local.rotation.x);
					data.writeFloat(sd.local.rotation.y);
					data.writeFloat(sd.local.rotation.z);
					data.writeFloat(sd.local.rotation.w);
					data.writeFloat(sd.local.scale.x);
					data.writeFloat(sd.local.scale.y);
					data.writeFloat(sd.local.scale.z);
					
					if (transformLRH) {
						sd.local.matrix.transformLRH();
						sd.local.rotation.transformLRHQuaternion();
						sd.local.scale.transformLRH();
					}
				}
			}
			
			_writeBlock(temp, ASModelChunk.ANIM_DATA, data);
			
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
	}
}