package asgl.shaders.asm.agal {
	public class AGALHelper {
		public function AGALHelper() {
		}
		public static function getMatrixValueFromConstants(constantsType:String, row:uint, column:uint, columns:uint, matrixDataFirstIndex:uint, xyzw:Vector.<String>):String {
			var index:uint = row*columns+column;
			var offset:uint = index/4;
			index %= 4;
			return constantsType+(matrixDataFirstIndex+offset)+'.'+xyzw[index];
		}
		/**
		 * va1 -> va1</br>
		 * va1.x -> va1
		 */
		public static function getRegister(reg:String):String {
			return reg.split('.')[0];
		}
		/**
		 * va1 -> 1</br>
		 * va1.x -> 1
		 */
		public static function getRegisterIndex(reg:String):int {
			var arr:Array = reg.split('.');
			var str:String = arr[0];
			var length:int = str.length;
			for (var i:int = 0; i<length; i++) {
				var code:int = str.charCodeAt(i);
				if (code>=48 && code<=57) {
					return int(str.substr(i));
				}
			}
			
			return -1;
		}
		/**
		 * va1 -> va</br>
		 * va1.x -> va
		 */
		public static function getRegisterType(reg:String):String {
			var arr:Array = reg.split('.');
			var str:String = arr[0];
			var length:int = str.length;
			for (var i:int = 0; i<length; i++) {
				var code:int = str.charCodeAt(i);
				if (code>=48 && code<=57) {
					return str.substr(0, i);
				}
			}
			
			return str;
		}
		/**
		 * va1 -> xyzw</br>
		 * va1.x -> x
		 */
		public static function getScalars(reg:String):String {
			var arr:Array = reg.split('.');
			var length:uint = arr.length;
			if (length == 1) {
				return 'xyzw';
			} if (length == 2) {
				return arr[1];
			} else {
				return null;
			}
		}
		public static function isConstant(src:String):Boolean {
			var type:String = getRegisterType(src);
			return type == RegisterType.VERTEX_CONSTANT || type == RegisterType.FRAGMENT_CONSTANT;
		}
		/**
		 * va1.x, va1.y -> va1.xy
		 * va1.x, va2.x -> null
		 */
		public static function mergeVector(vec1:String, vec2:String):String {
			var reg1:Array = vec1.split('.');
			var reg2:Array = vec2.split('.');
			
			var reg:String = reg1[0];
			
			if (reg == reg2[0]) {
				if (reg1.length>1 && reg2.length>1) {
					var scalars:String = reg1[1]+reg2[1];
					if (scalars.length>4) {
						return null;
					} else {
						return  reg+'.'+scalars;
					}
				} else {
					return null;
				}
			} else {
				return null;
			}
		}
		/**
		 * slit vector to scalars
		 */
		public static function splitVector(src:String, containRegisterType:Boolean=true):Vector.<String> {
			var scalars:Vector.<String> = new Vector.<String>();
			
			var arr:Array = src.split('.');
			var reg:String = containRegisterType ? arr[0]+'.' : '';
			
			if (arr.length == 1) {
				scalars[0] = reg+'.x';
				scalars[1] = reg+'.y';
				scalars[2] = reg+'.z';
				scalars[3] = reg+'.w';
			} else {
				var index:uint = 0;
				var coms:String = arr[1];
				var length:int = coms.length;
				for (var i:int = 0; i<length; i++) {
					scalars[index++] = reg+coms.substr(i, 1);
				}
			}
			
			return scalars;
		}
	}
}