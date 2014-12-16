package asgl.shaders.scripts.compiler {
	import flash.display3D.Context3DProgramType;
	import flash.utils.ByteArray;

	public class ProgramSettings {
		private static const MAX:String = 'max';
		
		public var version:uint;
		
		private var _indices:Object;
		private var _indicesConf:Object;
		
		private var _programType:String;
		private var _mm:IMemberManager;
		
		private var _numbers:Vector.<Number>;
		private var _settingsNumbers:Vector.<ProgramSettingsNumber>;
		private var _properties:Object;
		
		private var _localConstants:Array;
		
		public function ProgramSettings() {
		}
		public function init(programType:String, mm:IMemberManager, properties:Vector.<FunctionData>):void {
			_programType = programType;
			_mm = mm;
			
			_indices = {};
			
			_indicesConf = {};
			_indicesConf[PropertyOptionalParamType.BUFFER] = {MAX:-1};
			_indicesConf[PropertyOptionalParamType.TEXTURE] = {MAX:-1};
			_indicesConf[PropertyOptionalParamType.CONSTANTS] = {MAX:-1};
			
			var len:uint = properties.length;
			for (var i:uint = 0; i < len; i++) {
				var property:FunctionData = properties[i];
				
				if (property.returnType == PropertyOptionalParamType.TEXTURE ||
					property.returnType == PropertyOptionalParamType.BUFFER ||
					property.returnType == PropertyOptionalParamType.CONSTANTS) {
					_indicesConf[property.name] = property;
				} 
			}
			
			_numbers = new Vector.<Number>();
			_settingsNumbers = new Vector.<ProgramSettingsNumber>();
			
			_properties = {};
			_localConstants = [];
		}
		public function get indicesConfig():Object {
			return _indicesConf;
		}
		public function get numbers():Vector.<Number> {
			return _numbers;
		}
		public function get settingsNumbers():Vector.<ProgramSettingsNumber> {
			return _settingsNumbers;
		}
		public function addLocalConstant(name:String, position:uint, length:uint, offset:int):void {
			_localConstants.push(name, position, length, offset);
		}
		public function addNumber(position:uint, value:Number):void {
			var index:int = _numbers.indexOf(value);
			if (index == -1) {
				index = _numbers.length;
				_numbers[index] = value;
			}
			
			var psn:ProgramSettingsNumber = new ProgramSettingsNumber();
			psn.position = position;
			psn.index = index;
			_settingsNumbers.push(psn);
		}
		public function addProperty(name:String, indexBytesPos:uint, indexBitOffset:uint, indexBitLen:uint):void {
			var src:ProgramSettingsSource = new ProgramSettingsSource();
			src.indexBytesPostion = indexBytesPos;
			src.indexBitOffset = indexBitOffset;
			src.indexBitLength = indexBitLen;
			//src.maskBytesPosition = indexBytesPos + maskBytesOffset;
			//src.maskValue = maskValue;
			
			//src.textureSamplerState = textureSampleState;
			
			var v:Vector.<ProgramSettingsSource> = _properties[name];
			if (v == null) {
				v = new Vector.<ProgramSettingsSource>();
				_properties[name] = v;
			}
			
			v.push(src);
		}
		public function finish(bytes:ByteArray):void {
			_setFixedIndices();
			_finishProperties(bytes);
			_finishNumbers(bytes);
			_finishLocalConstants(bytes);
		}
		public function getIndices(type:String):Object {
			var op:Object = {};
			
			for (var name:String in _indices) {
				var fd:FunctionData = _indicesConf[name];
				if (fd.returnType == type) {
					op[name] = _indices[name];
				}
			}
			
			return op;
		}
		public function getPropertySources(name:String):Vector.<ProgramSettingsSource> {
			return _properties[name];
		}
		private function _allocateIndex(name:String):int {
			if (name in _indices) {
				return _indices[name];
			} else if (name in _indicesConf) {
				var propertyIndex:uint = 0;
				
				var fd:FunctionData = _indicesConf[name];
				var propertyIndices:Object = _indicesConf[fd.returnType];
				var max:uint = propertyIndices[MAX];
				
				var length:uint = 1;
				if (fd.returnType == PropertyOptionalParamType.CONSTANTS) {
					var lenValue:* = fd.optionalParams[PropertyOptionalParamType.LENGTH];
					if (lenValue == '*') {
						_indices[name] = max + 1;
						
						return max + 1;
					} else {
						length = lenValue;
						if (length == 0) length = 1;
					}
				}
				
				while (true) {
					if (propertyIndex in propertyIndices) {
						propertyIndex++;
					} else {
						var i:uint;
						var success:Boolean = true;
						
						if (length > 1) {
							var num:uint = length + propertyIndex;
							for (i = propertyIndex; i < num; i++) {
								if (propertyIndices[i]) {
									success = false;
									break;
								}
							}
						}
						
						if (success) break;
					}
				}
				
				length += propertyIndex;
				for (i = propertyIndex; i < length; i++) {
					if (max < i) max = i;
					propertyIndices[i] = true;
				}
				
				propertyIndices[MAX] = max;
				
				_indices[name] = propertyIndex;
				
				return propertyIndex;
			} else {
				return -1;
			}
		}
		private function _finishLocalConstants(bytes:ByteArray):void {
			var len:uint = _localConstants.length;
			
			for (var i:uint = 0; i < len; i += 4) {
				var name:String = _localConstants[i];
				var pos:uint = _localConstants[int(i + 1)];
				var length:uint = _localConstants[int(i + 2)];
				var offset:int = _localConstants[int(i + 3)];
				
				var value:uint = _allocateIndex(name) + offset;
				
				bytes.position = pos;
				
				if (length == 8) {
					bytes.writeByte(value);
				} else if (length == 16) {
					bytes.writeShort(value);
				}
			}
		}
		private function _finishNumbers(bytes:ByteArray):void {
			if (_numbers.length > 0) {
				var psn:ProgramSettingsNumber;
				
				var old:Vector.<Number> = _numbers.concat();
				_numbers.sort(Array.NUMERIC);
				
				var len:uint = _settingsNumbers.length;
				for (var i:uint = 0; i < len; i++) {
					psn = _settingsNumbers[i];
					psn.index = _numbers.indexOf(old[psn.index]);
				}
				
				var div:Number = _numbers.length / 4;
				if (div > int(div)) _numbers.length = (int(div) + 1) * 4;
				
				var fd:FunctionData = new FunctionData('');
				fd.type = FunctionType.PROPERTY;
				fd.returnType = PropertyOptionalParamType.CONSTANTS;
				fd.name = '__' + (_programType == Context3DProgramType.VERTEX ? 'vert' : 'frag') + 'HideNumbers';
				fd.optionalParams[PropertyOptionalParamType.NAME] = '';
				fd.optionalParams[PropertyOptionalParamType.LENGTH] = _numbers.length / 4;
				fd.optionalParams[PropertyOptionalParamType.VALUES] = _numbers;
				_mm.setProperty(fd.name, fd, false);
				_indicesConf[fd.name] = fd;
				
				var firstRegister:int = _allocateIndex(fd.name);
				
				for (i = 0; i < len; i++) {
					psn = _settingsNumbers[i];
					
					bytes.position = psn.position;
					
					var mask:uint = psn.index;
					var index:uint = firstRegister + uint(mask * 0.25);
					mask %= 4;
					
					bytes.writeShort(index);
					bytes.position++;
					bytes.writeByte((mask << 6) | (mask << 4) | (mask << 2) | mask);
				}
			}
		}
		private function _finishProperties(bytes:ByteArray):void {
			var anyConstants:String;
			
			for (var name:String in _properties) {
				var fd:FunctionData = _indicesConf[name];
				if (fd.returnType == PropertyOptionalParamType.CONSTANTS) {
					if (fd.optionalParams[PropertyOptionalParamType.LENGTH] == '*') {
						if (anyConstants == null) {
							anyConstants = name;
							continue;
						} else {
							throw new Error();
						}
					}
				}
				
				_setPropertyIndex(name, bytes);
			}
			
			if (anyConstants != null) _setPropertyIndex(name, bytes);
		}
		private function _setFixedIndices():void {
			for (var name:String in _properties) {
				if (name in _indicesConf) {
					var fd:FunctionData = _indicesConf[name];
					
					if (PropertyOptionalParamType.INDEX in fd.optionalParams) {
						var propertyIndex:uint = fd.optionalParams[PropertyOptionalParamType.INDEX];
						
						var propertyIndices:Object = _indicesConf[fd.returnType];
						
						var length:uint = 1;
						if (fd.returnType == PropertyOptionalParamType.CONSTANTS) {
							length = fd.optionalParams[PropertyOptionalParamType.LENGTH];
						}
						
						length += propertyIndex;
						for (var i:uint = propertyIndex; i < length; i++) {
							propertyIndices[i] = true;
						}
						
						_indices[name] = propertyIndex;
					}
				}
			}
		}
		private function _setPropertyIndex(name:String, bytes:ByteArray):void {
			var index:uint = _allocateIndex(name);
			
			var v:Vector.<ProgramSettingsSource> = _properties[name];
			var len:uint = v.length;
			
			for (var i:uint = 0; i < len; i++) {
				var pss:ProgramSettingsSource = v[i];
				
				var pos:uint = pss.indexBytesPostion;
				var offset:uint = pss.indexBitOffset;
				var bits:uint = pss.indexBitLength;
				
				var finalValue:uint;
				
				bytes.position = pos;
				
				if (offset == 0) {
					finalValue = index;
				} else {
					var oldValue:uint;
					var total:uint;
					
					if (bits <= 8) {
						oldValue = bytes.readUnsignedByte();
						total = 8;
					} else if (bits <= 16) {
						oldValue = bytes.readUnsignedShort();
						total = 16;
					} else {
						oldValue = bytes.readUnsignedShort();
						total = 32;
					}
					
					var value1:uint = oldValue & ((Math.pow(2, offset) - 1) << (total - offset));
					var value2:uint = (index & (Math.pow(2, bits) - 1)) << (total - bits);
					var value3:uint = oldValue & (Math.pow(2, (total - offset - bits)) - 1);
					
					finalValue = value1 | value2 | value3;
				}
				
				bytes.position = pos;
				if (bits <= 8) {
					bytes.writeByte(finalValue);
				} else if (bits <= 16) {
					bytes.writeShort(finalValue);
				} else {
					bytes.writeUnsignedInt(finalValue);
				}
			}
		}
	}
}