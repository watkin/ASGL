package asgl.system {
	import asgl.asgl_protected;
	
	use namespace asgl_protected;
	
	public class IndexBufferManager {
		public static const VERTEX_BUFFER_MAX:int = 8;
		
		private var _device:Device3D;
		private var _indexBufferMap:Object;
		public function IndexBufferManager(device:Device3D) {
			_device = device;
			
			_indexBufferMap = {};
		}
		public function createIndexBufferData(numIndices:int):IndexBufferData {
			var data:IndexBufferData = new IndexBufferData(_device, numIndices);
			_indexBufferMap[data._instanceID] = data;
			
			return data;
		}
		public function disposeIndexBuffers():void {
			var num:int = 0;
			var arr:Vector.<uint> = new Vector.<uint>();
			for (var id:int in _indexBufferMap) {
				arr[num++] = id;
			}
			
			for (var i:int = 0; i < num; i++) {
				var data:IndexBufferData = _indexBufferMap[arr[i]];
				data.dispose();
			}
		}
		asgl_protected function _clearCache():void {
			for each (var data:DeviceData in _indexBufferMap) {
				data._clearCache();
			}
		}
		asgl_protected function _disposeIndexBufferData(data:IndexBufferData):void {
			delete _indexBufferMap[data._instanceID];
		}
		asgl_protected function _lost():void {
			for each (var data:DeviceData in _indexBufferMap) {
				data._lost();
			}
		}
		asgl_protected function _recovery():void {
			for each (var data:DeviceData in _indexBufferMap) {
				data._recovery();
			}
		}
	}
}