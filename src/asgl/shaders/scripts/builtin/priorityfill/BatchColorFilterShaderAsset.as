package asgl.shaders.scripts.builtin.priorityfill {
	import flash.utils.ByteArray;
	
	/**
	 * define : </br>
	 * COLOR_FILTER : COLOR_FILTER_NONE, COLOR_FILTER_ADD, COLOR_FILTER_MUL
	 */
	
	public class BatchColorFilterShaderAsset {
		[Embed(source="BatchColorFilterShader.bin", mimeType="application/octet-stream")]
		internal static var ShaderAsset:Class;
		
		public function BatchColorFilterShaderAsset() {
		}
		public static function get asset():ByteArray {
			return new ShaderAsset();
		}
	}
}

