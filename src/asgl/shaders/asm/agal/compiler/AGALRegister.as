package asgl.shaders.asm.agal.compiler {
	import asgl.asgl_protected;
	
	use namespace asgl_protected;

	public class AGALRegister {
		asgl_protected var _maxNum:uint;
		asgl_protected var _scope:uint;
		asgl_protected var _type:uint;
		
		public function AGALRegister(type:uint, maxNum:uint, scope:uint) {
			_type = type;
			_maxNum = maxNum;
			_scope = scope;
		}
		public function get maxNum():uint {
			return _maxNum;
		}
		public function get scope():uint {
			return _scope;
		}
		public function get type():uint {
			return _type;
		}
	}
}