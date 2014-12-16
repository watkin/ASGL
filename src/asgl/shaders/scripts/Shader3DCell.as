package asgl.shaders.scripts {
	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import asgl.asgl_protected;
	import asgl.events.ASGLEvent;
	import asgl.shaders.asm.agal.compiler.AGALSamplerFlag;
	import asgl.system.AbstractTextureData;
	import asgl.system.ProgramData;
	
	use namespace asgl_protected;
	
	public class Shader3DCell {
		private static var _idMap:Object = {};
		private static var _idManager:uint = 0;
		
		asgl_protected var _buffers:Object;
		asgl_protected var _textures:Object;
		asgl_protected var _vertexConstants:Object;
		asgl_protected var _fragmentConstants:Object;
		asgl_protected var _constants:Object;
		
		asgl_protected var _sourceID:String;
		asgl_protected var _mask:uint;
		
		asgl_protected var _vertexAsset:ByteArray;
		asgl_protected var _fragmentAsset:ByteArray;
		
		asgl_protected var _shader:Shader3D
		asgl_protected var _programs:Object;
		
		public function Shader3DCell(shader:Shader3D, bytes:ByteArray) {
			_shader = shader;
			_programs = {};
			
			_vertexAsset = new ByteArray();
			_vertexAsset.endian = Endian.LITTLE_ENDIAN;
			_fragmentAsset = new ByteArray();
			_fragmentAsset.endian = Endian.LITTLE_ENDIAN;
			
			_buffers = {};
			_textures = {};
			_vertexConstants = {};
			_fragmentConstants = {};
			_constants = {};
			
			_mask = bytes.readUnsignedInt();
			
			var name:String;
			
			var num:int = bytes.readUnsignedByte();
			while (num-- > 0) {
				_buffers[bytes.readUTF()] = new ShaderBuffer(bytes.readUTF(), bytes.readUnsignedByte());
			}
			
			num = bytes.readUnsignedByte();
			while (num-- > 0) {
				_vertexConstants[bytes.readUTF()] = bytes.readUnsignedByte();
			}
			
			var desc:String;
			
			num = bytes.readUnsignedByte();
			while (num-- > 0) {
				name = bytes.readUTF();
				desc = bytes.readUTF();
				var sampler:int = bytes.readUnsignedByte();
				//var samplerState:int = bytes.readUnsignedInt();
				var count:int = bytes.readUnsignedByte();
				var pos:Vector.<int> = new Vector.<int>(count);
				for (var j:int = 0; j < count; j++) {
					pos[j] = bytes.readUnsignedShort();
				}
				
				_textures[name] = new ShaderTexture(desc, sampler, pos);
			}
			
			num = bytes.readUnsignedByte();
			while (num-- > 0) {
				_fragmentConstants[bytes.readUTF()] = bytes.readUnsignedByte();
			}
			
			num = bytes.readUnsignedByte();
			while (num-- > 0) {
				name = bytes.readUTF();
				desc = bytes.readUTF();
				var sc:ShaderConstants = new ShaderConstants(bytes.readUnsignedByte());
				sc._name = desc;
				_constants[name] = sc;
				
				if (bytes.readBoolean()) {
					var max:int = sc._length * 4;
					
					sc.values = new Vector.<Number>(max);
					
					for (var i:int = 0; i < max; i++) {
						sc.values[i] = bytes.readFloat();
					}
				}
			}
			
			_vertexAsset.length = 0;
			_fragmentAsset.length = 0;
			
			var len:int = bytes.readUnsignedShort();
			if (len != 0) {
				bytes.readBytes(_vertexAsset, 0, len);
			}
			
			len = bytes.readUnsignedShort();
			if (len != 0) {
				bytes.readBytes(_fragmentAsset, 0, len);
			}
			
			_sourceID = bytes.readUTF();
		}
		public function changeTextureFormat(texs:Object):void {
			for (var name:String in _textures) {
				var st:ShaderTexture = _textures[name];
				var formatValue:int = 0;
				if (texs != null) {
					var tex:AbstractTextureData = texs[name];
					formatValue = tex == null ? 0 : AGALSamplerFlag.FORMAT[tex._format];
				}
				
				var len:int = st._samplersPosition.length;
				for (var i:int = 0; i < len; i++) {
					_fragmentAsset.position = st._samplersPosition[i] + 5;
					var old:int = _fragmentAsset.readUnsignedByte();
					_fragmentAsset.position--;
					_fragmentAsset.writeByte((old & 0xF0) | formatValue);
				}
			}
		}
		public function getShaderProgram(texs:Object):ProgramData {
			var id:uint = getTexturesID(texs);
			
			var p:ProgramData = _programs[id];
			if (p == null) {
				changeTextureFormat(texs);
				
				var vert:ByteArray = _vertexAsset;
				var frag:ByteArray = _fragmentAsset;
				if (_shader._device._cachePrograms) {
					vert = new ByteArray();
					vert.endian = Endian.LITTLE_ENDIAN;
					vert.writeBytes(_vertexAsset);
					frag = new ByteArray();
					frag.endian = Endian.LITTLE_ENDIAN;
					frag.writeBytes(_fragmentAsset);
				}
				
				p = _shader._device._programManager.createProgramData();
				p._cell = this;
				p.uploadFromByteArray(vert, frag);
				_programs[id] = p;
				p.id = _applyID(id);
				
				Shader3D._shaderPrograms[p.id] = p;
				
				p.addEventListener(ASGLEvent.DISPOSE, _disposeProgramDataHandler, false, 0, true);
			}
			
			return p;
		}
		public function getTexturesID(texs:Object):uint {
			var id:uint = 0;
			
			if (texs != null) {
				for (var name:String in _textures) {
					var st:ShaderTexture = _textures[name];
					var tex:AbstractTextureData = texs[name];
					if (tex != null) {
						var flag:int = AGALSamplerFlag.FORMAT[tex._format];
						id = id | (flag << st._index);
					}
				}
			}
			
			return id;
		}
		asgl_protected function _dispose():void {
			if (_shader != null) {
				_shader = null;
				
				for each (var p:ProgramData in _programs) {
					p.removeEventListener(ASGLEvent.DISPOSE, _disposeProgramDataHandler);
					p.dispose();
					
					delete Shader3D._shaderPrograms[p.id];
				}
				
				_programs = null;
			}
		}
		asgl_protected function _applyID(texturesID:uint):uint {
			var key:String = _sourceID + texturesID;
			if (key in _idMap) {
				return _idMap[key];
			} else {
				var id:uint = ++_idManager;
				_idMap[key] = id;
				
				return id;
			}
		}
		private function _disposeProgramDataHandler(e:Event):void {
			var p:ProgramData = e.currentTarget as ProgramData;
			p.removeEventListener(ASGLEvent.DISPOSE, _disposeProgramDataHandler);
			
			delete _programs[p.id];
			delete Shader3D._shaderPrograms[p.id];
			
			_shader._disposeShaderProgram();
		}
	}
}