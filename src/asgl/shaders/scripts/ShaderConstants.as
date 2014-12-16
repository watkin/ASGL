package asgl.shaders.scripts {
	import asgl.asgl_protected;
	
	use namespace asgl_protected;

	public class ShaderConstants {
		public var values:Vector.<Number>;
		
		asgl_protected var _name:String;
		asgl_protected var _length:int;
		
		public function ShaderConstants(length:int=-1) {
			_length = length;
		}
		public function get length():int {
			return _length;
		}
		public function set length(value:int):void {
			_length = value;
		}
		public function get name():String {
			return _name;
		}
		public function set name(value:String):void {
			_name = value;
		}
	}
}