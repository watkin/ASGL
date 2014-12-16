package asgl.shaders.scripts.builtin {
	import flash.utils.ByteArray;
	
	/**
	 * define : </br>
	 * NUM_BLEND_BONE : 0, 1, 2, 3, 4
	 */
	
	public class SkinnedMeshShaderAsset {
		[Embed(source="SkinnedMeshShader.bin", mimeType="application/octet-stream")]
		internal static var ShaderAsset:Class;
		
		public function SkinnedMeshShaderAsset() {
		}
		public static function get asset():ByteArray {
			return new ShaderAsset();
		}
	}
}

