package asgl.shaders.scripts.builtin.postprocess {
	import flash.utils.ByteArray;
	
	public class Dispersion3x3ShaderAsset {
		[Embed(source="Dispersion3x3Shader.bin", mimeType="application/octet-stream")]
		internal static var ShaderAsset:Class;
		
		public function Dispersion3x3ShaderAsset() {
		}
		public static function get asset():ByteArray {
			return new ShaderAsset();
		}
	}
}

