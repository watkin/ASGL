package asgl.system {
	import flash.display3D.Context3D;
	import flash.display3D.VertexBuffer3D;
	import flash.utils.ByteArray;
	
	import asgl.asgl_protected;
	import asgl.events.ASGLEvent;
	
	use namespace asgl_protected;

	public class VertexBufferData extends DeviceData {
		public var format:String;
		public var bufferOffset:int;
		
		asgl_protected var _buffer:VertexBuffer3D;
		asgl_protected var _data32PerVertex:int;
		asgl_protected var _numVertices:int;
		
		private var _referenceData:*;
		private var _referenceBytesOffset:int;
		private var _referenceStartVertex:int;
		private var _referenceNumVertices:int;
		
		public function VertexBufferData(device:Device3D, numVertices:int, data32PerVertex:int) {
			super(device);
			
			_numVertices = numVertices;
			_data32PerVertex = data32PerVertex;
			
			_constructor();
		}
		protected function _constructor():void {
			_device._debugger._usedVertexBufferSize += _data32PerVertex * _numVertices * 4;
			
			var context:Context3D = _device._context3D;
			if (context != null) {
				if (context.driverInfo == Device3D.DISPOSED) {
					_device._lost();
				} else {
					_buffer = _device._context3D.createVertexBuffer(_numVertices, _data32PerVertex);
				}
			}
		}
		public function get buffer():VertexBuffer3D {
			return _buffer;
		}
		public function get data32PerVertex():int {
			return _data32PerVertex;
		}
		public function get numVertices():int {
			return _numVertices;
		}
		public function active(index:uint, bufferOffset:int=0, format:String=null):Boolean {
			if (format == null) format = this.format;
			return _device._vertexBufferManager.setVertexBufferFromData(this, index, bufferOffset, format);
		}
		public function createSub(bufferOffset:int, data32PerVertex:int):SubVertexBufferData {
			return new SubVertexBufferData(_device, _numVertices, data32PerVertex, bufferOffset, this);
		}
		public override function dispose():void {
			if (_device != null) {
				if (_buffer != null) {
					_buffer.dispose();
					_buffer = null;
				}
				
				_device._debugger._usedVertexBufferSize -= _data32PerVertex * _numVertices * 4;
				
				_device._vertexBufferManager._disposeVertexBufferData(this);
				_device = null;
				
				_referenceData = null;
				
				_valid = false;
				
				if (hasEventListener(ASGLEvent.DISPOSE)) dispatchEvent(new ASGLEvent(ASGLEvent.DISPOSE));
			}
		}
		public function uploadFromByteArray(data:ByteArray, byteArrayOffset:int=0, startVertex:int=0, numVertices:int=-1):void {
			if (_device._cacheVertexBuffers) {
				_referenceData = data;
				_referenceBytesOffset = byteArrayOffset;
				_referenceStartVertex = startVertex;
				_referenceNumVertices = numVertices;
			} else {
				_referenceData = null;
			}
			
			if (numVertices < 0) numVertices = _numVertices;
			
			if (_buffer != null) {
				if (_device._context3D.driverInfo == Device3D.DISPOSED) {
					_device._lost();
				} else {
					_buffer.uploadFromByteArray(data, byteArrayOffset, startVertex, numVertices);
					_valid = true;
				}
			}
		}
		public function uploadFromVector(data:Vector.<Number>, startVertex:int=0, numVertices:int=-1):void {
			if (_device._cacheVertexBuffers) {
				_referenceData = data;
				_referenceStartVertex = startVertex;
				_referenceNumVertices = numVertices;
			} else {
				_referenceData = null;
			}
			
			if (numVertices < 0) numVertices = _numVertices;
			
			if (_buffer != null) {
				if (_device._context3D.driverInfo == Device3D.DISPOSED) {
					_device._lost();
				} else {
					_buffer.uploadFromVector(data, startVertex, numVertices);
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
				_buffer = _device._context3D.createVertexBuffer(_numVertices, _data32PerVertex);
				
				if (_referenceData != null) {
					if (_referenceData is ByteArray) {
						uploadFromByteArray(_referenceData, _referenceBytesOffset, _referenceStartVertex, _referenceNumVertices);
					} else {
						uploadFromVector(_referenceData, _referenceStartVertex, _referenceNumVertices);
					}
				}
			}
		}
	}
}