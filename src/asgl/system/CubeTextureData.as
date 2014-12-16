package asgl.system {
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.CubeTexture;
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import asgl.asgl_protected;
	import asgl.events.ASGLEvent;
	import asgl.materials.TextureFormatType;
	
	use namespace asgl_protected;

	public class CubeTextureData extends AbstractTextureData {
		private var _tex:CubeTexture;
		private var _size:int;
		
		private var _referenceData:Array;
		
		public function CubeTextureData(device:Device3D, size:int, format:String, optimizeForRenderToTexture:Boolean, streamingLevels:int) {
			super(device, format, optimizeForRenderToTexture, streamingLevels);
			
			_mipmap = [];
			_referenceData = [];
			
			_size = size;
			_width = _size;
			_height = _size;
			
			var srcWidth:int = _size;
			var srcHeight:int = _size;
			var miplevel:int = 0;
			var side:int = 0;
			
			include 'TextureData_setUsedSize.define';
			
			_device._debugger._usedCubeTextureSize += usedSize;
			
			var context:Context3D = _device._context3D;
			if (context != null) {
				if (context.driverInfo == Device3D.DISPOSED) {
					_device._lost();
				} else {
					_tex = _device._context3D.createCubeTexture(_size, _format, _optimizeForRenderToTexture, _streamingLevels);
					_texture = _tex;
					_tex.addEventListener(Event.TEXTURE_READY, _textureReadyHandler, false, 0, true);
				}
			}
		}
		public override function dispose():void {
			if (_device != null) {
				if (_texture != null) {
					_texture.removeEventListener(Event.TEXTURE_READY, _textureReadyHandler);
					_texture.dispose();
					_texture = null;
				}
				
				for each (var size:int in _mipmap) {
					_device._debugger._usedCubeTextureSize -= size;
				}
				_device._textureManager._disposeTextureData(this);
				_device = null;
				
				_mipmap = null;
				
				for (var level:int in _referenceData) {
					var info:TextureDataInfo = _referenceData[level];
					
					info.data = null;
					_referenceDataInfos[_numReferenceDataInfo++] = info;
				}
				
				_referenceData = null;
				
				_valid = false;
				
				if (hasEventListener(ASGLEvent.DISPOSE)) dispatchEvent(new ASGLEvent(ASGLEvent.DISPOSE));
			}
		}
		public override function uploadCompressedTextureFromByteArray(data:ByteArray, byteArrayOffset:uint=0, async:Boolean=false):void {
			var info:TextureDataInfo = _referenceData[miplevel];
			if (_device._cacheTextures) {
				if (info == null) {
					if (_numReferenceDataInfo == 0) {
						info = new TextureDataInfo();
					} else {
						info = _referenceDataInfos[--_numReferenceDataInfo];
					}
				}
				
				info.type = TextureFormatType.ATF;
				info.data = data;
				info.bytesOffset = byteArrayOffset;
				info.async = async;
				info.side = side;
				
				_referenceData[miplevel] = info;
			} else {
				if (info != null) {
					delete _referenceData[miplevel];
					info.data = null;
					
					_referenceDataInfos[_numReferenceDataInfo++] = info;
				}
			}
			
			if (_tex != null) {
				if (_device._context3D.driverInfo == Device3D.DISPOSED) {
					_device._lost();
				} else {
					_tex.uploadCompressedTextureFromByteArray(data, byteArrayOffset, async);
					_valid = true;
				}
				
				var srcWidth:int = _size;
				var srcHeight:int = _size;
				var miplevel:int = 0;
				var side:int = 0;
				
				include 'TextureData_setUsedSize.define';
				
				_device._debugger._usedCubeTextureSize += usedSize;
			}
		}
		public override function uploadFromBitmapData(source:BitmapData, miplevel:uint=0, side:uint=0):void {
			var info:TextureDataInfo = _referenceData[miplevel];
			if (_device._cacheTextures) {
				if (info == null) {
					if (_numReferenceDataInfo == 0) {
						info = new TextureDataInfo();
					} else {
						info = _referenceDataInfos[--_numReferenceDataInfo];
					}
				}
				
				info.type = TextureFormatType.BMD;
				info.data = source;
				info.side = side;
				
				_referenceData[miplevel] = info;
			} else {
				if (info != null) {
					delete _referenceData[miplevel];
					info.data = null;
					
					_referenceDataInfos[_numReferenceDataInfo++] = info;
				}
			}
			
			if (_tex != null) {
				if (_device._context3D.driverInfo == Device3D.DISPOSED) {
					_device._lost();
				} else {
					_tex.uploadFromBitmapData(source, side, miplevel);
					_valid = true;
				}
				
				var srcWidth:int = _size;
				var srcHeight:int = _size;
				
				include 'TextureData_setUsedSize.define';
				
				_device._debugger._usedCubeTextureSize += usedSize;
			}
		}
		public override function uploadFromByteArray(data:ByteArray, byteArrayOffset:uint=0, miplevel:uint=0, side:uint=0):void {
			var info:TextureDataInfo = _referenceData[miplevel];
			if (_device._cacheTextures) {
				if (info == null) {
					if (_numReferenceDataInfo == 0) {
						info = new TextureDataInfo();
					} else {
						info = _referenceDataInfos[--_numReferenceDataInfo];
					}
				}
				
				info.type = TextureFormatType.BYTES;
				info.data = data;
				info.bytesOffset = byteArrayOffset;
				info.side = side;
				
				_referenceData[miplevel] = info;
			} else {
				if (info != null) {
					delete _referenceData[miplevel];
					info.data = null;
					
					_referenceDataInfos[_numReferenceDataInfo++] = info;
				}
			}
			
			if (_tex != null) {
				if (_device._context3D.driverInfo == Device3D.DISPOSED) {
					_device._lost();
				} else {
					_tex.uploadFromByteArray(data, byteArrayOffset, side, miplevel);
					_valid = true;
				}
				
				var srcWidth:uint = _size;
				var srcHeight:uint = _size;
				
				include 'TextureData_setUsedSize.define';
				
				_device._debugger._usedCubeTextureSize += usedSize;
			}
		}
		asgl_protected override function _clearCache():void {
			if (_referenceData.length > 0) {
				for (var level:int in _referenceData) {
					var info:TextureDataInfo = _referenceData[level];
					
					info.data = null;
					_referenceDataInfos[_numReferenceDataInfo++] = info;
				}
				
				_referenceData.length = 0;
			}
		}
		asgl_protected override function _lost():void {
			_tex.removeEventListener(Event.TEXTURE_READY, _textureReadyHandler);
			_tex = null;
			_texture = null;
			_valid = false;
		}
		asgl_protected override function _recovery():void {
			if (_device._context3D.driverInfo == Device3D.DISPOSED) {
				_device._lost();
			} else {
				_tex = _device._context3D.createCubeTexture(_size, _format, _optimizeForRenderToTexture, _streamingLevels);
				_texture = _tex;
				_tex.addEventListener(Event.TEXTURE_READY, _textureReadyHandler, false, 0, true);
				
				for (var level:* in _referenceData) {
					var info:TextureDataInfo = _referenceData[level];
					if (info.type == TextureFormatType.BYTES) {
						uploadFromByteArray(info.data, info.bytesOffset, level, info.side);
					} else if (info.type == TextureFormatType.BMD) {
						uploadFromBitmapData(info.data, level, info.side);
					} else if (info.type == TextureFormatType.ATF) {
						uploadCompressedTextureFromByteArray(info.data, info.bytesOffset, info.async);
					}
				}
			}
		}
	}
}