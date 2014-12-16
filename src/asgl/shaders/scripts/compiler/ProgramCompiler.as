package asgl.shaders.scripts.compiler {
	import flash.display3D.Context3DProgramType;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import asgl.shaders.asm.agal.compiler.AGALAssembler;
	import asgl.shaders.asm.agal.compiler.AGALConfiguration;
	import asgl.shaders.asm.agal.compiler.AGALOpcode;
	import asgl.shaders.asm.agal.compiler.AGALRegister;
	import asgl.shaders.asm.agal.compiler.AGALSamplerFlag;
	import asgl.system.Context3DSampleSpecial;

	public class ProgramCompiler implements IProgramCompiler {
		private var _assembler:AGALAssembler;
		
		private var _opMap:Object;
		private var _regMap:Object;
		private var _config:AGALConfiguration;
		
		private var _isVert:Boolean;
		
		private var _settings:ProgramSettings;
		
		public function ProgramCompiler() {
			_assembler = new AGALAssembler();
			
			_opMap = {};
			
			_opMap[BaseFunctionType._ADD] = AGALOpcode.ADD;
			_opMap[BaseFunctionType._SUB] = AGALOpcode.SUB;
			_opMap[BaseFunctionType._MUL] = AGALOpcode.MUL;
			_opMap[BaseFunctionType._DIV] = AGALOpcode.DIV;
			_opMap[BaseFunctionType._NEG] = AGALOpcode.NEG;
			_opMap[BaseFunctionType._MOVE] = AGALOpcode.MOV;
			_opMap[BaseFunctionType._IS_EQUAL] = AGALOpcode.SEQ;
			_opMap[BaseFunctionType._IS_NOT_EQUAL] = AGALOpcode.SNE;
			_opMap[BaseFunctionType._IS_LESS] = AGALOpcode.SLT;
			_opMap[BaseFunctionType._IS_GREATER_EQUAL] = AGALOpcode.SGE;
			
			_opMap[BaseFunctionType.ABS] = AGALOpcode.ABS;
			_opMap[BaseFunctionType.CROSS] = AGALOpcode.CRS;
			_opMap[BaseFunctionType.COS] = AGALOpcode.COS;
			_opMap[BaseFunctionType.DDX] = AGALOpcode.DDX;
			_opMap[BaseFunctionType.DDY] = AGALOpcode.DDY;
			_opMap[BaseFunctionType.DOT_3] = AGALOpcode.DP3;
			_opMap[BaseFunctionType.DOT_4] = AGALOpcode.DP4;
			_opMap[BaseFunctionType.ELSE] = AGALOpcode.ELS;
			_opMap[BaseFunctionType.ENDIF] = AGALOpcode.EIF;
			_opMap[BaseFunctionType.EXP_2] = AGALOpcode.EXP;
			_opMap[BaseFunctionType.FRAC] = AGALOpcode.FRC;
			_opMap[BaseFunctionType.IFE] = AGALOpcode.IFE;
			_opMap[BaseFunctionType.IFG] = AGALOpcode.IFG;
			_opMap[BaseFunctionType.IFL] = AGALOpcode.IFL;
			_opMap[BaseFunctionType.IFNE] = AGALOpcode.INE;
			_opMap[BaseFunctionType.CLIP] = AGALOpcode.KIL;
			_opMap[BaseFunctionType.LOG_2] = AGALOpcode.LOG;
			_opMap[BaseFunctionType.M33] = AGALOpcode.M33;
			_opMap[BaseFunctionType.M34] = AGALOpcode.M34;
			_opMap[BaseFunctionType.M44] = AGALOpcode.M44;
			_opMap[BaseFunctionType.MAX] = AGALOpcode.MAX;
			_opMap[BaseFunctionType.MIN] = AGALOpcode.MIN;
			_opMap[BaseFunctionType.NORMALIZE] = AGALOpcode.NRM;
			_opMap[BaseFunctionType.POW] = AGALOpcode.POW;
			_opMap[BaseFunctionType.RCP] = AGALOpcode.RCP;
			_opMap[BaseFunctionType.RSQRT] = AGALOpcode.RSQ;
			_opMap[BaseFunctionType.SATURATE] = AGALOpcode.SAT;
			_opMap[BaseFunctionType.SIN] = AGALOpcode.SIN;
			_opMap[BaseFunctionType.SQRT] = AGALOpcode.SQT;
			_opMap[BaseFunctionType.TEX] = AGALOpcode.TEX;
			
			_config = new AGALConfiguration(0);
			
			_regMap = {};
			_regMap[BaseVariableType.VERTEX_ATTRIBUTE] = _config.va;
			_regMap[BaseVariableType.VERTEX_CONSTANT] = _config.vc;
			_regMap[BaseVariableType.VERTEX_OUTPUT] = _config.vo;
			_regMap[BaseVariableType.VERTEX_TEMPORARY] = _config.vt;
			_regMap[BaseVariableType.VARYING] = _config.v;
			_regMap[BaseVariableType.FRAGMENT_CONSTANT] = _config.fc;
			_regMap[BaseVariableType.FRAGMENT_OUTPUT] = _config.fo;
			_regMap[BaseVariableType.FRAGMENT_TEMPORARY] = _config.ft;
		}
		public function compile(programType:String, opcodes:Vector.<Opcode>, mm:IMemberManager, settings:ProgramSettings):ByteArray {
			var bytes:ByteArray = new ByteArray();
			bytes.endian = Endian.LITTLE_ENDIAN;
			
			_isVert = programType == Context3DProgramType.VERTEX;
			
			_assembler.writeHeader(bytes, programType);
			
			var properties:Vector.<FunctionData> = mm.getProperties();
			_settings = settings;
			_settings.init(programType, mm, properties);
			
			var len:uint = opcodes.length;
			for (var i:uint = 0; i < len; i++) {
				var opcode:Opcode = opcodes[i];
				
				var agalOp:AGALOpcode = _opMap[opcode.func];
				
 				if (agalOp == null) {
					//error
				} else {
					if (settings.version < agalOp.version) settings.version = agalOp.version;
					
					var j:int;
					var num:uint;
					var reg:AGALRegister;
					var mask:uint = 0;
					var index:int;
					var s:String;
					
					_assembler.writeOperationCode(bytes, agalOp.type);
					
					if (opcode.dest == null) {
						_assembler.writeEmptyDestination(bytes);
					} else {
						_writeDest(bytes, opcode.dest);
					}
					
					var args:Vector.<Variable> = opcode.args;
					
					if (args.length == 0) {
						_assembler.writeEmptySource(bytes);
						_assembler.writeEmptySource(bytes);
					} else {
						var arg:Variable = args[0];
						
						_writeSrc(bytes, arg);
						
						if (args.length == 1) {
							_assembler.writeEmptySource(bytes);
						} else {
							if (agalOp.type == AGALOpcode.TEX.type) {
								_writeSampler(bytes, args, mm);
							} else {
								_writeSrc(bytes, args[1]);
							}
						}
					}
				}
			}
			
			bytes.position = 0;
			_assembler.writeHeader(bytes, programType, _settings.version);
			
			_settings.finish(bytes);
			_settings = null;
			
			bytes.position = bytes.length;
			
			return bytes;
		}
		private function _writeDest(bytes:ByteArray, dest:Variable):void {
			var info:Info = new Info(_regMap, dest, true, _isVert);
			
			_assembler.writeDestination(bytes, info.type, info.index, info.mask);
		}
		private function _writeSrc(bytes:ByteArray, src:Variable):void {
			var info:Info = new Info(_regMap, src, false, _isVert);
			
			if (src.args != null && src.args.length > 1) {
				var info3:Info;
				
				var info2:Info = new Info(_regMap, src.args[0], false, _isVert);
				if (info2.replace == null) {
					var offset:uint = 0;
					
					if (src.args.length > 1) offset = uint(src.args[1].name);
					
					_assembler.writeSource(bytes, info.type, info2.index, info.mask, true, info2.type, info2.mask & 0x3, offset);
				} else if (src.args.length == 2) {
					if (Util.isNumber(src.args[1].name, null)) {
						_settings.addLocalConstant(info2.replace, bytes.position, 16, int(src.args[1].name));
						
						_assembler.writeSource(bytes, info.type, info.index, info.mask);//index
					} else {
						info3 = new Info(_regMap, src.args[1], false, _isVert);
						
						if (info3.replace != null) _settings.addProperty(info3.replace, bytes.position, 0, 16);
						_settings.addLocalConstant(info2.replace, bytes.position + 2, 8, 0);
						
						_assembler.writeSource(bytes, info.type, info3.index, info.mask, true, info3.type, info3.mask & 0x3, 0);//offset
					}
				} else if (src.args.length == 3) {
					if (Util.isNumber(src.args[1].name, null)) {
						_settings.addLocalConstant(info2.replace, bytes.position, 16, int(src.args[1].name) + int(src.args[2].name));
						
						_assembler.writeSource(bytes, info.type, info.index, info.mask);//index
					} else {
						info3 = new Info(_regMap, src.args[1], false, _isVert);
						
						if (info3.replace != null) _settings.addProperty(info3.replace, bytes.position, 0, 16);
						_settings.addLocalConstant(info2.replace, bytes.position + 2, 8, int(src.args[2].name));
						
						_assembler.writeSource(bytes, info.type, info3.index, info.mask, true, info3.type, info3.mask & 0x3, 0);//offset
					}
				}
				
				/*
				var info2:Info = new Info(_regMap, src.args[0], false, _isVert, _settings);
				if (info2.replace != null) {
					_settings.addProperty(info2.replace, bytes.position, 0, 16, 3, info2.mask);
				}
				
				var offset:uint = 0;
				
				if (src.args.length > 1) {
					var info3:Info = new Info(_regMap, src.args[1], false, _isVert, _settings);
					if (info3.replace == null) {
						offset = uint(src.args[1].name);
					} else {
						_settings.addProperty(info3.replace, bytes.position + 2, 0, 8, 4, info3.mask);
					}
				}
				
				_assembler.writeSource(bytes, info.type, info2.index, info.mask, true, info2.type, info2.mask & 0x3, offset);
				*/
			} else {
				if (info.replace == null) {
					if (Util.isNumber(src.name, src.component)) {
						var number:Number = src.component == null ? Number(src.name) : Number(src.name + '.' + src.component);
						
						_settings.addNumber(bytes.position, number);
						
						var reg:AGALRegister = _isVert ? _regMap[BaseVariableType.VERTEX_CONSTANT] : _regMap[BaseVariableType.FRAGMENT_CONSTANT];
						
						_assembler.writeSource(bytes, reg.type, 0, 0);
					} else {
						_assembler.writeSource(bytes, info.type, info.index, info.mask);
					}
				} else {
					_settings.addProperty(info.replace, bytes.position, 0, 16);//, 3, info.mask);
					
					_assembler.writeSource(bytes, info.type, info.index, info.mask);
				}
			}
		}
		private function _writeSampler(bytes:ByteArray, args:Vector.<Variable>, mm:IMemberManager):void {
			var len:uint = args.length;
			
			var arg:Variable;
			
			var filter:uint = 0;
			var mipmap:uint = 0;
			var wrap:uint = 0;
			var special:uint = 0;
			var format:uint = 0;
			var dim:uint = args[0].getTypeWithComponent(null) == BaseVariableType.FLOAT_2 ? 0 : 1;
			
			var info1:Info;
			
			if (len == 2) {
				arg = args[1];
				
				info1 = new Info(_regMap, args[1], false, _isVert);
				
				/*
				filter = AGALSamplerFlag.FILTER[Context3DTextureFilter.LINEAR];
				mipmap = AGALSamplerFlag.MIPMAP[Context3DMipFilter.MIPNONE];
				wrap = AGALSamplerFlag.WRAP[Context3DWrapMode.CLAMP];
				special = AGALSamplerFlag.SPECIAL[SampleSpecialType.IGNORESAMPLER];
				format = AGALSamplerFlag.FORMAT[Context3DTextureFormat.BGRA];
				*/
				
				_settings.addProperty(info1.replace, bytes.position, 0, 16);
				
				_assembler.writeSampler(bytes, 0, 0, 0, 0, AGALSamplerFlag.SPECIAL[Context3DSampleSpecial.IGNORESAMPLER], dim, format);
			} else {
				info1 = new Info(_regMap, args[1], false, _isVert);
				var info2:Info = new Info(_regMap, args[2], false, _isVert);
				var info3:Info = new Info(_regMap, args[3], false, _isVert);
				var info4:Info = new Info(_regMap, args[4], false, _isVert);
				var info5:Info = new Info(_regMap, args[5], false, _isVert);
				var info6:Info = new Info(_regMap, args[6], false, _isVert);
				
				if (info1.replace != null) {
					_settings.addProperty(info1.replace, bytes.position, 0, 16);//, 0, 0);
				}
				
				if (info2.replace == null) {
					arg = args[2];
					if (Util.isString(arg.name)) {
						filter = AGALSamplerFlag.FILTER[arg.name.substr(1, arg.name.length - 2)];
					} else {
						filter = uint(arg.name);
					}
				} else {
					_settings.addProperty(info2.replace, bytes.position + 4, 0, 4);//, 0, 0);
				}
				
				if (info3.replace == null) {
					arg = args[3];
					if (Util.isString(arg.name)) {
						mipmap = AGALSamplerFlag.MIPMAP[arg.name.substr(1, arg.name.length - 2)];
					} else {
						mipmap = uint(arg.name);
					}
				} else {
					_settings.addProperty(info3.replace, bytes.position + 4, 4, 4);//, 0, 0);
				}
				
				if (info4.replace == null) {
					arg = args[4];
					if (Util.isString(arg.name)) {
						wrap = AGALSamplerFlag.WRAP[arg.name.substr(1, arg.name.length - 2), 0];
					} else {
						wrap = uint(arg.name);
					}
				} else {
					_settings.addProperty(info4.replace, bytes.position + 5, 0, 4);//, 0, 0);
				}
				
				if (info5.replace == null) {
					arg = args[5];
					if (Util.isString(arg.name)) {
						special = AGALSamplerFlag.SPECIAL[arg.name.substr(1, arg.name.length - 2), 0];
					} else {
						special = uint(arg.name);
					}
				} else {
					_settings.addProperty(info5.replace, bytes.position + 5, 4, 4);//, 0, 0);
				}
				
				if (info6.replace == null) {
					arg = args[6];
					if (Util.isString(arg.name)) {
						format = AGALSamplerFlag.FORMAT[arg.name.substr(1, arg.name.length - 2)];
					} else {
						format = uint(arg.name);
					}
				} else {
					_settings.addProperty(info6.replace, bytes.position + 6, 4, 4);//, 0, 0);
				}
				
				_assembler.writeSampler(bytes, info1.index, filter, mipmap, wrap, special, dim, format);
			}
		}
	}
}
import asgl.shaders.asm.agal.compiler.AGALRegister;
import asgl.shaders.scripts.compiler.Variable;

class Info {
	private static var _destComMap:Object = _createDestComMap();
	private static var _srcComMap:Object = _createSrcComMap();
	
	public var replace:String;
	public var index:int;
	public var mask:uint;
	public var type:uint;
	
	public function Info(regMap:Object, src:Variable, isDest:Boolean, isVert:Boolean) {
		var srcType:String = src.type;
		
		var srcMask:String;
		
		if (src.name == null) {
			index = -1;
		} else {
			index = src.name.search(/#/);
			if (index == -1) {
				index = src.name.search(/[0-9]/);
				index = int(src.name.substr(index));
			} else {
				replace = src.name.substring(index + 1, src.name.lastIndexOf('#'));
				index = -1;
				//index = property._allocateIndex(replace);
				
				/*
				index = replace.indexOf('@');
				if (index != -1) {
					var param:String = replace.substr(index+1);
					replace = replace.substr(0, index);
					
					if (param == PropertyOptionalParamType.ATTRIBUTE) {
						srcType = BaseVariableType.VERTEX_ATTRIBUTE;
					} else if (param == PropertyOptionalParamType.CONSTANT) {
						srcType = isVert ? BaseVariableType.VERTEX_CONSTANT : BaseVariableType.FRAGMENT_CONSTANT;
					}
					
					srcMask = src.component;
					if (srcMask == null) {
						if (src.type == BaseVariableType.FLOAT) {
							srcMask = 'x';
						} else if (src.type == BaseVariableType.FLOAT_2) {
							srcMask = 'xy';
						} else if (src.type == BaseVariableType.FLOAT_3) {
							srcMask = 'xyz';
						} else if (src.type == BaseVariableType.FLOAT_4) {
							srcMask = 'xyzw';
						}
					}
				}
				*/
			}
		}
		
		if (srcMask == null) srcMask = src.component == null ? 'xyzw' : src.component;
		
		var reg:AGALRegister = regMap[srcType];
		if (reg != null) type = reg.type;
		
		mask = 0;
		
		var len:uint = srcMask.length;
		var j:int;
		var s:String;
		
		if (isDest) {
			for (j = 0; j < len; j++) {
				s = srcMask.charAt(j);
				mask |= _destComMap[s];
			}
		} else {
			s = srcMask.charAt(len-1);
			for (j = 4 - len - 1; j >= 0; j--) {
				mask = mask << 2;
				mask |= _srcComMap[s];
			}
			
			for (j = len - 1; j >= 0; j--) {
				s = srcMask.charAt(j);
				mask = mask << 2;
				mask |= _srcComMap[s];
			}
		}
	}
	private static function _createDestComMap():Object {
		var map:Object = {};
		
		map['x'] = 0x1;
		map['y'] = 0x2;
		map['z'] = 0x4;
		map['w'] = 0x8;
		
		map['r'] = 0x1;
		map['g'] = 0x2;
		map['b'] = 0x4;
		map['a'] = 0x8;
		
		return map;
	}
	private static function _createSrcComMap():Object {
		var map:Object = {};
		
		map['x'] = 0x0;
		map['y'] = 0x1;
		map['z'] = 0x2;
		map['w'] = 0x3;
		
		map['r'] = 0x0;
		map['g'] = 0x1;
		map['b'] = 0x2;
		map['a'] = 0x3;
		
		return map;
	}
}