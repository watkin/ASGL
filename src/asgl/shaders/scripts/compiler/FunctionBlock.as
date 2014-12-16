package asgl.shaders.scripts.compiler {
	public class FunctionBlock {
		private static var _anonymousAccumulator:uint;
		
		private var _data:FunctionData;
		
		public function FunctionBlock(data:FunctionData) {
			_data = data;
		}
		public function get isInterface():Boolean {
			return _data.code == null;
		}
		public function get data():FunctionData {
			return _data;
		}
		public function expansion(opcode:Opcode, parser:ShaderScriptCompiler, mm:IMemberManager):Vector.<Opcode> {
			var scope:String = 'func_' + _data.name + '_' + (_anonymousAccumulator++) + '_';
			
			var oc:Opcode;
			
			var opcodes:Vector.<Opcode> = new Vector.<Opcode>();
			
			var vars1:Vector.<Variable> = _data.params;
			var vars2:Vector.<Variable> = opcode.args;
			if (vars1 != null && vars2 != null) {
				var len1:uint = vars1.length;
				if (len1 == vars2.length) {
					for (var ii:uint = 0; ii < len1; ii++) {
						var var1:Variable = vars1[ii];
						var var2:Variable = vars2[ii];
						
						var type2:String = var2.getTypeWithComponent(mm);
						//if (type2 != var2.type) {
							var v:Variable = _data.params[ii].clone();
							v.setName(scope, v.name);
							oc = new Opcode();
							oc.func = BaseFunctionType._MOVE;
							oc.dest = v;
							oc.args = new Vector.<Variable>();
							oc.args[0] = var2;
							
							vars2[ii] = v;
							
							opcodes.push(oc);
						//}
						
						//if (var1.type != type2 && var1.type != null && type2 != null) {
						//	throw new Error('function:'+_data.name+' params type error');
						//}
					}
				} else {
					throw new Error('function:' + _data.name + ' params num error');
				}
			}
			
			var funcOpcodes:Vector.<Opcode> = parser.parseFunc(_data, scope);
			
			opcodes = opcodes.concat(funcOpcodes);
			
			//trace(SSLOpcode.toString(opcodes));
			
			var params:Vector.<String> = new Vector.<String>();
			var max:uint = _data.params.length;
			for (var i:uint = 0; i < max; i++) {
				params[i] = scope + _data.params[i].fullName;
			}
			
			var len:uint = opcodes.length;
			for (i = 0; i < len; i++) {
				oc = opcodes[i];
				
				if (oc.dest != null) {
					var index:int = params.indexOf(oc.dest.fullName);
					if (index != -1) {
						params.splice(index, 1);
						//oc.copyDest(opcode.args[index], mm);
					}
				}
				
				var args:Vector.<Variable> = oc.args;
				if (args != null) {
					var num:uint = args.length;
					for (var j:uint = 0; j < num; j++) {
						index = params.indexOf(args[j].fullName);
						if (index != -1) {
							args[j].copy(opcode.args[index], mm);
						}
					}
				}
			}
			
			if (opcodes.length > 0) {
				var last:Opcode = opcodes[int(opcodes.length - 1)];
				if (last.func == BaseFunctionType.RETURN) {
					last.dest.type = _data.returnType;
				}
			}
			
			//trace(SSLOpcode.toString(opcodes));
			
			return opcodes;
		}
	}
}