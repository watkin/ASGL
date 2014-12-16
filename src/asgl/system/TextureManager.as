package asgl.system {
	import flash.display3D.textures.TextureBase;
	
	import asgl.asgl_protected;
	import asgl.materials.TextureAsset;
	
	use namespace asgl_protected;
	
	public class TextureManager {
		public static const SAMPLER_MAX:int = 8;
		
		asgl_protected var _textureMap:Object;
		
		private var _device:Device3D;
		private var _statusMap:Vector.<TextureInfo>;
		private var _occupiedStatus:Vector.<TextureInfo>;
		private var _numOccupied:int;
		
		public function TextureManager(device:Device3D) {
			_device = device;
			
			_textureMap = {};
			_statusMap = new Vector.<TextureInfo>(SAMPLER_MAX);
			for (var i:int = 0; i < SAMPLER_MAX; i++) {
				_statusMap[i] = new TextureInfo(i);
			}
			
			_occupiedStatus = new Vector.<TextureInfo>(SAMPLER_MAX);
			_numOccupied = 0;
		}
		public function createCubeTextureData(size:int, format:String, optimizeForRenderToTexture:Boolean, streamingLevels:int=0):CubeTextureData {
			var data:CubeTextureData = new CubeTextureData(_device, size, format, optimizeForRenderToTexture, streamingLevels);
			_textureMap[data._instanceID] = data;
			
			return data;
		}
		public function createCubeTextureDataFromTextureAsset(ta:TextureAsset, optimizeForRenderToTexture:Boolean, streamingLevels:int=0):CubeTextureData {
			return createCubeTextureData(ta.width, ta.format, optimizeForRenderToTexture, streamingLevels);
		}
		public function createRectangleTextureData(width:int, height:int, format:String, optimizeForRenderToTexture:Boolean):RectangleTextureData {
			var data:RectangleTextureData = new RectangleTextureData(_device, width, height, format, optimizeForRenderToTexture);
			_textureMap[data._instanceID] = data;
			
			return data;
		}
		public function createTextureData(width:int, height:int, format:String, optimizeForRenderToTexture:Boolean, streamingLevels:int=0):TextureData {
			var data:TextureData = new TextureData(_device, width, height, format, optimizeForRenderToTexture, streamingLevels);
			_textureMap[data._instanceID] = data;
			
			return data;
		}
		public function createTextureDataFromObject(to:TextureAsset, optimizeForRenderToTexture:Boolean, streamingLevels:int=0):TextureData {
			return createTextureData(to.width, to.height, to.format, optimizeForRenderToTexture, streamingLevels);
		}
		public function deactiveTextures():void {
			if (_numOccupied > 0) {
				var i:int;
				var info:TextureInfo;
				
				if (_device._context3D == null) {
					for (i = 0; i < _numOccupied; i++) {
						info = _occupiedStatus[i];
						info.occupiedIndex = -1;
					}
				} else {
					for (i = 0; i < _numOccupied; i++) {
						info = _occupiedStatus[i];
						_device._context3D.setTextureAt(info.index, null);
						info.occupiedIndex = -1;
						
						_device._debugger._changeTextureStateCount++;
					}
				}
				
				_numOccupied = 0;
			}
		}
		public function deactiveOccupiedTextures():void {
			if (_numOccupied > 0) {
				var i:int;
				var info:TextureInfo;
				var trail:TextureInfo;
				
				if (_device._context3D == null) {
					for (i = _numOccupied - 1; i >= 0; i--) {
						info = _occupiedStatus[i];
						if (info.occupiedValue == 0) {
							_numOccupied--;
							
							if (info.occupiedIndex != _numOccupied) {
								trail = _occupiedStatus[_numOccupied];
								_occupiedStatus[info.occupiedIndex] = trail;
								trail.occupiedIndex = info.occupiedIndex;
							}
							
							info.occupiedIndex = -1;
						}
					}
				} else {
					for (i = _numOccupied - 1; i >= 0; i--) {
						info = _occupiedStatus[i];
						if (info.occupiedValue == 0) {
							_device._context3D.setTextureAt(info.index, null);
							
							_device._debugger._changeTextureStateCount++;
							
							_numOccupied--;
							
							if (info.occupiedIndex != _numOccupied) {
								trail = _occupiedStatus[_numOccupied];
								_occupiedStatus[info.occupiedIndex] = trail;
								trail.occupiedIndex = info.occupiedIndex;
							}
							
							info.occupiedIndex = -1;
						}
					}
				}
			}
		}
		public function disposeTextures():void {
			var num:int = 0;
			var arr:Vector.<uint> = new Vector.<uint>();
			for (var id:int in _textureMap) {
				arr[num++] = id;
			}
			
			for (var i:int = 0; i < num; i++) {
				var data:AbstractTextureData = _textureMap[arr[i]];
				data.dispose();
			}
		}
		public function resetOccupiedState():void {
			for (var i:int = 0; i < _numOccupied; i++) {
				var info:TextureInfo = _occupiedStatus[i];
				info.occupiedValue = 0;
			}
		}
		public function setTextureAt(sampler:int, texture:TextureBase):Boolean {
			if (sampler >= SAMPLER_MAX) return false;
			
			if (texture == null) {
				if (_device._context3D != null) {
					_device._context3D.setTextureAt(sampler, null);
					
					_device._debugger._changeTextureStateCount++;
				}
			} else {
				if (_device._context3D != null) {
					_device._context3D.setTextureAt(sampler, texture);
					
					_device._debugger._changeTextureStateCount++;
				}
			}
			
			return true;
		}
		public function setTextureFromData(data:AbstractTextureData, sampler:int):Boolean {
			if (sampler >= SAMPLER_MAX) return false;
			
			var info:TextureInfo = _statusMap[sampler];
			
			if (data == null) {
				if (info.occupiedIndex != -1) {
					if (_device._context3D != null) {
						_device._context3D.setTextureAt(sampler, null);
						
						_device._debugger._changeTextureStateCount++;
					}
					
					_numOccupied--;
					
					if (info.occupiedIndex != _numOccupied) {
						var trail:TextureInfo = _occupiedStatus[_numOccupied];
						_occupiedStatus[info.occupiedIndex] = trail;
						trail.occupiedIndex = info.occupiedIndex;
					}
					
					info.occupiedIndex = -1;
				}
				
				return true;
			} else {
				var root:AbstractTextureData = data._root;
				
				if (root._valid) {
					if (info.occupiedIndex == -1 || info.instanceID != root._instanceID) {
						if (_device._context3D != null) {
							_device._context3D.setTextureAt(sampler, data._texture);
							
							_device._debugger._changeTextureStateCount++;
						}
						
						info.instanceID = root._instanceID;
						
						if (info.occupiedIndex == -1) {
							info.occupiedIndex = _numOccupied;
							_occupiedStatus[_numOccupied++] = info;
						}
					}
					
					info.occupiedValue = 1;
					
					return true;
				} else {
					return false;
				}
				
			}
		}
		public function setSamplerState(sampler:int, wrap:String, filter:String, mipmap:String):void {
			if (_device._context3D != null) {
				_device._context3D.setSamplerStateAt(sampler, wrap, filter, mipmap);
				
				_device._debugger._changeOtherStateCount++;
			}
		}
		public function setSamplerStateFromData(sampler:int, data:SamplerStateData):void {
			if (_device._context3D != null) {
				var info:TextureInfo = _statusMap[sampler];
				if (info.samplerStateValue != data._samplerStateValue) {
					info.samplerStateValue = data._samplerStateValue;
					
					_device._context3D.setSamplerStateAt(sampler, data._wrap, data._filter, data._mipmap);
					
					_device._debugger._changeOtherStateCount++;
				}
			}
		}
		public function setSamplerStateFromTextureAsset(sampler:int, ta:TextureAsset):void {
			if (_device._context3D != null) {
				_device._context3D.setSamplerStateAt(sampler, ta.wrap, ta.filter, ta.mipmap);
				
				_device._debugger._changeTextureStateCount++;
			}
		}
		asgl_protected function _clearCache():void {
			for each (var data:DeviceData in _textureMap) {
				data._clearCache();
			}
		}
		asgl_protected function _disposeTextureData(data:AbstractTextureData):void {
			delete _textureMap[data._instanceID];
		}
		asgl_protected function _lost():void {
			for each (var data:DeviceData in _textureMap) {
				data._lost();
			}
		}
		asgl_protected function _recovery():void {
			var info:TextureInfo;
			for (var i:int = 0; i < SAMPLER_MAX; i++) {
				info = _statusMap[i];
				info.samplerStateValue = 0xFFFFFFFF;
			}
			
			for each (var data:DeviceData in _textureMap) {
				data._recovery();
			}
			
			for (i = 0; i < _numOccupied; i++) {
				info = _occupiedStatus[i];
				var td:AbstractTextureData = _textureMap[info.instanceID];
				if (td != null) {
					setSamplerStateFromData(info.index, td._samplerStateData);
					setTextureFromData(td, info.index);
				}
			}
		}
	}
}

class TextureInfo {
	public var instanceID:uint;
	public var index:int;
	public var occupiedIndex:int;
	public var occupiedValue:int;
	
	public var samplerStateValue:uint;
	
	public function TextureInfo(index:int) {
		this.index = index;
		occupiedIndex = -1;
		samplerStateValue = 0xFFFFFFFF;
	}
}