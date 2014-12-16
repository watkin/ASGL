package asgl.system {
	import flash.display3D.Context3D;
	import flash.display3D.Program3D;
	import flash.utils.ByteArray;
	
	import asgl.asgl_protected;
	import asgl.events.ASGLEvent;
	import asgl.shaders.scripts.Shader3DCell;
	
	use namespace asgl_protected;

	public class ProgramData extends DeviceData {
		
		public var id:*;
		
		asgl_protected var _program:Program3D;
		asgl_protected var _cell:Shader3DCell;
		
		private var _size:uint;
		
		private var _referenceVertexBytes:ByteArray;
		private var _referenceFragmentBytes:ByteArray;
		
		public function ProgramData(device:Device3D) {
			super(device);
			
			var context:Context3D = _device._context3D;
			if (context != null) {
				if (context.driverInfo == Device3D.DISPOSED) {
					_device._lost();
				} else {
					_program = context.createProgram();
				}
			}
		}
		public function get program():Program3D {
			return _program;
		}
		public function active():void {
			_device._programManager.setProgramFromData(this);
		}
		public override function dispose():void {
			if (_device != null) {
				if (_program != null) {
					_program.dispose();
					_program = null;
					
					_device._debugger._usedVertexBufferSize -= _size;
				}
				
				_device._programManager._disposeProgramDara(this);
				_device = null;
				
				_referenceVertexBytes = null;
				_referenceFragmentBytes = null;
				
				_cell = null;
				
				_valid = false;
				
				if (hasEventListener(ASGLEvent.DISPOSE)) dispatchEvent(new ASGLEvent(ASGLEvent.DISPOSE));
			}
		}
		public function uploadFromByteArray(vertexProgram:ByteArray, fragmentProgram:ByteArray):void {
			if (_device._cachePrograms) {
				_referenceVertexBytes = vertexProgram;
				_referenceFragmentBytes = fragmentProgram;
			} else {
				_referenceVertexBytes = null;
				_referenceFragmentBytes = null;
			}
			
			_device._debugger._usedProgramSize -= _size;
			_size = vertexProgram.length + fragmentProgram.length;
			_device._debugger._usedProgramSize += _size;
			
			if (_program != null) {
				if (_device._context3D.driverInfo == Device3D.DISPOSED) {
					_device._lost();
				} else {
					_program.upload(vertexProgram, fragmentProgram);
					_valid = true;
				}
			}
		}
		asgl_protected override function _clearCache():void {
			_program = null;
		}
		asgl_protected override function _lost():void {
			_program = null;
			_valid = false;
		}
		asgl_protected override function _recovery():void {
			if (_device._context3D.driverInfo == Device3D.DISPOSED) {
				_device._lost();
			} else {
				_program = _device._context3D.createProgram();
				
				if (_referenceVertexBytes != null) {
					this.uploadFromByteArray(_referenceVertexBytes, _referenceFragmentBytes);
				}
			}
		}
	}
}