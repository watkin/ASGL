package asgl.animators {
	import asgl.asgl_protected;
	import asgl.entities.Coordinates3D;
	import asgl.entities.Object3D;
	import asgl.math.Matrix4x4;
	
	use namespace asgl_protected;

	public class SkeletonAnimationAsset {
		private static var _identityMatrix:Matrix4x4 = new Matrix4x4();
		
		public var name:String;
		
		/**
		 * map[boneName:String] = Vector.<SkeletonData>
		 */
		public var animationDataByNameMap:Object;
		
		/**
		 * map[boneName:String] = Vector.<Number>
		 */
		public var animationTimesByNameMap:Object;
		public var totalFrames:int;
		
		public var rootBones:Vector.<Object3D>;
		
		public function SkeletonAnimationAsset() {
		}
		public function calculateGlobalMatrix(rootBones:Vector.<Object3D>):void {
			this.rootBones = rootBones;
			
			var len:int = rootBones.length;
			
			for (var i:int = 0; i < totalFrames; i++) {
				for (var j:int = 0; j < len; j++) {
					_multiplyChildren(i, rootBones[j], _identityMatrix);
				}
			}
		}
		public function polishKeyFramesFromTimes():void {
			if (totalFrames > 1) {
				var findTimes:Vector.<Number>;
				for each (var times:Vector.<Number> in animationTimesByNameMap) {
					if (times.length == totalFrames) {
						findTimes = times;
						break;
					}
				}
				
				if (findTimes != null) {
					var minTime:Number = findTimes[0];
					var maxTime:Number = findTimes[int(totalFrames - 1)];
					var delay:Number = findTimes[1] - findTimes[0];
					
					for (var name:String in animationDataByNameMap) {
						var sds:Vector.<SkeletonData> = animationDataByNameMap[name];
						if (sds.length < totalFrames) {
							times = animationTimesByNameMap[name];
							var frame:Number = minTime;
							
							var copy:Vector.<SkeletonData> = sds.concat();
							sds.length = 0;
							
							var prev:SkeletonData = null;
							var prevTime:Number;
							var prevIndex:int;
							
							for (var i:int = 0; i < totalFrames; i++) {
								var index:int = times.indexOf(frame);
								if (index == -1) {
									var nextIndex:int = prevIndex + 1;
									var nextTime:Number;
									while (true) {
										if (nextIndex >= copy.length) {
											nextIndex = -1;
											break;
										} else {
											nextTime = times[nextIndex];
											if (nextTime >= frame) {
												break;
											} else {
												nextIndex++;
											}
										}
									}
									
									var sd:SkeletonData = new SkeletonData();
									
									if (nextIndex == -1) {
										sd.copy(prev);
									} else {
										var next:SkeletonData = copy[nextIndex];
										var t:Number = (frame - prevTime) / (nextTime - prevTime);
										SkeletonData.slerp(prev, next, t, sd);
									}
									
									sds[i] = sd;
								} else {
									prevIndex = index;
									prevTime = frame;
									prev = copy[index];
									sds[i] = prev;
								}
								
								frame += delay;
							}
							
							animationTimesByNameMap[name] = findTimes.concat();
						}
					}
				}
			}
		}
		public function slice(startIndex:uint, length:uint):SkeletonAnimationAsset {
			var endIndex:int = startIndex+length;
			
			var sao:SkeletonAnimationAsset = new SkeletonAnimationAsset();
			
			var name:String;
			
			if (animationDataByNameMap != null) {
				var matricesByNameMap:Object = {};
				sao.animationDataByNameMap = matricesByNameMap;
				
				for (name in animationDataByNameMap) {
					var sds:Vector.<SkeletonData> = animationDataByNameMap[name];
					matricesByNameMap[name] = sds.slice(startIndex, endIndex);
				}
			}
			
			if (animationTimesByNameMap != null) {
				var timesByNameMap:Object = {};
				sao.animationTimesByNameMap = timesByNameMap;
				
				for (name in animationTimesByNameMap) {
					var times:Vector.<Number> = animationTimesByNameMap[name];
					timesByNameMap[name] = times.slice(startIndex, endIndex);
				}
			}
			
			sao.totalFrames = length;
			
			return sao;
		}
		private function _multiplyChildren(frame:int, bone:Coordinates3D, parentMat:Matrix4x4):void {
			var v:Vector.<SkeletonData> = animationDataByNameMap[bone.name];
			if (v != null) {
				var sd:SkeletonData = v[frame];
				
				Matrix4x4.append3x4(sd.local.matrix, parentMat, sd.global.matrix);
				
				sd.global.updateTRS();
				
				var children:Vector.<Coordinates3D> = bone._delayChildren;
				var max:int = bone._delayNumChildren;
				for (var i:int = 0; i < max; i++) {
					var child:Coordinates3D = children[i];
					if (child != null) _multiplyChildren(frame, child, sd.global.matrix);
				}
			}
		}
	}
}