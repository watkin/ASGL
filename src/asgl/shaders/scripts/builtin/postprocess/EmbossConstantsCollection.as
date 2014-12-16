package asgl.shaders.scripts.builtin.postprocess {
	import asgl.shaders.scripts.ShaderConstants;
	import asgl.shaders.scripts.ShaderConstantsCollection;
	import asgl.shaders.scripts.ShaderPropertyType;
	
	public class EmbossConstantsCollection extends ShaderConstantsCollection {
		private var _bgColor:ShaderConstants;
		private var _texAtt:ShaderConstants;
		
		public function EmbossConstantsCollection() {
		}
		public override function clear():void {
			super.clear();
			
			_bgColor = null;
			_texAtt = null;
		}
		public function get backgroundColor():ShaderConstants {
			return _bgColor;
		}
		public function set backgroundColor(value:ShaderConstants):void {
			_bgColor = value;
			_setConstants(ShaderPropertyType.BACKGROUND_COLOR, value);
		}
		public function get textureAttribute():ShaderConstants {
			return _texAtt;
		}
		public function set textureAttribute(value:ShaderConstants):void {
			_texAtt = value;
			_setConstants(ShaderPropertyType.SOURCE_TEX_ATTRIBUTE, value);
		}
	}
}