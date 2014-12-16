package asgl.shaders.scripts.compiler {
	public interface IOpcodeParser {
		function parse(mm:IMemberManager, funcTable:FunctionTable, css:Vector.<CodeSegment>):Vector.<Opcode>;
	}
}