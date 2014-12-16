package asgl.shaders.asm {
	import asgl.shaders.asm.agal.OpcodeType;

	public class ShaderHelper {
		private static var _opcodeMap:Object;
		public function ShaderHelper() {
		}
		public static function getOpcodeNum(code:String):uint {
			_opcodeMapInit();
			
			var lines:Array = code.replace(/[\f\n\r\v]+/g, '\n').split('\n');
			var len:int = lines.length;
			
			var num:uint = 0;
			
			for (var i:uint = 0; i<len; i++ ) {
				var line:String = lines[i];
				line = line.replace(/^\s+|\s+$/g, '');
				
				var startcomment:int = line.search('//');
				if (startcomment != -1) line = line.slice( 0, startcomment );
				
				var optsi:int = line.search(/<.*>/g);
				var opts:Array;
				if (optsi != -1) {
					opts = line.slice(optsi).match(/([\w\.\-\+]+)/gi);
					line = line.slice(0, optsi);
				}
				
				var opCode:Array = line.match(/^\w{3}/ig);
				
				if (_opcodeMap[opCode[0]] != null) num++;
			}
			
			return num;
		}
		public static function getSimpleOpcodeNum(code:String):uint {
			_opcodeMapInit();
			
			var lines:Array = code.replace(/[\f\n\r\v]+/g, '\n').split('\n');
			var len:int = lines.length;
			
			var num:uint = 0;
			
			for (var i:uint = 0; i<len; i++ ) {
				var line:String = lines[i];
				line = line.replace(/^\s+|\s+$/g, '');
				
				var startcomment:int = line.search('//');
				if (startcomment != -1) line = line.slice( 0, startcomment );
				
				var optsi:int = line.search(/<.*>/g);
				var opts:Array;
				if (optsi != -1) {
					opts = line.slice(optsi).match(/([\w\.\-\+]+)/gi);
					line = line.slice(0, optsi);
				}
				
				var opCode:Array = line.match(/^\w{3}/ig);
				
				var value:* = _opcodeMap[opCode[0]];
				if (value != null) num += value;
			}
			
			return num;
		}
		private static function _opcodeMapInit():void {
			if (_opcodeMap == null) {
				_opcodeMap = {};
				
				_opcodeMap[OpcodeType.ABSOLUTE] = 1;
				_opcodeMap[OpcodeType.ADD] = 1;
				_opcodeMap[OpcodeType.CROSS_PRODUCT] = 3;
				_opcodeMap[OpcodeType.COSINE] = 40;
				_opcodeMap[OpcodeType.DIVIDE] = 5;
				_opcodeMap[OpcodeType.DOT_PRODUCT_3] = 1;
				_opcodeMap[OpcodeType.DOT_PRODUCT_4] = 1;
				_opcodeMap[OpcodeType.EXPONENTIAL_2] = 4;
				_opcodeMap[OpcodeType.FRACTIONAL] = 1;
				_opcodeMap[OpcodeType.IS_EQUAL] = 5;
				_opcodeMap[OpcodeType.IS_GREATER_EQUAL] = 1;
				_opcodeMap[OpcodeType.IS_LESS_THAN] = 1;
				_opcodeMap[OpcodeType.IS_NOT_EQUAL] = 5;
				_opcodeMap[OpcodeType.KILL] = 0;//
				_opcodeMap[OpcodeType.LOGARITHM_2] = 4;
				_opcodeMap[OpcodeType.MULTIPLY_MATRIX_3X3] = 4;
				_opcodeMap[OpcodeType.MULTIPLY_MATRIX_3X4] = 4;
				_opcodeMap[OpcodeType.MULTIPLY_MATRIX_4X4] = 5;
				_opcodeMap[OpcodeType.MAXIMUM] = 1;
				_opcodeMap[OpcodeType.MINIMUM] = 1;
				_opcodeMap[OpcodeType.MOVE] = 1;
				_opcodeMap[OpcodeType.MULTIPLY] = 1;
				_opcodeMap[OpcodeType.NEGATE] = 1;
				_opcodeMap[OpcodeType.NORMALIZE] = 4;
				_opcodeMap[OpcodeType.POWER] = 16;
				_opcodeMap[OpcodeType.RECIPROCAL] = 4;
				_opcodeMap[OpcodeType.RECIPROCAL_ROOT] = 4;
				_opcodeMap[OpcodeType.SATURATE] = 3;
				_opcodeMap[OpcodeType.SINE] = 40;
				_opcodeMap[OpcodeType.SQUARE_ROOT] = 8;
				_opcodeMap[OpcodeType.SUBTRACT] = 1;
				_opcodeMap[OpcodeType.TEXTURE_SAMPLE] = 0;//
			}
		}
	}
}