package asgl.shaders.scripts.builtin.particles {
	import flash.utils.ByteArray;
	
	/**
	 * define : </br>
	 * PARTICLE_ROTATE : DISABLE, ENABLE</br>
	 * TEXTURE_ANIMATION : TEXTURE_ANIMATION_NONE, TEXTURE_ANIMATION_TILE</br>
	 * BILLBOARD : DISABLE, ENABLE
	 * MULTIPLIED_ALPHA : DISABLE, ENABLE
	 */
	
	public class TextureParticleShaderAsset {
		[Embed(source="TextureParticleShader.bin", mimeType="application/octet-stream")]
		internal static var ShaderAsset:Class;
		
		public function TextureParticleShaderAsset() {
		}
		public static function get asset():ByteArray {
			return new ShaderAsset();
		}
	}
}

