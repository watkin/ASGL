package asgl.system {
	import asgl.asgl_protected;
	
	use namespace asgl_protected;
	
	public class ProgramManager {
		private var _device:Device3D;
		private var _programMap:Object;
		
		private var _currentProgramID:*;
		private var _currentProgramInstanceID:uint;
		public function ProgramManager(device:Device3D) {
			_device = device;
			
			_programMap = {};
		}
		public function createProgramData():ProgramData {
			var data:ProgramData = new ProgramData(_device);
			_programMap[data._instanceID] = data;
			
			return data;
		}
		public function setProgramFromData(data:ProgramData):Boolean {
			if (data == null) {
				if (_device._context3D != null) {
					_device._context3D.setProgram(null);
					_currentProgramInstanceID = 0;
					
					_device._debugger._changeProgramStateCount++;
				}
				
				_currentProgramID = null;
				
				return true;
			} else if (data._valid) {
				var id:* = data.id;
				if (_currentProgramID != id || id == null) {
					_currentProgramID = id;
					
					if (_device._context3D != null) {
						_device._context3D.setProgram(data._program);
						_currentProgramInstanceID = data._instanceID;
						
						_device._debugger._changeProgramStateCount++;
					}
				}
				
				return true;
			} else {
				return false;
			}
		}
		public function disposePrograms():void {
			var num:int = 0;
			var arr:Vector.<uint> = new Vector.<uint>();
			for (var id:uint in _programMap) {
				arr[num++] = id;
			}
			
			for (var i:int = 0; i < num; i++) {
				var data:ProgramData = _programMap[arr[i]];
				data.dispose();
			}
		}
		asgl_protected function _clearCache():void {
			for each (var data:DeviceData in _programMap) {
				data._clearCache();
			}
		}
		asgl_protected function _disposeProgramDara(data:ProgramData):void {
			delete _programMap[data._instanceID];
		}
		asgl_protected function _lost():void {
			for each (var data:DeviceData in _programMap) {
				data._lost();
			}
		}
		asgl_protected function _recovery():void {
			for each (var data:DeviceData in _programMap) {
				data._recovery();
			}
			
			if (_currentProgramInstanceID != 0) {
				var pd:ProgramData = _programMap[_currentProgramInstanceID];
				
				if (pd != null && pd._valid) {
					_device._context3D.setProgram(pd._program);
				}
			}
		}
	}
}