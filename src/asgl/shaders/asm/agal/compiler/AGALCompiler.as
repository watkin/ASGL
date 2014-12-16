package asgl.shaders.asm.agal.compiler {
	import flash.display3D.Context3DMipFilter;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFilter;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DWrapMode;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import asgl.asgl_protected;
	import asgl.shaders.asm.agal.OpcodeType;
	import asgl.shaders.asm.agal.RegisterType;
	import asgl.system.Context3DSampleDimension;
	import asgl.system.Context3DSampleSpecial;
	
	use namespace asgl_protected;

	public class AGALCompiler {
		private static const MAX_OPCODES:uint = 200;
		
		private static var _isInit:Boolean;
		private static var _tokenReg:RegExp;
		private static var _elementReg:RegExp;
		private static var _registerReg:RegExp;
		private static var _indexReg:RegExp;
		private static var _indirectReg:RegExp;
		private static var _typeReg:RegExp;
		private static var _xrRex:RegExp;
		private static var _ygRex:RegExp;
		private static var _zbRex:RegExp;
		private static var _waRex:RegExp;
		private static var _opcodeMap:Object;
		private static var _registerMap:Object;
		private static var _sampleValueMap:Object;
		private static var _sampleIndexMap:Object;
		
		private var _register:RegisterData;
		private var _assembler:AGALAssembler;
		
		public function AGALCompiler() {
			_init();
			
			_register = new RegisterData();
			_assembler = new AGALAssembler();
		}
		private static function _init():void {
			if (!_isInit) {
				_isInit = true;
				
				_opcodeMap = {};
				_registerMap = {};
				_sampleValueMap = {};
				_sampleIndexMap = {};
				
				_registerMap[RegisterType.VERTEX_ATTRIBUTE] = AGALRegisterType.VA_ID;
				_registerMap[RegisterType.VERTEX_CONSTANT] = AGALRegisterType.VC_ID;
				_registerMap[RegisterType.FRAGMENT_CONSTANT] = AGALRegisterType.FC_ID;
				_registerMap[RegisterType.VERTEX_TEMPORARY] = AGALRegisterType.VT_ID;
				_registerMap[RegisterType.FRAGMENT_TEMPORARY] = AGALRegisterType.FT_ID;
				
				_registerMap[RegisterType.VERTEX_OUTPUT_V1] = AGALRegisterType.VO_ID;
				_registerMap[RegisterType.VERTEX_OUTPUT_V2] = AGALRegisterType.VO_ID;
				
				_registerMap[RegisterType.FRAGMENT_OUTPUT_V1] = AGALRegisterType.FO_ID;
				_registerMap[RegisterType.FRAGMENT_OUTPUT_V2] = AGALRegisterType.FO_ID;
				
				_registerMap[RegisterType.VARYING_V1] = AGALRegisterType.V_ID;
				_registerMap[RegisterType.VARYING_V2] = AGALRegisterType.V_ID;
				_registerMap[RegisterType.VARYING_V3] = AGALRegisterType.V_ID;
				_registerMap[RegisterType.VARYING_V4] = AGALRegisterType.V_ID;
				
				_registerMap[RegisterType.TEXTURE_SAMPLER] = AGALRegisterType.FS_ID;
				
				_sampleIndexMap[Context3DTextureFilter.NEAREST] = 0;
				_sampleValueMap[Context3DTextureFilter.NEAREST] = AGALSamplerFlag.FILTER[Context3DTextureFilter.NEAREST];
				_sampleIndexMap[Context3DTextureFilter.LINEAR] = 0;
				_sampleValueMap[Context3DTextureFilter.LINEAR] = AGALSamplerFlag.FILTER[Context3DTextureFilter.LINEAR];
				
				_sampleIndexMap[Context3DMipFilter.MIPNONE] = 1;
				_sampleValueMap[Context3DMipFilter.MIPNONE] = AGALSamplerFlag.MIPMAP[Context3DMipFilter.MIPNONE];
				_sampleIndexMap[Context3DMipFilter.MIPNEAREST] = 1;
				_sampleValueMap[Context3DMipFilter.MIPNEAREST] = AGALSamplerFlag.MIPMAP[Context3DMipFilter.MIPNEAREST];
				_sampleIndexMap[Context3DMipFilter.MIPLINEAR] = 1;
				_sampleValueMap[Context3DMipFilter.MIPLINEAR] = AGALSamplerFlag.MIPMAP[Context3DMipFilter.MIPLINEAR];
				
				_sampleIndexMap[Context3DWrapMode.CLAMP] = 2;
				_sampleValueMap[Context3DWrapMode.CLAMP] = AGALSamplerFlag.WRAP[Context3DWrapMode.CLAMP];
				_sampleIndexMap[Context3DWrapMode.REPEAT] = 2;
				_sampleValueMap[Context3DWrapMode.REPEAT] = AGALSamplerFlag.WRAP[Context3DWrapMode.REPEAT];
				
				_sampleIndexMap[Context3DSampleSpecial.SPECIALNONE] = 3;
				_sampleValueMap[Context3DSampleSpecial.SPECIALNONE] = AGALSamplerFlag.SPECIAL[Context3DSampleSpecial.SPECIALNONE];
				_sampleIndexMap[Context3DSampleSpecial.IGNORESAMPLER] = 3;
				_sampleValueMap[Context3DSampleSpecial.IGNORESAMPLER] = AGALSamplerFlag.SPECIAL[Context3DSampleSpecial.IGNORESAMPLER];
				
				_sampleIndexMap[Context3DSampleDimension.D2] = 4;
				_sampleValueMap[Context3DSampleDimension.D2] = AGALSamplerFlag.DIMENSION[Context3DSampleDimension.D2];
				_sampleIndexMap[Context3DSampleDimension.CUBE] = 4;
				_sampleValueMap[Context3DSampleDimension.CUBE] = AGALSamplerFlag.DIMENSION[Context3DSampleDimension.CUBE];
				
				_sampleIndexMap[Context3DTextureFormat.BGRA] = 5;
				_sampleValueMap[Context3DTextureFormat.BGRA] = AGALSamplerFlag.FORMAT[Context3DTextureFormat.BGRA];
				_sampleIndexMap[Context3DTextureFormat.COMPRESSED] = 5;
				_sampleValueMap[Context3DTextureFormat.COMPRESSED] = AGALSamplerFlag.FORMAT[Context3DTextureFormat.COMPRESSED];
				_sampleIndexMap[Context3DTextureFormat.COMPRESSED_ALPHA] = 5;
				_sampleValueMap[Context3DTextureFormat.COMPRESSED_ALPHA] = AGALSamplerFlag.FORMAT[Context3DTextureFormat.COMPRESSED_ALPHA];
				
				var pattern:String = '[';
				
				pattern += OpcodeType.ABSOLUTE + ' ';
				_opcodeMap[OpcodeType.ABSOLUTE] = AGALOpcode.ABS;
				
				pattern += OpcodeType.ADD + ' ';
				_opcodeMap[OpcodeType.ADD] = AGALOpcode.ADD;
				
				pattern += OpcodeType.COSINE + ' ';
				_opcodeMap[OpcodeType.COSINE] = AGALOpcode.COS;
				
				pattern += OpcodeType.CROSS_PRODUCT + ' ';
				_opcodeMap[OpcodeType.CROSS_PRODUCT] = AGALOpcode.CRS;
				
				pattern += OpcodeType.DDX + ' ';
				_opcodeMap[OpcodeType.DDX] = AGALOpcode.DDX;
				
				pattern += OpcodeType.DDY + ' ';
				_opcodeMap[OpcodeType.DDY] = AGALOpcode.DDY;
				
				pattern += OpcodeType.DIVIDE + ' ';
				_opcodeMap[OpcodeType.DIVIDE] = AGALOpcode.DIV;
				
				pattern += OpcodeType.DOT_PRODUCT_3 + ' ';
				_opcodeMap[OpcodeType.DOT_PRODUCT_3] = AGALOpcode.DP3;
				
				pattern += OpcodeType.DOT_PRODUCT_4 + ' ';
				_opcodeMap[OpcodeType.DOT_PRODUCT_4] = AGALOpcode.DP4;
				
				pattern += OpcodeType.ELSE + ' ';
				_opcodeMap[OpcodeType.ELSE] = AGALOpcode.ELS;
				
				pattern += OpcodeType.END_IF + ' ';
				_opcodeMap[OpcodeType.END_IF] = AGALOpcode.EIF;
				
				pattern += OpcodeType.EXPONENTIAL_2 + ' ';
				_opcodeMap[OpcodeType.EXPONENTIAL_2] = AGALOpcode.EXP;
				
				pattern += OpcodeType.FRACTIONAL + ' ';
				_opcodeMap[OpcodeType.FRACTIONAL] = AGALOpcode.FRC;
				
				pattern += OpcodeType.IF_EQUAL + ' ';
				_opcodeMap[OpcodeType.IF_EQUAL] = AGALOpcode.IFE;
				
				pattern += OpcodeType.IF_GREATER + ' ';
				_opcodeMap[OpcodeType.IF_GREATER] = AGALOpcode.IFG;
				
				pattern += OpcodeType.IF_LESSL + ' ';
				_opcodeMap[OpcodeType.IF_LESSL] = AGALOpcode.IFL;
				
				pattern += OpcodeType.IF_NOT_EQUAL + ' ';
				_opcodeMap[OpcodeType.IF_NOT_EQUAL] = AGALOpcode.INE;
				
				pattern += OpcodeType.IS_EQUAL + ' ';
				_opcodeMap[OpcodeType.IS_EQUAL] = AGALOpcode.SEQ;
				
				pattern += OpcodeType.IS_GREATER_EQUAL + ' ';
				_opcodeMap[OpcodeType.IS_GREATER_EQUAL] = AGALOpcode.SGE;
				
				pattern += OpcodeType.IS_LESS_THAN + ' ';
				_opcodeMap[OpcodeType.IS_LESS_THAN] = AGALOpcode.SLT;
				
				pattern += OpcodeType.IS_NOT_EQUAL + ' ';
				_opcodeMap[OpcodeType.IS_NOT_EQUAL] = AGALOpcode.SNE;
				
				pattern += OpcodeType.KILL + ' ';
				_opcodeMap[OpcodeType.KILL] = AGALOpcode.KIL;
				
				pattern += OpcodeType.LOGARITHM_2 + ' ';
				_opcodeMap[OpcodeType.LOGARITHM_2] = AGALOpcode.LOG;
				
				pattern += OpcodeType.MAXIMUM + ' ';
				_opcodeMap[OpcodeType.MAXIMUM] = AGALOpcode.MAX;
				
				pattern += OpcodeType.MINIMUM + ' ';
				_opcodeMap[OpcodeType.MINIMUM] = AGALOpcode.MIN;
				
				pattern += OpcodeType.MOVE + ' ';
				_opcodeMap[OpcodeType.MOVE] = AGALOpcode.MOV;
				
				pattern += OpcodeType.MULTIPLY + ' ';
				_opcodeMap[OpcodeType.MULTIPLY] = AGALOpcode.MUL;
				
				pattern += OpcodeType.MULTIPLY_MATRIX_3X3 + ' ';
				_opcodeMap[OpcodeType.MULTIPLY_MATRIX_3X3] = AGALOpcode.M33;
				
				pattern += OpcodeType.MULTIPLY_MATRIX_3X4 + ' ';
				_opcodeMap[OpcodeType.MULTIPLY_MATRIX_3X4] = AGALOpcode.M34;
				
				pattern += OpcodeType.MULTIPLY_MATRIX_4X4 + ' ';
				_opcodeMap[OpcodeType.MULTIPLY_MATRIX_4X4] = AGALOpcode.M44;
				
				pattern += OpcodeType.NEGATE + ' ';
				_opcodeMap[OpcodeType.NEGATE] = AGALOpcode.NEG;
				
				pattern += OpcodeType.NORMALIZE + ' ';
				_opcodeMap[OpcodeType.NORMALIZE] = AGALOpcode.NRM;
				
				pattern += OpcodeType.POWER + ' ';
				_opcodeMap[OpcodeType.POWER] = AGALOpcode.POW;
				
				pattern += OpcodeType.RECIPROCAL + ' ';
				_opcodeMap[OpcodeType.RECIPROCAL] = AGALOpcode.RCP;
				
				pattern += OpcodeType.RECIPROCAL_ROOT + ' ';
				_opcodeMap[OpcodeType.RECIPROCAL_ROOT] = AGALOpcode.RSQ;
				
				pattern += OpcodeType.SATURATE + ' ';
				_opcodeMap[OpcodeType.SATURATE] = AGALOpcode.SAT;
				
				pattern += OpcodeType.SINE + ' ';
				_opcodeMap[OpcodeType.SINE] = AGALOpcode.SIN;
				
				pattern += OpcodeType.SQUARE_ROOT + ' ';
				_opcodeMap[OpcodeType.SQUARE_ROOT] = AGALOpcode.SQT;
				
				pattern += OpcodeType.SUBTRACT + ' ';
				_opcodeMap[OpcodeType.SUBTRACT] = AGALOpcode.SUB;
				
				pattern += OpcodeType.TEXTURE_SAMPLE;
				_opcodeMap[OpcodeType.TEXTURE_SAMPLE] = AGALOpcode.TEX;
				
				pattern += '][^\n;]*';
				_tokenReg = new RegExp(pattern, 'g');
				
				_elementReg = /[^\s,<>]*[^\s,<>]/g;
				_registerReg = /[^\.\[\]]*[^\.\[\]]/g;
				_indexReg = /\D/g;
				_indirectReg = /[^\+]*[^\+]/g;
				_typeReg = /[0-9]/g;
				_xrRex = /[xr]/g;
				_ygRex = /[yg]/g;
				_zbRex = /[zb]/g;
				_waRex = /[wa]/g;
			}
		}
		private static function _analyseRegister(regData:RegisterData, src:String, sampleFlags:Array, config:AGALConfiguration):void {
			var len:uint;
			var i:uint;
			var last:uint;
			var index:uint;
			
			var arr:Array = src.match(_registerReg);
			var regStr:String = arr[0];
			var typeStr:String = regStr.replace(_typeReg, '');
			var reg:AGALRegister = config.getRegsiterFromID(_registerMap[typeStr]);
			if (reg == null) {
				regData.success = false;
			} else {
				var comStr:String;
				
				regData.success = true;
				regData.type = reg._type;
				
				len = arr.length;
				if (len == 1) {
					regData.indirect = false;
					
					index = int(regStr.replace(_indexReg, ''));
					if (index < reg._maxNum) {
						regData.index = index;
						
						regData.components[0] = 1;
						regData.components[1] = 2;
						regData.components[2] = 3;
						regData.components[3] = 4;
					} else {
						regData.success = false;
					}
				} else if (len == 2) {
					regData.indirect = false;
					
					index = int(regStr.replace(_indexReg, ''));
					if (index<reg._maxNum) {
						regData.index = index;
						
						comStr = arr[1];
						comStr = comStr.replace(_xrRex, '1').replace(_ygRex, '2').replace(_zbRex, '3').replace(_waRex, '4');
						len = comStr.length;
						last = 0;
						for (i = 0; i < len; i++) {
							last = uint(comStr.charAt(i));
							regData.components[i] = last;
						}
						for (; i < 4; i++) {
							regData.components[i] = last;
						}
					} else {
						regData.success = false;
					}
				} else if (len < 5 && src.indexOf('.') < src.lastIndexOf(']')) {
					regData.indirect = true;
					
					var indirectRegStr:String = arr[1];
					reg = config.getRegsiterFromID(_registerMap[indirectRegStr.replace(_typeReg, '')]);
					if (reg == null) {
						regData.success = false;
					} else {
						var lastComStr:String = arr[int(len - 1)];
						
						arr = arr[2].match(_indirectReg);
						var len1:uint = arr.length;
						if (len1 > 2) {
							regData.success = false;
						} else {
							comStr = arr[0];
							if (comStr == 'x' || comStr == 'r') {
								regData.indirectComponent = 1;
							} else if (comStr == 'y' || comStr == 'g') {
								regData.indirectComponent = 2;
							} else if (comStr == 'z' || comStr == 'b') {
								regData.indirectComponent = 3;
							} else if (comStr == 'w' || comStr == 'a') {
								regData.indirectComponent = 4;
							} else {
								regData.success = false;
							}
								
							if (regData.success) {
								regData.indirectType = reg._type;
								
								regData.index = int(indirectRegStr.replace(_indexReg, ''));
								
								regData.indirectOffset = len1 == 1 ? 0 : uint(arr[1]);
								
								if (len == 3) {
									regData.components[0] = 1;
									regData.components[1] = 2;
									regData.components[2] = 3;
									regData.components[3] = 4;
								} else {
									comStr = lastComStr.replace(_xrRex, '1').replace(_ygRex, '2').replace(_zbRex, '3').replace(_waRex, '4');
									len1 = comStr.length;
									last = 0;
									for (i = 0; i < len1; i++) {
										last = uint(comStr.charAt(i));
										regData.components[i] = last;
									}
									for (; i < 4; i++) {
										regData.components[i] = last;
									}
								}
							}
						}
					}
				} else {
					regData.success = false;
				}
				
				if (typeStr == RegisterType.TEXTURE_SAMPLER && regData.success) {
					regData.sampleFlags[0] = 0;
					regData.sampleFlags[1] = 0;
					regData.sampleFlags[2] = 0;
					regData.sampleFlags[3] = 0;
					regData.sampleFlags[4] = 0;
					regData.sampleFlags[5] = 0;
					if (sampleFlags != null) {
						len = sampleFlags.length;
						
						for (i = 0; i < len; i++) {
							var flags:String = sampleFlags[i];
							var value:* = _sampleIndexMap[flags];
							if (value != null) regData.sampleFlags[value] = _sampleValueMap[flags];
						}
					}
				}
			}
		}
		public function compile(programType:String, code:String, version:uint=0, op:ByteArray=null):ByteArray {
//			var isDebug:Boolean = false;
			
			var conf:AGALConfiguration = new AGALConfiguration(version);
			
			if (op == null) {
				op = new ByteArray();
			} else {
				op.length = 0;
			}
			op.endian = Endian.LITTLE_ENDIAN;
			
			if (version == 0) version = 1;
			
			_assembler.writeHeader(op, programType, version);
			
			var scope:uint;
			if (programType == Context3DProgramType.VERTEX) {
				scope = AGALScopeType.VERTEX;
			} else {
				scope = AGALScopeType.FRAGMENT;
			}
			
			var tokens:Array = code.match(_tokenReg);
			
			var error:Boolean = false;
			
			var length:uint = tokens.length;
			if (length > MAX_OPCODES) {
				error = true;
			} else {
				label1:for (var i:uint = 0; i < length; i++) {
					var token:String = tokens[i];
					
//					if (i == 18) {
//						trace(i, op.length);//439, 458
//					}
					
					var elements:Array = token.match(_elementReg);
					var opcodeStr:String = elements[0];
					
					var opcode:AGALOpcode = _opcodeMap[opcodeStr];
					if (opcode == null) {
						_printError(i + 1, token, 'opcode not found');
						error = true;
						break;
					} else {
						if (version < opcode.version) version = opcode.version
						if ((opcode._scope & scope) != scope) {
							_printError(i + 1, token, 'opcode scope error');
							error = true;
							break;
						}
					}
					
					var destStr:String = null;
					var src1Str:String = null;
					var src2Str:String = null;
					var samplers:Array = null;
					
					if (opcode.hasDest) {
						destStr = elements[1];
						if (destStr == null) _printError(i + 1, token, 'dest is null');
						
						if (opcode.numRegisters > 0) {
							src1Str = elements[2];
							if (src1Str == null) _printError(i + 1, token, 'src1 is null');
							if (opcode.numRegisters > 1) {
								src2Str = elements[3];
								if (src2Str == null) _printError(i + 1, token, 'src2 is null');
							}
						}
						
						if (opcodeStr == OpcodeType.TEXTURE_SAMPLE) samplers = elements.slice(4);
					} else {
						if (opcode.numRegisters > 0) {
							src1Str = elements[1];
							if (src1Str == null) _printError(i + 1, token, 'src1 is null');
							if (opcode.numRegisters > 1) {
								src2Str = elements[2];
								if (src2Str == null) _printError(i + 1, token, 'src2 is null');
							}
						}
					}
					
//					var op:String = opcode+'||';
					
					var arr:Array;
					var reg:String;
					var str:String;
					var value:*;
					
					var mask:uint;
					var j:uint;
					var regCom:uint;
					
					_assembler.writeOperationCode(op, opcode._type);
					
					if (destStr == null) {
						_assembler.writeEmptyDestination(op);
					} else {
						_analyseRegister(_register, destStr, null, conf);
						if (_register.success) {
							mask = 0;
							var oldDestCom:uint = 0;
							for (j = 0; j < 4; j++) {
								regCom  = _register.components[j];
								if (regCom > 0 && regCom<oldDestCom) {
									_printError(i + 1, token, 'scalars of dest is not order');
									error = true;
									break label1;
								} else {
									oldDestCom = regCom;
								}
								
								if (regCom == 1) {
									mask |= 0x1;
								} else if (regCom == 2) {
									mask |= 0x2;
								} else if (regCom == 3) {
									mask |= 0x4;
								} else if (regCom == 4) {
									mask |= 0x8;
								}
							}
							
							if ((mask & 0x1) == 0) {
								if (!(mask == 0x2 || mask == 0x4 || mask == 0x8)) {
									_printError(i + 1, token, 'scalars of dest is not from x start');
									error = true;
									break label1;
								}
							}
							
							_assembler.writeDestination(op, _register.type, _register.index, mask);
							
//							if (isDebug) {
//								var destComs:String = register.components[0].toString()+register.components[1].toString()+register.components[2].toString()+register.components[3].toString();
//								op += register.type+'_'+register.index+'.'+destComs+'||';
//							}
						}
					}
					
					if (src1Str == null) {
						_assembler.writeEmptySource(op);
					} else {
						_analyseRegister(_register, src1Str, null, conf);
						if (_register.success) {
							mask = 0;
							for (j = 0; j < 4; j++) {
								regCom = _register.components[j];
								if (regCom != 0) mask |= (regCom - 1) << (j * 2);
							}
							
							if (_register.indirect) {
								_assembler.writeSource(op, _register.type, _register.index, mask, _register.indirect, _register.indirectType, _register.indirectComponent-1, _register.indirectOffset);
							} else {
								_assembler.writeSource(op, _register.type, _register.index, mask);
							}
							
//							if (isDebug) {
//								var src1Coms:String = register.components[0].toString()+register.components[1].toString()+register.components[2].toString()+register.components[3].toString();
//								op += register.type;
//								if (register.indirect) {
//									op += '['+register.indirectType+'_'+register.index+'.'+register.indirectComponent+'+'+register.indirectOffset+'].'+src1Coms+'||';
//								} else {
//									op +='_'+register.index+'.'+src1Coms+'||';
//								}
//							}
						}
					}
					
					if (src2Str == null) {
						_assembler.writeEmptySource(op);
					} else {
						_analyseRegister(_register, src2Str, samplers, conf);
						if (_register.success) {
							if (_register.type == AGALRegisterType.FS) {
								_assembler.writeSampler(op, _register.index, _register.sampleFlags[0], _register.sampleFlags[1], _register.sampleFlags[2], _register.sampleFlags[3], _register.sampleFlags[4], _register.sampleFlags[5], _register.bias);
							} else {
								mask = 0;
								for (j = 0; j < 4; j++) {
									regCom = _register.components[j];
									if (regCom != 0) mask |= (regCom - 1) << (j * 2);
								}
								
								if (_register.indirect) {
									_assembler.writeSource(op, _register.type, _register.index, mask, _register.indirect, _register.indirectType, _register.indirectComponent-1, _register.indirectOffset);
								} else {
									_assembler.writeSource(op, _register.type, _register.index, mask);
								}
							}
							
//							if (isDebug) {
//								var src2Coms:String = register.components[0].toString()+register.components[1].toString()+register.components[2].toString()+register.components[3].toString();
//								op += register.type;
//								if (register.indirect) {
//									op += '['+register.indirectType+'_'+register.index+'.'+register.indirectComponent+'+'+register.indirectOffset+'].'+src2Coms+'||';
//								} else {
//									op +='_'+register.index+'.'+src2Coms+'||';
//								}
//								if (register.type == _samplerValue) {
//									op += '<'+register.sampleFlags[0]+', '+register.sampleFlags[1]+', '+register.sampleFlags[2]+', '+register.sampleFlags[3]+'>||';
//								}
//							}
						}
					}
					
//					trace(op);
				}
			}
			
			if (error) {
				op.length = 0;
				
				return null;
			} else {
				op.position = 0;
				_assembler.writeHeader(op, programType, version);
				op.position = op.length;
				
				return op;
			}
		}
		private function _printError(index:uint, token:String, msg:String):void {
			trace('compile error:line('+index+') token('+token+') '+msg);
		}
	}
}
class RegisterData {
	public var success:Boolean;
	public var type:uint;
	public var index:uint;
	public var components:Vector.<uint> = new Vector.<uint>(4, true);
	
	public var indirect:Boolean;
	public var indirectType:uint;
	public var indirectComponent:uint;
	public var indirectOffset:uint;
	
	//filter, mipmap, warp, dimension
	public var sampleFlags:Vector.<uint> = new Vector.<uint>(6, true);
	public var bias:int;
}