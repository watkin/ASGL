package asgl.shaders.scripts {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import asgl.asgl_protected;
	import asgl.events.ASGLEvent;
	import asgl.system.AbstractTextureData;
	import asgl.system.Device3D;
	
	use namespace asgl_protected;
	
	[Event(name="dispose", type="asgl.events.ASGLEvent")]
	[Event(name="disposeShaderProgram", type="asgl.events.ASGLEvent")]
	[Event(name="upload", type="asgl.events.ASGLEvent")]
	
	public class Shader3D extends EventDispatcher {
		public static const NULL_MASK:Number = 0x1FFFFFFFF;
		
		asgl_protected static var _shaderPrograms:Object = {};
		
		private static var _instanceIDAccumulator:uint = 0;
		
		asgl_protected static var _globalConstants:Object = {};
		asgl_protected static var _globalTextures:Object = {};
		asgl_protected static var _globalDefine:Object = {};
		asgl_protected static var _globalDefineChangeCount:uint = 1;
		
		//read only
		public var define:Object;
		//
		
		asgl_protected var _instanceID:uint;
		
		asgl_protected var _device:Device3D;
		
		asgl_protected var _shaders:Object;
		asgl_protected var _shaderMask:Number;
		asgl_protected var _shaderCell:Shader3DCell;
		
		asgl_protected var _name:String;
		
		public function Shader3D(device:Device3D) {
			_instanceID = ++_instanceIDAccumulator;
			
			define = {};
			_shaders = {};
			_shaderMask = NULL_MASK;
			
			_device = device;
		}
		public static function setGlobalConstants(name:String, values:ShaderConstants):void {
			if (values == null) {
				delete _globalConstants[name];
			} else {
				_globalConstants[name] = values;
			}
		}
		public static function setGlobalDefine(name:String, value:*):void {
			if (value == null) {
				if (name in _globalDefine) {
					delete _globalDefine[name];
					
					_globalDefineChangeCount++;
				}
			} else {
				if (value != _globalDefine[name]) {
					_globalDefine[name] = value;
					
					_globalDefineChangeCount++;
				}
			}
		}
		public static function setGlobalTexture(name:String, tex:AbstractTextureData):void {
			var old:AbstractTextureData = _globalTextures[name];
			if (old != null) old.removeEventListener(ASGLEvent.DISPOSE, _disposeTexHandler);
			
			if (tex == null) {
				if (old != null) {
					delete _globalTextures[name];
				}
			} else {
				_globalTextures[name] = tex;
				
				tex.addEventListener(ASGLEvent.DISPOSE, _disposeTexHandler, false, 0, true);
			}
		}
		asgl_protected static function _createIndexConstants(head:String, max:uint):Vector.<String> {
			var vec:Vector.<String> = new Vector.<String>(max);
			
			for (var i:int = 0; i < max; i++) {
				vec[i] = head + i;
			}
			
			return vec;
		}
		private static function _disposeTexHandler(e:Event):void {
			var tex:* = e.currentTarget;
			
			for (var name:String in _globalTextures) {
				if (_globalTextures[name] == tex) {
					setGlobalTexture(name, null);
					break;
				}
			}
		}
		public function get instanceID():uint {
			return _instanceID;
		}
		public function get name():String {
			return _name;
		}
		public function dispose():void {
			if (_device != null) {
				_clear();
				
				_device = null;
				
				if (hasEventListener(ASGLEvent.DISPOSE)) dispatchEvent(new ASGLEvent(ASGLEvent.DISPOSE));
			}
		}
		public function getShaderCell(localDefine:Object, globalDefine:Object):Shader3DCell {
			if (globalDefine == null) globalDefine = _globalDefine;
			
			var mask:uint = 0;
			
			for (var name:String in define) {
				var def:Object = null;
				if (name in localDefine) {
					def = localDefine;
				} else if (name in globalDefine) {
					def = globalDefine;
				}
				
				if (def != null) {
					var sd:ShaderDefine = define[name];
					
					var value:uint = int(def[name]) + sd.offset;
					
					mask |= value << sd.length;
				}
			}
			
			if (_shaderMask != mask) {
				_shaderMask = mask;
				var cell:Shader3DCell = _shaders[mask];
				if (_shaderCell != cell) _shaderCell = cell;
			}
			
			return _shaderCell;
		}
		public function upload(bytes:ByteArray):void {
			_clear();
			
			bytes.endian = Endian.LITTLE_ENDIAN;
			bytes.position = 3;
			
			_name = bytes.readUTF();
			
			var len:int = bytes.readUnsignedByte();
			for (var i:int = 0; i < len; i++) {
				var name:String = bytes.readUTF();
				var sd:ShaderDefine = new ShaderDefine();
				sd.offset = bytes.readShort();
				sd.length = bytes.readUnsignedShort();
				define[name] = sd;
			}
			
			var cell:Shader3DCell;
			
			len = bytes.readUnsignedShort();
			for (i = 0; i < len; i++) {
				cell = new Shader3DCell(this, bytes);
				
				_shaders[cell._mask] = cell;
			}
			
			for each (cell in _shaders) {
				_shaderCell = cell;
				_shaderMask = _shaderCell._mask;
				break;
			}
			
			if (hasEventListener(ASGLEvent.UPLOAD)) dispatchEvent(new ASGLEvent(ASGLEvent.UPLOAD));
		}
		asgl_protected function _disposeShaderProgram():void {
			if (hasEventListener(ASGLEvent.DISPOSE_SHADER_PROGRAM)) dispatchEvent(new ASGLEvent(ASGLEvent.DISPOSE_SHADER_PROGRAM));
		}
		private function _clear():void {
			for (var key:* in define) {
				define = {};
				break;
			}
			
			var hasData:Boolean = false;
			for each (var cell:Shader3DCell in _shaders) {
				cell._dispose();
				hasData = true;
			}
			
			_shaderMask = NULL_MASK;
			if (_shaderCell != null) _shaderCell = null;
			
			if (hasData) {
				_shaders = {};
				if (hasEventListener(ASGLEvent.DISPOSE_SHADER_PROGRAM)) dispatchEvent(new ASGLEvent(ASGLEvent.DISPOSE_SHADER_PROGRAM));
			}
		}
	}
}