package asgl.shaders.scripts.compiler {
	public interface IOpcodeOptimizer {
		function optimize(opcodes:Vector.<Opcode>, mm:IMemberManager):Vector.<Opcode>;
	}
}