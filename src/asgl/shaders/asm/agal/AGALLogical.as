package asgl.shaders.asm.agal {
	public class AGALLogical {
		public function AGALLogical() {
		}
		/**
		 * destination = source1 && source2 ? 1 : 0
		 * @param src1 = 0 or 1, the value can set dest
		 * @param src2 = 0 or 1, the value can set dest
		 * @param constant = v.n</br>
		 * constant = 2
		 */
		public static function and(dest:String, src1:String, src2:String, constant:String):String {
			var code:String = '';
			
			code += AGALBase.add(dest, src1, src2);
			code += AGALBase.isEqual(dest, dest, constant);
			
			return code;
		}
		/**
		 * destination = !source
		 * @param src = 0 or 1, the value can set dest
		 * @param constant = v.n</br>
		 * constant = 1
		 */
		public static function not(dest:String, src:String, constant:String):String {
			var code:String = '';
			
			code += AGALBase.sub(dest, constant, src);
			
			return code;
		}
		/**
		 * destination = source1 || source2 ? 1 : 0
		 * @param src1 = 0 or 1, the value can set dest
		 * @param src2 = 0 or 1, the value can set dest
		 * @param constant = v.n</br>
		 * constant = 0
		 */
		public static function or(dest:String, src1:String, src2:String, constant:String):String {
			var code:String = '';
			
			code += AGALBase.add(dest, src1, src2);
			code += AGALBase.isNotEqual(dest, dest, constant);
			
			return code;
		}
	}
}