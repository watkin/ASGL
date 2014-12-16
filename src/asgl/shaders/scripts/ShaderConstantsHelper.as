package asgl.shaders.scripts {
	import asgl.asgl_protected;
	import asgl.system.AbstractTextureData;
	
	use namespace asgl_protected;

	public class ShaderConstantsHelper {
		public function ShaderConstantsHelper() {
		}
		public static function generateBoxBlurMatrix3x3(sc:ShaderConstants=null):ShaderConstants {
			if (sc == null) {
				sc = new ShaderConstants(3);
				sc.values = new Vector.<Number>(12);
			}
			
			return _generateBoxBlurMatrix(1, sc);
		}
		public static function generateBoxBlurMatrix5x5(sc:ShaderConstants=null):ShaderConstants {
			if (sc == null) {
				sc = new ShaderConstants(7);
				sc.values = new Vector.<Number>(28);
			}
			
			return _generateBoxBlurMatrix(2, sc);
		}
		private static function _generateBoxBlurMatrix(range:int, sc:ShaderConstants):ShaderConstants {
			var values:Vector.<Number> = sc.values;
			
			var len:int = range * 2 + 1;
			len *= len;
			
			var value:Number = 1 / len;
			
			for (var i:int = 0; i < len; i++) {
				values[i] = value;
			}
			
			return sc;
		}
		public static function generateEdgeDetectionMatrix(sc:ShaderConstants=null):ShaderConstants {
			if (sc == null) {
				sc = new ShaderConstants(3);
				sc.values = new Vector.<Number>(12);
			}
			
			var values:Vector.<Number> = sc.values;
			values[0] = -1;
			values[1] = -2;
			values[2] = -1;
			
			values[6] = 1;
			values[7] = 2;
			values[8] = 1;
			
			return sc;
		}
		public static function generateNumber4(value1:Number, value2:Number, value3:Number, value4:Number, sc:ShaderConstants=null):ShaderConstants {
			if (sc == null) {
				sc = new ShaderConstants(1);
				sc.values = new Vector.<Number>(4);
			}
			
			var values:Vector.<Number> = sc.values;
			values[0] = value1;
			values[1] = value2;
			values[2] = value3;
			values[3] = value4;
			
			return sc;
		}
		public static function generateGaussianBlurMatrix3x3(sigma:Number=1, sc:ShaderConstants=null):ShaderConstants {
			if (sc == null) {
				sc = new ShaderConstants(3);
				sc.values = new Vector.<Number>(12);
			}
			
			return _generateGaussianBlurMatrix(1, sigma, sc);
		}
		public static function generateGaussianBlurMatrix5x5(sigma:Number=1, sc:ShaderConstants=null):ShaderConstants {
			if (sc == null) {
				sc = new ShaderConstants(7);
				sc.values = new Vector.<Number>(28);
			}
			
			return _generateGaussianBlurMatrix(2, sigma, sc);
		}
		private static function _generateGaussianBlurMatrix(range:int, sigma:Number, sc:ShaderConstants):ShaderConstants {
			var values:Vector.<Number> = sc.values;
			
			var k:Number = 2 * sigma * sigma;
			var sum:Number = 0;
			
			var index:int = 0;
			
			for (var y:int = -range; y <= range; y++) {
				var y2:int = y * y;
				for (var x:int = -range; x <= range; x++) {
					var value:Number = Math.exp(-(x * x + y2) / k);
					values[index++] = value;
					sum += value;//or sum = k*Math.PI;
				}
			}
			
			var len:int = range * 2 + 1;
			len *= len;
			
			for (var i:int = 0; i < len; i++) {
				values[i] /= sum;
			}
			
			return sc;
		}
		public static function generateLaplacianSharpenMatrix3x3(intensity:Number=1, sc:ShaderConstants=null):ShaderConstants {
			if (sc == null) {
				sc = new ShaderConstants(3);
				sc.values = new Vector.<Number>(12);
			}
			
			return _generateLaplacianSharpenMatrix(1, intensity, sc);
		}
		public static function generateLaplacianSharpenMatrix5x5(intensity:Number=1, sc:ShaderConstants=null):ShaderConstants {
			if (sc == null) {
				sc = new ShaderConstants(7);
				sc.values = new Vector.<Number>(28);
			}
			
			return _generateLaplacianSharpenMatrix(2, intensity, sc);
		}
		private static function _generateLaplacianSharpenMatrix(range:int, intensity:Number, sc:ShaderConstants):ShaderConstants {
			var values:Vector.<Number> = sc.values;
			
			var len:int = range * 2 + 1;
			len *= len;
			
			var value0:Number = intensity + 1;
			var value1:Number = (1 - value0) / (len - 1);
			
			for (var i:int = 0; i < len; i++) {
				values[i] = value1;
			}
			values[int(len * 0.5)] = value0;
			
			return sc;
		}
		public static function generateTexAttribute(tex:AbstractTextureData, thickness:Number=1, sc:ShaderConstants=null):ShaderConstants {
			if (sc == null) {
				sc = new ShaderConstants(1);
				sc.values = new Vector.<Number>(4);
			}
			
			var values:Vector.<Number> = sc.values;
			
			values[0] = tex._width;
			values[1] = tex._height;
			values[2] = thickness / tex._width;
			values[3] = thickness / tex._height;
			
			return sc;
		}
		public static function generateThreshold(threshold:Number, sc:ShaderConstants=null):ShaderConstants {
			if (sc == null) {
				sc = new ShaderConstants(1);
				sc.values = new Vector.<Number>(4);
			}
			
			var values:Vector.<Number> = sc.values;
			values[0] = threshold;
			values[1] = threshold * threshold;
			
			return sc;
		}
	}
}