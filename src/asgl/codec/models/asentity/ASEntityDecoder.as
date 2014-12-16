package asgl.codec.models.asentity {
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import asgl.codec.models.asmesh.ASModelChunk;
	import asgl.entities.EntityAsset;
	import asgl.entities.Object3D;
	import asgl.math.Float3;
	import asgl.math.Float4;
	import asgl.math.Matrix4x4;

	public class ASEntityDecoder {
		public var entityAsset:EntityAsset;
		
		public function ASEntityDecoder() {
		}
		public function clear():void {
			entityAsset = null;
		}
		public function decode(bytes:ByteArray, transformLRH:Boolean=false):void {
			clear();
			entityAsset = new EntityAsset();
			
			bytes.position = 0;
			bytes.endian = Endian.LITTLE_ENDIAN;
			
			bytes.readUTFBytes(8);
			
			var matricesDataType:uint;
			
			var rootBones:Vector.<Object3D>;
			var bones:Vector.<Object3D>;
			
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
				} else if (chunk == ASModelChunk.BONES) {
					if (rootBones == null) {
						rootBones = new Vector.<Object3D>();
						bones = new Vector.<Object3D>();
						entityAsset.rootEntities = rootBones;
						entityAsset.entities = bones;
					}
					
					var matrix:Matrix4x4 = new Matrix4x4();
					var quat:Float4 = new Float4();
					var pos:Float3 = new Float3();
					var scale:Float3 = new Float3();
					var bonesMap:Object = {};
					var bonesNum:uint = bytes.readUnsignedShort();
					
					var rootBonesIndex:uint = rootBones.length;
					var bonesIndex:uint = bones.length;
					
					while (bonesNum-- > 0) {
						var name:String = bytes.readUTF();
						var id:int = bytes.readUnsignedShort();
						var parentID:int = bytes.readShort();
						
						var bone:Object3D = new Object3D();
						bone.name = name;
						
						if (matricesDataType == 1) {
							matrix.copyDataFromBytes3x4(bytes);
							if (transformLRH) matrix.transformLRH();
							
							bone.setLocalMatrix(matrix);
						} else if (matricesDataType == 2) {
							pos.x = bytes.readFloat();
							pos.y = bytes.readFloat();
							pos.z = bytes.readFloat();
							quat.x = bytes.readFloat();
							quat.y = bytes.readFloat();
							quat.z = bytes.readFloat();
							quat.w = bytes.readFloat();
							scale.x = bytes.readFloat();
							scale.y = bytes.readFloat();
							scale.z = bytes.readFloat();
							if (transformLRH) {
								pos.transformLRH();
								quat.transformLRHQuaternion();
								scale.transformLRH();
							}
							
							bone.setLocalPosition(pos.x, pos.y, pos.z, false);
							bone.setLocalRotation(quat, false);
							bone.setLocalScale(scale.x, scale.y, scale.z);
						}
						
						bonesMap[id] = bone;
						if (parentID == -1) {
							rootBones[rootBonesIndex++] = bone;
						} else {
							var parent:Object3D = bonesMap[parentID];
							parent.addChild(bone);
						}
						
						bones[bonesIndex++] = bone;
					}
				} else {
					bytes.position += length;
				}
			}
		}
	}
}