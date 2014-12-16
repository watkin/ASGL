package asgl.system {
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import asgl.asgl_protected;
	import asgl.events.ASGLEvent;
	
	use namespace asgl_protected;

	public class SubVertexBufferData extends VertexBufferData {
		asgl_protected var _root:VertexBufferData;
		
		public function SubVertexBufferData(device:Device3D, numVertices:int, data32PerVertex:int, bufferOffset:int, root:VertexBufferData) {
			super(device, numVertices, data32PerVertex);
			
			this.bufferOffset = bufferOffset;
			_root = root;
			
			_rootInstancID = _root._instanceID;
			_buffer = _root._buffer;
			
			_root.addEventListener(ASGLEvent.DISPOSE, _disposeHandler, false, 0, true);
		}
		protected override function _constructor():void {
		}
		public override function active(index:uint, bufferOffset:int=0, format:String=null):Boolean {
			if (format == null) format = this.format;
			return _device._vertexBufferManager.setVertexBufferFromData(_root, index, this.bufferOffset + bufferOffset, format);
		}
		public override function createSub(bufferOffset:int, data32PerVertex:int):SubVertexBufferData {
			return new SubVertexBufferData(_device, _numVertices, data32PerVertex, this.bufferOffset + bufferOffset, _root);
		}
		public override function dispose():void {
			if (_device != null) {
				removeEventListener(ASGLEvent.DISPOSE, _disposeHandler);
				
				_root = null;
				_device = null;
				_buffer = null;
				
				if (hasEventListener(ASGLEvent.DISPOSE)) dispatchEvent(new ASGLEvent(ASGLEvent.DISPOSE));
			}
		}
		public override function uploadFromByteArray(data:ByteArray, byteArrayOffset:int=0, startVertex:int=0, numVertices:int=-1):void {
			_root.uploadFromByteArray(data, byteArrayOffset, startVertex, numVertices);
		}
		public override function uploadFromVector(data:Vector.<Number>, startVertex:int=0, numVertices:int=-1):void {
			_root.uploadFromVector(data, startVertex, numVertices);
		}
		private function _disposeHandler(e:Event):void {
			dispose();
		}
	}
}