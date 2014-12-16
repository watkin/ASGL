package asgl.shaders.scripts.builtin.forward {
	import flash.utils.ByteArray;

	public class LightingMeshShaderAsset {
		[Embed(source="LightingMeshShader.bin", mimeType="application/octet-stream")]
		internal static var ShaderAsset:Class;
		
		public function LightingMeshShaderAsset() {
		}
		public static function get asset():ByteArray {
			return new ShaderAsset();
		}
	}
}