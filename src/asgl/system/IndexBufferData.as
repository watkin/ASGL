package asgl.system {
	import flash.display3D.Context3D;
	import flash.display3D.IndexBuffer3D;
	import flash.utils.ByteArray;
	
	import asgl.asgl_protected;
	import asgl.events.ASGLEvent;
	
	use namespace asgl_protected;

	public class IndexBufferData extends DeviceData {
		asgl_protected var _buffer:IndexBuffer3D;
		asgl_protected var _root:IndexBufferData;
		
		asgl_protected var _firstIndex:int;
		asgl_protected var _numIndices:int;
		asgl_protected var _numTriangles:int;
		
		private var _referenceData:*;
		private var _referenceBytesOffset:int;
		private var _referenceStartOffset:int;
		private var _referenceCount:int;
		
		public function IndexBufferData(device:Device3D, numIndices:int) {
			super(device);
			_numIndices = numIndices;
			_numTriangles = _numIndices / 3;
			
			_constructor();
		}
		protected function _constructor():void {
			_root = this;
			
			_device._debugger._usedIndexBufferSize += numIndices * 4;
			
			var context:Context3D = _device._context3D;
			if (context != null) {
				if (context.driverInfo == Device3D.DISPOSED) {
					_device._lost();
				} else {
					_buffer = context.createIndexBuffer(numIndices);
				}
			}
		}
		public function get buffer():IndexBuffer3D {
			return _buffer;
		}
		public function get numIndices():int {
			return _numIndices;
		}
		public function createSub(firstIndex:int, numIndices:int):SubIndexBufferData {
			if (firstIndex >= _numIndices) {
				firstIndex = _numIndices + _firstIndex - 1;
				numIndices = 0;
			} else {
				var len:int = _numIndices - firstIndex;
				if (numIndices < 0 || numIndices > len) numIndices = len;
				firstIndex += _firstIndex;
			}
			
			return new SubIndexBufferData(_device, numIndices, firstIndex, _root);
		}
		public override function dispose():void {
			if (_device != null) {
				if (_buffer != null) {
					_buffer.dispose();
					_buffer = null;
				}
				
				_device._debugger._usedIndexBufferSize -= numIndices * 4;
				
				_device._indexBufferManager._disposeIndexBufferData(this);
				_device = null;
				
				_referenceData = null;
				
				_valid = false;
				
				if (hasEventListener(ASGLEvent.DISPOSE)) dispatchEvent(new ASGLEvent(ASGLEvent.DISPOSE));
			}
		}
		public function draw(firstIndex:int=0, numTriangles:int=-1):int {
			return _device.drawTrianglesFromData(this, firstIndex, numTriangles);
		}
		public function uploadFromByteArray(data:ByteArray, byteArrayOffset:int=0, startOffset:int=0, count:int=-1):void {
			if (_device._cacheIndexBuffers) {
				_referenceData = data;
				_referenceBytesOffset = byteArrayOffset;
				_referenceStartOffset = startOffset;
				_referenceCount = count;
			} else {
				_referenceData = null;
			}
			
			if (count < 0 || count > _numIndices) count = _numIndices;
			
			if (_buffer != null) {
				if (_device._context3D.driverInfo == Device3D.DISPOSED) {
					_device._lost();
				} else {
					_buffer.uploadFromByteArray(data, byteArrayOffset, startOffset, count);
					_valid = true;
				}
			}
		}
		public function uploadFromVector(data:Vector.<uint>, startOffset:int=0, count:int=-1):void {
			if (_device._cacheIndexBuffers) {
				_referenceData = data;
				_referenceStartOffset = startOffset;
				_referenceCount = count;
			} else {
				_referenceData = null;
			}
			
			if (count < 0 || count > _numIndices) count = _numIndices;
			
			if (_buffer != null) {
				if (_device._context3D.driverInfo == Device3D.DISPOSED) {
					_device._lost();
				} else {
					_buffer.uploadFromVector(data, startOffset, count);
					_valid = true;
				}
			}
		}
		asgl_protected override function _clearCache():void {
			_referenceData = null;
		}
		asgl_protected override function _lost():void {
			_buffer = null;
			_valid = false;
		}
		asgl_protected override function _recovery():void {
			if (_device._context3D.driverInfo == Device3D.DISPOSED) {
				_device._lost();
			} else {
				_buffer = _device._context3D.createIndexBuffer(numIndices);
				
				if (_referenceData != null) {
					if (_referenceData is ByteArray) {
						uploadFromByteArray(_referenceData, _referenceBytesOffset, _referenceStartOffset, _referenceCount);
					} else {
						uploadFromVector(_referenceData, _referenceStartOffset, _referenceCount);
					}
				}
			}
		}
	}
}