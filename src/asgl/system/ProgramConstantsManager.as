package asgl.system {
	import flash.display3D.Context3DProgramType;
	import flash.utils.ByteArray;
	
	import asgl.asgl_protected;
	import asgl.math.Matrix4x4;
	
	use namespace asgl_protected;
	
	public class ProgramConstantsManager {
		public static const VERTEX_CONSTANTS_MAX:int = 128;
		public static const FRAGMENT_CONSTANTS_MAX:int = 28;
		
		private static var _numberVector:Vector.<Number> = new Vector.<Number>(4, true);
		private static var _number16Vector:Vector.<Number> = new Vector.<Number>(16, true);
		
		private var _constantsUpdateCount:uint;
		
		private var _device:Device3D;
		private var _vertexConstants:Vector.<Number>;
		private var _fragmentConstants:Vector.<Number>;
		private var _vertexConstantsMap:Vector.<Number>;
		private var _fragmentConstantsMap:Vector.<Number>;
		
		public function ProgramConstantsManager(device:Device3D) {
			_device = device;
			
			_vertexConstants = new Vector.<Number>(VERTEX_CONSTANTS_MAX);
			_fragmentConstants = new Vector.<Number>(FRAGMENT_CONSTANTS_MAX);
			_vertexConstantsMap = new Vector.<Number>(VERTEX_CONSTANTS_MAX);
			_fragmentConstantsMap = new Vector.<Number>(FRAGMENT_CONSTANTS_MAX);
		}
		public function setProgramConstantsFromByteArray(programType:String, firstRegister:uint, numRegisters:int, data:ByteArray, byteArrayOffset:uint):int {
			if (data == null) return -1;
			
			if (numRegisters < 0) numRegisters = (data.length - byteArrayOffset) / 16;
			if (numRegisters == 0) return -1;
			
			var constans:Vector.<Number>;
			var constansMap:Vector.<Number>;
			var max:int;
			if (programType == Context3DProgramType.VERTEX) {
				constans = _vertexConstants;
				constansMap = _vertexConstantsMap;
				max = VERTEX_CONSTANTS_MAX;
			} else if (programType == Context3DProgramType.FRAGMENT) {
				constans = _fragmentConstants;
				constansMap = _fragmentConstantsMap;
				max = FRAGMENT_CONSTANTS_MAX;
			} else {
				return -1;
			}
			
			if (firstRegister + numRegisters > max) return -1;
			
			if (_device._cacheProgramConstants) {
				constansMap[firstRegister] = (++_constantsUpdateCount) << 8 | numRegisters;
				
				var index:int = firstRegister * 4;
				var j:int = numRegisters * 4;
				var oldPos:int = data.position;
				data.position = byteArrayOffset;
				while (j != 0) {
					j--;
					constans[index++] = data.readFloat();
				}
				data.position = oldPos;
			}
			
			if (_device._context3D != null) {
				_device._context3D.setProgramConstantsFromByteArray(programType, firstRegister, numRegisters, data, byteArrayOffset);
				
				_device._debugger._changeConstantStateCount++;
			}
			
			return numRegisters;
		}
		public function setProgramConstantsFromMatrix(programType:String, firstRegister:uint, matrix:Matrix4x4, transposedMatrix:Boolean=false):int {
			if (matrix == null) return -1;
			
			var constans:Vector.<Number>;
			var constansMap:Vector.<Number>;
			var max:int;
			if (programType == Context3DProgramType.VERTEX) {
				constans = _vertexConstants;
				constansMap = _vertexConstantsMap;
				max = VERTEX_CONSTANTS_MAX;
			} else if (programType == Context3DProgramType.FRAGMENT) {
				constans = _fragmentConstants;
				constansMap = _fragmentConstantsMap;
				max = FRAGMENT_CONSTANTS_MAX;
			} else {
				return -1;
			}
			
			if (firstRegister + 4 > max) return -1;
			
			if (_device._cacheProgramConstants) {
				constansMap[firstRegister] = (++_constantsUpdateCount) << 8 | 4;
				
				matrix.toVector4x4(transposedMatrix, _number16Vector);
				
				var index:int = firstRegister * 4;
				constans[index++] = _number16Vector[0];
				constans[index++] = _number16Vector[1];
				constans[index++] = _number16Vector[2];
				constans[index++] = _number16Vector[3];
				constans[index++] = _number16Vector[4];
				constans[index++] = _number16Vector[5];
				constans[index++] = _number16Vector[6];
				constans[index++] = _number16Vector[7];
				constans[index++] = _number16Vector[8];
				constans[index++] = _number16Vector[9];
				constans[index++] = _number16Vector[10];
				constans[index++] = _number16Vector[11];
				constans[index++] = _number16Vector[12];
				constans[index++] = _number16Vector[13];
				constans[index++] = _number16Vector[14];
				constans[index] = _number16Vector[15];
			}
			
			if (_device._context3D != null) {
				if (!_device._cacheProgramConstants) matrix.toVector4x4(transposedMatrix, _number16Vector);
				
				_device._context3D.setProgramConstantsFromVector(programType, firstRegister, _number16Vector, 4);
				
				_device._debugger._changeConstantStateCount++;
			}
			
			return 4;
		}
		public function setProgramConstantsFromNumber4(programType:String, firstRegister:uint, value1:Number=0, value2:Number=0, value3:Number=0, value4:Number=0):int {
			_numberVector[0] = value1;
			_numberVector[1] = value2;
			_numberVector[2] = value3;
			_numberVector[3] = value4;
			
			var constans:Vector.<Number>;
			var constansMap:Vector.<Number>;
			var max:int;
			if (programType == Context3DProgramType.VERTEX) {
				constans = _vertexConstants;
				constansMap = _vertexConstantsMap;
				max = VERTEX_CONSTANTS_MAX;
			} else if (programType == Context3DProgramType.FRAGMENT) {
				constans = _fragmentConstants;
				constansMap = _fragmentConstantsMap;
				max = FRAGMENT_CONSTANTS_MAX;
			} else {
				return -1;
			}
			
			if (firstRegister >= max) return -1;
			
			if (_device._cacheProgramConstants) {
				constansMap[firstRegister] = (++_constantsUpdateCount) << 8 | 1;
				
				var index4:int = firstRegister * 4;
				constans[index4++] = value1;
				constans[index4++] = value2;
				constans[index4++] = value3;
				constans[index4] = value4;
			}
			
			if (_device._context3D != null) {
				_device._context3D.setProgramConstantsFromVector(programType, firstRegister, _numberVector, 1);
				
				_device._debugger._changeConstantStateCount++;
			}
			
			return 1;
		}
		public function setProgramConstantsFromVector(programType:String, firstRegister:uint, data:Vector.<Number>, numRegisters:int=-1):int {
			if (data == null) return -1;
			
			var finalNumRegisters:int;
			
			if (numRegisters < 0) {
				var length:int = data.length;
				var div:int = length * 0.25;
				var mod:int = length % 4;
				
				numRegisters = div;
				
				if (mod > 0) {
					finalNumRegisters = numRegisters + 1;
					
					var start:int = div * 4;
					for (var i:int = 0; i < mod; i++) {
						_numberVector[i] = data[int(start + i)];
					}
					
					mod = 4 - mod;
					
					start = i;
					for (i = 0; i < mod; i++) {
						_numberVector[int(start + i)] = 0;
					}
				} else {
					finalNumRegisters = numRegisters;
				}
			} else {
				finalNumRegisters = numRegisters;
			}
			
			if (finalNumRegisters == 0) return -1;
			
			var constans:Vector.<Number>;
			var constansMap:Vector.<Number>;
			var max:int;
			if (programType == Context3DProgramType.VERTEX) {
				constans = _vertexConstants;
				constansMap = _vertexConstantsMap;
				max = VERTEX_CONSTANTS_MAX;
			} else if (programType == Context3DProgramType.FRAGMENT) {
				constans = _fragmentConstants;
				constansMap = _fragmentConstantsMap;
				max = FRAGMENT_CONSTANTS_MAX;
			} else {
				return -1;
			}
			
			if (firstRegister + finalNumRegisters > max) return -1;
			
			if (_device._cacheProgramConstants) {
				constansMap[firstRegister] = (++_constantsUpdateCount) << 8 | finalNumRegisters;
				
				var index:int;
				var index4:int;
				if (numRegisters>0) {
					for (var j:int = 0; j<numRegisters; j++) {
						index = j + firstRegister;
						var j4:int = j * 4;
						index4 = index * 4;
						constans[index4++] = data[j4++];
						constans[index4++] = data[j4++];
						constans[index4++] = data[j4++];
						constans[index4] = data[j4];
					}
				}
				if (finalNumRegisters>numRegisters) {
					index = firstRegister+numRegisters;
					index4 = index * 4;
					constans[index4++] = _numberVector[0];
					constans[index4++] = _numberVector[1];
					constans[index4++] = _numberVector[2];
					constans[index4] = _numberVector[3];
				}
			}
			
			if (_device._context3D != null) {
				if (numRegisters > 0) {
					_device._context3D.setProgramConstantsFromVector(programType, firstRegister, data, numRegisters);
					
					_device._debugger._changeConstantStateCount++;
				}
				if (finalNumRegisters > numRegisters) {
					_device._context3D.setProgramConstantsFromVector(programType, firstRegister + numRegisters, _numberVector, 1);
					
					_device._debugger._changeConstantStateCount++;
				}
			}
			
			return finalNumRegisters;
		}
		asgl_protected function _recovery():void {
			var index4:int;
			var count:int;
			var value:Number;
			var oldCount:int;
			var oldNum:int;
			var success:Boolean;
			
			for (var i:int = 0; i < VERTEX_CONSTANTS_MAX; i++) {
				value = _vertexConstantsMap[i];
				count = value >> 8;
				
				if (count > oldCount) {
					oldCount = count;
					oldNum = (value & 0xFF) - 1;
					index4 = i * 4;
					success = true;
				} else if (count < oldCount && oldNum > 0) {
					oldNum--;
					index4 = i * 4;
					success = true;
				} else {
					success = false;
				}
				
				if (success) {
					_numberVector[0] = _vertexConstants[index4++];
					_numberVector[1] = _vertexConstants[index4++];
					_numberVector[2] = _vertexConstants[index4++];
					_numberVector[3] = _vertexConstants[index4];
					_device._context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, i, _numberVector, 1);
				}
			}
			
			oldCount = 0;
			oldNum = 0;
			for (i = 0; i < FRAGMENT_CONSTANTS_MAX; i++) {
				value = _fragmentConstantsMap[i];
				count = value >> 8;
				
				if (count > oldCount) {
					oldCount = count;
					oldNum = (value & 0xFF) - 1;
					index4 = i * 4;
					success = true;
				} else if (count < oldCount && oldNum > 0) {
					oldNum--;
					index4 = i * 4;
					success = true;
				} else {
					success = false;
				}
				
				if (success) {
					_numberVector[0] = _fragmentConstants[index4++];
					_numberVector[1] = _fragmentConstants[index4++];
					_numberVector[2] = _fragmentConstants[index4++];
					_numberVector[3] = _fragmentConstants[index4];
					_device._context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, i, _numberVector, 1);
				}
			}
		}
	}
}