package asgl.shaders.scripts.compiler {
	public interface IProgramFormatter {
		function format(programType:String, opcodes:Vector.<Opcode>, param:Variable, scope:String, mm:IMemberManager, varyingMap:Object):Vector.<Opcode>;
	}
}