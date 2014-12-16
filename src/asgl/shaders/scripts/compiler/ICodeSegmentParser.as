package asgl.shaders.scripts.compiler {
	public interface ICodeSegmentParser {
		function parse(code:String, scope:String, functionTable:FunctionTable, isParams:Boolean=false):Vector.<CodeSegment>;
	}
}