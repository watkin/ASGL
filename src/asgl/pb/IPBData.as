package asgl.pb {
	import flash.display.Shader;

	public interface IPBData {
		function get offsetTargetLength():uint;
		function get shader():Shader;
		function get target():Object;
		function get targetHeight():uint;
		function get targetWidth():uint;
	}
}