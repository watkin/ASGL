/**
 * result color = (source color ~~ sourceFactor) + (destination color ~~ destinationFactor)
 */
package asgl.system {
	import flash.display3D.Context3DBlendFactor;
	
	import asgl.asgl_protected;
	
	use namespace asgl_protected;

	public class BlendFactorsData {
		private static const _blendValues:Object = _getBlendValues();
		
		public static const ADDITIVE:BlendFactorsData = new BlendFactorsData(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE);
		public static const MUL_ALPHA_ADDITIVE:BlendFactorsData = new BlendFactorsData(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE);
		public static const ALPHA_BLEND:BlendFactorsData = new BlendFactorsData(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
		public static const MULTIPLY:BlendFactorsData = new BlendFactorsData(Context3DBlendFactor.DESTINATION_COLOR, Context3DBlendFactor.ZERO);
		public static const NO_BLEND:BlendFactorsData = new BlendFactorsData(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
		public static const SCREEN:BlendFactorsData = new BlendFactorsData(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_COLOR);
		
		asgl_protected var _destinationFactor:String;
		asgl_protected var _sourceFactor:String;
		
		asgl_protected var _blendFactorsID:uint;
		
		public function BlendFactorsData(sourceFactor:String, destinationFactor:String) {
			_sourceFactor = sourceFactor;
			_destinationFactor = destinationFactor;
			
			_blendFactorsID = (_blendValues[_sourceFactor] << 4) | _blendValues[_destinationFactor];
		}
		private static function _getBlendValues():Object {
			var map:Object = {};
			
			map[Context3DBlendFactor.DESTINATION_ALPHA] = 1;
			map[Context3DBlendFactor.DESTINATION_COLOR] = 2;
			map[Context3DBlendFactor.ONE] = 3;
			map[Context3DBlendFactor.ONE_MINUS_DESTINATION_ALPHA] = 4;
			map[Context3DBlendFactor.ONE_MINUS_DESTINATION_COLOR] = 5;
			map[Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA] = 6;
			map[Context3DBlendFactor.ONE_MINUS_SOURCE_COLOR] = 7;
			map[Context3DBlendFactor.SOURCE_ALPHA] = 8;
			map[Context3DBlendFactor.SOURCE_COLOR] = 9;
			map[Context3DBlendFactor.ZERO] = 10;
			
			return map;
		}
		public function get destinationFactor():String {
			return _destinationFactor;
		}
		public function get sourceFactor():String {
			return _sourceFactor;
		}
	}
}