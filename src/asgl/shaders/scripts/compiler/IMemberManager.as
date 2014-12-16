package asgl.shaders.scripts.compiler {
	public interface IMemberManager {
		function reset():void;
		function createVariableName():String;
		function createVariable(type:String=null, scope:String=null):Variable;
		function addStructPrototype(struct:Struct, isInternal:Boolean):void;
		function getStructPrototype(name:String):Struct;
		function getType(name:String):String;
		function setType(name:String, type:String):uint;
		function setTypeFromVariable(variable:Variable):uint;
		function setReference(name:String, ref:Variable):void;
		function getReference(name:String):Variable;
		function setProperty(name:String, data:FunctionData, isInternal:Boolean):void;
		function getProperty(name:String):FunctionData;
		function getProperties():Vector.<FunctionData>;
	}
}