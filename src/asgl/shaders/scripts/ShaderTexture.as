package asgl.shaders.scripts {
	import asgl.asgl_protected;
	
	use namespace asgl_protected;
	
	public class ShaderTexture {
		asgl_protected var _name:String;
		asgl_protected var _index:int;
		//asgl_protected var _samplerState:uint;
		asgl_protected var _samplersPosition:Vector.<int>;
		
		public function ShaderTexture(name:String, index:int, samplersPositon:Vector.<int>) {
			_name = name;
			_index = index;
			//_samplerState = sampleState;
			_samplersPosition = samplersPositon;
		}
	}
}