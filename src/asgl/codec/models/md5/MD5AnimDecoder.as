package asgl.codec.models.md5 {
	import asgl.animators.SkeletonAnimationAsset;
	import asgl.animators.SkeletonData;
	import asgl.math.Float3;
	import asgl.math.Float4;

	public class MD5AnimDecoder {
		public var skeletonAnimationAsset:SkeletonAnimationAsset;
		
		public function MD5AnimDecoder(data:String=null, transformLRH:Boolean=false) {
			if (data == null) {
				clear();
			} else {
				decode(data, transformLRH);
			}
		}
		public function clear():void {
			skeletonAnimationAsset = null;
		}
		public function decode(data:String, transformLRH:Boolean=false):void {
			clear();
			
			skeletonAnimationAsset = new SkeletonAnimationAsset();
			var dataList:Array = data.split('\n');
			var mainLength:int = dataList.length;
			var list:Array;
			var j:int;
			var floats:Vector.<Number> = new Vector.<Number>();
			var baseFramesData:Vector.<Number>;
			var numAnimatedComponents:int;
			var hierarchyData:Array;
			var numBones:int;
			var animationMatricesByNameMap:Object;
			var quat:Float4 = new Float4();
			var pos:Float3 = new Float3();
			for (var i:int = 0; i < mainLength; i++) {
				var line:String = dataList[i];
				if (line.indexOf('numFrames ') != -1) {
					skeletonAnimationAsset.totalFrames = line.split(' ')[1];
				} else if (line.indexOf('numAnimatedComponents ') != -1) {
					numAnimatedComponents = line.split(' ')[1];
				} else if (line.indexOf('numJoints ') != -1) {
					
				} else if (line.indexOf('frameRate ') != -1) {
					
				} else if (line.indexOf('hierarchy {') != -1) {
					animationMatricesByNameMap = {};
					skeletonAnimationAsset.animationDataByNameMap = animationMatricesByNameMap;
					hierarchyData = [];
					while (true) {
						i++;
						line = dataList[i];
						if (line.indexOf('}') == 0) {
							break;
						} else {
							numBones++;
							var index:int = line.indexOf('//');
							if (index != -1) line = line.substr(0, index);
							list = line.split('"');
							var boneName:String = list[1];
							line = list[2];
							list = line.split(' ')
							hierarchyData.push(boneName, int(list[1]), int(list[2]));
							animationMatricesByNameMap[boneName] = new Vector.<SkeletonData>();
						}
					}
				} else if (line.indexOf('bounds {') != -1) {
					while (true) {
						i++;
						line = dataList[i];
						if (line.indexOf('}') == 0) {
							break;
						} else {
							
						}
					}
				} else if (line.indexOf('baseframe {') != -1) {
					baseFramesData = new Vector.<Number>();
					while (true) {
						i++;
						line = dataList[i];
						if (line.indexOf('}') == 0) {
							break;
						} else {
							list = line.split('(');
							line = list[1];
							var basePos:Array = line.split(' ');
							_removeEmptyArrayElement(basePos);
							baseFramesData.push(basePos[0], basePos[1], basePos[2]);
							line = list[2];
							var baseQuat:Array = line.split(' ');
							_removeEmptyArrayElement(baseQuat);
							baseFramesData.push(baseQuat[0], baseQuat[1], baseQuat[2]);
						}
					}
				} else if (line.indexOf('frame ') != -1) {
					floats.length = 0;
					line = '';
					while (true) {
						i++;
						var tempLine:String = dataList[i];
						if (tempLine.indexOf('}') == 0) {
							if (line != '') {
								list = line.split(' ');
								for (j = 0; j < numAnimatedComponents; j++) {
									floats.push(list[int(j + 1)]);
								}
								for (j = 0; j < numBones; j++) {
									var k:int = j * 3;
									var matrices:Vector.<SkeletonData> = animationMatricesByNameMap[hierarchyData[k]];
									var flags:int = hierarchyData[int(k + 1)];
									var startIndex:int = hierarchyData[int(k + 2)];
									k = j * 6;
									pos.x = baseFramesData[k];
									pos.y = baseFramesData[int(k+1)];
									pos.z = baseFramesData[int(k+2)];
									quat.x = baseFramesData[int(k+3)];
									quat.y = baseFramesData[int(k+4)];
									quat.z = baseFramesData[int(k+5)];
									k = 0;
									if (flags & 1) pos.x = floats[startIndex+(k++)];
									if (flags & 2) pos.y = floats[startIndex+(k++)];
									if (flags & 4) pos.z = floats[startIndex+(k++)];
									if (flags & 8) quat.x = floats[startIndex+(k++)];
									if (flags & 16) quat.y = floats[startIndex+(k++)];
									if (flags & 32) quat.z = floats[startIndex+k];
									quat.calculateQuaternionW();
									
									if (transformLRH) {
										quat.transformLRHQuaternion();
										pos.transformLRH();
									}
									
									var sd:SkeletonData = new SkeletonData();
									sd.local.rotation.x = quat.x;
									sd.local.rotation.y = quat.y;
									sd.local.rotation.z = quat.z;
									sd.local.rotation.w = quat.w;
									sd.local.matrix.m30 = pos.x;
									sd.local.matrix.m31 = pos.y;
									sd.local.matrix.m32 = pos.z;
									
									sd.local.updateMatrix();
									
									matrices.push(sd);
								}
							}
							break;
						} else {
							line += tempLine;
						}
					}
				}
			}
		}
		private function _removeEmptyArrayElement(list:Array):void {
			var length:int = list.length;
			for (var i:int = 0; i < length; i++) {
				if (list[i] == '') {
					list.splice(i, 1);
					i--;
					length--;
				}
			}
		}
	}
}