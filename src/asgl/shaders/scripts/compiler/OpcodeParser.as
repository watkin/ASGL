package asgl.shaders.scripts.compiler {
	public class OpcodeParser implements IOpcodeParser {
		private var _operatorFuncMap:Object;
		
		public function OpcodeParser() {
			_operatorFuncMap = {};
			_operatorFuncMap[OperatorSymbol.IS_LESS] = BaseFunctionType._IS_LESS;
			_operatorFuncMap[OperatorSymbol.IS_EQUAL] = BaseFunctionType._IS_EQUAL;
			_operatorFuncMap[OperatorSymbol.IS_NOT_EQUAL] = BaseFunctionType._IS_NOT_EQUAL;
			_operatorFuncMap[OperatorSymbol.IS_GREATER] = BaseFunctionType._IS_GREATER;
			_operatorFuncMap[OperatorSymbol.IS_LESS_EQUAL] = BaseFunctionType._IS_LESS_EQUAL;
			_operatorFuncMap[OperatorSymbol.IS_GREATER_EQUAL] = BaseFunctionType._IS_GREATER_EQUAL;
			_operatorFuncMap[OperatorSymbol.IS_AND] = BaseFunctionType._IS_AND;
			_operatorFuncMap[OperatorSymbol.IS_OR] = BaseFunctionType._IS_OR;
			_operatorFuncMap[OperatorSymbol.IS_NOT] = BaseFunctionType._IS_NOT;
		}
		public function parse(mm:IMemberManager, funcTable:FunctionTable, css:Vector.<CodeSegment>):Vector.<Opcode> {
			var op:Vector.<Opcode> = new Vector.<Opcode>();
			
			var len:uint = css.length;
			
			var oc:Opcode;
			
			var temp:Vector.<CodeSegment> = new Vector.<CodeSegment>();
			
			var operators:Vector.<String> = new Vector.<String>();
			var states:Vector.<Boolean> = new Vector.<Boolean>();
			var last:Vector.<Opcode> = new Vector.<Opcode>();
			
			for (var i:uint = 0; i < len; i++) {
				var cs:CodeSegment = css[i];
				
				operators[i] = cs.operator;
				var subOpcodes:Vector.<Opcode>;
				
				if (cs.name != '') {
					oc = new Opcode();
					oc.func = cs.name;
					oc.args = new Vector.<Variable>();
					
					var num:uint = cs.bodies.length;
					for (var j:uint = 0; j < num; j++) {
						temp[0] = cs.bodies[j];
						subOpcodes = parse(mm, funcTable, temp);
						if (subOpcodes.length > 0) {
							op = op.concat(subOpcodes);
							oc.copyArgs(j, subOpcodes[int(subOpcodes.length - 1)].dest, mm);
						}
					}
					
					var returnType:String = funcTable.getFuncType(cs.name, oc.args, mm);
					if (returnType != BaseVariableType.VOID) {
						oc.dest = mm.createVariable();
						oc.dest.type = returnType;
						mm.setType(oc.dest.fullName, oc.dest.type);
					}
					
					op.push(oc);
					
					if (cs.component != '') {
						var oc2:Opcode = new Opcode();
						oc2.func = BaseFunctionType._MOVE;
						oc2.args = new Vector.<Variable>();
						oc2.dest = mm.createVariable();
						oc2.copyArgs(0, oc.dest, mm);
						oc2.args[0].component = cs.component;
						oc2.dest.type = oc2.args[0].getTypeWithComponent(mm);
						mm.setType(oc2.dest.fullName, oc2.dest.type);
						
						op.push(oc2);
						
						oc = oc2;
					}
					
					states[i] = false;
					last[i] = oc;
				} else if (cs.bodies != null) {
					subOpcodes = parse(mm, funcTable, cs.bodies);
					if (subOpcodes.length > 0) {
						states[i] = false;
						op = op.concat(subOpcodes);
						last[i] = subOpcodes[int(subOpcodes.length - 1)];
					}
				} else {
					oc = new Opcode();
					mm.setType(cs.body.fullName, cs.body.type);
					oc.copyDest(cs.body, mm);
					
					if (cs.component != '') {
						oc.dest.component = cs.component;
					}
					
					if (Util.isNumber(oc.dest.name, oc.dest.component)) {
						oc.dest.type = BaseVariableType.FLOAT;
						mm.setType(oc.dest.fullName, oc.dest.type);
					}
					
					states[i] = true;
					last[i] = oc;
				}
			}
			
			var has:Boolean;
			var operator:String;
			var func:String;
			
			do {
				has = false;
				
				for (i = 0; i < len; i++) {
					operator = operators[i];
					if (operator == OperatorSymbol.IS_NOT) {
						oc = new Opcode();
						oc.dest = mm.createVariable();
						oc.func = BaseFunctionType._IS_NOT;
						oc.args = new Vector.<Variable>();
						oc.copyArgs(0, last[i].dest, mm);
						oc.dest.type = oc.args[0].getTypeWithComponent(mm);
						mm.setType(oc.dest.fullName, oc.dest.type);
						
						op.push(oc);
						
						last[i] = oc;
						
						operators[i] = '';
					}
				}
			} while (has);
			
			do {
				has = false;
				
				for (i = 1; i < len; i++) {
					operator = operators[i];
					if (operator == OperatorSymbol.MUL || operator == OperatorSymbol.DIV) {
						oc = new Opcode();
						oc.dest = mm.createVariable();
						oc.func = operator == OperatorSymbol.MUL ? BaseFunctionType._MUL : BaseFunctionType._DIV;
						oc.args = new Vector.<Variable>();
						oc.copyArgs(0, last[int(i - 1)].dest, mm);
						oc.copyArgs(1, last[i].dest, mm);
						if (oc.args[0].getTypeWithComponent(mm) == oc.args[1].getTypeWithComponent(mm)) {
							oc.dest.type = oc.args[0].getTypeWithComponent(mm);
							mm.setType(oc.dest.fullName, oc.dest.type);
						}
						
						op.push(oc);
						
						operators.splice(i, 1);
						last.splice(i - 1, 2, oc);
						states.splice(i - 1, 2, false);
						len--;
						
						has = true;
						
						break;
					}
				}
			} while (has);
			
			do {
				has = false;
				
				for (i = 0; i < len; i++) {
					operator = operators[i];
					if (operator == OperatorSymbol.ADD || operator == OperatorSymbol.SUB) {
						oc = new Opcode();
						oc.dest = mm.createVariable();
						oc.func = operator == OperatorSymbol.ADD ? BaseFunctionType._ADD : BaseFunctionType._SUB;
						oc.args = new Vector.<Variable>();
						oc.copyArgs(0, last[int(i - 1)].dest, mm);
						oc.copyArgs(1, last[i].dest, mm);
						if (oc.args[0].getTypeWithComponent(mm) == oc.args[1].getTypeWithComponent(mm)) {
							oc.dest.type = oc.args[0].getTypeWithComponent(mm);
							mm.setType(oc.dest.fullName, oc.dest.type);
						}
						
						op.push(oc);
						
						operators.splice(i, 1);
						last.splice(i - 1, 2, oc);
						states.splice(i - 1, 2, false);
						len--;
						
						has = true;
						
						break;
					}
				}
			} while (has);
			
			do {
				has = false;
				
				for (i = 0; i < len; i++) {
					operator = operators[i];
					
					func = _operatorFuncMap[operator];
					if (func != null) has = true;
					
					if (has) {
						oc = new Opcode();
						oc.dest = mm.createVariable();
						oc.func = func;
						oc.args = new Vector.<Variable>();
						oc.copyArgs(0, last[int(i - 1)].dest, mm);
						oc.copyArgs(1, last[i].dest, mm);
						if (oc.args[0].getTypeWithComponent(mm) == oc.args[1].getTypeWithComponent(mm)) {
							oc.dest.type = oc.args[0].getTypeWithComponent(mm);
							mm.setType(oc.dest.fullName, oc.dest.type);
						}
						
						op.push(oc);
						
						operators.splice(i, 1);
						last.splice(i - 1, 2, oc);
						states.splice(i - 1, 2, false);
						len--;
						
						break;
					}
				}
			} while (has);
			
			len = states.length;
			for (i = 0; i < len; i++) {
				if (states[i]) op.push(last[i]);
			}
			
			return op;
		}
	}
}