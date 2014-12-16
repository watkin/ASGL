package asgl.shaders.scripts.compiler {
	public class OpcodeOptimizer implements IOpcodeOptimizer {
		public function OpcodeOptimizer() {
		}
		public function optimize(opcodes:Vector.<Opcode>, mm:IMemberManager):Vector.<Opcode> {
//			trace(Opcode.toString(opcodes));
			var len:int = opcodes.length;
			for (var i:int = 0; i < len; i++) {
				var opcode:Opcode = opcodes[i];
				if (opcode.func == null) {
					opcodes.splice(i, 1);
					
					i--;
					len--;
				} else if (opcode.dest != null && mm.getStructPrototype(opcode.dest.type) != null) {
					var has:Boolean = false;
					
					for (var j:int = i + 1; j < len; j++) {
						if (opcodes[j].hasVar(opcode.dest)) {
							has = true;
							break;
						}
					}
					
					if (!has && opcode.func != 'return') {
						opcodes.splice(i, 1);
						
						i--;
						len--;
					}
				}
			}
//			trace(Opcode.toString(opcodes));
			return opcodes;
		}
	}
}