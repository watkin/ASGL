package asgl.materials {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display3D.Context3DTextureFormat;
	import flash.utils.ByteArray;

	public class TextureAsset {
		public var type:uint;
		public var name:String;
		public var data:*;
		public var width:uint;
		public var height:uint;
		public var mipLevel:uint;
		public var side:uint;
		
		public var dimension:String;
		public var filter:String;
		public var format:String;
		public var mipmap:String;
		public var special:String;
		public var wrap:String;
		
		public function TextureAsset() {
			type = TextureFormatType.UNKNOW;
		}
		public function formatInfo():void {
			if (type == TextureFormatType.UNKNOW) {
				if (data != null) {
					if (data is ByteArray) {
						data.position = 0;
						if (data.readUTFBytes(3) == 'ATF') {
							type = TextureFormatType.ATF
						} else {
							//
						}
					} else if (data is BitmapData) {
						type = TextureFormatType.BMD;
					} else if (data is Bitmap) {
						type = TextureFormatType.BMD;
						data = data.bitmapData;
					}
				}
			}
			
			switch (type) {
				case TextureFormatType.ATF :
					if (data is ByteArray) {
						data.position = 5;
						
						if (data.readUnsignedByte() == 0xFF) {
							data.position = 12;
						} else {
							data.position = 6;
						}
						
						var fmt:uint = data.readUnsignedByte() & 0x7F;
						
						if (fmt == 1) {
							format = Context3DTextureFormat.BGRA;
						} else if (fmt == 3) {
							format = Context3DTextureFormat.COMPRESSED;
						} else if (fmt == 5) {
							format = Context3DTextureFormat.COMPRESSED_ALPHA;
						}
						
						width = Math.pow(2, data[7]);
						height = Math.pow(2, data[8]);
					}
					
					break;
				case TextureFormatType.BMD :
					format = Context3DTextureFormat.BGRA;
					
					if (data is BitmapData) {
						width = data.width;
						height = data.height;
					}
					
					break;
				case TextureFormatType.BGRA8888_BYTES :
					format = Context3DTextureFormat.BGRA;
					
					break;
				case TextureFormatType.GBAR4444_BYTES :
					format = Context3DTextureFormat.BGRA_PACKED;
					
					break;
				case TextureFormatType.BRG556_BYTES :
					format = Context3DTextureFormat.BGR_PACKED;
					
					break;
			}
		}
	}
}