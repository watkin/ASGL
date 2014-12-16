package asgl.shaders.asm.agal {
	public class AGALComparison {
		public function AGALComparison() {
		}
		/**
		 * src1 < src2 ? x : y
		 * 
		 * @param dest
		 * @param src1 the value can set dest or tmp.
		 * @param src2 the value can set dest or tmp.
		 * @param x the value can set tmp.
		 * @param y
		 * @param constant = 1
		 * @param tmp
		 */
		public static function ifLessThan(dest:String, src1:String, src2:String, x:String, y:String, constant:String, tmp:String):String {
			var code:String = '';
			
			if (AGALHelper.isConstant(src1) && AGALHelper.isConstant(src2)) {
				code += AGALBase.move(dest, src1);
				code += AGALBase.isLessThan(dest, dest, src2);
			} else {
				code += AGALBase.isLessThan(dest, src1, src2);
			}
			
			code += AGALBase.mul(tmp, dest, x);
			code += AGALBase.sub(dest, constant, dest);
			code += AGALBase.mul(dest, dest, y);
			code += AGALBase.add(dest, dest, tmp);
			
			return code;
		}
		/**
		 * set-if-less-equal.</br>
		 * destination = source1 > source2 ? 1 : 0
		 */
		public static function isGreaterThan(dest:String, src1:String, src2:String, tmp:String):String {
			var code:String = '';
			
			code += AGALBase.isGreaterEqual(dest, src1, src2);
			code += AGALBase.isEqual(tmp, src1, src2);
			code += AGALBase.isNotEqual(dest, dest, tmp);
			
			return code;
		}
		/**
		 * set-if-less-equal.</br>
		 * destination = source1 <= source2 ? 1 : 0
		 */
		public static function isLessEqual(dest:String, src1:String, src2:String, tmp:String):String {
			var code:String = '';
			
			code += AGALBase.isEqual(dest, src1, src2);
			code += AGALBase.isLessThan(tmp, src1, src2);
			code += AGALBase.isNotEqual(dest, dest, tmp);
			
			return code;
		}
	}
}