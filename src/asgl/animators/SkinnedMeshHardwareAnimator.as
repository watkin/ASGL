package asgl.animators {
	import asgl.asgl_protected;
	import asgl.shaders.scripts.ShaderConstants;
	
	use namespace asgl_protected;
	
	public class SkinnedMeshHardwareAnimator extends BaseAnimator {
		asgl_protected var _destShaderConstants:ShaderConstants;
		
		protected var _cachePrecision:uint = 0;
		protected var _cacheInterval:Number = 0;
		
		protected var _skeletonMatrixCalculator:AbstractSkeletonMatrixCalculator;
		protected var _data:SkinnedMeshAsset;
		
		public function SkinnedMeshHardwareAnimator(skeletonMatrixCalculator:AbstractSkeletonMatrixCalculator, data:SkinnedMeshAsset=null) {
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
			
			if (_destShaderConstants != null && _data != null) {
				_destShaderConstants._length = _data.boneNames.length * 3;
				_destShaderConstants.values.length = _destShaderConstants._length * 4;
			}
		}
		public function get dataIsReady():Boolean {
			return _data != null;
		}
		public function get destShaderConstants():ShaderConstants {
			return _destShaderConstants;
		}
		public function set destShaderConstants(value:ShaderConstants):void {
			_destShaderConstants = value;
			
			if (_destShaderConstants != null && _data != null) {
				_destShaderConstants._length = _data.boneNames.length * 3;
				_destShaderConstants.values.length = _destShaderConstants._length * 4;
			}
		}
		protected override function _update(lerp:Boolean):void {
			if (_skeletonMatrixCalculator == null || _currentClip == null || _data == null || _destShaderConstants == null) return;
			
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
			
			_skeletonMatrixCalculator.getSkinnedMeshBoneMatrices(_data.boneNames, _destShaderConstants.values);
			
			_updateCount++;
		}
	}
}

