package asgl.system {
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import asgl.asgl_protected;
	import asgl.events.ASGLEvent;
	
	use namespace asgl_protected;

	public class SubIndexBufferData extends IndexBufferData {
		public function SubIndexBufferData(device:Device3D, numIndices:int, firstIndex:int, root:IndexBufferData) {
			super(device, numIndices);
			
			_firstIndex = firstIndex;
			
			_root = root;
			_rootInstancID = _root._instanceID;
			_buffer = _root._buffer;
			
			_root.addEventListener(ASGLEvent.DISPOSE, _disposeHandler, false, 0, true);
		}
		protected override function _constructor():void {
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
		public override function uploadFromVector(data:Vector.<uint>, startVertex:int=0, numVertices:int=-1):void {
			_root.uploadFromVector(data, startVertex, numVertices);
		}
		private function _disposeHandler(e:Event):void {
			dispose();
		}
	}
}