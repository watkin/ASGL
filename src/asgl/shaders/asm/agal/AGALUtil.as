package asgl.shaders.asm.agal {

	public class AGALUtil {
		public function AGALUtil() {
		}
		/**
		 * if src < threshold, kill.
		 * 
		 * @param src = v.n
		 * @param threshold = v.n
		 * @param tmp = v or v.nn, will use two components.
		 */
		public static function killThreshold(src:String, threshold:String, tmp:String):String {
			var scalars:Vector.<String> = AGALHelper.splitVector(tmp);
			
			var s1:String = scalars[0];
			var s2:String = scalars[1];
			
			var code:String = '';
			
			code += AGALComparison.isLessEqual(s1, src, threshold, s2);
			code += AGALBase.negate(s1, s1);
			code += AGALBase.kill(s1);
			
			return code;
		}
	}
}