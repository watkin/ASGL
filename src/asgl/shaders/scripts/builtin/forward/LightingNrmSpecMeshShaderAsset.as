package asgl.shaders.scripts.builtin.forward {
	import flash.utils.ByteArray;
	
	public class LightingNrmSpecMeshShaderAsset {
		[Embed(source="LightingNrmSpecMeshShader.bin", mimeType="application/octet-stream")]
		internal static var ShaderAsset:Class;
		
		public function LightingNrmSpecMeshShaderAsset() {
		}
		public static function get asset():ByteArray {
			return new ShaderAsset();
		}
	}
}

