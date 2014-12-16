package asgl.animators {
	import asgl.asgl_protected;
	
	use namespace asgl_protected;
	
	public class BaseAnimator {
		asgl_protected var _updateCount:uint;
		
		protected var _globalCurrentFrame:Number;
		protected var _globalCurrentTileFrame:int;
		protected var _localCurrentFrame:Number;
		protected var _localCurrentTileFrame:int;
		protected var _accumulationFrame:Number;
		protected var _localEndFrame:int;
		protected var _localStartFrame:int;
		protected var _endFrame:Number;
		protected var _rangeLength:Number;
		protected var _frameInterval:Number;
		protected var _startFrame:Number;
		protected var _localTotalFrames:int;
		protected var _globalTotalFrames:int;
		protected var _currentWrap:int;
		protected var _globalWrap:int;
		
		protected var _clips:Object;
		
		protected var _totalBlendFrames:Number;
		protected var _currentBlendFrames:Number;
		
		protected var _currentLabel:String;
		protected var _currentClip:AnimationClip;
		protected var _prevLabel:String;
		protected var _prevClip:AnimationClip;
		protected var _prevFrame:Number;
		
		public function BaseAnimator() {
			_globalWrap = AnimationWrapMode.CLAMP;
			_currentWrap = _globalWrap;
			_globalCurrentFrame = -1;
			_localCurrentFrame = 0;
			_accumulationFrame = 0;
			_localStartFrame = 0;
			_localEndFrame = -1;
			_globalTotalFrames = 0;
			_updateCount = 1;
			
			_clips = {};
		}
		public function get currentWrap():int {
			return _currentWrap;
		}
		public function get accumulationFrame():Number {
			return _accumulationFrame;
		}
		public function get localCurrentFrame():Number {
			return _localCurrentFrame;
		}
		public function get localCurrentTileFrame():int {
			return _localCurrentTileFrame;
		}
		public function get globalCurrentFrame():Number {
			return _globalCurrentFrame;
		}
		public function get globalCurrentTileFrame():int {
			return _globalCurrentTileFrame;
		}
		public function get globalWrap():int {
			return _globalWrap;
		}
		public function set globalWrap(value:int):void {
			if (_globalWrap != value) {
				if (value == AnimationWrapMode.CLAMP || value == AnimationWrapMode.LOOP || value == AnimationWrapMode.PINGPONG) {
					_globalWrap = value;
					
					if (_currentClip != null) {
						_currentWrap = _globalWrap;
						appendFrame(0, false);
					}
				}
			}
		}
		public function get localTotalFrames():int {
			return _localTotalFrames;
		}
		public function get globalTotalFrames():int {
			return _globalTotalFrames;
		}
		public function get updateCount():uint {
			return _updateCount;
		}
		public function appendFrame(frame:Number, update:Boolean=true):void {
			if (_globalTotalFrames < 1) {
				if (_globalCurrentFrame != -1) {
					_clear();
					_localCurrentFrame = -1;
					_localCurrentTileFrame = -1;
					_accumulationFrame = 0;
					_globalCurrentFrame = -1;
					_globalCurrentTileFrame = -1;
				}
				
				return;
			}
			
			_accumulationFrame += frame;
			
			if (_currentWrap == AnimationWrapMode.CLAMP) {
				_localCurrentFrame += frame;
				
				if (_localCurrentFrame < 0) {
					_localCurrentFrame = 0;
				} else if (_localCurrentFrame > _rangeLength) {
					_localCurrentFrame = _rangeLength;
				}
			} else if (_currentWrap == AnimationWrapMode.LOOP) {
				_localCurrentFrame += frame;
				
				if (_rangeLength == 0) {
					_localCurrentFrame = 0;
				} else {
					if (_localCurrentFrame > _rangeLength) {
						_localCurrentFrame = _rangeLength % (_localCurrentFrame - _rangeLength);
					} else if (_localCurrentFrame < 0) {
						_localCurrentFrame = _rangeLength + (_localCurrentFrame % _rangeLength);
					}
				}
			} else {
				if (_rangeLength == 0) {
					_localCurrentFrame = 0;
				} else {
					frame = _accumulationFrame / _rangeLength;
					if (frame < 0) {
						if (int(frame) % 2 == 0) {
							_localCurrentFrame = _rangeLength + (_accumulationFrame % _rangeLength);
						} else {
							_localCurrentFrame = -_accumulationFrame % _rangeLength;
						}
					} else {
						if (int(frame) % 2 == 0) {
							_localCurrentFrame = _accumulationFrame % _rangeLength;
						} else {
							_localCurrentFrame = _rangeLength - (_accumulationFrame % _rangeLength);
						}
					}
				}
			}
			
			_globalCurrentFrame = _startFrame + _localCurrentFrame;
			
			if (_frameInterval == 0) {
				_localCurrentTileFrame = 0;
			} else {
				_localCurrentTileFrame = _localCurrentFrame / _frameInterval;
				if (_localCurrentTileFrame >= _localTotalFrames) _localCurrentTileFrame = _rangeLength;
			}
			
			_globalCurrentTileFrame = _startFrame + _localCurrentTileFrame;
			
			if (update) this.update();
		}
		public function changeClip(label:String, gotoFrame:Number=0, blendFrames:Number=0, update:Boolean=true):Boolean {
			if (blendFrames > 0) {
				_prevLabel = _currentLabel;
				_prevClip = _currentClip;
				_prevFrame = _globalCurrentFrame;
				
				_totalBlendFrames = blendFrames;
				_currentBlendFrames = 0;
			} else {
				_totalBlendFrames = 0;
				_prevLabel = null;
				_prevClip = null;
			}
			
			if (_currentLabel != label) {
				_currentLabel = label;
				_currentClip = _clips[label];
			}
			
			if (_currentClip == null) {
				_currentWrap = _globalWrap;
				
				if (gotoFrame >= 0) {
					_setTotalFrames(0);
					this.gotoFrame(gotoFrame, update);
				} else {
					_setTotalFrames(0);
					appendFrame(0, update);
				}
				
				return false;
			} else {
				if (_currentClip._wrap == AnimationWrapMode.NONE) {
					_currentWrap = _globalWrap;
				} else {
					_currentWrap = _currentClip._wrap;
				}
				
				if (gotoFrame >= 0) {
					_setTotalFrames(_currentClip._totalFrames);
					this.gotoFrame(gotoFrame, update);
				} else {
					_setTotalFrames(_currentClip._totalFrames);
					appendFrame(0, update);
				}
				
				return true;
			}
		}
		public function clearClips():void {
			for (var key:* in _clips) {
				_clips = {};
				_currentClip = null;
				_prevClip = null;
				
				break;
			}
			
			_currentWrap = _globalWrap;
			
			_setTotalFrames(0);
			appendFrame(0, false);
		}
		public function gotoFrame(frame:Number, update:Boolean=true):void {
			_localCurrentFrame = frame;
			_accumulationFrame = frame;
			appendFrame(0, update);
		}
		public function getClip(label:String):AnimationClip {
			return _clips[label];
		}
		public function setClip(label:String, clip:AnimationClip):void {
			if (clip == null) {
				delete _clips[label];
				
				if (_currentLabel == label) {
					_currentClip = null;
					
					_currentWrap = _globalWrap;
					
					_setTotalFrames(0);
					appendFrame(0, false);
				}
				
				if (_prevLabel == label) {
					_prevClip = null;
				}
			} else {
				_clips[label] = clip;
				
				if (_currentLabel == label) {
					_currentClip = clip;
					
					if (_currentClip._wrap == AnimationWrapMode.NONE) {
						_currentWrap = _globalWrap;
					} else {
						_currentWrap = _currentClip._wrap;
					}
					
					_setTotalFrames(clip._totalFrames);
					appendFrame(0, false);
				}
				
				if (_prevLabel == label) {
					_prevClip = clip;
				}
			}
		}
		public function update():void {
			if (_globalTotalFrames < 1 || _globalCurrentFrame < 0) return;
			
			_update(_globalCurrentFrame != int(_globalCurrentFrame));
		}
		protected function _clear():void {
		}
		protected function _update(lerp:Boolean):void {
			_updateCount++;
		}
		private function _setTotalFrames(totalFrames:int):void {
			_globalTotalFrames = totalFrames;
			
			if (_currentClip == null) {
				_setRange();
			} else {
				_setRange(_currentClip._startFrame, _currentClip._endFrame);
			}
		}
		private function _setRange(startFrame:int=0, endFrame:int=-1):void {
			if (endFrame < 0) {
				endFrame = _globalTotalFrames - 1;
				_localEndFrame = -1;
			} else {
				_localEndFrame = endFrame;
				if (endFrame >= _globalTotalFrames) endFrame = _globalTotalFrames - 1;
			}
			if (startFrame < 0) {
				startFrame = 0;
				_localStartFrame = 0;
			} else if (startFrame > endFrame) {
				_localStartFrame = startFrame;
				startFrame = endFrame;
			}
			
			_startFrame = startFrame;
			_endFrame = endFrame;
			_rangeLength = _endFrame - _startFrame;
			
			if (_globalTotalFrames == 0) {
				_localTotalFrames = 0;
				_frameInterval = 0;
			} else {
				_localTotalFrames = _rangeLength + 1;
				_frameInterval = _rangeLength / _localTotalFrames;
			}
		}
	}
}