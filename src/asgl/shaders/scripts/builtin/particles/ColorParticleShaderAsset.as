package asgl.shaders.scripts.builtin.particles {
	import flash.utils.ByteArray;
	
	/**
	 * define : </br>
	 * PARTICLE_ROTATE : DISABLE, ENABLE</br>
	 * BILLBOARD : DISABLE, ENABLE
	 * MULTIPLIED_ALPHA : DISABLE, ENABLE
	 */
	
	public class ColorParticleShaderAsset {
		[Embed(source="ColorParticleShader.bin", mimeType="application/octet-stream")]
		internal static var ShaderAsset:Class;
		
		public function ColorParticleShaderAsset() {
		}
		public static function get asset():ByteArray {
			return new ShaderAsset();
		}
	}
}

