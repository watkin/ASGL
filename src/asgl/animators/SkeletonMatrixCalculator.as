package asgl.animators {
	import asgl.asgl_protected;
	import asgl.entities.Object3D;
	import asgl.entities.SimpleCoordinates3D;
	import asgl.math.Float3;
	import asgl.math.Float4;
	import asgl.math.Matrix4x4;
	
	use namespace asgl_protected;

	public class SkeletonMatrixCalculator extends AbstractSkeletonMatrixCalculator {
		asgl_protected var _animationLabel:String;
		asgl_protected var _skinnedMeshLabel:String;
		asgl_protected var _frame:Number;
		asgl_protected var _prevAnimationLabel:String;
		
		asgl_protected var _matricesCache:Object;
		asgl_protected var _matricesBlendCache:Object;
		
		private var _needNewIns:Boolean;
		private var _setProperties:Boolean;
		
		private var _intFrame:int;
		private var _interp:Number;
		private var _isBlend:Boolean;
		//temp
		private var _matricesByNameMap:Object;
		private var _rootBones:Vector.<Object3D>;
		
		public function SkeletonMatrixCalculator() {
			_setProperties = true;
			_matricesCache = {};
			_matricesBlendCache = {};
		}
		public function get frame():Number {
			return _frame;
		}
		public function get animationlabel():String {
			return _animationLabel;
		}
		public function get skinnedMeshLabel():String {
			return _skinnedMeshLabel;
		}
		public function get prevAnimationLabel():String {
			return _prevAnimationLabel;
		}
		public function changeBlendCache(animationLabel:String, skinnedMeshLabel:String, cachePrecision:uint, frame:Number, prevAnimationLabel:String, prevFrame:Number, weight:Number):Boolean {
			if (cachePrecision == 0) {
				return false;
			} else {
				var label:String = animationLabel + '|' + skinnedMeshLabel;
				var prevLabel:String = prevAnimationLabel + '|' + skinnedMeshLabel;
				
				var map:Object = _matricesBlendCache[label];
				if (map == null) {
					return false;
				} else {
					map = map[label];
					if (map == null) {
						return false;
					} else {
						var cacheInterval:Number = 1 / cachePrecision;
						
						var intFrame:int = prevFrame;
						var prevCacheKey:String = intFrame + '.' + int((prevFrame - intFrame) / cacheInterval);
						intFrame = frame;
						var curCacheKey:String = intFrame + '.' + int((frame - intFrame) / cacheInterval);
						var cacheKey:String = label + '|' + prevCacheKey + '|' + label + '|' + curCacheKey + '|' + int(weight / cacheInterval);
						
						var animMap:Object = map[cacheKey];
						if (animMap == null) {
							return false;
						} else {
							_animationMatrices = animMap;
							_needNewIns = true;
							
							_animationLabel = animationlabel;
							_skinnedMeshLabel = skinnedMeshLabel;
							_prevAnimationLabel = prevAnimationLabel;
							_frame = frame;
							
							return true;
						}
					}
				}
			}
		}
		public function changeCache(animationLabel:String, skinnedMeshLabel:String, cachePrecision:uint, frame:Number):Boolean {
			if (cachePrecision == 0) {
				return false;
			} else {
				var label:String = animationLabel + '|' + skinnedMeshLabel;
				
				var frameMap:Object = _matricesCache[label];
				if (frameMap == null) {
					return false;
				} else {
					var cacheInterval:Number = 1 / cachePrecision;
					
					var intFrame:int = frame;
					var animMap:Object = frameMap[intFrame + '.' + int((frame - intFrame) / cacheInterval)];
					if (animMap == null) {
						return false;
					} else {
						_animationMatrices = animMap;
						_needNewIns = true;
						
						_animationLabel = animationlabel;
						_skinnedMeshLabel = skinnedMeshLabel;
						_prevAnimationLabel = null;
						_frame = frame;
						
						return true;
					}
				}
			}
		}
		public function clearCache(animationLabel:String=null, skinnedMeshLabel:String=null):void {
			if (animationLabel == null && skinnedMeshLabel == null) {
				for (var key:* in _matricesCache) {
					_matricesCache = {};
					break;
				}
				
				for (key in _matricesBlendCache) {
					_matricesBlendCache = {};
					break;
				}
				
				_animationLabel = null;
				_skinnedMeshLabel = null;
				_prevAnimationLabel = null;
				_frame = frame;
			} else {
				var label:String = animationLabel + '|' + skinnedMeshLabel;
				
				delete _matricesCache[label];
				delete _matricesBlendCache[label];
				
				if (_animationLabel == animationLabel && _skinnedMeshLabel == skinnedMeshLabel) {
					_animationLabel = null;
					_skinnedMeshLabel = null;
					_prevAnimationLabel = null;
					_frame = frame;
				}
			}
		}
		public function clearAnimationMatrices():void {
			for (var key:* in _animationMatrices) {
				_animationMatrices = {};
				_needNewIns = false;
				break;
			}
		}
		/*
		public static function getSkinnedMeshBoneMatrixComponentsFromCache(cache:Object, boneNames:Vector.<String>, opM00_M03:Vector.<Number>, opM10_M13:Vector.<Number>, opM20_M23:Vector.<Number>):void {
			var length:int = boneNames.length;
			
			var max:uint = length * 4;
			
			opM00_M03.length = max;
			opM10_M13.length = max;
			opM20_M23.length = max;
			
			var index:uint = 0;
			
			for (var i:int = 0; i < length; i++) {
				var sc:SimpleCoordinates3D = cache[boneNames[i]];
				if (sc == null) {
					opM00_M03[index] = 0;
					opM10_M13[index] = 0;
					opM20_M23[index++] = 0;
					
					opM00_M03[index] = 0;
					opM10_M13[index] = 0;
					opM20_M23[index++] = 0;
					
					opM00_M03[index] = 0;
					opM10_M13[index] = 0;
					opM20_M23[index++] = 0;
					
					opM00_M03[index] = 0;
					opM10_M13[index] = 0;
					opM20_M23[index++] = 0;
				} else {
					var m:Matrix4x4 = sc.matrix;
					
					opM00_M03[index] = m.m00;
					opM10_M13[index] = m.m01;
					opM20_M23[index++] = m.m02;
					
					opM00_M03[index] = m.m10;
					opM10_M13[index] = m.m11;
					opM20_M23[index++] = m.m12;
					
					opM00_M03[index] = m.m20;
					opM10_M13[index] = m.m21;
					opM20_M23[index++] = m.m22;
					
					opM00_M03[index] = m.m30;
					opM10_M13[index] = m.m31;
					opM20_M23[index++] = m.m32;
				}
			}
		}
		*/
		public static function getSkinnedMeshBoneMatricesFromCache(cache:Object, boneNames:Vector.<String>, op:Vector.<Number>=null):Vector.<Number> {
			var length:int = boneNames.length;
			
			var max:int = length * 12;
			
			if (op == null) {
				op = new Vector.<Number>(max);
			} else if (op.length != max) {
				if (op.fixed) {
					if (op.length < max) return null;
				} else {
					op.length = max;
				}
			}
			
			var index:int = 0;
			
			for (var i:int = 0; i < length; i++) {
				var sc:SimpleCoordinates3D = cache[boneNames[i]];
				if (sc == null) {
					op[index++] = 0;
					op[index++] = 0;
					op[index++] = 0;
					op[index++] = 0;
					op[index++] = 0;
					op[index++] = 0;
					op[index++] = 0;
					op[index++] = 0;
					op[index++] = 0;
					op[index++] = 0;
					op[index++] = 0;
					op[index++] = 0;
				} else {
					var m:Matrix4x4 = sc.matrix;
					
					op[index++] = m.m00;
					op[index++] = m.m10;
					op[index++] = m.m20;
					op[index++] = m.m30;
					op[index++] = m.m01;
					op[index++] = m.m11;
					op[index++] = m.m21;
					op[index++] = m.m31;
					op[index++] = m.m02;
					op[index++] = m.m12;
					op[index++] = m.m22;
					op[index++] = m.m32;
				}
			}
			
			return op;
		}
		/*
		public function getSkinnedMeshBoneMatrixComponents(boneNames:Vector.<String>, opM00_M03:Vector.<Number>, opM10_M13:Vector.<Number>, opM20_M23:Vector.<Number>):void {
			getSkinnedMeshBoneMatrixComponentsFromCache(_animationMatrices, boneNames, opM00_M03, opM10_M13, opM20_M23);
		}
		*/
		public override function getSkinnedMeshBoneMatrices(boneNames:Vector.<String>, op:Vector.<Number>=null):Vector.<Number> {
			return getSkinnedMeshBoneMatricesFromCache(_animationMatrices, boneNames, op);
		}
		public static function getSkinnedMeshBoneTRSFromCache(cache:Object, boneNames:Vector.<String>, op:Vector.<Number>=null):Vector.<Number> {
			var length:int = boneNames.length;
			
			var max:int = length * 12;
			
			if (op == null) {
				op = new Vector.<Number>(max);
			} else if (op.length != max) {
				if (op.fixed) {
					if (op.length < max) return null;
				} else {
					op.length = max;
				}
			}
			
			var index:int = 0;
			
			for (var i:int = 0; i < length; i++) {
				var sc:SimpleCoordinates3D = cache[boneNames[i]];
				if (sc == null) {
					op[index++] = 0;
					op[index++] = 0;
					op[index++] = 0;
					op[index++] = 0;
					op[index++] = 0;
					op[index++] = 0;
					op[index++] = 0;
					op[index++] = 0;
					op[index++] = 0;
					op[index++] = 0;
					op[index++] = 0;
					op[index++] = 0;
				} else {
					op[index++] = sc.matrix.m30;
					op[index++] = sc.matrix.m31;
					op[index++] = sc.matrix.m32;
					op[index++] = 0;
					op[index++] = sc.rotation.x;
					op[index++] = sc.rotation.y;
					op[index++] = sc.rotation.z;
					op[index++] = sc.rotation.w;
					op[index++] = sc.scale.x;
					op[index++] = sc.scale.y;
					op[index++] = sc.scale.z;
					op[index++] = 0;
				}
			}
			
			return op;
		}
		public function getSkinnedMeshBoneQuatAndPos(boneNames:Vector.<String>, op:Vector.<Number>=null):Vector.<Number> {
			return getSkinnedMeshBoneTRSFromCache(_animationMatrices, boneNames, op);
		}
		public override function calculate(animationLabel:String, skinnedMeshLabel:String, cacheInterval:Number, frame:Number, 
										   bonesName:Vector.<String>, rootBones:Vector.<Object3D>, animationDataByNameMap:Object, skinnedMeshAsset:SkinnedMeshAsset, 
										   cacheKey:String=null, cacheIntervalAmount:int=0):Boolean {
			if (_setProperties) {
				_frame = frame;
				_animationLabel = animationLabel;
				_skinnedMeshLabel = skinnedMeshLabel;
				_prevAnimationLabel = null;
			}
			
			var frameMap:Object;
			
			if (cacheInterval > 0) {
				var label:String = animationLabel + '|' + skinnedMeshLabel;
				
				frameMap = _matricesCache[label];
				if (frameMap == null) {
					frameMap = {};
					_matricesCache[label] = frameMap;
				} else {
					if (cacheKey == null) {
						var intFrame:int = frame;
						cacheIntervalAmount = int((frame - intFrame) / cacheInterval);
						cacheKey = intFrame + '.' + cacheIntervalAmount;
					}
					
					var animMap:Object = frameMap[cacheKey];
					if (animMap == null) {
						frame = intFrame + cacheInterval * cacheIntervalAmount;
					} else {
						_animationMatrices = animMap;
						
						return false;
					}
				}
			}
			
			if (_needNewIns) _animationMatrices = {};
			_needNewIns = cacheInterval > 0;
			
			_intFrame = frame;
			_interp = frame - _intFrame;
			_rootBones = rootBones;
			_matricesByNameMap = animationDataByNameMap
			
			_isBlend = false;
			
			if (cacheInterval == 0) {
				if (_interp == 0) {
					_updateBones(bonesName, skinnedMeshAsset);
				} else {
					_updateBonesLerp(bonesName, skinnedMeshAsset);
				}
			} else {
				var length:int = _rootBones.length;
				var i:int;
				
				if (_interp == 0) {
					for (i = 0; i < length; i++) {
						_updateChildren(_rootBones[i]);
					}
				} else {
					for (i = 0; i < length; i++) {
						_updateChildrenLerp(_rootBones[i], skinnedMeshAsset);
					}
				}
				
				frameMap[cacheKey] = _animationMatrices;
			}
			
			_rootBones = null;
			_matricesByNameMap = null;
			
			return true;
		}
		public override function calculateBlend(animationLabel:String, skinnedMeshLabel:String, cacheInterval:Number, frame:Number, 
												bonesName:Vector.<String>, rootBones:Vector.<Object3D>, animationDataByNameMap:Object, skinnedMeshAsset:SkinnedMeshAsset, 
												prevAnimationLabel:String, prevFrame:Number, prevAnimationDataByNameMap:Object, weight:Number):Boolean {
			var label:String;
			var prevLabel:String;
			
			_frame = frame;
			_animationLabel = animationLabel;
			_skinnedMeshLabel = skinnedMeshLabel;
			_prevAnimationLabel = prevAnimationLabel;
			
			var map:Object;
			var cacheKey:String;
			var prevCacheKey:String;
			var curCacheKey:String;
			var prevCacheIntervalAmount:int;
			var curCacheIntervalAmount:int;
			
			if (cacheInterval > 0) {
				label = animationLabel + '|' + skinnedMeshLabel;
				prevLabel = prevAnimationLabel + '|' + skinnedMeshLabel;
				
				var intFrame:int = prevFrame;
				prevCacheIntervalAmount = int((prevFrame - intFrame) / cacheInterval);
				prevCacheKey = intFrame + '.' + prevCacheIntervalAmount;
				
				intFrame = frame;
				curCacheIntervalAmount = int((frame - intFrame) / cacheInterval);
				curCacheKey = intFrame + '.' + curCacheIntervalAmount;
				
				var cacheWeightIntervalAmount:int = int(weight / cacheInterval);
				
				cacheKey = prevLabel + '|' + prevCacheKey + '|' + label + '|' + curCacheKey + '|' + cacheWeightIntervalAmount;
				
				map = _matricesBlendCache[label];
				if (map != null) {
					map = map[prevLabel];
					if (map != null) {
						var animMap:Object = map[cacheKey];
						
						if (animMap == null) {
							weight = cacheWeightIntervalAmount * cacheInterval;
						} else {
							_animationMatrices = animMap;
							
							return false;
						}
					}
				}
			}
			
			_isBlend = true;
			_setProperties = false;
			
			if (_needNewIns) _animationMatrices = {};
			_needNewIns = false;
			
			calculate(prevAnimationLabel, skinnedMeshLabel, cacheInterval, prevFrame, bonesName, rootBones, prevAnimationDataByNameMap, skinnedMeshAsset, prevCacheKey, prevCacheIntervalAmount);
			var prevMatrices:Object = _animationMatrices;
			
			_animationMatrices = {};
			_needNewIns = false;
			
			calculate(animationLabel, skinnedMeshLabel, cacheInterval, frame, bonesName, rootBones, animationDataByNameMap, skinnedMeshAsset, curCacheKey, curCacheIntervalAmount);
			var curMatrices:Object = _animationMatrices;
			
			_needNewIns = cacheInterval > 0;
			_setProperties = true;
			
			for (var name:String in prevMatrices) {
				var sc0:SimpleCoordinates3D = prevMatrices[name];
				var sc1:SimpleCoordinates3D = curMatrices[name];
				
				var sc:SimpleCoordinates3D = new SimpleCoordinates3D();
				var m:Matrix4x4 = sc.matrix;
				
				var q0:Float4 = sc0.rotation;
				var q1:Float4 = sc1.rotation;
				var t:Number = weight;
				var opFloat4:Float4 = sc.rotation;
				
				include '../math/Float4_slerpQuaternion.define';
				
				var sx:Number = sc0.scale.x + (sc1.scale.x - sc0.scale.x) * weight;
				var sy:Number = sc0.scale.y + (sc1.scale.y - sc0.scale.y) * weight;
				var sz:Number = sc0.scale.z + (sc1.scale.z - sc0.scale.z) * weight;
				
				m.m30 = sc0.matrix.m30 + (sc1.matrix.m30 - sc0.matrix.m30) * weight;
				m.m31 = sc0.matrix.m31 + (sc1.matrix.m31 - sc0.matrix.m31) * weight;
				m.m32 = sc0.matrix.m32 + (sc1.matrix.m32 - sc0.matrix.m32) * weight;
				
				var x2:Number = opFloat4.x * 2;
				var y2:Number = opFloat4.y * 2;
				var z2:Number = opFloat4.z * 2;
				var xx:Number = opFloat4.x * x2;
				var xy:Number = opFloat4.x * y2;
				var xz:Number = opFloat4.x * z2;
				var yy:Number = opFloat4.y * y2;
				var yz:Number = opFloat4.y * z2;
				var zz:Number = opFloat4.z * z2;
				var wx:Number = opFloat4.w * x2;
				var wy:Number = opFloat4.w * y2;
				var wz:Number = opFloat4.w * z2;
				m.m00 = (1 - yy - zz) * sx;
				m.m01 = (xy + wz) * sx;
				m.m02 = (xz - wy) * sx;
				m.m10 = (xy - wz) * sy;
				m.m11 = (1 - xx - zz) * sy;
				m.m12 = (yz + wx) * sy;
				m.m20 = (xz + wy) * sz;
				m.m21 = (yz - wx) * sz;
				m.m22 = (1 - xx - yy) * sz;
				
				m.prepend4x4(skinnedMeshAsset.preOffsetMatrices[name]);
				
				sc.scale.x = sx;
				sc.scale.y = sy;
				sc.scale.z = sz;
				
				_animationMatrices[name] = m;
			}
			
			if (cacheInterval > 0) {
				map = _matricesBlendCache[label];
				if (map == null) {
					map = {};
					_matricesBlendCache[label] = map;
				}
				
				var map2:Object = map[prevAnimationLabel];
				if (map2 == null) {
					map2 = {};
					map[prevAnimationLabel] = map2;
				}
				
				map2[cacheKey] = _animationMatrices;
				
				//============
				map = _matricesBlendCache[prevAnimationLabel];
				if (map == null) {
					map = {};
					_matricesBlendCache[prevAnimationLabel] = map;
				}
				
				map2 = map[label];
				if (map2 == null) {
					map2 = {};
					map[label] = map2;
				}
				
				map2[cacheKey] = _animationMatrices;
			}
			
			return true;
		}
		private function _updateBones(names:Vector.<String>, skinnedMeshAsset:SkinnedMeshAsset):void {
			var len:int = names.length;
			
			for (var i:int = 0; i < len; i++) {
				var name:String = names[i];
				
				var coord:SimpleCoordinates3D = _animationMatrices[name];
				if (coord == null) {
					coord = new SimpleCoordinates3D();
					_animationMatrices[name] = coord;
				}
				var cm:Matrix4x4 = coord.matrix;
				
				var v:Vector.<SkeletonData> = _matricesByNameMap[name];
				
				var sd:SkeletonData = v[_intFrame];
				
				var sdm:Matrix4x4 = sd.global.matrix;
				var rotation:Float4 = sd.global.rotation;
				var scale:Float3 = sd.global.scale;
				
				cm.m30 = sdm.m30;
				cm.m31 = sdm.m31;
				cm.m32 = sdm.m32;
				coord.rotation.x = rotation.x;
				coord.rotation.y = rotation.y;
				coord.rotation.z = rotation.z;
				coord.rotation.w = rotation.w;
				coord.scale.x = scale.x;
				coord.scale.y = scale.y;
				coord.scale.z = scale.z;
				
				if (!_isBlend) {
					cm.m00 = sdm.m00;
					cm.m01 = sdm.m01;
					cm.m02 = sdm.m02;
					cm.m10 = sdm.m10;
					cm.m11 = sdm.m11;
					cm.m12 = sdm.m12;
					cm.m20 = sdm.m20;
					cm.m21 = sdm.m21;
					cm.m22 = sdm.m22;
					
					cm.prepend4x4(skinnedMeshAsset.preOffsetMatrices[name]);
				}
			}
		}
		private function _updateChildren(bone:Object3D):void {
			var name:String = bone.name;
			
			var coord:SimpleCoordinates3D = _animationMatrices[name];
			if (coord == null) {
				coord = new SimpleCoordinates3D();
				_animationMatrices[name] = coord;
			}
			
			var cm:Matrix4x4 = coord.matrix;
			
			var v:Vector.<SkeletonData> = _matricesByNameMap[name];
			
			var sd:SkeletonData = v[_intFrame];
			
			var sdm:Matrix4x4 = sd.global.matrix;
			var rotation:Float4 = sd.global.rotation;
			var scale:Float3 = sd.global.scale;
			
			cm.m30 = sdm.m30;
			cm.m31 = sdm.m31;
			cm.m32 = sdm.m32;
			coord.rotation.x = rotation.x;
			coord.rotation.y = rotation.y;
			coord.rotation.z = rotation.z;
			coord.rotation.w = rotation.w;
			coord.scale.x = scale.x;
			coord.scale.y = scale.y;
			coord.scale.z = scale.z;
			
			if (!_isBlend) {
				cm.m00 = sdm.m00;
				cm.m01 = sdm.m01;
				cm.m02 = sdm.m02;
				cm.m10 = sdm.m10;
				cm.m11 = sdm.m11;
				cm.m12 = sdm.m12;
				cm.m20 = sdm.m20;
				cm.m21 = sdm.m21;
				cm.m22 = sdm.m22;
			}
			
			var coord3D:Object3D = bone;
			
			include '../entities/Coordinates3D_externalLoopChildrenUpperHalf.define';
			_updateChildren(childCoord);
			include '../entities/Coordinates3D_externalLoopChildrenBottomHalf.define';
		}
		private function _updateBonesLerp(names:Vector.<String>, skinnedMeshAsset:SkinnedMeshAsset):void {
			var len:int = names.length;
			
			for (var i:int = 0; i < len; i++) {
				var name:String = names[i];
				
				var coord:SimpleCoordinates3D = _animationMatrices[name];
				if (coord == null) {
					coord = new SimpleCoordinates3D();
					_animationMatrices[name] = coord;
				}
				var cm:Matrix4x4 = coord.matrix;
				
				var v:Vector.<SkeletonData> = _matricesByNameMap[name];
				
				var sd0:SkeletonData = v[_intFrame];
				var sd1:SkeletonData = v[int(_intFrame + 1)];
				
				var pos0:Matrix4x4 = sd0.global.matrix;
				var pos1:Matrix4x4 = sd1.global.matrix;
				
				var q0:Float4 = sd0.global.rotation;
				var q1:Float4 = sd1.global.rotation;
				
				var s0:Float3 = sd0.global.scale;
				var s1:Float3 = sd1.global.scale;
				
				var t:Number = _interp;
				var opFloat4:Float4 = coord.rotation;
				
				include '../math/Float4_slerpQuaternion.define';
				
				var sx:Number = s0.x + (s1.x - s0.x) * _interp;
				var sy:Number = s0.y + (s1.y - s0.y) * _interp;
				var sz:Number = s0.z + (s1.z - s0.z) * _interp;
				
				cm.m30 = pos0.m30 + (pos1.m30 - pos0.m30) * _interp;
				cm.m31 = pos0.m31 + (pos1.m31 - pos0.m31) * _interp;
				cm.m32 = pos0.m32 + (pos1.m32 - pos0.m32) * _interp;
				coord.scale.x = sx;
				coord.scale.y = sy;
				coord.scale.z = sz;
				
				if (!_isBlend) {
					var x2:Number = opFloat4.x * 2;
					var y2:Number = opFloat4.y * 2;
					var z2:Number = opFloat4.z * 2;
					var xx:Number = opFloat4.x * x2;
					var xy:Number = opFloat4.x * y2;
					var xz:Number = opFloat4.x * z2;
					var yy:Number = opFloat4.y * y2;
					var yz:Number = opFloat4.y * z2;
					var zz:Number = opFloat4.z * z2;
					var wx:Number = opFloat4.w * x2;
					var wy:Number = opFloat4.w * y2;
					var wz:Number = opFloat4.w * z2;
					cm.m00 = (1 - yy - zz) * sx;
					cm.m01 = (xy + wz) * sx;
					cm.m02 = (xz - wy) * sx;
					cm.m10 = (xy - wz) * sy;
					cm.m11 = (1 - xx - zz) * sy;
					cm.m12 = (yz + wx) * sy;
					cm.m20 = (xz + wy) * sz;
					cm.m21 = (yz - wx) * sz;
					cm.m22 = (1 - xx - yy) * sz;
					
					cm.prepend4x4(skinnedMeshAsset.preOffsetMatrices[name]);
				}
			}
		}
		private function _updateChildrenLerp(bone:Object3D, skinnedMeshAsset:SkinnedMeshAsset):void {
			var name:String = bone.name;
			
			var coord:SimpleCoordinates3D = _animationMatrices[name];
			if (coord == null) {
				coord = new SimpleCoordinates3D();
				_animationMatrices[name] = coord;
			}
			var cm:Matrix4x4 = coord.matrix;
			
			var v:Vector.<SkeletonData> = _matricesByNameMap[name];
			
			var sd0:SkeletonData = v[_intFrame];
			var sd1:SkeletonData = v[int(_intFrame + 1)];
			
			var pos0:Matrix4x4 = sd0.global.matrix;
			var pos1:Matrix4x4 = sd1.global.matrix;
			
			var q0:Float4 = sd0.global.rotation;
			var q1:Float4 = sd1.global.rotation;
			
			var s0:Float3 = sd0.global.scale;
			var s1:Float3 = sd1.global.scale;
			
			var t:Number = _interp;
			var opFloat4:Float4 = coord.rotation;
			
			include '../math/Float4_slerpQuaternion.define';
			
			var sx:Number = s0.x + (s1.x - s0.x) * _interp;
			var sy:Number = s0.y + (s1.y - s0.y) * _interp;
			var sz:Number = s0.z + (s1.z - s0.z) * _interp;
			
			cm.m30 = pos0.m30 + (pos1.m30 - pos0.m30) * _interp;
			cm.m31 = pos0.m31 + (pos1.m31 - pos0.m31) * _interp;
			cm.m32 = pos0.m32 + (pos1.m32 - pos0.m32) * _interp;
			coord.scale.x = sx;
			coord.scale.y = sy;
			coord.scale.z = sz;
			
			if (!_isBlend) {
				var x2:Number = opFloat4.x * 2;
				var y2:Number = opFloat4.y * 2;
				var z2:Number = opFloat4.z * 2;
				var xx:Number = opFloat4.x * x2;
				var xy:Number = opFloat4.x * y2;
				var xz:Number = opFloat4.x * z2;
				var yy:Number = opFloat4.y * y2;
				var yz:Number = opFloat4.y * z2;
				var zz:Number = opFloat4.z * z2;
				var wx:Number = opFloat4.w * x2;
				var wy:Number = opFloat4.w * y2;
				var wz:Number = opFloat4.w * z2;
				cm.m00 = (1 - yy - zz) * sx;
				cm.m01 = (xy + wz) * sx;
				cm.m02 = (xz - wy) * sx;
				cm.m10 = (xy - wz) * sy;
				cm.m11 = (1 - xx - zz) * sy;
				cm.m12 = (yz + wx) * sy;
				cm.m20 = (xz + wy) * sz;
				cm.m21 = (yz - wx) * sz;
				cm.m22 = (1 - xx - yy) * sz;
				
				cm.prepend4x4(skinnedMeshAsset.preOffsetMatrices[name]);
			}
			
			var coord3D:Object3D = bone;
			
			include '../entities/Coordinates3D_externalLoopChildrenUpperHalf.define';
			_updateChildrenLerp(childCoord, skinnedMeshAsset);
			include '../entities/Coordinates3D_externalLoopChildrenBottomHalf.define';
		}
	}
}