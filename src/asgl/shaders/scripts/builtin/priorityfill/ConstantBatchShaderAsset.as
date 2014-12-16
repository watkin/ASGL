package asgl.shaders.scripts.builtin.priorityfill {
	import flash.utils.ByteArray;

	public class ConstantBatchShaderAsset {
		[Embed(source="ConstantBatchShader.bin", mimeType="application/octet-stream")]
		internal static var ShaderAsset:Class;
		
		public function ConstantBatchShaderAsset() {
		}
		public static function get asset():ByteArray {
			return new ShaderAsset();
		}
	}
}