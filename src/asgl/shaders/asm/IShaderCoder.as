package asgl.shaders.asm {
	public interface IShaderCoder {
		function get code():String;
		function clear():void;
		function appendCode(code:String):void;
	}
}