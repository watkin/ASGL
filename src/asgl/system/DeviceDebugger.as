package asgl.system {
	import asgl.asgl_protected;
	
	use namespace asgl_protected;

	public class DeviceDebugger {
		public static const BYTE:uint = 0;
		public static const KB:uint = 1;
		public static const MB:uint = 2;
		
		private static const TO_KB:Number = 1 / 1024;
		private static const TO_MB:Number = TO_KB / 1024;
		
		asgl_protected var _changeConstantStateCount:uint;
		asgl_protected var _changeOtherStateCount:uint;
		asgl_protected var _changeProgramStateCount:uint;
		asgl_protected var _changeTextureStateCount:uint;
		asgl_protected var _changeVertexStateCount:uint;
		
		asgl_protected var _drawCalls:uint;
		asgl_protected var _drawTriangles:uint;
		
		asgl_protected var _usedCubeTextureSize:uint;
		asgl_protected var _usedIndexBufferSize:uint;
		asgl_protected var _usedProgramSize:uint;
		asgl_protected var _usedTextureSize:uint;
		asgl_protected var _usedVertexBufferSize:uint;
		
		public function DeviceDebugger() {
		}
		public function get changeStateCount():uint {
			return _changeConstantStateCount + _changeOtherStateCount + _changeProgramStateCount + _changeTextureStateCount + _changeVertexStateCount;
		}
		public function get drawCalls():uint {
			return _drawCalls;
		}
		public function get drawTriangles():uint {
			return _drawTriangles;
		}
		public function clear(changeStateCount:Boolean=true, drawState:Boolean=true):void {
			if (changeStateCount) {
				_changeConstantStateCount = 0;
				_changeOtherStateCount = 0;
				_changeProgramStateCount = 0;
				_changeTextureStateCount = 0;
				_changeVertexStateCount = 0;
			}
			
			if (drawState) {
				_drawCalls = 0;
				_drawTriangles = 0;
			}
		}
		public function getUsedCubeTextureSize(type:uint=BYTE):Number {
			if (type == KB) {
				return _usedCubeTextureSize * TO_KB;
			} else if (type == MB) {
				return _usedCubeTextureSize * TO_MB;
			} else {
				return _usedCubeTextureSize;
			}
		}
		public function getUsedIndexBufferSize(type:uint=BYTE):Number {
			if (type == KB) {
				return _usedIndexBufferSize * TO_KB;
			} else if (type == MB) {
				return _usedIndexBufferSize * TO_MB;
			} else {
				return _usedIndexBufferSize;
			}
		}
		public function getUsedProgramSize(type:uint=BYTE):Number {
			if (type == KB) {
				return _usedProgramSize * TO_KB;
			} else if (type == MB) {
				return _usedProgramSize * TO_MB;
			} else {
				return _usedProgramSize;
			}
		}
		public function getUsedTextureSize(type:uint=BYTE):Number {
			if (type == KB) {
				return _usedTextureSize * TO_KB;
			} else if (type == MB) {
				return _usedTextureSize * TO_MB;
			} else {
				return _usedTextureSize;
			}
		}
		public function getUsedVertexBufferSize(type:uint=BYTE):Number {
			if (type == KB) {
				return _usedVertexBufferSize * TO_KB;
			} else if (type == MB) {
				return _usedVertexBufferSize * TO_MB;
			} else {
				return _usedVertexBufferSize;
			}
		}
		public function toString():String {
			return 'device debugger: \n' +
				'drawCalls [' + _drawCalls + '] \n' +
				'drawTriangles [' + _drawTriangles + '] \n' +
				'state [vertex:' + _changeVertexStateCount + ' texture:' + _changeTextureStateCount + ' constant:' + _changeConstantStateCount + ' program:' + _changeProgramStateCount + ' other:' + _changeOtherStateCount + '] \n'+
				'vertexBuffer [' + getUsedVertexBufferSize(MB).toFixed(3) + 'MB] \n'+
				'indexBuffer [' + getUsedIndexBufferSize(MB).toFixed(3) + 'MB] \n'+
				'texture [' + getUsedTextureSize(MB).toFixed(3) + 'MB] \n'+
				'cubeTexture [' + getUsedCubeTextureSize(MB).toFixed(3) + 'MB] \n'+
				'program [' + getUsedProgramSize(MB).toFixed(3) + 'MB]';
		}
	}
}