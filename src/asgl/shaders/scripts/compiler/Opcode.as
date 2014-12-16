package asgl.shaders.scripts.compiler {
	public class Opcode {
		public var func:String;
		public var dest:Variable;
		public var args:Vector.<Variable>;
		
		public function Opcode() {
		}
		public function copyArgs(index:uint, target:Variable, mm:IMemberManager=null):void {
			if (args == null) args = new Vector.<Variable>();
			var variable:Variable = new Variable();
			variable.copy(target, mm);
			args[index] = variable;
		}
		
		public function copyDest(target:Variable, mm:IMemberManager=null):void {
			if (dest == null) dest = new Variable();
			dest.copy(target, mm);
		}
		public function hasVar(v:Variable):Boolean {
			if (dest != null && dest.hasVar(v)) return true;
			
			if (args != null) {
				var len:int = args.length;
				for (var i:int = 0; i < len; i++) {
					if (args[i].hasVar(v)) return true;
				}
			}
			
			return false;
		}
		public function setFunc(operator:String):void {
			switch (operator) {
				case OperatorSymbol.ADD:
					func = BaseFunctionType._ADD;
					break;
				case OperatorSymbol.SUB :
					func = BaseFunctionType._SUB;
					break;
				case OperatorSymbol.MUL :
					func = BaseFunctionType._MUL;
					break;
				case OperatorSymbol.DIV :
					func = BaseFunctionType._DIV;
					break;
				case OperatorSymbol.EQUAL :
					func = BaseFunctionType._MOVE;
					break;
				case OperatorSymbol.IS_LESS :
					func = BaseFunctionType._IS_LESS;
					break;
				case OperatorSymbol.IS_EQUAL :
					func = BaseFunctionType._IS_EQUAL;
					break;
				case OperatorSymbol.IS_NOT_EQUAL :
					func = BaseFunctionType._IS_NOT_EQUAL;
					break;
				case OperatorSymbol.IS_GREATER :
					func = BaseFunctionType._IS_GREATER;
					break;
				case OperatorSymbol.IS_LESS_EQUAL :
					func = BaseFunctionType._IS_LESS_EQUAL;
					break;
				case OperatorSymbol.IS_GREATER_EQUAL :
					func = BaseFunctionType._IS_GREATER_EQUAL;
					break;
				case OperatorSymbol.IS_AND :
					func = BaseFunctionType._IS_AND;
					break;
				case OperatorSymbol.IS_OR :
					func = BaseFunctionType._IS_OR;
					break;
				case OperatorSymbol.IS_NOT :
					func = BaseFunctionType._IS_NOT;
					break;
				default :
					break;
			}
		}
		public function toString():String {
			var str:String = 'func:' + func + ' dest:' + dest + ' args[';
			if (args == null) {
				str += '0]:';
			} else {
				var len:uint = args.length;
				
				str += len + ']:';
				
				for (var i:uint = 0; i < len; i++) {
					str += args[i];
					if (i + 1 < len) {
						str += ', ';
					}
				}
			}
			return str;
		}
		public static function toString(opcodes:Vector.<Opcode>):String {
			var str:String = '';
			
			var lines:uint = 0;
			
			var len:uint = opcodes.length;
			for (var i:uint = 0; i < len; i++) {
				var oc:Opcode = opcodes[i];
				
				str += '\n[lines:' + (++lines) + '] ';
				
				if (oc.func == null) {
					str += oc.dest;
				} else {
					switch (oc.func) {
						case BaseFunctionType._ADD:
							str += oc.dest + ' = ' + oc.args[0] + ' + ' + oc.args[1];
							break;
						case BaseFunctionType._SUB:
							str += oc.dest + ' = ' + oc.args[0] + ' - ' + oc.args[1];
							break;
						case BaseFunctionType._MUL:
							str += oc.dest + ' = ' + oc.args[0] + ' * ' + oc.args[1];
							break;
						case BaseFunctionType._DIV:
							str += oc.dest + ' = ' + oc.args[0] + ' / ' + oc.args[1];
							break;
						case BaseFunctionType._MOVE:
							str += oc.dest + ' = ' + oc.args[0];
							break;
						case BaseFunctionType._NEG:
							str += oc.dest + ' = -' + oc.args[0];
							break;
						case BaseFunctionType._IS_EQUAL:
							str += oc.dest + ' = ' + oc.args[0] + ' == ' + oc.args[1];
							break;
						case BaseFunctionType._IS_NOT_EQUAL:
							str += oc.dest + ' = ' + oc.args[0] + ' != ' + oc.args[1];
							break;
						case BaseFunctionType._IS_LESS:
							str += oc.dest + ' = ' + oc.args[0] + ' < ' + oc.args[1];
							break;
						case BaseFunctionType._IS_GREATER:
							str += oc.dest + ' = ' + oc.args[0] + ' > ' + oc.args[1];
							break;
						case BaseFunctionType._IS_LESS_EQUAL:
							str += oc.dest + ' = ' + oc.args[0] + ' <= ' + oc.args[1];
							break;
						case BaseFunctionType._IS_GREATER_EQUAL:
							str += oc.dest + ' = ' + oc.args[0] + ' >= ' + oc.args[1];
							break;
						case BaseFunctionType._IS_AND:
							str += oc.dest + ' = ' + oc.args[0] + ' && ' + oc.args[1];
							break;
						case BaseFunctionType._IS_OR:
							str += oc.dest + ' = ' + oc.args[0] + ' || ' + oc.args[1];
							break;
						case BaseFunctionType._IS_NOT:
							str += oc.dest + ' = !' + oc.args[0];
							break;
						default :
							if (oc.func != null) {
								if (oc.dest != null) str += oc.dest + ' = ';
								str += oc.func + ' ( ';
								var args:String = '';
								var num:uint = oc.args.length;
								for (var j:uint = 0; j < num; j++) {
									str += oc.args[j];
									if (j + 1 < num) {
										str += ' , ';
									}
								}
								str += ' ) ';
							}
							
							break;
					}
				}
			}
			
			return str;
		}
	}
}