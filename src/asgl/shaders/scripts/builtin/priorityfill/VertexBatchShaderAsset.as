package asgl.shaders.scripts.builtin.priorityfill {
	import flash.utils.ByteArray;

	public class VertexBatchShaderAsset {
		[Embed(source="VertexBatchShader.bin", mimeType="application/octet-stream")]
		internal static var ShaderAsset:Class;
		
		public function VertexBatchShaderAsset() {
		}
		public static function get asset():ByteArray {
			return new ShaderAsset();
		}
	}
}