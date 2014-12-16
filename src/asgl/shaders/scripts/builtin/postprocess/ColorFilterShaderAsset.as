package asgl.shaders.scripts.builtin.postprocess {
	import flash.utils.ByteArray;
	
	/**
	 * define : </br>
	 * COLOR_FILTER : COLOR_FILTER_NONE, COLOR_FILTER_ADD, COLOR_FILTER_MUL
	 */

	public class ColorFilterShaderAsset {
		[Embed(source="ColorFilterShader.bin", mimeType="application/octet-stream")]
		internal static var ShaderAsset:Class;
		
		public function ColorFilterShaderAsset() {
		}
		public static function get asset():ByteArray {
			return new ShaderAsset();
		}
	}
}