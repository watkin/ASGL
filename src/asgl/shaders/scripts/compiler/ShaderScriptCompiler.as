package asgl.shaders.scripts.compiler {
	import com.adobe.crypto.MD5;
	
	import flash.display3D.Context3DProgramType;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import asgl.shaders.scripts.libs.ShaderScriptLibs;

	public class ShaderScriptCompiler {
		private var _opcodeParser:IOpcodeParser;
		private var _codeSegmentParser:ICodeSegmentParser;
		private var _memberManager:IMemberManager;
		private var _opcodeOptimizer:IOpcodeOptimizer;
		
		private var _defineTable:DefineTable;
		private var _functionTable:FunctionTable;
		private var _includeMap:Object;
		
		private var _scopeAccumulator:uint = 0;
		
		private var _programFormater:IProgramFormatter;
		private var _programCompiler:IProgramCompiler;
		
		private var _printMsg:Boolean;
		private var _debugger:Boolean;
		
		public function ShaderScriptCompiler(mm:IMemberManager=null, codeSegmentParser:ICodeSegmentParser=null, opcodeParser:IOpcodeParser=null, opcodeOptimizer:IOpcodeOptimizer=null,
							   programFormatter:IProgramFormatter=null, programCompiler:IProgramCompiler=null) {
			_memberManager = mm;
			if (_memberManager == null) _memberManager = new MemberManager();
			_codeSegmentParser = codeSegmentParser;
			if (_codeSegmentParser == null) _codeSegmentParser = new CodeSegmentParser();
			_opcodeParser = opcodeParser;
			if (_opcodeParser == null) _opcodeParser = new OpcodeParser();
			_opcodeOptimizer = opcodeOptimizer;
			if (_opcodeOptimizer == null) _opcodeOptimizer = new OpcodeOptimizer();
			
			_programFormater = programFormatter;
			if (_programFormater == null) _programFormater = new ProgramFormatter();
			_programCompiler = programCompiler;
			if (_programCompiler == null) _programCompiler = new ProgramCompiler();
			
			_defineTable = new DefineTable();
			_functionTable = new FunctionTable();
			_includeMap = {};
			
			this.includeScript(ShaderScriptLibs.getLib('Core'));
		}
		
		public function includeScript(code:String):void {
			_parseProgram(code, true);
		}
		
		public function compile(code:String, printMsg:Boolean=false):ByteArray {
			_printMsg = printMsg;
			
			var op:OpcodeProgram = _parseProgram(code, false);
			
			var bytes:ByteArray = new ByteArray();
			bytes.endian = Endian.LITTLE_ENDIAN;
			
			var bytes1:ByteArray = new ByteArray();
			bytes1.endian = Endian.LITTLE_ENDIAN;
			
			bytes.writeUTFBytes('SSL');
			bytes.writeUTF(op.name);
			
			var len1:uint = op.maskNames.length;
			
			bytes.writeByte(len1);
			
			for (var k:uint = 0; k < len1; k++) {
				bytes.writeUTF(op.maskNames[k]);
				bytes.writeShort(op.valueOffset[k]);
				bytes.writeShort(op.maskBits[k]);
			}
			
			len1 = op.vert.length;
			
			bytes.writeShort(len1);
			
			for (k = 0; k < len1; k++) {
				bytes.writeUnsignedInt(op.maskValues[k]);
				
				var vert:ByteArray;
				var frag:ByteArray;
				var fragReplaceTexMap:Object = {};
				
				var vertSettings:ProgramSettings = new ProgramSettings();
				var fragSettings:ProgramSettings = new ProgramSettings();
				
				if (op.vert != null) {
					vert = _programCompiler.compile(Context3DProgramType.VERTEX, op.vert[k], _memberManager, vertSettings);
				}
				
				if (op.frag != null) {
					frag = _programCompiler.compile(Context3DProgramType.FRAGMENT, op.frag[k], _memberManager, fragSettings);
				}
				
				if (vertSettings.version != fragSettings.version) {
					var max:uint = vertSettings.version > fragSettings.version ? vertSettings.version : fragSettings.version;
					if (vert != null) {
						vert.position = 1;
						vert.writeUnsignedInt(max);
					}
					if (frag != null) {
						frag.position = 1;
						frag.writeUnsignedInt(max);
					}
				}
				
				var pos:uint;
				var i:uint;
				var len:uint;
				
				var settings:ProgramSettings;
				
				//=============================
				
				var consts:Vector.<String> = new Vector.<String>();
				for (var j:uint = 0; j < 2; j++) {
					settings = j == 0 ? vertSettings : fragSettings;
					
					var indices:Object;
					var indexName:String;
					var count:uint = 0;
					var fd:FunctionData;
					
					if (j == 0) {
						indices = settings.getIndices(PropertyOptionalParamType.BUFFER);
						
						for (indexName in indices) {
							count++;
						}
						
						bytes.writeByte(count);
						
						for (indexName in indices) {
							fd = settings.indicesConfig[indexName];
							
							bytes.writeUTF(indexName);
							bytes.writeUTF(fd.optionalParams[PropertyOptionalParamType.NAME]);
							bytes.writeByte(indices[indexName]);
						}
					} else {
						indices = settings.getIndices(PropertyOptionalParamType.TEXTURE);
						
						for (indexName in indices) {
							count++;
						}
						
						bytes.writeByte(count);
						
						for (indexName in indices) {
							fd = settings.indicesConfig[indexName];
							
							bytes.writeUTF(indexName);
							bytes.writeUTF(fd.optionalParams[PropertyOptionalParamType.NAME]);
							bytes.writeByte(indices[indexName]);
							
							var pss:Vector.<ProgramSettingsSource> = settings.getPropertySources(indexName);
							//bytes.writeUnsignedInt(pss[0].textureSamplerState);
							
							len = pss.length;
							
							bytes.writeByte(len);
							
							for (i = 0; i < len; i++) {
								bytes.writeShort(pss[i].indexBytesPostion);
							}
						}
					}
					
					count = 0;
					indices = settings.getIndices(PropertyOptionalParamType.CONSTANTS);
					
					for (indexName in indices) {
						count++;
					}
					
					bytes.writeByte(count);
					
					for (indexName in indices) {
						bytes.writeUTF(indexName);
						bytes.writeByte(indices[indexName]);
						
						consts.push(indexName);
					}
				}
				
				var num:uint = consts.length;
				bytes.writeByte(num);
				for (j = 0; j < num; j++) {
					var name:String = consts[j];
					
					var cp:FunctionData = _memberManager.getProperty(name);
					bytes.writeUTF(name);
					bytes.writeUTF(cp.optionalParams[PropertyOptionalParamType.NAME]);
					bytes.writeByte(cp.optionalParams[PropertyOptionalParamType.LENGTH]);
					var values:Vector.<Number> = cp.optionalParams[PropertyOptionalParamType.VALUES];
					if (values == null) {
						bytes.writeBoolean(false);
					} else {
						bytes.writeBoolean(true);
						
						len = values.length;
						for (i = 0; i < len; i++) {
							bytes.writeFloat(values[i]);
						}
					}
				}
				
				//=====================================
				
				bytes1.length = 0;
				
				bytes1.writeShort(vert.length);
				bytes1.writeBytes(vert);
				
				bytes1.writeShort(frag.length);
				bytes1.writeBytes(frag);
				
				bytes.writeBytes(bytes1);
				
				bytes.writeUTF(MD5.hashBinary(bytes1));
			}
			
			op = null;
			
			return bytes;
		}
		
		private function _parseProgram(code:String, isInternal:Boolean):OpcodeProgram {
			_memberManager.reset();
			
			var op:OpcodeProgram;
			
			if (!isInternal) {
				_defineTable.clear();
				_functionTable.clear();
				
				op = new OpcodeProgram();
			}
			
			_scopeAccumulator = 0;
			
			var index:int;
			var i:uint;
			var s:String;
			var temp:String;
			var len:uint = code.length;
			
			while (true) {
				index = code.search(/\/\//);
				if (index == -1) {
					break;
				} else {
					temp = code.substr(index + 2);
					code = code.substr(0, index) + temp.substr(temp.search(/[\r\n]/) + 1);
				}
			}
			
			while (true) {
				index = code.search(/\/\*/);
				if (index == -1) {
					break;
				} else {
					temp = code.substr(index + 2);
					code = code.substr(0, index) + temp.substr(temp.search(/\*\//) + 2);
				}
			}
			
			var scriptName:String = '';
			
			index = code.indexOf('#name ');
			if (index != -1) {
				len = code.length;
				
				for (i = index + 6; i < len; i++) {
					s = code.charAt(i);
					if (scriptName == '' && s.search(/\s/) != -1) continue;
					
					if (s == ';') {
						code = code.substr(0, index) + code.substr(i + 1);
						
						break;
					} else {
						scriptName += s;
					}
				}
			}
			
			var compileParameters:Object = {};
			
			while (true) {
				index = code.indexOf('#compile ');
				if (index == -1) {
					break;
				} else {
					len = code.length;
					var compileParams:String = '';
					for (i = index + 9; i < len; i++) {
						s = code.charAt(i);
						if (s == ';') {
							code = code.substr(0, index) + code.substr(i + 1);
							break;
						} else {
							compileParams += s;
						}
					}
					
					var cp:CompileParameter = CompileParameter.create(compileParams);
					compileParameters[cp.name] = cp;
				}
			}
			
			if (isInternal) {
				if (scriptName != '') {
					_includeMap[scriptName] = true;
				}
				
				compileParameters = {};
			} else {
				op.name = scriptName;
			}
			
			while (true) {
				var includeName:String = '';
				
				index = code.search(/\binclude /);
				if (index == -1) {
					break;
				} else {
					len = code.length;
					
					for (i = index + 8; i < len; i++) {
						s = code.charAt(i);
						if (includeName == '' && s.search(/\s/) != -1) continue;
						
						if (s == ';') {
							code = code.substr(0, index) + code.substr(i + 1);
							
							break;
						} else {
							includeName += s;
						}
					}
					
					if (includeName != '') {
						if (!(includeName in _includeMap)) includeScript(ShaderScriptLibs.getLib(includeName));
					}
				}
			}
			
			var vertProgram:String = null;
			var fragProgram:String = null;
			
			while (true) {
				var program:String = '';
				
				index = code.search(/\bprogram /);
				if (index == -1) {
					break;
				} else {
					len = code.length;
					
					for (i = index + 8; i < len; i++) {
						s = code.charAt(i);
						if (program == '' && s.search(/\s/) != -1) continue;
						
						if (s == ';') {
							code = code.substr(0, index) + code.substr(i + 1);
							
							break;
						} else {
							program += s;
						}
					}
					
					if (program != '') {
						program = Util.formatSpace(program);
						var params:Array = program.split(' ');
						if (params.length > 1) {
							if (params[0] == 'vertex') {
								vertProgram = params[1];
							} else if (params[0] == 'fragment') {
								fragProgram = params[1];
							}
						}
					}
				}
			}
			
			code = code.replace(/[\r\n]/g, '');
			code = OperatorSymbol.replaceSymbol(code);
			//code = code.replace(/\s/g, '');
			
			var funcs:Vector.<String> = new Vector.<String>();
			len = code.length;
			var count:int = 0;
			index = 0;
			for (i = 0; i < len; i++) {
				s = code.charAt(i);
				
				if (s == '{') {
					count++;
				} else if (s == '}') {
					count--;
					if (count < 0) {
						throw new Error('code error');
					} else if (count == 0) {
						funcs.push(code.substring(index, i + 1));
						index = i + 1;
					}
				} else if (count == 0) {
					if (s == ';') {
						funcs.push(code.substring(index, i + 1));
						index = i + 1;
					}
				}
			}
			
			if (!isInternal && _printMsg) {
				trace('\nname : ' + scriptName);
			}
			
			var compileEach:CompileEach = compileParameters[CompileParameter.EACH];
			if (compileEach == null || compileEach.define.length == 0) {
				_parse(op, isInternal, vertProgram, fragProgram, funcs, null, null);
			} else {
				op.setDefine(compileEach.define);
				
				_compileEach(op, isInternal, vertProgram, fragProgram, funcs, compileEach.define, 0, new Vector.<int>());
			}
			
			return op;
		}
		private function _compileEach(op:OpcodeProgram, isInternal:Boolean, vertProgram:String, fragProgram:String, funcs:Vector.<String>, define:Vector.<CompileEachDefine>, index:uint, activeIndices:Vector.<int>):void {
			var group:CompileEachDefine = define[index];
			var len:uint = group.values.length;
			
			for (var i:uint = 0; i < len; i++) {
				activeIndices[index] = i;
				if (index + 1 < define.length) {
					_compileEach(op, isInternal, vertProgram, fragProgram, funcs, define, index + 1, activeIndices);
				} else {
					_parse(op, isInternal, vertProgram, fragProgram, funcs, define, activeIndices);
				}
			}
		}
		private function _parse(op:OpcodeProgram, isInternal:Boolean, vertProgram:String, fragProgram:String, funcs:Vector.<String>, define:Vector.<CompileEachDefine>, activeIndices:Vector.<int>):void {
			var defineParams:String = '';
			
			if (define != null) {
				var num:uint = define.length;
				for (var j:uint = 0; j < num; j++) {
					var group:CompileEachDefine = define[j];
					
					var defineValue:String = group.values[activeIndices[j]];
					_defineTable.setReplace(group.name, defineValue);
					
					defineParams += group.name + '[' + defineValue + '] ';
				}
			}
			
			var varyingMap:Object = {};
			
			var vertFunc:FunctionData = null;
			var fragFunc:FunctionData = null;
			
			var len:uint = funcs.length;
			for (var i:uint = 0; i < len; i++) {
				var func:String = funcs[i];
				
				var data:FunctionData = new FunctionData(func);
				if (data.code != null) {
					var src:String = data.code;
					
					var runBrance:Boolean = !isInternal && ((vertProgram != null && data.name == vertProgram) || (fragProgram != null && data.name == fragProgram));
					
					while (true) {
						if (runBrance) data.code = _defineTable.staticBranch(data.code);
						data.code = _defineTable.expand(data.code);
						
						if (src == data.code) {
							break;
						} else {
							src = data.code;
						}
					}
				}
				
				if (data.type == FunctionType.DEFINE) {
					_defineTable.setDefine(data, isInternal);
				} else if (data.type == FunctionType.PROPERTY) {
					_memberManager.setProperty(data.name, data, isInternal);
					//trace(data);
				} else if (data.type == FunctionType.STRUCT) {
					var struct:Struct = new Struct(data.name, data.code);
					_memberManager.addStructPrototype(struct, isInternal);
				} else if (data.type == FunctionType.FUNCTION) {
					var setToTable:Boolean = true;
					if (!isInternal) {
						if (vertProgram != null && data.name == vertProgram) {
							vertFunc = data;
							if (vertFunc.code.indexOf('compileContinue()') != -1) vertFunc = null;
							
							setToTable = false;
						}
						if (fragProgram != null && data.name == fragProgram) {
							fragFunc = data;
							if (fragFunc.code.indexOf('compileContinue()') != -1) fragFunc = null;
							
							setToTable = false;
						}
					}
					
					if (setToTable) _functionTable.setFunc(data, isInternal);
				}
			}
			
			if (vertFunc != null && fragFunc != null) {
				if (_printMsg) {
					trace('\ndefine : ' + defineParams);
				}
				
				var vertOpcodes:Vector.<Opcode> = parseFunc(vertFunc, 'main_');
				//trace('\nsrc vert:');
				//trace(Opcode.toString(vertOpcodes));
				
				op.vert.push(_programFormater.format(Context3DProgramType.VERTEX, vertOpcodes, vertFunc.params[0], 'main_', _memberManager, varyingMap));
				
				if (_printMsg) {
					//trace('\nname : ' + scriptName);
					trace('\nfinal vert:' + Opcode.toString(vertOpcodes));
				}
				
				//_debugger = true;
				var fragOpcodes:Vector.<Opcode> = parseFunc(fragFunc, 'main_');
				//trace('\nsrc frag:');
				//trace(Opcode.toString(fragOpcodes));
				//trace();
				
				op.frag.push(_programFormater.format(Context3DProgramType.FRAGMENT, fragOpcodes, fragFunc.params[0], 'main_', _memberManager, varyingMap));
				
				if (_printMsg) {
					trace('\nfinal frag:' + Opcode.toString(fragOpcodes));
				}
				
				op.appendDefineActiveIndices(activeIndices);
			}
		}
		public function parseFunc(data:FunctionData, scope:String=null):Vector.<Opcode> {
			var opcodes:Vector.<Opcode> = new Vector.<Opcode>();
			
			var len:uint = data.params.length;
			for (var i:uint = 0; i < len; i++) {
				var param:Opcode = new Opcode();
				param.dest = data.params[i].clone();
				param.dest.setName(scope, param.dest.name);
				opcodes.push(param);
				
				_memberManager.setType(param.dest.fullName, param.dest.type);
			}
			
			var code:String = data.code;
			
			var lines:Array = code.split(';');
			len = lines.length;
			for (i = 0; i < len; i++) {
				var line:String = lines[i];
				
				var index:int = line.search(/\/\//);
				if (index != -1) {
					line = line.substr(0, index);
				}
				
				index = line.search(/=/);
				
				var codeLeft:String = null;
				var codeRight:String = null;
				var operator:String = null;
				var formatLeft:Array = null;
				
				if (index == -1) {
					codeRight = line;
				} else {
					codeLeft = line.substr(0, index);

					formatLeft = _formatLeft(codeLeft);
					
					codeLeft = formatLeft[0];
					operator = formatLeft[1];
					
					codeRight = line.substr(index + 1);
				}
				
				var isReturn:Boolean = false;
				
				if (codeRight != null) {
					isReturn = codeRight.search(/\s*return\s+/) != -1;
					
					if (isReturn) {
						codeRight = codeRight.replace(/\s*return\s+/, '');
					} else {
						if (codeLeft == null) {
							if (codeRight.search(/[\+\-\*\/\(]/) == -1) {
								codeLeft = codeRight;
								codeRight = null;
								
								formatLeft = _formatLeft(codeLeft);
								
								codeLeft = formatLeft[0];
								operator = formatLeft[1];
							}
						}
					}
					
					if (codeRight != null) {
						codeRight = codeRight.replace(/\s/g, '');
						
						if (isReturn) codeRight = 'return(' + codeRight + ')';
					}
				}
				
				var leftOpcodes:Vector.<Opcode> = null;
				var rightOpcodes:Vector.<Opcode> = null;
				
				
				if (codeLeft != null) {
					var left:Vector.<CodeSegment> = _codeSegmentParser.parse(codeLeft, scope, _functionTable);
					leftOpcodes = _opcodeParser.parse(_memberManager, _functionTable, left);
					opcodes = opcodes.concat(leftOpcodes);
					
					//trace(SSLOpcode.toString(leftOpcodes));
				}
				
				if (codeRight != null) {
					var right:Vector.<CodeSegment> = _codeSegmentParser.parse(codeRight, scope, _functionTable);
					rightOpcodes = _opcodeParser.parse(_memberManager, _functionTable, right);
					opcodes = opcodes.concat(rightOpcodes);
					
					//trace(SSLOpcode.toString(rightOpcodes));
				}
				
				//trace(SSLOpcode.toString(opcodes));
				
				if (operator != null) {
					if (leftOpcodes != null && leftOpcodes.length > 0 && rightOpcodes != null && rightOpcodes.length > 0) {
						var leftDest:Opcode = leftOpcodes[int(leftOpcodes.length - 1)];
						var rightDest:Opcode = rightOpcodes[int(rightOpcodes.length - 1)];
						
						var oc:Opcode = new Opcode();
						oc.copyDest(leftDest.dest);
						oc.setFunc(operator);
						oc.args = new Vector.<Variable>();
						
						if (operator == OperatorSymbol.EQUAL) {
							oc.copyArgs(0, rightDest.dest);
						} else {
							oc.copyArgs(0, leftDest.dest);
							oc.copyArgs(1, rightDest.dest);
						}
						
						opcodes.push(oc);
					}
				}
			}
			
//			trace(Opcode.toString(opcodes));
//			trace();
			
			_expandStruct(opcodes);
			
//			trace(Opcode.toString(opcodes));
//			trace();
			
			_deduceType(opcodes);
			
//			trace(Opcode.toString(opcodes));
//			trace();
			
			opcodes = _expandFunc(opcodes);
			
//			trace(Opcode.toString(opcodes));
//			trace();
			
			_expandStruct(opcodes);
			
//			trace(Opcode.toString(opcodes));
//			trace();
			
			_deduceType(opcodes);
			
//			trace(Opcode.toString(opcodes));
//			trace();
			
			opcodes = _opcodeOptimizer.optimize(opcodes, _memberManager);
			
//			trace(Opcode.toString(opcodes));
//			trace();
			
			return opcodes;
			
			//trace(SSLOpcode.toString(opcodes));
		}
		private function _expandFunc(opcodes:Vector.<Opcode>):Vector.<Opcode> {
			var len:uint = opcodes.length;
			for (var i:uint = 0; i<len; i++) {
				var opcode:Opcode = opcodes[i];
				if (opcode.func != null) {
					var funcOpcodes:Vector.<Opcode> = _functionTable.expand(opcode, this, _memberManager);
					if (funcOpcodes == null) {
						//trace(opcode);
					} else {
						var returnOc:Opcode = null;
						var lastFuncOc:Opcode = funcOpcodes[int(funcOpcodes.length - 1)];
						if (lastFuncOc.func == BaseFunctionType.RETURN) {
							returnOc = new Opcode();
							returnOc.dest = _memberManager.createVariable(lastFuncOc.dest.type);
							returnOc.func = BaseFunctionType._MOVE;
							returnOc.copyArgs(0, lastFuncOc.args[0]);
							_memberManager.setType(returnOc.dest.fullName, returnOc.dest.type);
							
							funcOpcodes[int(funcOpcodes.length - 1)] = returnOc;
						}
						
						if (opcode.dest != null) {
							if (returnOc == null) {
								//error	
							} else {
								var moveOc:Opcode = new Opcode();
								moveOc.copyDest(opcode.dest);
								moveOc.func = BaseFunctionType._MOVE;
								moveOc.copyArgs(0, returnOc.dest);
								
								funcOpcodes.push(moveOc);
							}
						}
						//trace(SSLOpcode.toString(opcodes));
						//trace(SSLOpcode.toString(funcOpcodes));
						var old:Vector.<Opcode> = opcodes;
						opcodes = old.slice(0, i);
						opcodes = opcodes.concat(funcOpcodes);
						opcodes = opcodes.concat(old.slice(i + 1));
						//opcodes.s
						
						var offset:int = funcOpcodes.length - 1;
						len += offset;
						i += offset;
					}
				}
			}
			return opcodes;
		}
		private function _expandStruct(opcodes:Vector.<Opcode>):void {
			var len:int = opcodes.length;
			for (var i:int = 0; i < len; i++) {
				var opcode:Opcode = opcodes[i];
				if (opcode.dest != null) {
					_expandStructForVariable(opcode.dest);
				}
				
				if (opcode.args != null) {
					var num:uint = opcode.args.length;
					for (var j:int = 0; j < num; j++) {
						_expandStructForVariable(opcode.args[j]);
					}
				}
				
				if (opcode.func == BaseFunctionType._MOVE) {
					if (_memberManager.getStructPrototype(opcode.dest.type) != null) {
						var isRoot:Boolean = true;
						var destRef:Variable = opcode.dest.getMemberReference(_memberManager);
						var memberName:String = destRef.memberName;
						
						if (destRef.parent != null) {
							isRoot = false;
							destRef = destRef.parent;
						}
						
						var arg:Variable = opcode.args[0];
						var clo:Variable;
						
						if (isRoot) {
							clo = arg.getMemberReference(_memberManager).clone();
							clo.parent = null;
							_memberManager.setReference(destRef.fullName, clo);
						} else {
							var ref:Variable = _memberManager.getReference(arg.fullName);
							clo = ref == null ? arg.clone() : ref.clone();
							clo.parent = destRef;
							clo.memberName = memberName;
							destRef.members[clo.memberName] = clo;
						}
					}
				}
			}
		}
		private function _expandStructForVariable(v:Variable):void {
			_setStructReference(v, null);
			
			var ref:Variable = v.getMemberReference(_memberManager);
			if (ref != null) {
				v.type = ref.type;
				v.setName(ref.scope, ref.name);
				v.component = ref.component;
			}
		}
		private function _setStructReference(v:Variable, structRef:Variable):void {
			var ref:Variable;
			
			var type:String = v.type;
			var fullName:String = v.fullName;
			
			if (type == null) type = _memberManager.getType(fullName);
			
			if (type != null) {
				var struct:Struct = _memberManager.getStructPrototype(type);
				if (struct == null) {
					if (structRef != null) {
						ref = _memberManager.createVariable(type, structRef.scope);
						
						structRef.members[v.name] = ref;
						ref.memberName = v.name;
						ref.parent = structRef;
						
						_memberManager.setType(ref.fullName, type);
						
						_memberManager.setReference(ref.fullName, ref);
					}
				} else {
					var b:Boolean = false;
					
					if (structRef == null) {
						if (_memberManager.getReference(fullName) == null) {
							b = true;
							
							ref = v.clone();
							ref.component = null;
							ref.parent = null;
							ref.memberName = null;
						}
					} else {
						b = true;
						
						ref = _memberManager.createVariable(type, structRef.scope);
						
						structRef.members[v.name] = ref;
						ref.memberName = v.name;
						ref.parent = structRef;
					}
					
					if (b) {
						_memberManager.setReference(ref.fullName, ref);
						
						ref.members = {};
						
						_memberManager.setType(ref.fullName, type);
						
						var len:uint = struct.members.length;
						for (var i:uint = 0; i < len; i++) {
							_setStructReference(struct.members[i], ref);
						}
					}
				}
			}
		}
		private function _deduceType(opcodes:Vector.<Opcode>):void {
			var len:uint = opcodes.length;
			for (var i:uint = 0; i < len; i++) {
				var opcode:Opcode = opcodes[i];
				
				var arg1:Variable = null;
				var arg2:Variable = null;
				var arg:Variable = null;
				
				var type:String;
				
				if (opcode.args != null) {
					var num:uint = opcode.args.length;
					for (var j:uint = 0; j < num; j++) {
						arg = opcode.args[j];
						if (arg.type == null) {
							type = _memberManager.getType(arg.fullName);
							if (type != null) arg.type = type;
						}
					}
				}
				
				if (opcode.dest != null) {
					if (opcode.dest.type == null) {
						type = _memberManager.getType(opcode.dest.fullName);
						if (type == null) {
							if (opcode.func == BaseFunctionType._ADD ||
								opcode.func == BaseFunctionType._SUB ||
								opcode.func == BaseFunctionType._MUL ||
								opcode.func == BaseFunctionType._DIV ||
								opcode.func == BaseFunctionType._IS_LESS ||
								opcode.func == BaseFunctionType._IS_EQUAL ||
								opcode.func == BaseFunctionType._IS_NOT_EQUAL ||
								opcode.func == BaseFunctionType._IS_GREATER_EQUAL) {
								arg1 = opcode.args[0];
								arg2 = opcode.args[1];
								if (arg1.getTypeWithComponent(_memberManager) == arg2.getTypeWithComponent(_memberManager) ) {
									opcode.dest.type = arg1.getTypeWithComponent(_memberManager) ;
								} else {
									var useCount1:uint;
									if (Util.isNumber(arg1.name, arg1.component)) {
										useCount1 = 1;
									} else {
										useCount1 = BaseVariableType.getFloatUseComponentCount(arg1.type, arg1.component);
									}
									
									var useCount2:uint;
									if (Util.isNumber(arg2.name, arg2.component)) {
										useCount2 = 1;
									} else {
										useCount2 = BaseVariableType.getFloatUseComponentCount(arg2.type, arg2.component);
									}
									
									arg = null;
									if (useCount1 == 1) {
										arg = arg2;
									} else if (useCount2 == 1) {
										arg = arg1;
									}
									
									if (arg != null) {
										opcode.dest.type = BaseVariableType.getFloatTypeFromComponent(arg.type, arg.component);
									}
								}
							} else if (opcode.func == BaseFunctionType.RETURN) {
								arg1 = opcode.args[0];
								opcode.dest.type = arg1.getTypeWithComponent(_memberManager) ;
							} else if (opcode.func == BaseFunctionType._MOVE || opcode.func == BaseFunctionType._NEG) {
								arg1 = opcode.args[0];
								
								if (opcode.dest.component == null) {
									if (arg1.component == null) {
										opcode.dest.type = arg1.type;
									} else {
										opcode.dest.type = arg1.getTypeWithComponent(_memberManager) ;
									}
								}
							} else {
								var returnType:String = _functionTable.getFuncType(opcode.func, opcode.args, _memberManager);
								if (returnType == BaseVariableType.VOID) {
									opcode.dest = null;
								} else {
									opcode.dest.type = returnType;
								}
							}
							
							if (opcode.dest != null && opcode.dest.type != null) _memberManager.setType(opcode.dest.fullName, opcode.dest.type);
						} else {
							opcode.dest.type = type;
						}
					}
				}
			}
		}
		private function _formatLeft(code:String):Array {
			var operator:String = null;
			var operatorIndex:int = code.search(/[\+\-\*\/]/);
			if (operatorIndex == -1) {
				operator = OperatorSymbol.EQUAL;
			} else {
				operator = code.charAt(operatorIndex);
				code = code.substring(0, operatorIndex);
			}
			
			code = Util.formatSpace(code);
			
			return [code, operator];
		}
	}
}
import asgl.shaders.scripts.compiler.CompileEachDefine;
import asgl.shaders.scripts.compiler.Opcode;

class OpcodeProgram {
	public var name:String = '';
	
	public var vert:Vector.<Vector.<Opcode>>;
	public var frag:Vector.<Vector.<Opcode>>;
	
	public var maskValues:Vector.<uint>;
	
	public var maskNames:Vector.<String>;
	public var maskBits:Vector.<uint>;
	public var valueOffset:Vector.<int>;
	
	private var _define:Vector.<CompileEachDefine>;
	
	public function OpcodeProgram() {
		vert = new Vector.<Vector.<Opcode>>();
		frag = new Vector.<Vector.<Opcode>>();
		
		_define = new Vector.<CompileEachDefine>();
		
		maskNames = new Vector.<String>();
		maskBits = new Vector.<uint>();
		valueOffset = new Vector.<int>();
		maskValues = new Vector.<uint>();
	}
	public function setDefine(define:Vector.<CompileEachDefine>):void {
		_define = define;
		
		var bits:uint = 0;
		var len:uint = _define.length;
		for (var i:uint = 0; i < len; i++) {
			maskNames[i] = _define[i].name;
			maskBits[i] = bits;
			valueOffset[i] = -_define[i].min;
			bits += _define[i].bits;
		}
	}
	public function appendDefineActiveIndices(indices:Vector.<int>):void {
		var maskValue:uint = 0;
		
		if (indices != null) {
			var len:uint = _define.length;
			for (var i:uint = 0; i < len; i++) {
				var group:CompileEachDefine = _define[i];
				
				var value:int = group.values[indices[i]] + valueOffset[i];
				var index:int = maskNames.indexOf(group.name);
				
				maskValue |= (value << maskBits[index]);
			}
		}
		
		maskValues.push(maskValue);
	}
}