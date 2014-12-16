package asgl.system {
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.RectangleTexture;
	import flash.utils.ByteArray;
	
	import asgl.asgl_protected;
	import asgl.events.ASGLEvent;
	import asgl.materials.TextureFormatType;
	
	use namespace asgl_protected;

	public class RectangleTextureData extends AbstractTextureData {
		private var _referenceData:TextureDataInfo;
		
		private var _tex:RectangleTexture;
		
		public function RectangleTextureData(device:Device3D, width:int, height:int, format:String, optimizeForRenderToTexture:Boolean) {
			super(device, format, optimizeForRenderToTexture, 0);
			
			_mipmap = [];
			
			_width = width;
			_height = height;
			
			var srcWidth:int = _width;
			var srcHeight:int = _height;
			var miplevel:int = 0;
			var side:int = 0;
			
			include 'TextureData_setUsedSize.define';
			
			_device._debugger._usedTextureSize += usedSize;
			
			var context:Context3D = _device._context3D;
			if (context != null) {
				if (context.driverInfo == Device3D.DISPOSED) {
					_device._lost();
				} else {
					_tex = _device._context3D.createRectangleTexture(_width, _height, _format, _optimizeForRenderToTexture);
					_texture = _tex;
				}
			}
		}
		public override function dispose():void {
			if (_device != null) {
				if (_tex != null) {
					_tex.dispose();
					_tex = null;
					_texture = null;
				}
				
				for each (var size:int in _mipmap) {
					_device._debugger._usedTextureSize -= size;
				}
				_device._textureManager._disposeTextureData(this);
				_device = null;
				
				_mipmap = null;
				
				if (_referenceData != null) {
					_referenceData.data = null;
					_referenceDataInfos[_numReferenceDataInfo++] = _referenceData;
					
					_referenceData = null;
				}
				
				_valid = false;
				
				if (hasEventListener(ASGLEvent.DISPOSE)) dispatchEvent(new ASGLEvent(ASGLEvent.DISPOSE));
			}
		}
		public override function uploadFromBitmapData(source:BitmapData, miplevel:uint=0, side:uint=0):void {
			miplevel = 0;
			
			if (_device._cacheTextures) {
				if (_referenceData == null) {
					if (_numReferenceDataInfo == 0) {
						_referenceData = new TextureDataInfo();
					} else {
						_referenceData = _referenceDataInfos[--_numReferenceDataInfo];
					}
				}
				
				_referenceData.type = TextureFormatType.BMD;
				_referenceData.data = source;
			} else {
				if (_referenceData != null) {
					_referenceData.data = null;
					
					_referenceDataInfos[_numReferenceDataInfo++] = _referenceData;
					_referenceData = null;
				}
			}
			
			if (_tex != null) {
				if (_device._context3D.driverInfo == Device3D.DISPOSED) {
					_device._lost();
				} else {
					_tex.uploadFromBitmapData(source);
					_valid = true;
				}
				
				var srcWidth:int = _width;
				var srcHeight:int = _height;
				
				include 'TextureData_setUsedSize.define';
				
				_device._debugger._usedTextureSize += usedSize;
			}
		}
		public override function uploadFromByteArray(data:ByteArray, byteArrayOffset:uint=0, miplevel:uint=0, side:uint=0):void {
			miplevel = 0;
			
			if (_device._cacheTextures) {
				if (_referenceData == null) {
					if (_numReferenceDataInfo == 0) {
						_referenceData = new TextureDataInfo();
					} else {
						_referenceData = _referenceDataInfos[--_numReferenceDataInfo];
					}
				}
				
				_referenceData.type = TextureFormatType.BYTES;
				_referenceData.data = data;
				_referenceData.bytesOffset = byteArrayOffset;
			} else {
				if (_referenceData != null) {
					_referenceData.data = null;
					
					_referenceDataInfos[_numReferenceDataInfo++] = _referenceData;
					_referenceData = null;
				}
			}
			
			if (_tex != null) {
				if (_device._context3D.driverInfo == Device3D.DISPOSED) {
					_device._lost();
				} else {
					_tex.uploadFromByteArray(data, byteArrayOffset);
					_valid = true;
				}
				
				var srcWidth:int = _width;
				var srcHeight:int = _height;
				
				include 'TextureData_setUsedSize.define';
				
				_device._debugger._usedTextureSize += usedSize;
			}
		}
		public override function uploadMipmapFromBitmapData(source:BitmapData, side:uint=0):void {
		}
		asgl_protected override function _clearCache():void {
			if (_referenceData != null) {
				_referenceData.data = null;
				_referenceDataInfos[_numReferenceDataInfo++] = _referenceData;
				
				_referenceData = null;
			}
		}
		asgl_protected override function _lost():void {
			_tex = null;
			_texture = null;
			_valid = false;
		}
		asgl_protected override function _recovery():void {
			if (_device._context3D.driverInfo == Device3D.DISPOSED) {
				_device._lost();
			} else {
				_tex = _device._context3D.createRectangleTexture(_width, _height, _format, _optimizeForRenderToTexture);
				_texture = _tex;
				
				if (_referenceData != null) {
					if (_referenceData.type == TextureFormatType.BYTES) {
						uploadFromByteArray(_referenceData.data, _referenceData.bytesOffset, 0, 0);
					} else if (_referenceData.type == TextureFormatType.BMD) {
						uploadFromBitmapData(_referenceData.data, 0, 0);
					}
				}
			}
		}
	}
}