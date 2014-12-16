package asgl.materials {
	public class ColorHelper {
		public function ColorHelper() {
		}
		public static function alphaBlend(newColor:uint, oldColor:uint, f:Number):uint {
			var a1:Number = (newColor >> 24 & 0xFF) / 255;
			var r1:Number = (newColor >> 16 & 0xFF) / 255;
			var g1:Number = (newColor >> 8 & 0xFF) / 255;
			var b1:Number = (newColor & 0xFF) / 255;
			
			var a2:Number = (oldColor >> 24 & 0xFF) / 255;
			var r2:Number = (oldColor >> 16 & 0xFF) / 255;
			var g2:Number = (oldColor >> 8 & 0xFF) / 255;
			var b2:Number = (oldColor & 0xFF) / 255;
			
			var f1:Number = a1;
			var f2:Number = 1 - a1;
			
			a1 *= f;
			r1 *= f;
			g1 *= f;
			b1 *= f;
			
			f = 1 - f;
			
			a1 = a1 * f1 + a2 * f2;
			r1 = r1 * f1 + r2 * f2;
			g1 = g1 * f1 + g2 * f2;
			b1 = b1 * f1 + b2 * f2;
			
			var blendColor:uint = (uint(a1 * 255) << 24) | (uint(r1 * 255) << 16) | (uint(g1 * 255) << 8) | uint(b1 * 255);
			
			return blendColor;
		}
		public static function lerp(c1:uint, c2:uint, f:Number):uint {
			include 'ColorHelper_lerp.define';
			
			return blendColor
		}
		/**
		 * @normal is normalized
		 */
		public static function getRGBFromNormal(nx:Number, ny:Number, nz:Number):uint {
			var c1:uint = (nx * 0.5 + 0.5) * 255;
			var c2:uint = (ny * 0.5 + 0.5) * 255;
			var c3:uint = (nz * 0.5 + 0.5) * 255;
			
			return (c1 << 16) | (c2 << 8) | c3;
		}
	}
}