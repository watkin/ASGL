package asgl.shaders.scripts {
	import asgl.asgl_protected;
	
	use namespace asgl_protected;
	
	public class ShaderConstantsCollection {
		asgl_protected var _constants:Object;
		
		public function ShaderConstantsCollection() {
			_constants = {};
		}
		public function clear():void {
			for (var key:* in _constants) {
				_constants = {};
				break;
			}
		}
		protected function _setConstants(name:String, value:ShaderConstants):void {
			if (value == null) {
				delete _constants[name];
			} else {
				_constants[name] = value;
			}
		}
	}
}