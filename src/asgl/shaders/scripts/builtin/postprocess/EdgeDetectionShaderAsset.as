package asgl.shaders.scripts.builtin.postprocess {
	import flash.utils.ByteArray;
	
	public class EdgeDetectionShaderAsset {
		[Embed(source="EdgeDetectionShader.bin", mimeType="application/octet-stream")]
		internal static var ShaderAsset:Class;
		
		public function EdgeDetectionShaderAsset() {
		}
		public static function get asset():ByteArray {
			return new ShaderAsset();
		}
	}
}

