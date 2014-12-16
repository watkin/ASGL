package asgl.codec.models.asanim {
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import asgl.animators.SkeletonAnimationAsset;
	import asgl.animators.SkeletonData;
	import asgl.math.Float4;
	import asgl.codec.models.asmesh.ASModelChunk;

	public class ASAnimDecoder {
		public var skeletonAnimationAsset:SkeletonAnimationAsset;
		
		public function ASAnimDecoder() {
		}
		public function clear():void {
			skeletonAnimationAsset = null;
		}
		public function decode(bytes:ByteArray, transformLRH:Boolean=false):void {
			clear();
			skeletonAnimationAsset = new SkeletonAnimationAsset();
			
			bytes.position = 0;
			bytes.endian = Endian.LITTLE_ENDIAN;
			
			bytes.readUTFBytes(6);
			
			var animationMatricesByNameMap:Object;
			var float4:Float4 = new Float4();
			
			while (bytes.bytesAvailable > 0) {
				var chunk:uint = bytes.readUnsignedShort();
				var length:uint = bytes.readUnsignedInt();
				
				if (chunk == ASModelChunk.MAIN) {
					var config:uint = bytes.readUnsignedByte();
					var version:uint = bytes.readUnsignedShort();
					
					var isCompress:Boolean = (config & 0x1) == 1;
					
					if (isCompress) {
						var data:ByteArray = new ByteArray();
						data.endian = Endian.LITTLE_ENDIAN;
						bytes.readBytes(data);
						data.uncompress();
						data.position = 0;
						bytes = data;
					}
				} else if (chunk == ASModelChunk.ANIM_DATA) {
					if (animationMatricesByNameMap == null) {
						animationMatricesByNameMap = {};
						skeletonAnimationAsset.animationDataByNameMap = animationMatricesByNameMap;
					}
					
					while (bytes.bytesAvailable>0) {
						var name:String = bytes.readUTF();
						var max:uint = bytes.readUnsignedShort();
						
						var matrices:Vector.<SkeletonData> = new Vector.<SkeletonData>(max);
						
						animationMatricesByNameMap[name] = matrices;
						
						for (var j:uint = 0; j < max; j++) {
							var sd:SkeletonData = new SkeletonData();
							
							sd.local.matrix.m30 = bytes.readFloat();
							sd.local.matrix.m31 = bytes.readFloat();
							sd.local.matrix.m32 = bytes.readFloat();
							sd.local.rotation.x = bytes.readFloat();
							sd.local.rotation.y = bytes.readFloat();
							sd.local.rotation.z = bytes.readFloat();
							sd.local.rotation.w = bytes.readFloat();
							sd.local.scale.x = bytes.readFloat();
							sd.local.scale.y = bytes.readFloat();
							sd.local.scale.z = bytes.readFloat();
							
							if (transformLRH) {
								sd.local.matrix.transformLRH();
								sd.local.rotation.transformLRHQuaternion();
								sd.local.scale.transformLRH();
							}
							
							sd.local.updateMatrix();
							
							matrices[j] = sd;
						}
						
						if (skeletonAnimationAsset.totalFrames == 0) skeletonAnimationAsset.totalFrames = max;
					}
				} else {
					bytes.position += length;
				}
			}
		}
	}
}