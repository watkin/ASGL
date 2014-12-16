package asgl.geometries {
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import asgl.asgl_protected;
	import asgl.events.ASGLEvent;
	import asgl.system.Device3D;
	import asgl.system.IndexBufferData;
	import asgl.system.VertexBufferData;
	
	use namespace asgl_protected;
	
	[Event(name="dispose", type="asgl.events.ASGLEvent")]

	public class MeshBuffer extends EventDispatcher {
		asgl_protected var _indexBuffer:IndexBufferData;
		
		asgl_protected var _vertexBuffers:Object;
		asgl_protected var _numVertexBuffers:uint;
		
		asgl_protected var _device:Device3D;
		
		asgl_protected var _security:Boolean;
		
		public function MeshBuffer(device:Device3D, security:Boolean) {
			_device = device;
			_security = security;
			
			_vertexBuffers = {};
		}
		public function get indexBuffer():IndexBufferData {
			return _indexBuffer;
		}
		public function set indexBuffer(value:IndexBufferData):void {
			if (_security) {
				if (_indexBuffer != null) _indexBuffer.removeEventListener(ASGLEvent.DISPOSE, _disposeIndexBufferHandler);
				_indexBuffer = value;
				if (_indexBuffer != null) _indexBuffer.addEventListener(ASGLEvent.DISPOSE, _disposeIndexBufferHandler, false, 0, true);
			} else {
				_indexBuffer = value;
			}
		}
		public function clear():void {
			if (_vertexBuffers != null) {
				if (_security) {
					for each (var vb:VertexBufferData in _vertexBuffers) {
						vb.removeEventListener(ASGLEvent.DISPOSE, _disposeVertexBufferHandler);
					}
					
					if (_indexBuffer != null) _indexBuffer.removeEventListener(ASGLEvent.DISPOSE, _disposeIndexBufferHandler);
				}
				
				_indexBuffer = null;
				_vertexBuffers = {};
				_numVertexBuffers = 0;
			}
		}
		public function dispose():void {
			if (_device != null) {
				var vb:VertexBufferData;
				
				if (_security) {
					for each (vb in _vertexBuffers) {
						vb.removeEventListener(ASGLEvent.DISPOSE, _disposeVertexBufferHandler);
						vb.dispose();
					}
					
					if (_indexBuffer != null) {
						_indexBuffer.removeEventListener(ASGLEvent.DISPOSE, _disposeIndexBufferHandler);
						_indexBuffer.dispose();
					}
				} else {
					for each (vb in _vertexBuffers) {
						vb.dispose();
					}
					
					if (_indexBuffer != null) _indexBuffer.dispose();
				}
				
				_vertexBuffers = null;
				_indexBuffer = null;
				_device = null;
				
				if (hasEventListener(ASGLEvent.DISPOSE)) dispatchEvent(new ASGLEvent(ASGLEvent.DISPOSE));
			}
		}
		public function getVertexBuffer(name:String):VertexBufferData {
			return _vertexBuffers[name];
		}
		public function setVertexBuffer(name:String, buffer:VertexBufferData):void {
			var old:VertexBufferData = _vertexBuffers[name];
			
			if (_security) {
				if (old != null) old.removeEventListener(ASGLEvent.DISPOSE, _disposeVertexBufferHandler);
				
				if (buffer == null) {
					if (old != null) {
						delete _vertexBuffers[name];
						
						_numVertexBuffers--;
					}
				} else {
					_vertexBuffers[name] = buffer;
					
					if (old == null) _numVertexBuffers++;
					
					buffer.addEventListener(ASGLEvent.DISPOSE, _disposeVertexBufferHandler, false, 0, true);
				}
			} else {
				if (buffer == null) {
					if (old != null) {
						delete _vertexBuffers[name];
						
						_numVertexBuffers--;
					}
				} else {
					_vertexBuffers[name] = buffer;
					
					if (old == null) _numVertexBuffers++;
				}
			}
		}
		public function setVertexBufferFormVector(name:String, values:Vector.<Number>, data32PerVertex:int, format:String):void {
			var num:uint = values.length / data32PerVertex;
			
			var vb:VertexBufferData = _vertexBuffers[name];
			
			if (vb == null || vb._numVertices != num) {
				if (_security) {
					if (vb != null) {
						vb.removeEventListener(ASGLEvent.DISPOSE, _disposeVertexBufferHandler);
						vb.dispose();
					}
					
					vb = _device._vertexBufferManager.createVertexBufferData(num, data32PerVertex);
					vb.format = format;
					_vertexBuffers[name] = vb;
					vb.addEventListener(ASGLEvent.DISPOSE, _disposeVertexBufferHandler, false, 0, true);
				} else {
					if (vb != null) vb.dispose();
					
					vb = _device._vertexBufferManager.createVertexBufferData(num, data32PerVertex);
					vb.format = format;
					_vertexBuffers[name] = vb;
				}
			} else if (vb.format != format) {
				vb.format = format;
			}
			
			vb.uploadFromVector(values);
		}
		public function setBuffersFormAsset(asset:MeshAsset, setIndices:Boolean=true):void {
			var element:MeshElement;
			
			for (var type:* in asset.elements) {
				var name:String = MeshElementType.SHADER_PROPERTY_MAPPING[type];
				if (name != null) {
					element = asset.elements[type];
					var format:String = null;
					switch (element.numDataPreElement) {
						case 3:
							format = Context3DVertexBufferFormat.FLOAT_3;
							break;
						case 2:
							format = Context3DVertexBufferFormat.FLOAT_2;
							break;
						case 1:
							format = Context3DVertexBufferFormat.FLOAT_1;
							break;
						case 4:
							format = Context3DVertexBufferFormat.FLOAT_4;
							break;
					}
					
					if (format != null) setVertexBufferFormVector(name, element.values, element.numDataPreElement, format);
				}
			}
			
			if (setIndices && asset.triangleIndices != null) {
				var num:uint = asset.triangleIndices.length;
				
				if (_indexBuffer == null || _indexBuffer._numIndices != num) {
					if (_security) {
						if (_indexBuffer != null) {
							_indexBuffer.removeEventListener(ASGLEvent.DISPOSE, _disposeIndexBufferHandler);
							_indexBuffer.dispose();
						}
						
						_indexBuffer = _device._indexBufferManager.createIndexBufferData(num);
						_indexBuffer.addEventListener(ASGLEvent.DISPOSE, _disposeIndexBufferHandler, false, 0, true);
					} else {
						if (_indexBuffer != null) _indexBuffer.dispose();
						
						_indexBuffer = _device._indexBufferManager.createIndexBufferData(num);
					}
				}
				
				_indexBuffer.uploadFromVector(asset.triangleIndices);
			}
		}
		private function _disposeVertexBufferHandler(e:Event):void {
			var buffer:* = e.currentTarget;
			
			for (var name:String in _vertexBuffers) {
				if (_vertexBuffers[name] == buffer) {
					setVertexBuffer(name, null);
					break;
				}
			}
		}
		private function _disposeIndexBufferHandler(e:Event):void {
			_indexBuffer.removeEventListener(ASGLEvent.DISPOSE, _disposeIndexBufferHandler);
			_indexBuffer = null;
		}
	}
}