package asgl.shaders.scripts.builtin.postprocess {
	import flash.utils.ByteArray;
	
	public class Dispersion5x5ShaderAsset {
		[Embed(source="Dispersion5x5Shader.bin", mimeType="application/octet-stream")]
		internal static var ShaderAsset:Class;
		
		public function Dispersion5x5ShaderAsset() {
		}
		public static function get asset():ByteArray {
			return new ShaderAsset();
		}
	}
}

