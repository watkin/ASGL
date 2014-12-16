package asgl.materials {
	import flash.display.BitmapData;
	import flash.display3D.Context3DTextureFilter;
	import flash.display3D.Context3DWrapMode;
	import flash.utils.ByteArray;

	public class SoftTexture {
		private var _height:uint;
		private var _width:uint;
		private var _width1:uint;
		private var _source:Vector.<uint>;
		public function SoftTexture() {
		}
		public function get colors():Vector.<uint> {
			return _source;
		}
		public function get height():uint {
			return _height;
		}
		public function get width():uint {
			return _width;
		}
		public function clear():void {
			if (_source != null) {
				_source = null;
				
				_width = 0;
				_height = 0;
			}
		}
		public function getNormalsFromTexCoordsAndRGBChannels(texCoords:Vector.<Number>, filter:String, wrap:String, op:Vector.<Number>=null):Vector.<Number> {
			if (_source == null) throw new Error('source is null');
			
			var length:uint = texCoords.length;
			
			var max:uint = length * 3;
			
			if (op == null) {
				op = new Vector.<Number>(max);
			} else if (op.length != max) {
				if (op.fixed) {
					if (op.length < max) return null;
				} else {
					op.length = max;
				}
			}
			
			var index:uint = 0;
			
			for (var i:uint = 0; i<length;) {
				var x:Number = texCoords[i++];
				var y:Number = texCoords[i++];
				
				include 'SoftTexture_getPixel32.define';
				
				op[index++] = ((color >> 16 & 0xFF) / 255 - 0.5) * 2;
				op[index++] = ((color >> 8 & 0xFF) / 255 - 0.5) * 2;
				op[index++] = ((color & 0xFF) / 255 - 0.5) * 2;
			}
			
			return op;
		}
		public function getPixel32(x:Number, y:Number, filter:String, wrap:String):uint {
			if (_source == null) throw new Error('source is null');
			
			include 'SoftTexture_getPixel32.define';
			
			return color;
		}
		public function getPixels32FromTexCoord(texCoords:Vector.<Number>, filter:String, wrap:String, op:Vector.<uint>=null):Vector.<uint> {
			if (_source == null) throw new Error('source is null');
			
			var length:uint = texCoords.length;
			
			var max:uint = length * 0.5;
			
			if (op == null) {
				op = new Vector.<uint>(length);
			} else if (op.length != max) {
				if (op.fixed) {
					if (op.length < max) return null;
				} else {
					op.length = max;
				}
			}
			
			var pos:uint = 0;
			
			for (var i:uint = 0; i<length;) {
				var x:Number = texCoords[i++];
				var y:Number = texCoords[i++];
				
				include 'SoftTexture_getPixel32.define';
				
				op[pos++] = color;
			}
			
			return op;
		}
		public function uploadFromBitmapData(source:BitmapData):void {
			_source = source.getVector(source.rect);
			
			_width = source.width;
			_width1 = _width - 1;
			_height = source.height - 1;
		}
		/**
		 * @param source source.readUnsignedInt() = ARGB
		 */
		public function uploadFromByteArray(source:ByteArray, width:uint, height:uint):void {
			var len:uint = source.length * 0.25;
			
			if (_source == null) {
				_source = new Vector.<uint>(len);
			} else {
				_source.length = len;
			}
			
			source.position = 0;
			
			for (var i:uint = 0; i < len; i++) {
				_source[i] = source.readUnsignedInt();
			}
			
			_width = width;
			_width1 = _width - 1;
			_height = height - 1;
		}
	}
}