package asgl.codec.images {
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public class BMPDecoder {
		private var _image:BitmapData;
		private var _bit:int;
		private var _height:int;
		private var _offset:int;
		private var _width:int;
		
		public function BMPDecoder(bytes:ByteArray=null):void {
			if (bytes == null) {
				clear();
			} else {
				decode(bytes);
			}
		}
		public function get bit():int {
			return _bit;
		}
		public function get bitmapData():BitmapData {
			return _image;
		}
		public function clear():void {
			_bit = 0;
			_image = null;
		}
		public function decode(bytes:ByteArray):void {
			clear();
			
			bytes.endian = Endian.LITTLE_ENDIAN;
			bytes.position = 10;
			_offset = bytes.readUnsignedInt();
			bytes.position = 18;
			_width = bytes.readUnsignedInt();//DWORD
			_height = bytes.readInt();
			var flipV:Boolean = true;
			if (_height<0) {
				_height *= -1;
				flipV = false;
			}
			bytes.position += 2;
			_bit = bytes.readUnsignedShort();//WORD
			var compression:int;
			if (_bit == 1) {
				_read1Bit(bytes);
			} else if (_bit == 4) {
				_read4Bit(bytes);
			} else if (_bit == 8) {
				_read8Bit(bytes);
			} else if (_bit == 16) {
				compression = bytes.readUnsignedInt();
				if (compression == 0) {
					_read16BitBI_RGB(bytes);
				} else if (compression == 3) {
					bytes.position = 54;
					var r:uint = bytes.readUnsignedInt();
					if (r == 0x7C00) {
						_read16BitBI_BITFIELDS555(bytes);
					} else if (r == 0xF800) {
						_read16BitBI_BITFIELDS565(bytes);
					}
				}
			} else if (_bit == 24) {
				_read24Bit(bytes);
			} else if (_bit == 32) {
				compression = bytes.readUnsignedInt();
				if (compression == 0) {
					_read32BitBI_RGB(bytes);
				} else if (compression == 3) {
					throw new Error();
					//_read32BitBI_BITFIELDS(bytes);
				}
			} else {
				throw new Error();
			}
			if (flipV) {
				var temp:BitmapData = _flip(_image);
				_image.dispose();
				_image = temp;
			}
		}
		private function _read1Bit(bytes:ByteArray):void {
			_image = new BitmapData(_width, _height, true, 0xFFFFFFFF);
			
			var pitch:int;
			if (_width % 4 == 0) {
				pitch = _width;
			} else {
				pitch = _width + 24 - _width % 4;
			}
			
			var indexBuffer:ByteArray = new ByteArray();
			bytes.position = _offset;
			bytes.readBytes(indexBuffer);
			var colorBuffer:ByteArray = new ByteArray();
			bytes.position = 54;
			bytes.readBytes(colorBuffer, 0, 8);
			
			for (var h:int = 0; h < _height; h++) {
				var k:int = h * pitch;
				for (var w:int = 0; w < _width; w++) {
					var index:int = k + w;
					var value:int = indexBuffer[index >> 3];
					index = (value >> (7 - index % 8) & (0xF >> 3)) << 2;
					_image.setPixel32(w, h, 0xFF000000 | (colorBuffer[index + 2] << 16) | (colorBuffer[index + 1] << 8) | colorBuffer[index]);
				}
			}
		}
		private function _read4Bit(bytes:ByteArray):void {
			_image = new BitmapData(_width, _height, true, 0xFFFFFFFF);
			
			var pitch:int;
			if (_width % 4 == 0) {
				pitch = _width;
			} else {
				pitch = _width + 8 - _width % 4;
			}
			
			var indexBuffer:ByteArray = new ByteArray();
			bytes.position = _offset;
			bytes.readBytes(indexBuffer);
			var colorBuffer:ByteArray = new ByteArray();
			bytes.position = 54;
			bytes.readBytes(colorBuffer, 0, 64);
			
			for (var h:int = 0; h < _height; h++) {
				var k:int = h * pitch;
				for (var w:int = 0; w < _width; w++) {
					var index:int = k + w;
					var value:int = indexBuffer[index >> 1];
					index = (value >> (4 - (index % 2) * 4) & 0xF) << 2;
					_image.setPixel32(w, h, 0xFF000000 | (colorBuffer[index + 2] << 16) | (colorBuffer[index + 1] << 8) | colorBuffer[index]);
				}
			}
		}
		private function _read8Bit(bytes:ByteArray):void {
			_image = new BitmapData(_width, _height, true, 0xFFFFFFFF);
			
			var pitch:int;
			if (_width % 4 == 0) {
				pitch = _width;
			} else {
				pitch = _width + 4 - _width % 4;
			}
			
			var indexBuffer:ByteArray = new ByteArray();
			bytes.position = _offset;
			bytes.readBytes(indexBuffer);
			var colorBuffer:ByteArray = new ByteArray();
			bytes.position = 54;
			bytes.readBytes(colorBuffer, 0, 1024);
			
			for (var h:int = 0; h < _height; h++) {
				var k:int = h * pitch;
				for (var w:int = 0; w < _width; w++) {
					var index:int = indexBuffer[k+w]<<2;
					_image.setPixel32(w, h, 0xFF000000| (colorBuffer[index + 2] << 16) | (colorBuffer[index + 1] << 8) | colorBuffer[index]);
				}
			}
		}
		private function _read16BitBI_RGB(bytes:ByteArray):void {
			_image = new BitmapData(_width, _height, true, 0xFFFFFFFF);
			
			var pitch:int = _width + _width % 2;
			var buffer:ByteArray = new ByteArray();
			bytes.position = _offset;
			bytes.readBytes(buffer);
			var n:Number = 0xFF / 0x1F;
			
			for (var h:int = 0; h < _height; h++) {
				var k:int = h*pitch;
				for (var w:int = 0; w < _width; w++) {
					var index:int = (k + w) << 1;
					_image.setPixel32(w, h, 0xFF000000 | ((buffer[index + 1] << 1) >> 3) * n << 16 | (((((buffer[index + 1]) << 6) & 0xFF) >> 3) + ((buffer[index]) >> 5)) * n << 8 | (buffer[index] & 0x1F) * n);
				}
			}
		}
		private function _read16BitBI_BITFIELDS555(bytes:ByteArray):void {
			_read16BitBI_RGB(bytes);
		}
		private function _read16BitBI_BITFIELDS565(bytes:ByteArray):void {
			_image = new BitmapData(_width, _height, true, 0xFFFFFFFF);
			
			var pitch:int = _width + _width % 2;
			var buffer:ByteArray = new ByteArray();
			bytes.position = _offset;
			bytes.readBytes(buffer);
			var n:Number = 0xFF / 0x1F;
			
			for (var h:int = 0; h < _height; h++) {
				var k:int = h * pitch;
				for (var w:int = 0; w < _width; w++) {
					var index:int = (k+w)<<1;
					_image.setPixel32(w, h, 0xFF000000 | (buffer[index + 1] >> 3) * n << 16|(((((buffer[index + 1]) << 5) & 0xFF) >> 2) + ((buffer[index]) >> 5)) * (0xFF / 0x3F) << 8 | (buffer[index] & 0x1F) * n);
				}
			}
		}
		private function _read24Bit(bytes:ByteArray):void {
			_image = new BitmapData(_width, _height, true, 0xFFFFFFFF);
			
			var pitch:int = _width % 4;
			var buffer:ByteArray = new ByteArray();
			bytes.position = _offset;
			bytes.readBytes(buffer);
			
			for (var h:int = 0; h < _height; h++) {
				var k1:int = h * _width;
				var k2:int = h * pitch;
				for (var w:int = 0; w < _width; w++) {
					var index:int = (k1 + w) * 3 + k2;
					_image.setPixel32(w, h, 0xFF000000 | buffer[index + 2] << 16 | buffer[index + 1] << 8 | buffer[index]);
				}
			}
		}
		private function _read32BitBI_RGB(bytes:ByteArray):void {
			_image = new BitmapData(_width, _height, true, 0xFFFFFFFF);
			
			var buffer:ByteArray = new ByteArray();
			bytes.position = _offset;
			bytes.readBytes(buffer);
			
			for (var h:int = 0; h < _height; h++) {
				var k:int = h * _width;
				for (var w:int = 0; w < _width; w++) {
					var index:int = (k + w) << 2;
					_image.setPixel32(w, h, 0xFF000000 | buffer[index + 2] << 16 | buffer[index + 1] << 8 | buffer[index]);
				}
			}
		}
		/**private function _read32BitBI_BITFIELDS(bytes:ByteArray):void {
			_bitmapData = new BitmapData(_width, _height, true, 0xFFFFFFFF);
			var buffer:ByteArray = new ByteArray();
			bytes.position = _offset;
			bytes.readBytes(buffer);
			for (var h:int = 0; h<_height; h++) {
				var k:int = h*_width;
				for (var w:int = 0; w<_width; w++) {
					var index:int = (k+w)<<2;
					_bitmapData.setPixel32(w, h, 0xFF000000|buffer[index+2]<<16|buffer[index+1]<<8|buffer[index]);
				}
			}
		}**/
		private function _flip(img:BitmapData):BitmapData {
			var w:int = img.width;
			var h:int = img.height;
			var out:BitmapData = new BitmapData(w, h, true, 0);
			var a:int = 1;
			var d:int = 1;
			var tx:int = 0;
			var ty:int = 0;
			
			d = -1;
			ty = h;
			
			out.draw(img, new Matrix(a, 0, 0, d, tx, ty));
			
			return out;
		}
	}
}