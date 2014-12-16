package asgl.materials {
	import asgl.asgl_protected;
	import asgl.shaders.scripts.ShaderConstants;
	import asgl.shaders.scripts.ShaderConstantsCollection;
	
	use namespace asgl_protected;
	
	public class MaterialProperty {
		asgl_protected var _shaderID:uint;
		
		asgl_protected var _constants:Object;
		asgl_protected var _define:Object;
		asgl_protected var _defineChangeCount:uint;
		asgl_protected var _currentUpdateCount:uint;
		
		asgl_protected var _shaderCellMask:Number;
		asgl_protected var _shaderProgramID:uint;
		
		public function MaterialProperty() {
			_define = {};
			_constants = {};
			_shaderCellMask = -1;
		}
		public function clearAll():void {
			clearConstants();
			clearDefine();
		}
		public function clearConstants():void {
			for (var key:* in _constants) {
				_constants = {};
				break;
			}
		}
		public function clearDefine():void {
			for (var key:* in _define) {
				_defineChangeCount = 0;
				_define = {};
				break;
			}
		}
		public function setConstants(name:String, value:ShaderConstants):void {
			if (value == null) {
				delete _constants[name];
			} else {
				_constants[name] = value;
			}
		}
		public function setConstantsCollection(c:ShaderConstantsCollection, clearOld:Boolean=true):void {
			if (clearOld) clearConstants();
			
			var map:Object = c._constants;
			if (map != null) {
				for (var name:String in map) {
					setConstants(name, map[name]);
				}
			}
		}
		public function setDefine(name:String, value:*):void {
			if (value == null) {
				if (name in _define) {
					delete _define[name];
					
					_defineChangeCount = 0;
				}
			} else {
				if (value != _define[name]) {
					_define[name] = value;
					
					_defineChangeCount = 0;
				}
			}
		}
		asgl_protected function _setShaderID(id:uint):void {
			if (_shaderID != id) {
				_shaderID = id;
				_defineChangeCount = 0;
				_currentUpdateCount = 0;
				_shaderCellMask = -1;
				_shaderProgramID = 0;
			}
		}
	}
}