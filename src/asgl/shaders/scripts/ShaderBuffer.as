package asgl.shaders.scripts {
	import asgl.asgl_protected;
	
	use namespace asgl_protected;
	
	public class ShaderBuffer {
		asgl_protected var _name:String;
		asgl_protected var _index:int;
		
		public function ShaderBuffer(name:String, index:int) {
			_name = name;
			_index = index;
		}
	}
}