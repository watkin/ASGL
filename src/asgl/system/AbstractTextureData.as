package asgl.system {
	import flash.display.BitmapData;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.TextureBase;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	import asgl.asgl_protected;
	import asgl.materials.TextureAsset;
	import asgl.materials.TextureFormatType;
	
	use namespace asgl_protected;
	
	[Event(name="textureReady", type="flash.events.Event")]

	public class AbstractTextureData extends DeviceData {
		protected static var _referenceDataInfos:Vector.<TextureDataInfo> = new Vector.<TextureDataInfo>(50);
		protected static var _numReferenceDataInfo:int;
		
		protected static var mipmapMatrix:Matrix = new Matrix();
		
		//use to rtt
		public var antiAlias:int;
		public var enableDepthAndStencil:Boolean;
		public var surfaceSelector:int;
		
		asgl_protected var _region:Rectangle;
		
		asgl_protected var _texture:TextureBase;
		asgl_protected var _root:AbstractTextureData;
		
		asgl_protected var _optimizeForRenderToTexture:Boolean;
		asgl_protected var _format:String;
		asgl_protected var _streamingLevels:int;
		
		asgl_protected var _height:int;
		asgl_protected var _width:int;
		
		asgl_protected var _samplerStateData:SamplerStateData;
		
		protected var _mipmap:Array;
		
		public function AbstractTextureData(device:Device3D, format:String, optimizeForRenderToTexture:Boolean, streamingLevels:int) {
			super(device);
			
			_root = this;
			
			_region = new Rectangle(0, 0, 1, 1);
			
			_format = format;
			_optimizeForRenderToTexture = optimizeForRenderToTexture;
			_streamingLevels = streamingLevels;
			
			antiAlias = 0;
			enableDepthAndStencil = false;
			surfaceSelector = 0;
			
			_samplerStateData = new SamplerStateData();
		}
		public function get format():String {
			return _format;
		}
		public function get optimizeForRenderToTexture():Boolean {
			return _optimizeForRenderToTexture;
		}
		public function get height():int {
			return _height;
		}
		public function get region():Rectangle {
			return _region;
		}
		public function get regionHeight():Number {
			return _height * _region.height;
		}
		public function get regionWidth():Number {
			return _width * _region.width;
		}
		public function get samplerStateData():SamplerStateData {
			return _samplerStateData;
		}
		public function get texture():TextureBase {
			return _texture;
		}
		public function get width():int {
			return _width;
		}
		public function active(sampler:int):Boolean {
			return _device._textureManager.setTextureFromData(this, sampler);
		}
		public function createSub(region:Rectangle=null):SubTextureData {
			var tex:SubTextureData = new SubTextureData(_device, _format, _optimizeForRenderToTexture, _streamingLevels, this);
			tex._samplerStateData.copySamplerState(_samplerStateData);
			
			if (region == null) {
				tex._region.x = _region.x;
				tex._region.y = _region.y;
				tex._region.width = _region.width;
				tex._region.height = _region.height;
			} else {
				tex._region.x = _region.x + _region.width * region.x;
				tex._region.y = _region.y + _region.height * region.y;
				tex._region.width = _region.width * region.width;
				tex._region.height = _region.height * region.height;
			}
			
			return tex;
		}
		public function setRenderToThis(colorOutputIndex:int=0):void {
			if (_device != null) {
				_device.setRenderToTextureData(this, enableDepthAndStencil, antiAlias, surfaceSelector, colorOutputIndex);
			}
		}
		public function uploadCompressedTextureFromByteArray(data:ByteArray, byteArrayOffset:uint=0, async:Boolean=false):void {
		}
		public function uploadEmpty(miplevel:uint=0, side:uint=0):void {
			var bytes:ByteArray = new ByteArray();
			if (_format == Context3DTextureFormat.BGRA) {
				bytes.length = _width * _height * 4;
			} else if (_format == Context3DTextureFormat.BGR_PACKED || _format == Context3DTextureFormat.BGRA_PACKED) {
				bytes.length = _width * _height * 2;
			} else if (_format == Context3DTextureFormat.COMPRESSED || _format == Context3DTextureFormat.COMPRESSED_ALPHA) {
				return;
			}
			
			uploadFromByteArray(bytes, 0, miplevel, side);
			
			if (!_device._cacheTextures) bytes.length = 0;
		}
		public function uploadFromBitmapData(source:BitmapData, miplevel:uint=0, side:uint=0):void {
		}
		/**
		 * BGRA8888 or GBAR4444 or BRG556, little endian
		 */
		public function uploadFromByteArray(data:ByteArray, byteArrayOffset:uint=0, miplevel:uint=0, side:uint=0):void {
		}
		public function uploadFromTextureAsset(ta:TextureAsset, async:Boolean=false):Boolean {
			if (ta.type == TextureFormatType.ATF) {
				uploadCompressedTextureFromByteArray(ta.data, 0, async);
			} else if (ta.type == TextureFormatType.BMD) {
				uploadFromBitmapData(ta.data, ta.mipLevel, ta.side);
			} else if (ta.type == TextureFormatType.BGRA8888_BYTES || ta.type == TextureFormatType.GBAR4444_BYTES || ta.type == TextureFormatType.BRG556_BYTES) {
				uploadFromByteArray(ta.data, 0, ta.mipLevel, ta.side);
			} else {
				return false;
			}
			
			return true;
		}
		public function uploadMipmapFromBitmapData(source:BitmapData, side:uint=0):void {
			if (_texture != null) {
				if (_device._context3D.driverInfo == Device3D.DISPOSED) {
					_device._lost();
				}
				
				uploadFromBitmapData(source, 0, side);
				
				var w:int = source.width;
				var h:int = source.height;
				
				if (w > 1 && h > 1) {
					w *= 0.5;
					h *= 0.5;
					
					var miplevel:int = 1;
					var rect:Rectangle = new Rectangle();
					var mipmap:BitmapData = new BitmapData(w, h, true, 0x0);
					
					while (w >= 1 || h >= 1) {
						rect.width = w;
						rect.height = h;
						
						mipmap.fillRect(rect, 0x0);
						
						mipmapMatrix.a = rect.width / source.width;
						mipmapMatrix.d = rect.height / source.height;
						
						mipmap.draw(source, mipmapMatrix, null, null, null, true);
						
						uploadFromBitmapData(mipmap, miplevel++, side);
						
						w *= 0.5;
						h *= 0.5;
						
						rect.width = w > 1? w : 1;
						rect.height = h > 1? h : 1;
					}
					
					if (!_device._cacheTextures) mipmap.dispose();
				}
			}
		}
		protected function _setUsedSize(srcWidth:int, srcHeight:int, miplevel:int, side:int):void {
			include 'TextureData_setUsedSize.define';
		}
		protected function _textureReadyHandler(e:Event):void {
			if (hasEventListener(Event.TEXTURE_READY)) dispatchEvent(e);
		}
	}
}