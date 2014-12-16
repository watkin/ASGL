package asgl.pb {
	import asgl.asgl_protected;
	
	import flash.display.BitmapData;
	import flash.display.ShaderJob;
	import flash.events.Event;
	import flash.events.ShaderEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class PBExecutor {
		private static var _idAccumulator:uint = 0;
		
		private static var _runningInfo:PBExecuteDataInfo;
		private static var _queueHead:PBExecuteDataInfo;
		private static var _queueTail:PBExecuteDataInfo;
		
		private static var _infoCache:Vector.<PBExecuteDataInfo> = new Vector.<PBExecuteDataInfo>();
		private static var _infoCacheNum:uint;
		
		private static var _data:PBExecutorData = new PBExecutorData();
		
		private static var _progress:uint;
		private static var _timer:Timer;
		
		private var _map:Array;
		public function PBExecutor() {
			if (_timer == null) {
				_timer = new Timer(100, 0);
				_timer.addEventListener(TimerEvent.TIMER, _timerCompleteHandler);
			}
			
			_map = [];
		}
		public function cancel(id:uint=0):void {
			var info:PBExecuteDataInfo;
			var has:Boolean = false;
			
			if (id == 0) {
				for each (info in _map) {
					info.clear(true);
					
					if (_runningInfo == info) {
						has = true;
						
						_timer.stop();
					} else {
						if (info.prev == null) {
							_queueHead = _queueHead.next;
							if (_queueHead == null) {
								_queueTail = null;
							} else {
								_queueHead.prev = null;
								info.next = null;
							}
						} else if (info.next == null) {
							_queueTail = _queueTail.prev;
							_queueTail.next = null;
							info.prev = null;
						} else {
							info.prev.next = info.next;
							info.next.prev = info.prev;
							info.prev = null;
							info.next = null;
						}
					}
					
					_infoCache[_infoCacheNum++] = info;
				}
				_map.length = 0;
			} else {
				info = _map[id];
				if (info != null) {
					delete _map[id];
					info.clear(true);
					
					if (_runningInfo == info) {
						has = true;
					} else {
						if (info.prev == null) {
							_queueHead = _queueHead.next;
							if (_queueHead == null) {
								_queueTail = null;
							} else {
								_queueHead.prev = null;
								info.next = null;
							}
						} else if (info.next == null) {
							_queueTail = _queueTail.prev;
							_queueTail.next = null;
							info.prev = null;
						} else {
							info.prev.next = info.next;
							info.next.prev = info.prev;
							info.prev = null;
							info.next = null;
						}
					}
					
					_infoCache[_infoCacheNum++] = info;
				}
			}
			
			if (has) {
				_runningInfo = null;
				if (_queueHead != null) {
					_runningInfo = _queueHead;
					_queueHead = _queueHead.next;
					if (_queueHead == null) {
						_queueTail = null;
					} else {
						_queueHead.prev = null;
						_runningInfo.next = null;
					}
					
					_runningInfo.run();
				}
			}
		}
		/**
		 * @param completeHandler handler(dest:Object):void
		 */
		public function start(data:IPBData, completeHandler:Function=null, async:Boolean=true):uint {
			if (async) {
				var info:PBExecuteDataInfo;
				if (_infoCacheNum == 0) {
					info = new PBExecuteDataInfo();
				} else {
					info = _infoCache[--_infoCacheNum];
				}
				
				info.id = ++_idAccumulator;
				info.completeHandler = completeHandler;
				info.executor = this;
				info.data = data;
				
				_map[info.id] = info;
				
				if (_runningInfo == null) {
					_runningInfo = info;
					
					_runningInfo.run();
				} else {
					if (_queueHead == null) {
						_queueHead = info;
						_queueTail = info;
					} else {
						info.prev = _queueTail;
						_queueTail.next = info;
						_queueTail = info;
					}
				}
				
				return info.id;
			} else {
				if (_runningInfo != null) {
					_timer.stop();
					
					_runningInfo.clearShaderJob(true);
					
					new ShaderJob(_data.shader, _data.target, _data.targetWidth, _data.targetHeight).start(true);
				}
				
				new ShaderJob(data.shader, data.target, data.targetWidth, data.targetHeight).start(true);
				
				var target:* = data.target;
				var offsetTargetLength:uint = data.offsetTargetLength;
				
				include 'PBExecutor_complate.define';
				
				if (_runningInfo != null) _runningInfo.run();
				
				return 0;
			}
		}
		asgl_protected function _clearJob(job:ShaderJob):void {
			_timer.stop();
			
			job.removeEventListener(ShaderEvent.COMPLETE, _completeHandler);
			job.shader = null;
			job.target = null;
		}
		asgl_protected function _runJob(info:PBExecuteDataInfo):void {
			var data:IPBData = info.data;
			var job:ShaderJob = new ShaderJob(data.shader, data.target, data.targetWidth, data.targetHeight);
			job.addEventListener(ShaderEvent.COMPLETE, _completeHandler, false, 0, true);
			info.shaderJob = job;
			
			_progress = 0;
			_timer.start();
			
			job.start(false);
		}
		private function _completeHandler(e:Event):void {
			_timer.stop();
			
			delete _map[_runningInfo.id];
			
			var data:IPBData = _runningInfo.data;
			var target:* = data.target;
			var offsetTargetLength:uint = data.offsetTargetLength;
			var completeHandler:Function = _runningInfo.completeHandler;
			
			_runningInfo.clear(false);
			_infoCache[_infoCacheNum++] = _runningInfo;
			_runningInfo = null;
			
			include 'PBExecutor_complate.define';
			
			if (_runningInfo == null && _queueHead != null) {
				_runningInfo = _queueHead;
				_queueHead = _queueHead.next;
				if (_queueHead == null) {
					_queueTail = null;
				} else {
					_queueHead.prev = null;
					_runningInfo.next = null;
				}
				
				_runningInfo.run();
			}
		}
		
		private static function _timerCompleteHandler(e:Event):void {
			if (_runningInfo.shaderJob.progress == 0) {
				if (_progress == 0) {
					_progress = 1;
				} else {
					_runningInfo.clearShaderJob(true);
					_runningInfo.run();
				}
			}
		}
	}
}