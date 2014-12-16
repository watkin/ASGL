package asgl.shaders.scripts {
	import asgl.asgl_protected;
	
	use namespace asgl_protected;
	
	public class ShaderDefineType {
		public static const COLOR_FILTER:String = 'COLOR_FILTER';
		public static const TEXTURE_ANIMATION:String = 'TEXTURE_ANIMATION';
		public static const PARTICLE_ROTATE:String = 'PARTICLE_ROTATE';
		public static const BILLBOARD:String = 'BILLBOARD';
		public static const NUM_BLEND_BONE:String = 'NUM_BLEND_BONE';
		public static const MULTIPLIED_ALPHA:String = 'MULTIPLIED_ALPHA';
		
		public static const LIGHTS:Vector.<String> = Shader3D._createIndexConstants('LIGHT', 2);
		public static const SHADOWS:Vector.<String> = Shader3D._createIndexConstants('SHADOW', 2);
		
		public function ShaderDefineType() {
		}
	}
}