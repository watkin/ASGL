package asgl.materials {
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import asgl.math.Float2;

	public class TextureHelper {
		private static var _float2:Float2 = new Float2();
		private static var _matrix:Matrix = new Matrix();
		
		public function TextureHelper() {
		}
		public static function convertToPowerOfTow(width:uint, height:uint, toLarger:Boolean=true, op:Float2=null):Float2 {
			var w2:int;
			if ((width & (width - 1)) == 0) {
				w2 = width;
			} else {
				w2 = Math.pow(2, int(Math.log(width) / Math.LN2));
				if (toLarger) w2 *= 2;
			}
			
			var h2:int;
			
			if ((height & (height - 1)) == 0) {
				h2 = height;
			} else {
				h2 = Math.pow(2, int(Math.log(height) / Math.LN2));
				if (toLarger) h2 *= 2;
			}
			
			if (op == null) {
				return new Float2(w2, h2);
			} else {
				op.x = w2;
				op.y = h2;
				
				return op;
			}
		}
		public static function convertBmpToPowerOfTow(bmd:BitmapData, toLarger:Boolean=true, smoothing:Boolean=true):BitmapData {
			var w:int = bmd.width;
			var h:int = bmd.height;
			
			var size:Float2 = convertToPowerOfTow(w, h, toLarger, _float2);
			
			if (w != size.x || h != size.y) {
				var copy:BitmapData = new BitmapData(size.x, size.y, true, 0);
				_matrix.a = size.x / w;
				_matrix.d = size.y / h;
				copy.draw(bmd, _matrix, null, null, null, smoothing);
				return copy;
			} else {
				return bmd.clone();
			}
		}
		public static function convertBmpToBGRA8888Bytes(bmp:BitmapData):ByteArray {
			var src:Vector.<uint> = bmp.getVector(bmp.rect);
			var len:int = src.length;
			var op:ByteArray = new ByteArray();
			op.endian = Endian.LITTLE_ENDIAN;
			op.length = len * 4;
			
			for (var i:int = 0; i < len; i++) {
				var c:uint = src[i];
				op.writeUnsignedInt(c);
			}
			
			return op;
		}
		public static function convertBmpToBGRA4444Bytes(bmp:BitmapData):ByteArray {
			var src:Vector.<uint> = bmp.getVector(bmp.rect);
			var len:int = src.length;
			var op:ByteArray = new ByteArray();
			op.endian = Endian.LITTLE_ENDIAN;
			op.length = len * 2;
			
			for (var i:int = 0; i < len; i++) {
				var c:uint = src[i];
				var a:Number = (c >> 24 & 0xFF) / 255;
				var r:Number = (c >> 16 & 0xFF) / 255;
				var g:Number = (c >> 8 & 0xFF) / 255;
				var b:Number = (c & 0xFF) / 255;
				
				op.writeShort((int(a * 15) << 12) | (int(r * 15) << 8) | (int(g * 15) << 4) | int(b * 15));
			}
			
			return op;
		}
		public static function convertBmpToBGR565Bytes(bmp:BitmapData):ByteArray {
			var src:Vector.<uint> = bmp.getVector(bmp.rect);
			var len:int = src.length;
			var op:ByteArray = new ByteArray();
			op.endian = Endian.LITTLE_ENDIAN;
			op.length = len * 2;
			
			for (var i:int = 0; i < len; i++) {
				var c:uint = src[i];
				var r:Number = (c >> 16 & 0xFF) / 255;
				var g:Number = (c >> 8 & 0xFF) / 255;
				var b:Number = (c & 0xFF) / 255;
				
				op.writeShort((int(r * 31) << 11) | (int(g * 63) << 5) | int(b * 31));
			}
			
			return op;
		}
	}
}