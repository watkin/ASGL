package asgl.shaders.scripts.builtin.postprocess {
	import asgl.asgl_protected;
	import asgl.shaders.scripts.ShaderConstants;
	import asgl.shaders.scripts.ShaderConstantsCollection;
	import asgl.shaders.scripts.ShaderPropertyType;
	
	use namespace asgl_protected;
	
	public class EdgeDetectionConstantsCollection extends ShaderConstantsCollection {
		private var _matrix:ShaderConstants;
		private var _texAtt:ShaderConstants;
		private var _threshold:ShaderConstants;
		
		public function EdgeDetectionConstantsCollection() {
		}
		public override function clear():void {
			super.clear();
			
			_matrix = null;
			_texAtt = null;
			_threshold = null;
		}
		public function get matrix():ShaderConstants {
			return _matrix;
		}
		public function set matrix(value:ShaderConstants):void {
			_matrix = value;
			_setConstants(ShaderPropertyType.FILTER_MATRIX_33, value);
		}
		public function get textureAttribute():ShaderConstants {
			return _texAtt;
		}
		public function set textureAttribute(value:ShaderConstants):void {
			_texAtt = value;
			_setConstants(ShaderPropertyType.SOURCE_TEX_ATTRIBUTE, value);
		}
		public function get threshold():ShaderConstants {
			return _threshold;
		}
		public function set threshold(value:ShaderConstants):void {
			_threshold = value;
			_setConstants(ShaderPropertyType.THRESHOLD, value);
		}
	}
}

