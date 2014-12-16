package asgl.animators {
	import asgl.asgl_protected;
	import asgl.entities.SimpleCoordinates3D;
	import asgl.math.Matrix4x4;
	
	use namespace asgl_protected;
	
	public class SkinnedMeshSoftwareAnimator extends BaseAnimator {
		asgl_protected var _destVertices:Vector.<Number>;
		asgl_protected var _srcVertices:Vector.<Number>;
		
		protected var _cachePrecision:uint = 0;
		protected var _cacheInterval:Number = 0;
		
		protected var _skeletonMatrixCalculator:AbstractSkeletonMatrixCalculator;
		protected var _data:SkinnedMeshAsset;
		
		public function SkinnedMeshSoftwareAnimator(skeletonMatrixCalculator:AbstractSkeletonMatrixCalculator, data:SkinnedMeshAsset=null) {
			_skeletonMatrixCalculator = skeletonMatrixCalculator;
			_data = data;
		}
		public function get cachePrecision():uint {
			return cachePrecision;
		}
		public function set cachePrecision(value:uint):void {
			_cachePrecision = value;
			_cacheInterval = _cachePrecision == 0 ? 0 : 1 / _cachePrecision;
		}
		public function get skeletonMatrixCalculator():AbstractSkeletonMatrixCalculator {
			return _skeletonMatrixCalculator;
		}
		public function set skeletonMatrixCalculator(value:AbstractSkeletonMatrixCalculator):void {
			_skeletonMatrixCalculator = value;
		}
		public function get skinnedMeshAsset():SkinnedMeshAsset {
			return _data;
		}
		public function set skinnedMeshAsset(value:SkinnedMeshAsset):void {
			_data = value;
		}
		public function get dataIsReady():Boolean {
			return _data != null && _srcVertices != null;
		}
		public function get destVertices():Vector.<Number> {
			return _destVertices;
		}
		public function set destVertices(value:Vector.<Number>):void {
			_destVertices = value;
		}
		public function get srcVertices():Vector.<Number> {
			return _srcVertices;
		}
		public function set srcVertices(value:Vector.<Number>):void {
			_srcVertices = value;
		}
		protected override function _update(lerp:Boolean):void {
			var matricesCache:Object;
			
			if (_skeletonMatrixCalculator == null || _currentClip == null || _data == null || _srcVertices == null || _destVertices == null) return;
			
			var curData:SkeletonAnimationAsset = _currentClip._data;
			
			if (_currentBlendFrames < _totalBlendFrames && _globalCurrentFrame < _totalBlendFrames) {
				_currentBlendFrames = _globalCurrentFrame;
				var prevData:SkeletonAnimationAsset = _prevClip._data;
				
				_skeletonMatrixCalculator.calculateBlend(_currentLabel, _data.label, _cacheInterval, _globalCurrentFrame, 
					_data.boneNames, curData.rootBones, curData.animationDataByNameMap, _data, 
					_prevLabel, _prevFrame, prevData.animationDataByNameMap, _currentBlendFrames / _totalBlendFrames);
			} else {
				_skeletonMatrixCalculator.calculate(_currentLabel, _data.label, _cacheInterval, _globalCurrentFrame, 
					_data.boneNames, curData.rootBones, curData.animationDataByNameMap, _data);
			}
			
			matricesCache = _skeletonMatrixCalculator._animationMatrices;
			
			var m:Matrix4x4;
			
			var skinnedVertices:Vector.<SkinnedVertex> = _data.skinnedVertices;
			var len:int = skinnedVertices.length;
			for (var i:int = 0; i < len; i++) {
				var dx:Number = 0;
				var dy:Number = 0;
				var dz:Number = 0;
				
				var v0:int = i * 3;
				var v1:int = v0 + 1;
				var v2:int = v0 + 2;
				
				var sx:Number = _srcVertices[v0];
				var sy:Number = _srcVertices[v1];
				var sz:Number = _srcVertices[v2];
				
				var sv:SkinnedVertex = skinnedVertices[i];
				var num:int = sv.boneNameIndices.length;
				for (var j:int = 0; j < num; j++) {
					var boneName:String = _data.boneNames[sv.boneNameIndices[j]];
					
					var weight:Number = sv.weights[j];
					
					var sc:SimpleCoordinates3D = matricesCache[boneName];
					
					m = sc.matrix;
					
					dx += (sx * m.m00 + sy * m.m10 + sz * m.m20 + m.m30) * weight;
					dy += (sx * m.m01 + sy * m.m11 + sz * m.m21 + m.m31) * weight;
					dz += (sx * m.m02 + sy * m.m12 + sz * m.m22 + m.m32) * weight;
				}
				
				_destVertices[v0] = dx;
				_destVertices[v1] = dy;
				_destVertices[v2] = dz;
			}
			
			_updateCount++;
			
			/*
			for (var key:* in data) {
				var dx:Number = 0;
				var dy:Number = 0;
				var dz:Number = 0;
				
				var arr:Array = data[key];
				var index:uint = uint(key) * 3;
				var length:uint = arr.length;
				for (var i:uint = 0; i < length; i += 5) {
					var weight:Number = arr[int(i + 1)];
					
					var sc:SimpleCoordinates3D = matricesCache[arr[i]];
					var m:Matrix4x4 = sc.matrix;
					
					f3.x = arr[int(i + 2)];
					f3.y = arr[int(i + 3)];
					f3.z = arr[int(i + 4)];
					
					include '../math/Matrix4x4_transform3x4Float3.define';
					
					dx += f3.x * weight;
					dy += f3.y * weight;
					dz += f3.z * weight;
					
					//use Vertex transformLocalSpace method
					//x += (sx*_om.m00+sy*_om.m10+sz*_om.m20+_om.m30)*weight;
					//y += (sx*_om.m01+sy*_om.m11+sz*_om.m21+_om.m31)*weight;
					//z += (sx*_om.m02+sy*_om.m12+sz*_om.m22+_om.m32)*weight;
				}
				_destVertices[index++] = dx;
				_destVertices[index++] = dy;
				_destVertices[index] = dz;
			}
			
			_updateCount++;
			*/
		}
	}
}