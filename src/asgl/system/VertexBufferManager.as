package asgl.system {
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.VertexBuffer3D;
	
	import asgl.asgl_protected;
	
	use namespace asgl_protected;
	
	public class VertexBufferManager {
		public static const VERTEX_BUFFER_MAX:int = 8;
		
		private var _device:Device3D;
		private var _bufferMap:Object;
		private var _statusMap:Vector.<BufferInfo>;
		private var _occupiedStatus:Vector.<BufferInfo>;
		private var _numOccupied:int;
		
		public function VertexBufferManager(device:Device3D) {
			_device = device;
			
			_bufferMap = {};
			_statusMap = new Vector.<BufferInfo>(VERTEX_BUFFER_MAX);
			for (var i:int = 0; i < VERTEX_BUFFER_MAX; i++) {
				_statusMap[i] = new BufferInfo(i);
			}
			
			_occupiedStatus = new Vector.<BufferInfo>(VERTEX_BUFFER_MAX);
			_numOccupied = 0;
		}
		public function createVertexBufferData(numVertices:int, data32PerVertex:int):VertexBufferData {
			var data:VertexBufferData = new VertexBufferData(_device, numVertices, data32PerVertex);
			_bufferMap[data._instanceID] = data;
			
			return data;
		}
		public function deactiveVertexBuffers():void {
			if (_numOccupied > 0) {
				var i:int;
				var info:BufferInfo;
				
				if (_device._context3D == null) {
					for (i = 0; i < _numOccupied; i++) {
						info = _occupiedStatus[i];
						info.occupiedIndex = -1;
					}
				} else {
					for (i = 0; i < _numOccupied; i++) {
						info = _occupiedStatus[i];
						_device._context3D.setVertexBufferAt(info.index, null);
						info.occupiedIndex = -1;
						
						_device._debugger._changeVertexStateCount++;
					}
				}
				
				_numOccupied = 0;
			}
		}
		public function deactiveOccupiedVertexBuffers():void {
			if (_numOccupied > 0) {
				var i:int;
				var info:BufferInfo;
				var trail:BufferInfo;
				
				if (_device._context3D == null) {
					for (i = _numOccupied - 1; i >= 0; i--) {
						info = _occupiedStatus[i];
						if (info.occupiedValue == 0) {
							_numOccupied--;
							
							if (info.occupiedIndex != _numOccupied) {
								trail = _occupiedStatus[_numOccupied];
								_occupiedStatus[info.occupiedIndex] = trail;
								trail.occupiedIndex = info.occupiedIndex;
							}
							
							info.occupiedIndex = -1;
						}
					}
				} else {
					for (i = _numOccupied - 1; i >= 0; i--) {
						info = _occupiedStatus[i];
						if (info.occupiedValue == 0) {
							_device._context3D.setVertexBufferAt(info.index, null);
							
							_device._debugger._changeVertexStateCount++;
							
							_numOccupied--;
							
							if (info.occupiedIndex != _numOccupied) {
								trail = _occupiedStatus[_numOccupied];
								_occupiedStatus[info.occupiedIndex] = trail;
								trail.occupiedIndex = info.occupiedIndex;
							}
							
							info.occupiedIndex = -1;
						}
					}
				}
			}
		}
		public function disposeVertexBuffers():void {
			var num:int = 0;
			var arr:Vector.<uint> = new Vector.<uint>();
			for (var id:int in _bufferMap) {
				arr[num++] = id;
			}
			
			for (var i:int = 0; i < num; i++) {
				var data:VertexBufferData = _bufferMap[arr[i]];
				data.dispose();
			}
		}
		public function resetOccupiedState():void {
			for (var i:int = 0; i < _numOccupied; i++) {
				var info:BufferInfo = _occupiedStatus[i];
				info.occupiedValue = 0;
			}
		}
		public function setVertexBufferAt(index:int, buffer:VertexBuffer3D, bufferOffset:int=0, format:String=Context3DVertexBufferFormat.FLOAT_4):Boolean {
			if (index >= VERTEX_BUFFER_MAX) return false;
			
			if (buffer == null) {
				if (_device._context3D != null) {
					_device._context3D.setVertexBufferAt(index, null);
					
					_device._debugger._changeVertexStateCount++;
				}
			} else {
				if (_device._context3D != null) {
					_device._context3D.setVertexBufferAt(index, buffer, bufferOffset, format);
					
					_device._debugger._changeVertexStateCount++;
				}
			}
			
			return true;
		}
		public function setVertexBufferFromData(data:VertexBufferData, index:int, bufferOffset:int=0, format:String=Context3DVertexBufferFormat.FLOAT_4):Boolean {
			if (index >= VERTEX_BUFFER_MAX) return false;
			
			var info:BufferInfo = _statusMap[index];
			
			if (data == null) {
				if (info.occupiedIndex != -1) {
					if (_device._context3D != null) {
						_device._context3D.setVertexBufferAt(index, null);
						
						_device._debugger._changeVertexStateCount++;
					}
					
					_numOccupied--;
					
					if (info.occupiedIndex != _numOccupied) {
						var trail:BufferInfo = _occupiedStatus[_numOccupied];
						_occupiedStatus[info.occupiedIndex] = trail;
						trail.occupiedIndex = info.occupiedIndex;
					}
					
					info.occupiedIndex = -1;
				}
				
				return true;
			} else if (data._valid) {
				if (info.occupiedIndex == -1 || info.instanceID != data._instanceID) {
					if (_device._context3D != null) {
						_device._context3D.setVertexBufferAt(index, data._buffer, bufferOffset, format);
						
						_device._debugger._changeVertexStateCount++;
					}
					
					info.instanceID = data._instanceID;
					
					if (info.occupiedIndex == -1) {
						info.occupiedIndex = _numOccupied;
						_occupiedStatus[_numOccupied++] = info;
					}
				}
				
				info.occupiedValue = 1;
				
				return true;
			} else {
				return false;
			}
		}
		asgl_protected function _clearCache():void {
			for each (var data:DeviceData in _bufferMap) {
				data._clearCache();
			}
		}
		asgl_protected function _disposeVertexBufferData(data:VertexBufferData):void {
			delete _bufferMap[data._instanceID];
		}
		asgl_protected function _lost():void {
			for each (var data:DeviceData in _bufferMap) {
				data._lost();
			}
		}
		asgl_protected function _recovery():void {
			for each (var data:DeviceData in _bufferMap) {
				data._recovery();
			}
			
			for (var i:int = 0; i < _numOccupied; i++) {
				var info:BufferInfo = _occupiedStatus[i];
				var vd:VertexBufferData = _bufferMap[info.instanceID];
				if (vd != null) setVertexBufferFromData(vd, info.index, info.offset, info.format);
			}
		}
	}
}

class BufferInfo {
	public var instanceID:uint;
	public var offset:int;
	public var format:String;
	public var index:int;
	public var occupiedIndex:int;
	public var occupiedValue:int;
	
	public function BufferInfo(index:int) {
		this.index = index;
		occupiedIndex = -1;
	}
}