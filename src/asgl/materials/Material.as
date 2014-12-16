package asgl.materials {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import asgl.asgl_protected;
	import asgl.events.ASGLEvent;
	import asgl.shaders.scripts.Shader3D;
	import asgl.shaders.scripts.Shader3DCell;
	import asgl.shaders.scripts.ShaderConstants;
	import asgl.shaders.scripts.ShaderConstantsCollection;
	import asgl.system.AbstractTextureData;
	import asgl.system.ProgramData;
	
	use namespace asgl_protected;
	
	[Event(name="updateShaderProgram", type="asgl.events.ASGLEvent")]

	public class Material extends EventDispatcher {
		private static var _instanceIDAccumulator:uint = 0;
		
		public var name:String;
		
		asgl_protected var _instanceID:uint;
		
		asgl_protected var _shader:Shader3D;
		asgl_protected var _shaderCell:Shader3DCell;
		
		asgl_protected var _constants:Object;
		asgl_protected var _define:Object;
		asgl_protected var _defineChangeCount:uint;
		asgl_protected var _textures:Object;
		asgl_protected var _numTextures:int;
		
		asgl_protected var _updateCount:uint;
		asgl_protected var _currentUpdateCount:uint;
		asgl_protected var _shaderProgram:ProgramData;
		
		public function Material() {
			_instanceID = ++_instanceIDAccumulator;
			
			_textures = {};
			_define = {};
			_constants = {};
			_updateCount = 1;
		}
		public function get instanceID():uint {
			return _instanceID;
		}
		public function get shader():Shader3D {
			return _shader;
		}
		public function set shader(value:Shader3D):void {
			if (_shader != null) {
				_shader.removeEventListener(ASGLEvent.UPLOAD, _uploadShaderHandler);
				_shader.removeEventListener(ASGLEvent.DISPOSE, _disposeShaderHandelr);
				_shader.removeEventListener(ASGLEvent.DISPOSE_SHADER_PROGRAM, _disposeShaderProgramHandler);
				
				_shaderCell = null;
				
				if (_shaderProgram != null) {
					_shaderProgram = null;
					
					if (hasEventListener(ASGLEvent.UPDATE_SHADER_PROGRAM)) dispatchEvent(new ASGLEvent(ASGLEvent.UPDATE_SHADER_PROGRAM));
				}
			}
			
			_shader = value;
			
			if (_shader != null) {
				_shader.addEventListener(ASGLEvent.UPLOAD, _uploadShaderHandler, false, 0, true);
				_shader.addEventListener(ASGLEvent.DISPOSE, _disposeShaderHandelr, false, 0, true);
				_shader.addEventListener(ASGLEvent.DISPOSE_SHADER_PROGRAM, _disposeShaderProgramHandler, false, 0, true);
			}
			
			_uploadShaderHandler(null);
		}
		public function get shaderProgram():ProgramData {
			updateShaderProgram();
			
			return _shaderProgram;
		}
		public function clearAll():void {
			shader = null;
			clearConstants();
			clearDefine();
			clearTextures();
		}
		public function clearConstants():void {
			for (var key:* in _constants) {
				_constants = {};
				break;
			}
		}
		public function clearDefine():void {
			for (var key:* in _define) {
				_defineChangeCount = 0;
				_define = {};
				break;
			}
		}
		public function clearTextures():void {
			if (_numTextures > 0) {
				for each (var tex:AbstractTextureData in _textures) {
					tex.removeEventListener(ASGLEvent.DISPOSE, _disposeTexHandler);
				}
				
				_textures = {};
				_numTextures = 0;
				
				_updateCount++;
			}
		}
		public function setConstants(name:String, value:ShaderConstants):void {
			if (value == null) {
				delete _constants[name];
			} else {
				_constants[name] = value;
			}
		}
		public function setConstantsCollection(c:ShaderConstantsCollection, clearOld:Boolean=true):void {
			if (clearOld) clearConstants();
			
			var map:Object = c._constants;
			if (map != null) {
				for (var name:String in map) {
					setConstants(name, map[name]);
				}
			}
		}
		public function setDefine(name:String, value:*):void {
			if (value == null) {
				if (name in _define) {
					delete _define[name];
					
					_defineChangeCount = 0;
				}
			} else {
				if (value != _define[name]) {
					_define[name] = value;
					
					_defineChangeCount = 0;
				}
			}
		}
		public function getTexture(name:String):AbstractTextureData {
			return _textures[name];
		}
		public function setTexture(name:String, tex:AbstractTextureData):void {
			var old:AbstractTextureData = _textures[name];
			if (old != null) old.removeEventListener(ASGLEvent.DISPOSE, _disposeTexHandler);
			
			if (tex == null) {
				if (old != null) {
					delete _textures[name];
					
					_numTextures--;
					
					_updateCount++;
				}
			} else {
				_textures[name] = tex;
				
				if (old == null) {
					_numTextures++;
					
					_updateCount++;
				} else if (old._format != tex._format) {
					_updateCount++;
				}
				
				tex.addEventListener(ASGLEvent.DISPOSE, _disposeTexHandler, false, 0, true);
			}
		}
		public function updateShaderProgram(mp:MaterialProperty=null):void {
			var cell:Shader3DCell;
			
			if (mp == null) {
				if (_shader != null) {
					if (_defineChangeCount != Shader3D._globalDefineChangeCount) {
						_defineChangeCount = Shader3D._globalDefineChangeCount;
						
						cell = _shader.getShaderCell(_define, null);
						
						if (_shaderCell != cell) {
							_shaderCell = cell;
							_currentUpdateCount = 0;
						}
					}
					
					if (_currentUpdateCount != _updateCount) {
						_currentUpdateCount = _updateCount;
						
						if (_shaderCell == null) {
							if (_shaderProgram != null) {
								_shaderProgram = null;
								
								if (hasEventListener(ASGLEvent.UPDATE_SHADER_PROGRAM)) dispatchEvent(new ASGLEvent(ASGLEvent.UPDATE_SHADER_PROGRAM));
							}
						} else {
							_shaderProgram = _shaderCell.getShaderProgram(_textures);
							
							if (hasEventListener(ASGLEvent.UPDATE_SHADER_PROGRAM)) dispatchEvent(new ASGLEvent(ASGLEvent.UPDATE_SHADER_PROGRAM));
						}
					}
				}
			} else {
				if (_shader == null) {
					mp._setShaderID(0);
				} else {
					if (mp._shaderID != _shader._instanceID) mp._setShaderID(_shader._instanceID);
					
					if (mp._defineChangeCount != Shader3D._globalDefineChangeCount) {
						mp._defineChangeCount = Shader3D._globalDefineChangeCount;
						
						cell = _shader.getShaderCell(mp._define, null);
						
						if (cell == null) {
							if (mp._shaderCellMask != -1) {
								mp._shaderCellMask = -1;
								mp._currentUpdateCount = 0;
							}
						} else if (mp._shaderCellMask != cell._mask) {
							mp._shaderCellMask = cell._mask;
							mp._currentUpdateCount = 0;
						}
					}
					
					if (mp._currentUpdateCount != _updateCount) {
						mp._currentUpdateCount = _updateCount;
						
						if (mp._shaderCellMask == -1) {
							mp._shaderProgramID = 0;
						} else {
							cell = _shader._shaders[mp._shaderCellMask];
							var sp:ProgramData = cell.getShaderProgram(_textures);
							mp._shaderProgramID = sp == null ? 0 : sp.id;
						}
					}
				}
			}
		}
		private function _uploadShaderHandler(e:Event):void {
			_updateCount++;
			_defineChangeCount = 0;
			_shaderCell = null;
			
			if (_shaderProgram != null) {
				_shaderProgram = null;
				if (hasEventListener(ASGLEvent.UPDATE_SHADER_PROGRAM)) dispatchEvent(new ASGLEvent(ASGLEvent.UPDATE_SHADER_PROGRAM));
			}
		}
		private function _disposeShaderHandelr(e:Event):void {
			this.shader = null;
		}
		private function _disposeShaderProgramHandler(e:Event):void {
			if (_shaderProgram != null && !_shaderProgram._valid) {
				_updateCount++;
				_shaderProgram = null;
				
				if (hasEventListener(ASGLEvent.UPDATE_SHADER_PROGRAM)) dispatchEvent(new ASGLEvent(ASGLEvent.UPDATE_SHADER_PROGRAM));
			}
		}
		private function _disposeTexHandler(e:Event):void {
			var tex:* = e.currentTarget;
			
			for (var name:String in _textures) {
				if (_textures[name] == tex) {
					setTexture(name, null);
					break;
				}
			}
		}
	}
}