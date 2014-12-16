package asgl.shaders.scripts.builtin.postprocess {
	import flash.utils.ByteArray;
	
	public class EmbossShaderAsset {
		[Embed(source="EmbossShader.bin", mimeType="application/octet-stream")]
		internal static var ShaderAsset:Class;
		
		public function EmbossShaderAsset() {
		}
		public static function get asset():ByteArray {
			return new ShaderAsset();
		}
	}
}

