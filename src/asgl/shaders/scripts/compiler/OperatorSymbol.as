package asgl.shaders.scripts.compiler {
	public class OperatorSymbol {
		public static const ADD:String = '+';
		public static const SUB:String = '-';
		public static const MUL:String = '*';
		public static const DIV:String = '/';
		public static const EQUAL:String = '=';
		public static const POINT:String = '.';
		public static const IS_EQUAL:String = '＝';
		public static const IS_NOT_EQUAL:String = '≠';
		public static const IS_LESS:String = '<';
		public static const IS_GREATER:String = '>';
		public static const IS_LESS_EQUAL:String = '≤';
		public static const IS_GREATER_EQUAL:String = '≥';
		public static const IS_AND:String = '＆';
		public static const IS_OR:String = '｜';
		public static const IS_NOT:String = '!';
		
		public function OperatorSymbol() {
		}
		public static function replaceSymbol(code:String):String {
			code = code.replace(/==/g, IS_EQUAL);
			code = code.replace(/!=/g, IS_NOT_EQUAL);
			code = code.replace(/<=/g, IS_LESS_EQUAL);
			code = code.replace(/>=/g, IS_GREATER_EQUAL);
			code = code.replace(/&&/g, IS_AND);
			code = code.replace(/\|\|/g, IS_OR);
			
			return code;
		}
	}
}