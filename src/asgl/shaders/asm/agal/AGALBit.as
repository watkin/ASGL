package asgl.shaders.asm.agal {
	public class AGALBit {
		public function AGALBit() {
		}
		/**
		 * @param constant the value is 2
		 */
		public static function leftShift(dest:String, src:String, shiftValue:String, constant:String):String {
			var code:String = '';
			
			code += AGALBase.pow(dest, constant, shiftValue);
			code += AGALBase.mul(dest, src, dest);
			
			return code;
		}
		/**
		 * @param constant the value is 2
		 */
		public static function rightShift(dest:String, src:String, shiftValue:String, constant:String):String {
			var code:String = '';
			
			code += AGALBase.pow(dest, constant, shiftValue);
			code += AGALBase.div(dest, src, dest);
			code += AGALMath.floor(dest, dest);
			
			return code;
		}
	}
}