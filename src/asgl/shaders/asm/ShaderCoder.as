package asgl.shaders.asm {

	public class ShaderCoder implements IShaderCoder {
		private var _code:String;
		public function ShaderCoder() {
			_code = '';
		}
		public function get code():String {
			return _code;
		}
		public function appendCode(code:String):void {
			_code += code;
		}
		public function clear():void {
			_code = '';
		}
	}
}