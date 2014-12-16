package asgl.shaders.scripts.compiler {
	import flash.utils.ByteArray;

	public interface IProgramCompiler {
		function compile(programType:String, opcodes:Vector.<Opcode>, mm:IMemberManager, settings:ProgramSettings):ByteArray;
	}
}