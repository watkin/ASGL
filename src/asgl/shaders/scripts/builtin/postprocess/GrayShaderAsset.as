package asgl.shaders.scripts.builtin.postprocess {
	import flash.utils.ByteArray;

	public class GrayShaderAsset {
		[Embed(source="GrayShader.bin", mimeType="application/octet-stream")]
		internal static var ShaderAsset:Class;
		
		public function GrayShaderAsset() {
		}
		public static function get asset():ByteArray {
			return new ShaderAsset();
		}
	}
}