package asgl.shaders.scripts.builtin.priorityfill {
	import flash.utils.ByteArray;
	
	public class BatchGrayFilterShaderAsset {
		[Embed(source="BatchGrayFilterShader.bin", mimeType="application/octet-stream")]
		internal static var ShaderAsset:Class;
		
		public function BatchGrayFilterShaderAsset() {
		}
		public static function get asset():ByteArray {
			return new ShaderAsset();
		}
	}
}
