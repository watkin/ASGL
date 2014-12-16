package asgl.shaders.scripts.builtin {
	import flash.utils.ByteArray;

	public class MeshShaderAsset {
		[Embed(source="MeshShader.bin", mimeType="application/octet-stream")]
		internal static var ShaderAsset:Class;
		
		public function MeshShaderAsset() {
		}
		public static function get asset():ByteArray {
			return new ShaderAsset();
		}
	}
}