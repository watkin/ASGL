package asgl.shaders.scripts.builtin {
	import flash.utils.ByteArray;

	public class DepthShaderAsset {
		[Embed(source="DepthShader.bin", mimeType="application/octet-stream")]
		internal static var ShaderAsset:Class;
		
		public function DepthShaderAsset() {
		}
		public static function get asset():ByteArray {
			return new ShaderAsset();
		}
	}
}