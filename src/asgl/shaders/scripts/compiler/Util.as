package asgl.shaders.scripts.compiler {
	public class Util {
		public function Util() {
		}
		public static function isNumber(name:String, component:String):Boolean {
			if (name == null) return false;
			if (component != null) name += '.' + component;
			if (name.charAt(0) == '-') name = name.substr(1);
			var number:String = name.replace(/[0-9]/g, '');
			return number == '' || number == '.';
		}
		public static function isString(name:String):Boolean {
			return name.charAt(0) == '"' && name.length > 1 && name.charAt(name.length - 1) == '"';
		}
		public static function formatSpace(str:String):String {
			var newStr:String = '';
			
			var isSpace:Boolean = false;
			var len:uint = str.length;
			for (var i:uint = 0; i < len; i++) {
				var s:String = str.charAt(i);
				if (s == '\n' || s == '\r') continue;
				if (s == ' ' || s == '	') {
					if (newStr != '') isSpace = true;
				} else {
					if (isSpace) {
						isSpace = false;
						newStr += ' '
					}
					newStr += s;
				}
			}
			
			return newStr;
		}
		public static function removeBothSidesSpace(str:String):String {
			var start:uint;
			var end:uint;
			
			var s:String;
			
			var len:uint = str.length;
			for (var i:int = 0; i < len; i++) {
				s = str.charAt(i);
				if (s != ' ' && s != '	') {
					start = i;
					break;
				}
			}
			
			for (i = len - 1; i >= 0; i--) {
				s = str.charAt(i);
				if (s != ' ' && s != '	') {
					end = i + 1;
					break;
				}
			}
			
			return str.substring(start, end);
		}
		//public static function sSsSsToSsS(str:String):String {
		//	return str.replace(/\s*(\S*)\s*(\S*)\s*/, _sSsSsToSsSRep);
		//}
		private static function _sSsSsToSsSRep():String {
			var arg1:String = arguments[1];
			var arg2:String = arguments[2];
			if (arg2 == '') {
				return arg1;
			} else {
				return arg1 + ' ' + arg2;
			}
		}
	}
}