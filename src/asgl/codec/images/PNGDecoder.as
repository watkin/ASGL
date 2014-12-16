package asgl.codec.images {
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public class PNGDecoder {
		public static const CHUNK_IHDR:uint = 0x49484452;
		public static const CHUNK_PLTE:uint = 0x504C5445;
		public static const CHUNK_TRNS:uint = 0x74524E53;
		public static const CHUNK_IDAT:uint = 0x49444154;
		public static const COLOR_GRAY:int = 0;
		public static const COLOR_RGB:int = 2;
		public static const COLOR_INDEX_RGB:int = 3;
		public static const COLOR_ALPHA_GRAY:int = 4;
		public static const COLOR_ARGB:int = 6;
		public static const FILTER_NONE:int = 0;
		public static const FILTER_SUB:int = 1;
		public static const FILTER_UP:int = 2;
		public static const FILTER_AVERAGE:int = 3;
		public static const FILTER_PAETH:int = 4;
		
		private var _plteList:Array;
		private var _trnsList:Array;
		private var _image:BitmapData;
		private var _bits:int;
		private var _bitsLength:int;
		private var _bitDepth:int;
		private var _colorType:int;
		private var _compressionMethod:int;
		private var _height:int;
		private var _width:int;
		
		public function PNGDecoder(bytes:ByteArray=null):void {
			if (bytes == null) {
				clear();
			} else {
				decode(bytes);
			}
		}
		public function get bitDepth():int {
			return _bitDepth;
		}
		public function get bitmapData():BitmapData {
			return _image;
		}
		public function get colorType():int {
			return _colorType;
		}
		public function get compressionMethod():int {
			return _compressionMethod;
		}
		public function clear():void {
			_plteList = null;
			_trnsList = null;
			_bitDepth = 0;
			_colorType = 0;
			_compressionMethod = 0;
			_image = null;
		}
		public function decode(bytes:ByteArray):void {
			clear();
			
			bytes.position = 8;
			bytes.endian = Endian.BIG_ENDIAN;
			var data:ByteArray = new ByteArray();
			data.endian = Endian.BIG_ENDIAN;
			var i:int;
			
			while (bytes.bytesAvailable >= 4) {
				var length:uint = bytes.readUnsignedInt();
				var header:uint = bytes.readUnsignedInt();
				var pos:uint = bytes.position;
				
				if (header == CHUNK_IHDR) {
					_width = bytes.readUnsignedInt();
					_height = bytes.readUnsignedInt();
					_image = new BitmapData(_width, _height, true, 0x0);
					_bitDepth = bytes.readUnsignedByte();
					_colorType = bytes.readUnsignedByte();
					_compressionMethod = bytes.readUnsignedByte();
					bytes.readUnsignedByte();
					bytes.readUnsignedByte();
				} else if (header == CHUNK_IDAT) {
					data.writeBytes(bytes, pos, length);
				} else if (header == CHUNK_PLTE) {
					_plteList = [];
					for (i = 0; i < length; i+=3) {
						_plteList[i] = bytes.readUnsignedByte() << 16 | bytes.readUnsignedByte() << 8 | bytes.readUnsignedByte();
					}
				} else if (header == CHUNK_TRNS) {
					_trnsList = [];
					for (i = 0; i < length; i++) {
						_trnsList[i] = bytes.readUnsignedByte() << 24;
					}
				}
				
				bytes.position = pos + length + 4;
			}
			
			data.uncompress();
			
			if (_colorType == COLOR_RGB) {
				if (_bitDepth == 8) {
					_readRGB8(data);
				}
			} else if (_colorType == COLOR_INDEX_RGB) {
				if (_bitDepth == 1) {
					if (_trnsList == null) {
						_readIndexRGB1(data);
					} else {
						_readIndexARGB1(data);
					}
				} else if (_bitDepth == 2) {
					if (_trnsList == null) {
						_readIndexRGB2(data);
					} else {
						_readIndexARGB2(data);
					}
				} else if (_bitDepth == 4) {
					if (_trnsList == null) {
						_readIndexRGB4(data);
					} else {
						_readIndexARGB4(data);
					}
				} else if (_bitDepth == 8) {
					if (_trnsList == null) {
						_readIndexRGB8(data);
					} else {
						_readIndexARGB8(data);
					}
				}
			} else if (_colorType == COLOR_ARGB) {
				if (_bitDepth == 8) {
					_readARGB8(data);
				}
			}
			_plteList = null;
			_trnsList = null;
		}
		private function _readARGB8(bytes:ByteArray):void {
			var x:int;
			var color:uint;
			var pa:int;
			var pr:int;
			var pg:int;
			var pb:int;
			var pa1:int;
			var pr1:int;
			var pg1:int;
			var pb1:int;
			var pa2:int;
			var pr2:int;
			var pg2:int;
			var pb2:int;
			var ca:int;
			var cr:int;
			var cg:int;
			var cb:int;
			
			var alpha:BitmapData = new BitmapData(_image.width, _image.height, false, 0x0);
			
			for (var y:int = 0; y < _height; y++) {
				var filter:int = bytes.readUnsignedByte();
				
				if (filter == FILTER_NONE) {
					for (x = 0; x < _width; x++) {
						pr = bytes.readUnsignedByte();
						pg = bytes.readUnsignedByte();
						pb = bytes.readUnsignedByte();
						alpha.setPixel(x, y, bytes.readUnsignedByte());
						
						_image.setPixel32(x, y, 0xFF000000 | pr << 16 | pg << 8 | pb);
					}
				} else if (filter == FILTER_SUB) {
					pr = bytes.readUnsignedByte();
					pg = bytes.readUnsignedByte();
					pb = bytes.readUnsignedByte();
					pa = bytes.readUnsignedByte();
					
					alpha.setPixel(0, y, pa);
					_image.setPixel32(0, y, 0xFF000000 | pr << 16 | pg << 8 | pb);
					
					for (x = 1; x < _width; x++) {
						cr = pr+bytes.readUnsignedByte() & 0xFF;
						cg = pg+bytes.readUnsignedByte() & 0xFF;
						cb = pb+bytes.readUnsignedByte() & 0xFF;
						ca = pa+bytes.readUnsignedByte() & 0xFF;
						
						alpha.setPixel(x, y, ca);
						_image.setPixel32(x, y, 0xFF000000 | cr << 16 | cg << 8 | cb);
						
						pr = cr;
						pg = cg;
						pb = cb;
						pa = ca;
					}
				} else if (filter == FILTER_UP) {
					for (x = 0; x < _width; x++) {
						color = _image.getPixel32(x, y - 1);
						
						cr = bytes.readUnsignedByte();
						cg = bytes.readUnsignedByte();
						cb = bytes.readUnsignedByte();
						
						alpha.setPixel(x, y, alpha.getPixel(x, y - 1) + bytes.readUnsignedByte() & 0xFF);
						_image.setPixel32(x, y, 0xFF000000 | ((color >> 16 & 0xFF) + cr & 0xFF) << 16 | ((color >> 8 & 0xFF) + cg & 0xFF) << 8 | ((color & 0xFF) + cb & 0xFF));
					}
				} else if (filter == FILTER_AVERAGE) {
					color = _image.getPixel32(0, y - 1);
					
					pr = bytes.readUnsignedByte() + ((color >> 16 & 0xFF) >> 1) & 0xFF;
					pg = bytes.readUnsignedByte() + ((color >> 8 & 0xFF) >> 1) & 0xFF;
					pb = bytes.readUnsignedByte() + ((color & 0xFF) >> 1) & 0xFF;
					pa = bytes.readUnsignedByte() + (alpha.getPixel(0, y - 1) >> 1) & 0xFF;
					
					alpha.setPixel(0, y, pa);
					_image.setPixel32(0, y, 0xFF000000 | pr << 16 | pg << 8 | pb);
					
					for (x = 1; x < _width; x++) {
						color = _image.getPixel32(x, y - 1);
						
						cr = bytes.readUnsignedByte() + (((color >> 16 & 0xFF) + pr) >> 1) & 0xFF;
						cg = bytes.readUnsignedByte() + (((color >> 8 & 0xFF) + pg) >> 1) & 0xFF;
						cb = bytes.readUnsignedByte() + (((color & 0xFF) + pb) >> 1) & 0xFF;
						ca = bytes.readUnsignedByte() + ((alpha.getPixel(x, y - 1) + pa) >> 1) & 0xFF;
						
						alpha.setPixel(x, y, ca);
						_image.setPixel32(x, y, 0xFF000000 | cr << 16 | cg << 8 | cb);
						
						pr = cr;
						pg = cg;
						pb = cb;
						pa = ca;
					}
				} else if (filter == FILTER_PAETH) {
					color = _image.getPixel32(0, y - 1);
					
					pa2 = alpha.getPixel(0, y - 1);
					pr2 = color >> 16 & 0xFF;
					pg2 = color >> 8 & 0xFF;
					pb2 = color & 0xFF;
					
					pr = bytes.readUnsignedByte() + pr2 & 0xFF;
					pg = bytes.readUnsignedByte() + pg2 & 0xFF;
					pb = bytes.readUnsignedByte() + pb2 & 0xFF;
					pa = bytes.readUnsignedByte() + pa2 & 0xFF;
					
					alpha.setPixel(0, y, pa);
					_image.setPixel32(0, y, 0xFF000000 | pr << 16 | pg << 8 | pb);
					
					for (x = 1; x < _width; x++) {
						color = _image.getPixel32(x, y - 1);
						pa1 = alpha.getPixel(x, y - 1);
						
						pr1 = color >> 16 & 0xFF;
						pg1 = color >> 8 & 0xFF;
						pb1 = color & 0xFF;
						
						cr = bytes.readUnsignedByte() + _paethPredictor(pr, pr1, pr2) & 0xFF;
						cg = bytes.readUnsignedByte() + _paethPredictor(pg, pg1, pg2) & 0xFF;
						cb = bytes.readUnsignedByte() + _paethPredictor(pb, pb1, pb2) & 0xFF;
						ca = bytes.readUnsignedByte() + _paethPredictor(pa, pa1, pa2) & 0xFF;
						
						alpha.setPixel(x, y, ca);
						_image.setPixel32(x, y, 0xFF000000 | cr << 16 | cg << 8 | cb);
						
						pa = ca;
						pr = cr;
						pg = cg;
						pb = cb;
						pa2 = pa1;
						pr2 = pr1;
						pg2 = pg1;
						pb2 = pb1;
					}
				} else {
					bytes.position += 4 * _width;
				}
			}
			
			for (x = 0; x < _width; x++){
				for (y = 0; y < _height; y++) {
					_image.setPixel32(x, y, alpha.getPixel(x, y) << 24 | _image.getPixel32(x, y) & 0xFFFFFF);
				}
			}
			
			alpha.dispose();
		}
		private function _readIndexARGB1(bytes:ByteArray):void {
			var x:int;
			var index:int;
			
			for (var y:int = 0; y < _height; y++) {
				var filter:int = bytes.readUnsignedByte();
				_bitsLength = 0;
				
				if (filter == FILTER_NONE) {
					for (x = 0; x < _width; x++) {
						index = _readBits(bytes, 1);
						_image.setPixel32(x, y, _trnsList[index] | _plteList[index]);
					}
				}
			}
		}
		private function _readIndexARGB2(bytes:ByteArray):void {
			var x:int;
			var index:int;
			
			for (var y:int = 0; y < _height; y++) {
				var filter:int = bytes.readUnsignedByte();
				_bitsLength = 0;
				
				if (filter == FILTER_NONE) {
					for (x = 0; x < _width; x++) {
						index = _readBits(bytes, 2);
						_image.setPixel32(x, y, _trnsList[index] | _plteList[index]);
					}
				}
			}
		}
		private function _readIndexARGB4(bytes:ByteArray):void {
			var x:int;
			var index:int;
			
			for (var y:int = 0; y < _height; y++) {
				var filter:int = bytes.readUnsignedByte();
				_bitsLength = 0;
				
				if (filter == FILTER_NONE) {
					for (x = 0; x < _width; x++) {
						index = _readBits(bytes, 4);
						_image.setPixel32(x, y, _trnsList[index] | _plteList[index]);
					}
				}
			}
		}
		private function _readIndexARGB8(bytes:ByteArray):void {
			var x:int;
			var index:int;
			
			for (var y:int = 0; y < _height; y++) {
				var filter:int = bytes.readUnsignedByte();
				
				if (filter == FILTER_NONE) {
					for (x = 0; x < _width; x++) {
						index = bytes.readUnsignedByte();
						_image.setPixel32(x, y, _trnsList[index] | _plteList[index]);
					}
				}
			}
		}
		private function _readIndexRGB1(bytes:ByteArray):void {
			var x:int;
			var index:int;
			
			for (var y:int = 0; y < _height; y++) {
				var filter:int = bytes.readUnsignedByte();
				_bitsLength = 0;
				
				if (filter == FILTER_NONE) {
					for (x = 0; x < _width; x++) {
						index = _readBits(bytes, 1);
						_image.setPixel32(x, y, 0xFF000000 | _plteList[index]);
					}
				}
			}
		}
		private function _readIndexRGB2(bytes:ByteArray):void {
			var x:int;
			var index:int;
			
			for (var y:int = 0; y < _height; y++) {
				var filter:int = bytes.readUnsignedByte();
				_bitsLength = 0;
				
				if (filter == FILTER_NONE) {
					for (x = 0; x < _width; x++) {
						index = _readBits(bytes, 2);
						_image.setPixel32(x, y, 0xFF000000 | _plteList[index]);
					}
				}
			}
		}
		private function _readIndexRGB4(bytes:ByteArray):void {
			var x:int;
			var index:int;
			
			for (var y:int = 0; y < _height; y++) {
				var filter:int = bytes.readUnsignedByte();
				_bitsLength = 0;
				
				if (filter == FILTER_NONE) {
					for (x = 0; x < _width; x++) {
						index = _readBits(bytes, 4);
						_image.setPixel32(x, y, 0xFF000000 | _plteList[index]);
					}
				}
			}
		}
		private function _readIndexRGB8(bytes:ByteArray):void {
			var x:int;
			var index:int;
			
			for (var y:int = 0; y < _height; y++) {
				var filter:int = bytes.readUnsignedByte();
				
				if (filter == FILTER_NONE) {
					for (x = 0; x < _width; x++) {
						index = bytes.readUnsignedByte();
						_image.setPixel32(x, y, 0xFF000000 | _plteList[index]);
					}
				}
			}
		}
		private function _readRGB8(bytes:ByteArray):void {
			var x:int;
			var color:uint;
			var pr:int;
			var pg:int;
			var pb:int;
			var pr1:int;
			var pg1:int;
			var pb1:int;
			var pr2:int;
			var pg2:int;
			var pb2:int;
			var cr:int;
			var cg:int;
			var cb:int;
			
			for (var y:int = 0; y < _height; y++) {
				var filter:int = bytes.readUnsignedByte();
				
				if (filter == FILTER_NONE) {
					for (x = 0; x < _width; x++) {
						_image.setPixel32(x, y, 0xFF000000 | bytes.readUnsignedByte() << 16 | bytes.readUnsignedByte() << 8 | bytes.readUnsignedByte());
					}
				} else if (filter == FILTER_SUB) {
					pr = bytes.readUnsignedByte();
					pg = bytes.readUnsignedByte();
					pb = bytes.readUnsignedByte();
					
					_image.setPixel32(0, y, 0xFF000000 | pr << 16 | pg << 8 | pb);
					
					for (x = 1;  x< _width; x++) {
						cr = pr+bytes.readUnsignedByte() & 0xFF;
						cg = pg+bytes.readUnsignedByte() & 0xFF;
						cb = pb+bytes.readUnsignedByte() & 0xFF;
						
						_image.setPixel32(x, y, 0xFF000000 | cr << 16 | cg << 8 | cb);
						
						pr = cr;
						pg = cg;
						pb = cb;
					}
				} else if (filter == FILTER_UP) {
					for (x = 0; x < _width; x++) {
						color = _image.getPixel32(x, y - 1);
						_image.setPixel32(x, y, 0xFF000000 | ((color >> 16 & 0xFF) + bytes.readUnsignedByte() & 0xFF) << 16 | ((color >> 8 & 0xFF) + bytes.readUnsignedByte() & 0xFF) << 8 | ((color & 0xFF) + bytes.readUnsignedByte() & 0xFF));
					}
				} else if (filter == FILTER_AVERAGE) {
					color = _image.getPixel32(0, y - 1);
					
					pr = bytes.readUnsignedByte() + ((color >> 16 & 0xFF) >> 1) & 0xFF;
					pg = bytes.readUnsignedByte() + ((color >> 8 & 0xFF) >> 1) & 0xFF;
					pb = bytes.readUnsignedByte() + ((color & 0xFF) >> 1) & 0xFF;
					
					_image.setPixel32(0, y, 0xFF000000 | pr << 16 | pg << 8 | pb);
					
					for (x = 1; x < _width; x++) {
						color = _image.getPixel32(x, y - 1);
						
						cr = bytes.readUnsignedByte() + (((color >> 16 & 0xFF) + pr) >> 1) & 0xFF;
						cg = bytes.readUnsignedByte() + (((color >> 8 & 0xFF) + pg) >> 1) & 0xFF;
						cb = bytes.readUnsignedByte() + (((color & 0xFF) + pb) >> 1) & 0xFF;
						
						_image.setPixel32(x, y, 0xFF000000 | cr << 16 | cg << 8 | cb);
						
						pr = cr;
						pg = cg;
						pb = cb;
					}
				} else if (filter == FILTER_PAETH) {
					color = _image.getPixel32(0, y - 1);
					
					pr2 = color >> 16 & 0xFF;
					pg2 = color >> 8 & 0xFF;
					pb2 = color & 0xFF;
					
					pr = bytes.readUnsignedByte() + pr2 & 0xFF;
					pg = bytes.readUnsignedByte() + pg2 & 0xFF;
					pb = bytes.readUnsignedByte() + pb2 & 0xFF;
					
					_image.setPixel32(0, y, 0xFF000000 | pr << 16 | pg << 8 | pb);
					
					for (x = 1; x < _width; x++) {
						color = _image.getPixel32(x, y-1);
						
						pr1 = color >> 16 & 0xFF;
						pg1 = color >> 8 & 0xFF;
						pb1 = color & 0xFF;
						
						cr = bytes.readUnsignedByte() + _paethPredictor(pr, pr1, pr2) & 0xFF;
						cg = bytes.readUnsignedByte() + _paethPredictor(pg, pg1, pg2) & 0xFF;
						cb = bytes.readUnsignedByte() + _paethPredictor(pb, pb1, pb2) & 0xFF;
						
						_image.setPixel32(x, y, 0xFF000000 | cr << 16 | cg << 8 | cb);
						
						pr = cr;
						pg = cg;
						pb = cb;
						pr2 = pr1;
						pg2 = pg1;
						pb2 = pb1;
					}
				} else {
					bytes.position += 3 * _width;
				}
			}
		}
		//tool function
		/**
		 * c0 = left, c1 = above, c2 = upper left.
		 */
		private function _paethPredictor(c0:int, c1:int, c2:int):int {
			var pa:int = c1 - c2;
    		var pb:int = c0 - c2;
    		var pc:int = pa + pb;
			
    		if (pa < 0) pa = -pa;
    		if (pb < 0) pb = -pb;
    		if (pc < 0) pc = -pc;
			
    		if (pa <= pb && pa <= pc) {
    			return c0;
    		} else if (pb <= pc) {
    			return c1;
    		} else {
    			return c2;
    		}
		}
		private function _readBits(bytes:ByteArray, length:int):int {
			if (_bitsLength == 0) {
				_bits = bytes.readUnsignedByte();
				_bitsLength = 8 - length;
				return _bits>>_bitsLength & ((2 << (length - 1)) - 1);
			} else if (_bitsLength >= length) {
				_bitsLength -= length;
				return _bits>>_bitsLength & ((2 << (length - 1)) - 1);
			} else {
				var temp:int = _bits;
				_bits = bytes.readUnsignedByte();
				var l:int = length - _bitsLength;
				var out:int = temp & ((2 << (l - 1)) - 1) << _bitsLength | _bits >> (8 - l) & ((2 << (l - 1)) - 1);
				_bitsLength = 8 - l;
				return out;
			}
		}
	}
}