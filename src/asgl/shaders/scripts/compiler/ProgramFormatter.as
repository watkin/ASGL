package asgl.shaders.scripts.compiler {
	import flash.display3D.Context3DProgramType;

	public class ProgramFormatter implements IProgramFormatter {
		private var _floatComponent:Object;
		private var _componentValues:Object;
		private var _regCountMap:Object;
		private var _mm:IMemberManager;
		private var _programType:String;
		private var _usingMaxTemporary:uint;
		private var _temporaryPool:Vector.<TemporaryData>;
		
		public function ProgramFormatter() {
			_floatComponent = {};
			_floatComponent[BaseVariableType.FLOAT] = 'w';
			_floatComponent[BaseVariableType.FLOAT_2] = 'xy';
			_floatComponent[BaseVariableType.FLOAT_3] = 'xyz';
			_floatComponent[BaseVariableType.FLOAT_4] = 'xyzw';
			
			_componentValues = {};
			_componentValues['x'] = 0;
			_componentValues['y'] = 1;
			_componentValues['z'] = 2;
			_componentValues['w'] = 3;
			
			_temporaryPool = new Vector.<TemporaryData>();
		}
		public function format(programType:String, opcodes:Vector.<Opcode>, param:Variable, scope:String, mm:IMemberManager, varyingMap:Object):Vector.<Opcode> {
			_programType = programType;
			_mm = mm;
			
			_temporaryPool.length = 0;
			_regCountMap = {};
			
//			trace(Opcode.toString(opcodes));
			_replace(opcodes, param, scope, mm, varyingMap);
//			trace(Opcode.toString(opcodes));
			_deleteUselessTemporary(opcodes);
			//trace(Opcode.toString(opcodes));
			do {
				_replaceRegister(opcodes);
			} while (_precomputedNumber(opcodes));
//			trace(Opcode.toString(opcodes));
			//_replaceRegister(opcodes);
			//trace(Opcode.toString(opcodes));
			_constDetection(opcodes);
			//trace(Opcode.toString(opcodes));
			_abridgeTemporary(opcodes);
			//trace(Opcode.toString(opcodes));
			//_multiplexTemporary(opcodes);
			//_abridgeTemporary(opcodes);
			_replaceProperty(opcodes);
			
			_programType = null;
			_mm = null;
			
			return opcodes;
		}
		private function _replace(opcodes:Vector.<Opcode>, param:Variable, scope:String, mm:IMemberManager, varyingMap:Object):void {
			var inoutStruct:Variable = mm.getReference(Variable.getFullName(scope, param.name));
			var isVaryings:Object = {};
			var varyings:Object = {};
			var varyingIndex:uint = 0;
			
			var name:String;
			for (name in inoutStruct.members) {
				var vary:Variable = inoutStruct.members[name];
				isVaryings[vary.fullName] = name;
			}
			
			var tempMap:Object = {};
			var tempComMap:Object = {};
			_usingMaxTemporary = 10000;
			var memberName:String;
			
			var len:uint = opcodes.length;
			
			for (var i:uint = 0; i < len; i++) {
				var opcode:Opcode = opcodes[i];
				
				var arg1:Variable = null;
				var count:uint;
				
				var args:Vector.<Variable> = opcode.args;
				if (args != null) {
					var num:uint = args.length;
					for (var j:uint = 0; j < num; j++) {
						arg1 = args[j];
						
						var replaceTemp:Boolean = false;
						
						if (_programType == Context3DProgramType.VERTEX) {
							replaceTemp = true;
						} else {
							memberName = isVaryings[arg1.fullName];
							if (memberName == null) {
								replaceTemp = true;
							} else {
								arg1.setName(arg1.scope, varyingMap[memberName]);
								if (arg1.component == null) arg1.component = 'xyzw';
								arg1.type = BaseVariableType.VARYING;
							}
						}
						
						if (replaceTemp) {
							if (tempMap[arg1.fullName] == null) {
								if (!Util.isNumber(arg1.name, arg1.component) && !Util.isString(arg1.name)) {
									if (_isProperty(arg1)) {
										//arg1.setName(arg1.scope, '#'+arg1.name+'#');
									} else {
										count = BaseVariableType.getFloatAvailableComponentCount(arg1.type);
										if (count > 0) {
											name = arg1.fullName;
											arg1.setName(arg1.scope, _getTemporary() + (_usingMaxTemporary++));
											_appendRegister(arg1.name);
											tempMap[name]  = arg1.name;
											if (count < 4 && arg1.component == null) {
												arg1.component = _floatComponent[arg1.type];
												tempComMap[name] = arg1.component;
											}
											if (arg1.component == null) arg1.component = 'xyzw';
											arg1.type = _getTemporary();
										}
									}
								}
							} else {
								name = arg1.fullName;
								arg1.type = _getTemporary();
								arg1.setName(arg1.scope, tempMap[name]);
								_appendRegister(arg1.name);
								if (arg1.component == null && tempComMap[name] != null) arg1.component = tempComMap[name];
								if (arg1.component == null) arg1.component = 'xyzw';
							}
						}
					}
				}
				
				if (opcode.func == BaseFunctionType.RETURN) {
					var struct:Struct = mm.getStructPrototype(opcode.dest.type);
					if (struct == null) {
						opcode.func = BaseFunctionType._MOVE;
						opcode.dest.type = _getOutput();
						opcode.dest.setName(opcode.dest.scope, _getOutput());
						if (opcode.dest.component == null) opcode.dest.component = 'xyzw';
						_appendRegister(opcode.dest.name);
					} else {
						opcodes.splice(i, 1);
						i--;
						len--;
						
						var structRef:Variable = opcode.args[0].getMemberReference(mm);
						for (var memName:String in structRef.members) {
							var var1:Variable = struct.membersMap[memName];
							if (var1.tag.search(/COLOR/) == 0) {
								var opIndex:int = int(var1.tag.substr(5));
								var opName:String = _getOutput() + opIndex;
								var opVar:Variable = structRef.members[memName];
								var opOpcode:Opcode = new Opcode();
								opOpcode.func = BaseFunctionType._MOVE;
								opOpcode.dest = new Variable();
								opOpcode.dest.type = opName;
								opOpcode.dest.setName(opOpcode.dest.scope, opName);
								opOpcode.dest.component = 'xyzw';
								opOpcode.args = new Vector.<Variable>(1);
								opOpcode.args[0] = new Variable();
								opOpcode.args[0].type = opVar.type;
								opOpcode.args[0].setName(opVar.scope, tempMap[opVar.fullName]);
								_appendRegister(opOpcode.dest.name);
								
								opcodes.splice(++i, 0, opOpcode);
								len++;
							}
						}
					}
				} else {
					if (opcode.func == BaseFunctionType.ATTRIBUTE) {
						arg1 = opcode.args[0];
						if (Util.isNumber(arg1.name, arg1.component)) {
							opcode.func = BaseFunctionType._MOVE;
							arg1.type = BaseVariableType.VERTEX_ATTRIBUTE;
							arg1.setName(arg1.scope, BaseVariableType.VERTEX_ATTRIBUTE + uint(arg1.name));
							if (arg1.component == null) arg1.component = 'xyzw';
							_appendRegister(arg1.name);
						} else if (_isProperty(arg1)) {
							opcode.func = BaseFunctionType._MOVE;
							arg1.type = BaseVariableType.VERTEX_ATTRIBUTE;
							arg1.setName(arg1.scope, BaseVariableType.VERTEX_ATTRIBUTE + '#' + arg1.name + '#');
							if (arg1.component == null) arg1.component = 'xyzw';
							//_appendReg(arg1.name);
						}
					} else if (opcode.func == BaseFunctionType.CONSTANT) {
						var v:Variable;
						
						arg1 = opcode.args[0];
						if (Util.isNumber(arg1.name, arg1.component)) {
							opcode.func = BaseFunctionType._MOVE;
							arg1.type = _getConstant();
							
							if (opcode.args.length > 1) {
								arg1.setName(arg1.scope, _getConstant() + (uint(arg1.name) + uint(opcode.args[1].name)));
							} else {
								arg1.setName(arg1.scope, _getConstant() + uint(arg1.name));
							}
							if (arg1.component == null) arg1.component = 'xyzw';
							
							_appendRegister(arg1.name);
						} else if (_isProperty(arg1)) {
							opcode.func = BaseFunctionType._MOVE;
							arg1.setName(arg1.scope, _getConstant() + '#' + arg1.name + '#');
							if (arg1.component == null) arg1.component = 'xyzw';
							
							if (opcode.args.length == 1) {
								arg1.type = _getConstant();
							} else {
								opcode.func = BaseFunctionType._MOVE;
								v = new Variable();
								v.args = opcode.args;
								v.type = _getConstant();
								opcode.args = new Vector.<Variable>();
								opcode.args[0] = v;
							}
							//_appendReg(arg1.name);
						} else {
							opcode.func = BaseFunctionType._MOVE;
							v = new Variable();
							v.args = opcode.args;
							v.type = _getConstant();
							opcode.args = new Vector.<Variable>();
							opcode.args[0] = v;
						}
					}
					
					if (opcode.dest != null) {
						if (isVaryings[opcode.dest.fullName] == null) {
							var com:String = _floatComponent[opcode.dest.type];
							if (com != null) {
								name = opcode.dest.fullName;
								if (tempMap[name] == null) {
									opcode.dest.setName(opcode.dest.scope, _getTemporary() + (_usingMaxTemporary++));
									_appendRegister(opcode.dest.name);
									tempMap[name] = opcode.dest.name;
									if (com != '' && opcode.dest.component == null) {
										opcode.dest.component = com;
									}
									count = BaseVariableType.getFloatAvailableComponentCount(opcode.dest.type);
									if (count < 4) {
										tempComMap[name] = com;
									}
									if (opcode.dest.component == null) opcode.dest.component = 'xyzw';
								} else {
									opcode.dest.setName(opcode.dest.scope, tempMap[name]);
									if (opcode.dest.component == null) {
										opcode.dest.component = _floatComponent[BaseVariableType.getFloatTypeFromComponent(opcode.dest.type, opcode.dest.component, false)];
										if (opcode.dest.component == null) opcode.dest.component = 'xyzw';
									}
									_appendRegister(opcode.dest.name);
									
									/*
									if (opcode.func == BaseFunctionType._MOVE) {
										if (opcode.dest.component == null) {
											arg1 = opcode.args[0];
											if (arg1.component != null) {
												opcode.dest.component = tempComMap[name];
											}
										}
									}
									*/
								}
								opcode.dest.type = _getTemporary();
							}
						} else if (_programType == Context3DProgramType.VERTEX) {
							opcode.dest.type = BaseVariableType.VARYING;
							if (varyings[opcode.dest.fullName] == null) {
								memberName = isVaryings[opcode.dest.fullName];
								
								name = opcode.dest.fullName;
								opcode.dest.setName(opcode.dest.scope, BaseVariableType.VARYING + (varyingIndex++));
								if (opcode.dest.component == null) opcode.dest.component = 'xyzw';
								_appendRegister(opcode.dest.name);
								varyings[name] = opcode.dest.name;
								
								varyingMap[memberName] = opcode.dest.name;
							} else {
								opcode.dest.setName(opcode.dest.scope, varyings[opcode.dest.fullName]);
								if (opcode.dest.component == null) opcode.dest.component = 'xyzw';
								_appendRegister(opcode.dest.name);
							}
						}
					}
				}
			}
		}
		private function _isProperty(v:Variable):Boolean {
			return _mm.getProperty(v.name) != null;
		}
		private function _isConstantProperty(v:Variable):Boolean {
			if (_mm.getType(v.fullName) == null) {
				var data:FunctionData = _mm.getProperty(v.name);
				if (data == null) {
					return false;
				} else {
					if (data.optionalParams.length > 0) {
						return data.optionalParams[0] == PropertyOptionalParamType.CONSTANTS;
					} else {
						return false;
					}
				}
			} else {
				return false;
			}
		}
		private function _appendRegister(name:String):void {
			if (_regCountMap[name] == null) {
				_regCountMap[name] = 1;
			} else {
				_regCountMap[name]++;
			}
		}
		private function _removeRegister(name:String, opcodes:Vector.<Opcode>, handler:Function=null):void {
			if (_regCountMap[name] != null) {
				if (_regCountMap[name] == 1) {
					delete _regCountMap[name];
					
					var index:int = name.search(/[0-9]/);
					if (index != -1) {
						var type:String = name.substr(0, index);
						
						if (type == _getConstant()) _usingMaxTemporary--;
						
						index = uint(name.substr(index));
						var newName:String = name;
						var oldName:String = type+(++index);
						while (true) {
							var count:uint = _replaceRegisterNameFromOpcodes(opcodes, oldName, newName);
							if (count == 0) {
								break;
							} else {
								if (handler != null) handler(oldName, newName);
								
								delete _regCountMap[oldName];
								_regCountMap[newName] = count;
								
								newName = oldName;
								oldName = type+(++index);
							}
						}
					}
				} else {
					_regCountMap[name]--;
				}
			}
		}
		private function _removeRegisterFromOpcode(opcode:Opcode, opcodes:Vector.<Opcode>):void {
			var map:Object = {};
			if (opcode.dest != null) _removeRegister(opcode.dest.name, opcodes);
			var args:Vector.<Variable> = opcode.args;
			if (args != null) {
				var num:uint = args.length;
				for (var j:uint = 0; j < num; j++) {
					var arg:Variable = args[j];
					_removeRegister(arg.name, opcodes);
				}
			}
		}
		private function _replaceRegisterNameFromOpcodes(opcodes:Vector.<Opcode>, oldName:String, newName:String, oldComponent:String=null, newComponent:String=null):uint {
			var count:uint = 0;
			
			var len:uint = opcodes.length;
			
			for (var i:uint = 0; i < len; i++) {
				var opcode:Opcode = opcodes[i];
				
				if (opcode.dest != null) {
					var finalOldName:String = oldName;
					if (oldComponent != null) finalOldName += '.' + oldComponent;
					
					var finalNewName:String = newName;
					if (newComponent != null) finalNewName += '.' + newComponent;
					
					var name:String = oldComponent == null ? opcode.dest.name : opcode.dest.nameWithComponent;
					if (finalOldName == name) {
						opcode.dest.setName(opcode.dest.scope, newName);
						if (newComponent != null) opcode.dest.component = newComponent;
						count++;
					}
				}
				
				var args:Vector.<Variable> = opcode.args;
				if (args != null) {
					var num:uint = args.length;
					for (var j:uint = 0; j < num; j++) {
						count += _replaceRegisterName(args[j], oldName, newName, oldComponent, newComponent);
					}
				}
			}
			
			return count;
		}
		private function _replaceRegisterName(v:Variable, oldName:String, newName:String, oldComponent:String=null, newComponent:String=null):uint {
			var count:uint = 0;
			
			var finalOldName:String = oldName;
			if (oldComponent != null) finalOldName += '.' + oldComponent;
			
			var finalNewName:String = newName;
			if (newComponent != null) finalNewName += '.' + newComponent;
			
			if (finalOldName != finalNewName) {
				var name:String = oldComponent == null ? v.name : v.nameWithComponent;
				if (finalOldName == name) {
					v.setName(v.scope, newName);
					if (newComponent != null) v.component = newComponent;
					count++;
				}
				
				if (v.args != null) {
					var len:uint = v.args.length;
					var num:uint = 0;
					for (var i:uint = 0; i < len; i++) {
						num += _replaceRegisterName(v.args[i], oldName, newName, oldComponent, newComponent);
					}
					
					count += num;
				}
			}
			
			return count;
		}
		private function _getFloat4Component(com:String):String {
			if (com == null) {
				return 'xyzw';
			} else {
				return com;
			}
		}
		private function _deleteUselessTemporary(opcodes:Vector.<Opcode>):void {
			var len:uint = opcodes.length;
			
			label1:for (var i:uint = 0; i < len; i++) {
				var opcode:Opcode = opcodes[i];
				if (opcode.dest != null && opcode.dest.type == _getTemporary()) {
					var name:String = opcode.dest.name;
					var mask:String = opcode.dest.component == null ? 'xyzw' : opcode.dest.component;
					
					for (var j:uint = i + 1; j < len; j++) {
						var op:Opcode = opcodes[j];
						var args:Vector.<Variable> = op.args;
						if (args != null) {
							var num:uint = args.length;
							for (var k:uint = 0; k < num; k++) {
								var arg:Variable = args[k];
								if (arg.args == null) {
									if (arg.name == name) {
										if (mask.search(new RegExp('[' + (arg.component == null ? 'xyzw' : arg.component) + ']')) != -1) {
											continue label1;
										}
									}
								} else {
									var num2:uint = arg.args.length;
									for (var l:uint = 0; l < num2; l++) {
										var arg1:Variable = arg.args[l];
										if (arg1.name == name) {
											if (mask.search(new RegExp('[' + (arg1.component == null ? 'xyzw' : arg1.component) + ']')) != -1) {
												continue label1;
											}
										}
									}
								}
							}
						}
						
						if (op.dest != null) {
							if (op.dest.name == name) {
								mask = mask.replace(new RegExp('[' + (op.dest.component == null ? 'xyzw' : op.dest.component) + ']', 'g'), '');
								if (mask == '') {
									opcodes.splice(i, 1);
									
									i--;
									if (len>0) len--;
									
									continue label1;
								}
							}
						}
					}
					
					opcodes.splice(i, 1);
					
					i--;
					if (len > 0) len--;
				}
			}
		}
		private function _precomputedNumber(opcodes:Vector.<Opcode>):Boolean {
			var len:uint = opcodes.length;
			
			var found:Boolean = false;
			
			for (var i:uint = 0; i < len; i++) {
				var opcode:Opcode = opcodes[i];
				
				var args:Vector.<Variable> = opcode.args;
				if (args != null && args.length == 2) {
					var arg0:Variable = args[0];
					var arg1:Variable = args[1];
					
					var isNumber0:Boolean = Util.isNumber(arg0.name, arg0.component);
					var isNumber1:Boolean = Util.isNumber(arg1.name, arg1.component);
					
					if (isNumber0 && isNumber1 && (opcode.func == BaseFunctionType._ADD || 
						opcode.func == BaseFunctionType._SUB ||
						opcode.func == BaseFunctionType._MUL ||
						opcode.func == BaseFunctionType._DIV)) {
						
						var number0:Number = Number(arg0.name + (arg0.component == null ? '' : '.' + arg0.component));
						var number1:Number = Number(arg1.name + (arg1.component == null ? '' : '.' + arg1.component));
						
						var value:Number;
						
						if (opcode.func == BaseFunctionType._ADD) {
							value = number0 + number1;
						} else if (opcode.func == BaseFunctionType._SUB) {
							value = number0 - number1;
						} else if (opcode.func == BaseFunctionType._MUL) {
							value = number0 * number1;
						} else if (opcode.func == BaseFunctionType._DIV) {
							value = number0 / number1;
						}
						
						opcode.func = BaseFunctionType._MOVE;
						args.length = 1;
						
						var index:int = value.toString().search(/\./);
						if (index == -1) {
							arg0.setName(arg0.scope, value.toString());
							arg0.component = null;
						} else {
							arg0.setName(arg0.scope, value.toString().substr(0, index));
							arg0.component = value.toString().substr(index + 1);
						}
						
						found = true;
					}
				}
			}
			
			return found;
		}
		private function _replaceRegister(opcodes:Vector.<Opcode>, aaa:Boolean=false):void {
			var len:uint = opcodes.length;
			
			var arr:Array = [];
			
			label2:for (var i:uint = 0; i < len; i++) {
				var opcode:Opcode = opcodes[i];
				
				if (opcode.dest != null) {
					if (opcode.dest.type == _getTemporary() && opcode.func != null) {
						var reg:RegExp = new RegExp('[' + _getFloat4Component(opcode.dest.component) + ']', 'g');
						
						var k:uint;
						var num:uint;
						var args:Vector.<Variable>;
						var arg:Variable;
						var op2:Opcode;
						arr.length = 0;
						
						label1:for (var j:uint = i + 1; j < len; j++) {
							op2 = opcodes[j];
							
							args = op2.args;
							if (args != null) {
								num = args.length;
								for (k = 0; k < num; k++) {
									arg = args[k];
									if (arg.args == null) {
										if (arg.name == opcode.dest.name) {
											if (_getFloat4Component(arg.component).replace(reg, '') == '') {
												arr.push(op2, arg, j);
											} else {
												arr.length = 0;
												break label1;
											}
										}
									} else {
										var args1:Vector.<Variable> = arg.args;
										var num2:uint = args1.length;
										for (var l:uint = 0; l < num2; l++) {
											arg = args1[l];
											if (arg.name == opcode.dest.name) {
												if (_getFloat4Component(arg.component).replace(reg, '') == '') {
													arr.push(op2, arg, j);
												} else {
													arr.length = 0;
													break label1;
												}
											}
										}
									}
								}
							}
						}
						
						var v:Variable;
						var op:Opcode;
						var index:uint;
						var reg2:RegExp;
						
						var count:uint = arr.length / 3;
						
						if (count > 0) {
							op = arr[0];
							index = arr[int(arr.length - 1)];
							
							for (j = i + 1; j < index; j++) {
								op2 = opcodes[j];
								
								if (op2.dest != null && op2.dest.name == opcode.dest.name) {
									if (count == 1) {
										reg2 = new RegExp('[' + _getFloat4Component(op2.dest.component) + ']', 'g');
										if ( _getFloat4Component(opcode.dest.component).replace(reg2, '') == '') {
											op = opcodes[i];
											opcodes.splice(i, 1);
											
											_removeRegisterFromOpcode(op, opcodes);
											//_goUpStatisticsData(i);
											
											i--;
											if (len > 0) len--;
										}
									}
									
									continue label2;
								}
							}
							
							var isReplaced:Boolean = false;
							var name:String;
							
							if (opcode.func == BaseFunctionType._MOVE) {
								arg = opcode.args[0];
								
								reg2 = new RegExp('[' + _getFloat4Component(arg.component) + ']');
								
								for (j = i + 1; j < index; j++) {
									op2 = opcodes[j];
									
									if (op2.dest != null && op2.dest.name == arg.name && _getFloat4Component(op2.dest.component).search(reg2) != -1) {
										continue label2;
									}
								}
								
								isReplaced = true;
								name = opcode.dest.name;
								
								var isNumber:Boolean = Util.isNumber(opcode.args[0].name, opcode.args[0].component);
								
								for (j = 0; j < count; j++) {
									v = arr[int(j * 3 + 1)];
									
									v.type = arg.type;
									v.setName(arg.scope, arg.name);
									v.args = arg.args;
									
									if (isNumber) {
										v.component = opcode.args[0].component;
									} else if (Util.isNumber(v.name, v.component)) {
										v.component = null;
									} else if (_isProperty(v)) {
										if (_mm.getProperty(v.name).returnType == BaseVariableType.FLOAT) v.component = null;
									} else {
										var com:String = v.component == null ? 'xyzw' : v.component;
										var com1:String = opcode.dest.component == null ? 'xyzw' : opcode.dest.component;
										var com2:String = arg.component == null ? 'xyzw' : arg.component;
										
										v.component = '';
										
										var len1:uint = com.length;
										for (k = 0; k < len1; k++) {
											var idx:int = com1.indexOf(com.charAt(k));
											if (idx == -1) {
												throw new Error();
											} else {
												v.component += com2.charAt(idx);
											}
										}
										
										if (v.component == '') v.component = null;
									}
									
									_removeRegister(name, opcodes);
								}
								
								_removeRegister(name, opcodes);
							} else if (count == 1) {
								op = arr[0];
								if (op.func == BaseFunctionType._MOVE) {
									if (op.dest.type == BaseVariableType.VARYING) {
										if (opcode.func == BaseFunctionType.POW) {
											continue;
										}
									}
									
									if (count == 1 && opcode.dest.nameWithComponent == op.args[0].nameWithComponent) {
										args = opcode.args;
										num = args.length;
										
										for (j = i + 1; j < index; j++) {
											op2 = opcodes[j];
											if (op2.dest != null) {
												name = op2.dest.name;
												for (k = 0; k < num; k++) {
													arg = args[k];
													reg2 = new RegExp('[' + _getFloat4Component(arg.component) + ']');
													if (name == arg.name && _getFloat4Component(op2.dest.component).search(reg2) != -1) continue label2;
												}
											}
										}
										
										isReplaced = true;
										name = opcode.dest.name;
										
										op.func = opcode.func;
										op.args = opcode.args;
										
										_removeRegister(name, opcodes);
										_removeRegister(name, opcodes);
										
										arg = op.args[0];
										
										if (Util.isNumber(arg.name, arg.component)) {
											if (op.func == BaseFunctionType.ATTRIBUTE) {
												op.func = BaseFunctionType._MOVE;
												arg.type = BaseVariableType.VERTEX_ATTRIBUTE;
												arg.setName(arg.scope, BaseVariableType.VERTEX_ATTRIBUTE + arg.name);
											} else if (op.func == BaseFunctionType.CONSTANT) {
												op.func = BaseFunctionType._MOVE;
												arg.type = _getConstant();
												arg.setName(arg.scope, _getConstant() + arg.name);
											}
										}
									}
								}
							}
							
							if (isReplaced) {
								opcodes.splice(i, 1);
								
								//_goUpStatisticsData(i);
								
								i--;
								if (len > 0) len--;
								
								//trace(Opcode.toString(opcodes));
							}
						}
					}
				}
			}
		}
		private function _abridgeTemporary(opcodes:Vector.<Opcode>):void {
			_usingMaxTemporary = 0;
			
			var len:uint = opcodes.length;
			
			var info:ScopeInfo;
			
			var list:Vector.<ScopeInfo> = new Vector.<ScopeInfo>();
			var freeMap:Object;
			
			var num:uint;
			var max:uint;
			var j:uint;
			var k:uint;
			var op:Opcode;
			var name:String;
			var mask:String;
			var freeMask:String;
			
			var needDestMap:Object = {};
			var infoMap:Object = {};
			
			var addToInfo:Function = function(arg:Variable, line:uint, info:ScopeInfo, freeMap:Object, mask:String):void {
				var readMask:String = arg.component == null ? 'xyzw' : arg.component;
				var len:uint = readMask.length;
				for (var i:uint = 0; i < len; i++) {
					var s:String = readMask.charAt(i);
					var index:int = mask.indexOf(s);
					if (index == -1) {
						var needScope:NeedScope = needDestMap[arg.name];
						if (needScope == null) {
							needScope = new NeedScope();
							needScope.info = info;
							needScope.mask = '';
							needDestMap[arg.name] = needScope;
						}
						
						if (needScope.mask.indexOf(s) == -1) {
							needScope.mask += s;
							info.appendMask(s);
						}
						
						if (freeMap[s] == null || freeMap[s] < i) {
							freeMap[s] = i;
						}
						
					}
					
					freeMap[s] = j;
				}
				
				info.useVariables.push(arg);
			};
			
			label1:for (var i:uint = 0; i < len; i++) {
				var opcode:Opcode = opcodes[i];
				mask = null;
				name = null;
				
				if (opcode.dest != null && opcode.dest.type == _getTemporary()) {
					name = opcode.dest.name;
					mask = opcode.dest.component == null ? 'xyzw' : opcode.dest.component;
					
					var needScope:NeedScope = needDestMap[name];
					if (needScope != null) {
						if (needScope.mask.search(new RegExp('[' + mask + ']', 'g')) != -1) {
							needScope.info.useVariables.push(opcode.dest);
							
							continue;
						}
					}
					
					freeMap = {};
					
					max = mask.length;
					for (var l:uint = 0; l < max; l++) {
						freeMap[mask.charAt(l)] = i;
					}
					
					info = new ScopeInfo();
					info.startMask = mask;
					info.maxMask = mask;
					info.startLine = i;
					
					list.push(info);
					
					var s:String;
					var mask2:String;
					var mask3:String;
					
					for (j = i + 1; j < len; j++) {
						op = opcodes[j];
						
						var args:Vector.<Variable> = op.args;
						if (args != null) {
							num = args.length;
							for (k = 0; k < num; k++) {
								var arg:Variable = args[k];
								var args1:Vector.<Variable> = arg.args;
								if (args1 == null) {
									if (arg.name == name && arg.type == _getTemporary()) {
										addToInfo(arg, i, info, freeMap, mask);
									}
								} else {
									max = args1.length;
									for (l = 0; l < max; l++) {
										arg = args1[l];
										if (arg.name == name && arg.type == _getTemporary()) addToInfo(arg, i, info, freeMap, mask);
									}
								}
							}
						}
						
						if (op.dest != null) {
							if (op.dest.name == name) {
								var writeMask:String = op.dest.component == null ? 'xyzw' : op.dest.component;
								max = writeMask.length;
								mask2 = mask;
								for (l = 0; l < max; l++) {
									s = writeMask.charAt(l);
									var index:int = mask2.indexOf(s);
									if (index != -1) {
										mask2 = mask2.replace(new RegExp(s, 'g'), '');
									}
								}
								
								mask3 = mask.replace(new RegExp('[' + mask2 + ']', 'g'), '');
								if (mask3 != '') {
									//info.freeMasks.push(mask3);
									//info.freeLines.push(j);
									
									mask = mask2;
									
									/*
									if (mask == '') {
										continue label1;
									}
									*/
								}
							}
						}
					}
					
					max = info.maxMask.length;
					for (l = 0; l < max; l++) {
						var m:String = info.maxMask.charAt(l);
						if (m in freeMap) {
							var line:uint = freeMap[m];
							
							var isInsert:Boolean = false;
							var max3:int = info.freeLines.length;
							for (var ll:int = 0; ll < max3; ll++) {
								if (line < info.freeLines[ll]) {
									info.freeLines.splice(ll, 0, line);
									info.freeMasks.splice(ll, 0, m);
									isInsert = true;
									break;
								}
							}
							if (!isInsert) {
								info.freeLines.push(line);
								info.freeMasks.push(m);
							}
						} else {
							info.freeLines.push(int.MAX_VALUE);
							info.freeMasks.push(m);
						}
					}
				}
			}
			
			var endLine:int = len;
			if (endLine > 0) endLine--;
			
			num = list.length;
			for (i = 0; i < num; i++) {
				info = list[i];
				
				var td:TemporaryData = _getTemporaryFromPool(info.maxMask.length, info.startLine, info.freeLines[int(info.freeLines.length - 1)], endLine);
				
				name = _getTemporary() + td.index;
				op = opcodes[info.startLine];
				op.dest.setName(op.dest.scope, name);
				
				op.dest.component = _replaceMask(info.maxMask, td.mask, op.dest.component);
				
				max = info.useVariables.length;
				
				var max2:uint;
				
				for (j = 0; j < max; j++) {
					var v:Variable = info.useVariables[j];
					v.setName(v.scope, name);
					
					v.component = _replaceMask(info.maxMask, td.mask, v.component);
				}
				
				max = info.freeMasks.length;
				
				for (j = 0; j < max; j++) {
					freeMask = info.freeMasks[j];
					_putTemporaryToPool(td.index, _replaceMask(info.maxMask, td.mask, freeMask), info.freeLines[j], endLine);
				}
				
				/*
				if (_programType == Context3DProgramType.FRAGMENT) {
					trace(Opcode.toString(opcodes));
					trace();
				}
				*/
			}
		}
		private function _replaceMask(oldFullMask:String, newFullMask:String, oldNeedMask:String):String {
			if (oldNeedMask == null) oldNeedMask = 'xyzw';
			
			var mask:String = '';
			
			var len:int = oldNeedMask.length;
			for (var i:int = 0; i < len; i++) {
				var s:String = oldNeedMask.charAt(i);
				var index:int = oldFullMask.indexOf(s);
				if (index == -1) {
					throw new Error();
				} else {
					mask += newFullMask.charAt(index);
				}
			}
			
			return mask;
		}
		private function _putTemporaryToPool(index:uint, mask:String, start:uint, end:uint):void {
			var data:TemporaryData = new TemporaryData();
			data.index = index;
			data.mask = mask;
			data.start = start;
			data.end = end;
			
			if (index == 5) {
				trace();
			}
			
			var len:int = _temporaryPool.length;
			var found:Boolean = false;
			
			for (var i:int = 0; i < len; i++) {
				var pool:TemporaryData = _temporaryPool[i];
				if (index < pool.index) {
					found = true;
					_temporaryPool.splice(i, 0, data);
					break;
				} else if (index == pool.index) {
					found = true;
					var merge:Boolean = false;
					for (var j:int = i; j < len; j++) {
						pool = _temporaryPool[i];
						if (pool.index == index) {
							if (pool.start == start && pool.end == end) {
								merge = true;
								
								pool.mask += mask;
								mask = '';
								if (pool.mask.indexOf('x') != -1) mask += 'x';
								if (pool.mask.indexOf('y') != -1) mask += 'y';
								if (pool.mask.indexOf('z') != -1) mask += 'z';
								if (pool.mask.indexOf('w') != -1) mask += 'w';
								
								pool.mask = mask;
							}
						} else {
							break;
						}
					}
					
					if (!merge) {
						var first:int = _componentValues[data.mask.charAt(0)];
						if (first < _componentValues[pool.mask.charAt(0)]) {
							_temporaryPool.splice(i, 0, data);
						} else {
							_temporaryPool.splice(i + 1, 0, data);
						}
					}
					
					break;
				}
			}
			
			if (!found) {
				_temporaryPool.push(data);
			}
		}
		
		private function _getTemporaryFromPool(count:uint, start:uint, end:uint, maxEnd:uint):TemporaryData {
			var data:TemporaryData = new TemporaryData();;
			
			var len:int = _temporaryPool.length;
			if (len == 0) {
				data.index = _usingMaxTemporary++;
				data.mask = 'xyzw';
			} else {
				var pool:TemporaryData;
				
				var foundPool:TemporaryData = null;
				var foundIndex:int;
				var foundWeight:int = int.MAX_VALUE;
				
				var temp:Vector.<TemporaryData> = new Vector.<TemporaryData>();
				
				for (var i:int = 0; i < len; i++) {
					pool = _temporaryPool[i];
					
					if (pool.mask.length >= count) {
						if (count > 1 && pool.mask.charAt(0) != 'x') continue;
						
						if (pool.start <= start && pool.end >= end) {
							temp.push(pool);
						}
					}
				}
				
				if (temp.length == 0) {
					var prevTd:TemporaryData = new TemporaryData();
					prevTd.index = -1;
					prevTd.mask = '';
					prevTd.pools = new Vector.<TemporaryData>();
					for (i = 0; i < len; i++) {
						pool = _temporaryPool[i];
						if (pool.start <= start && pool.end >= end) {
							if (pool.index == prevTd.index) {
								if (prevTd.start < pool.start) prevTd.start = pool.start;
								if (prevTd.end > pool.end) prevTd.end = pool.end;
								prevTd.pools.push(pool);
								
								var len2:int = pool.mask.length;
								for (var k:int = 0; k < len2; k++) {
									var c:String = pool.mask.charAt(k);
									if (prevTd.mask.indexOf(c) == -1) {
										if (c == 'x') {
											prevTd.mask = 'x' + prevTd.mask;
										} else if (c == 'y') {
											if (prevTd.mask.charAt(0) == 'x') {
												prevTd.mask = 'xy' + prevTd.mask.slice(1);
											} else {
												prevTd.mask = 'y' + prevTd.mask;
											}
										} else if (c == 'z') {
											if (prevTd.mask.charAt(prevTd.mask.length - 1) == 'w') {
												if (prevTd.mask.length == 1) {
													prevTd.mask = 'zw';
												} else {
													prevTd.mask = prevTd.mask.slice(0, prevTd.mask.length - 1) + 'zw';
												}
											} else {
												prevTd.mask += 'z';
											}
										} else {
											prevTd.mask += 'w';
										}
									}
								}
								
								if (prevTd.mask.length >= count) {
									if (count > 1 && prevTd.mask.charAt(0) != 'x') continue;
									
									temp.push(prevTd);
									
									prevTd = new TemporaryData();
									prevTd.index = -1;
									prevTd.mask = '';
									prevTd.pools = new Vector.<TemporaryData>();
								}
							} else {
								prevTd.index = pool.index;
								prevTd.mask = pool.mask;
								prevTd.start = pool.start;
								prevTd.end = pool.end;
								prevTd.pools.length = 0;
								prevTd.pools.push(pool);
							}
						}
					}
				}
				
				len = temp.length;
				for (i = 0; i < len; i++) {
					pool = temp[i];
					
					if (pool.mask.length == count) {
						if (foundPool == null) {
							foundPool = pool;
							foundIndex = i;
							foundWeight = start - pool.start + pool.end - end;
						} else {
							var weight:int = start - pool.start + pool.end - end;
							if (weight < foundWeight) {
								foundPool = pool;
								foundIndex = i;
								foundWeight = weight;
							}
						}
					} else {
						if (foundPool == null) {
							foundPool = pool;
							foundIndex = i;
							foundWeight = start - pool.start + pool.end - end;
						} else if (foundPool.mask.length > pool.mask.length) {
							foundPool = pool;
							foundIndex = i;
							foundWeight = start - pool.start + pool.end - end;
						}
					}
				}
				
				if (foundPool == null) {
					data.index = _usingMaxTemporary++;
					data.mask = 'xyzw';
					data.start = 0;
					data.end = maxEnd;
				} else {
					data.index = foundPool.index;
					data.mask = foundPool.mask;
					data.start = foundPool.start;
					data.end = foundPool.end;
					
					if (foundPool.pools == null) {
						_temporaryPool.splice(_temporaryPool.indexOf(foundPool), 1);
						len--;
					} else {
						for each (pool in foundPool.pools) {
							_temporaryPool.splice(_temporaryPool.indexOf(pool), 1);
							len--;
						}
					}
					
					/*
					for (var j:int = foundIndex; j < len; j++) {
						pool = _temporaryPool[j];
						if (pool.index == foundPool.index) {
							pool.mask = pool.mask.replace(new RegExp('[' + foundPool.mask + ']', 'g'), '');
							if (pool.mask == '') {
								_temporaryPool.splice(j, 1);
								
								j--;
								if (len > 0) len--;
							}
						} else if (pool.index > foundPool.index) {
							break;
						}
					}
					*/
				}
			}
			
			if (data.mask.length > count) {
				if (count == 1) {
					_putTemporaryToPool(data.index, data.mask.substr(0, data.mask.length - 1), data.start, data.end);
					data.mask = data.mask.charAt(data.mask.length - 1);
				} else {
					_putTemporaryToPool(data.index, data.mask.substr(count), data.start, data.end);
					data.mask = data.mask.substr(0, count);
				}
			}
			
			return data;
		}
		private function _insertLineToPool(beforeLine:uint):void {
			var len:int = _temporaryPool.length;
			for (var i:int = 0; i < len; i++) {
				var pool:TemporaryData = _temporaryPool[i];
				if (pool.start >= beforeLine) {
					pool.start++;
				}
				if (pool.end >= beforeLine) {
					pool.end++;
				}
			}
		}
		private function _constDetection(opcodes:Vector.<Opcode>):void {
			var len:uint = opcodes.length;
			
			var isUsed:Boolean = false;
			var temporaryIndex:int = _usingMaxTemporary + 1;
			
			for (var i:int = 0; i < len; i++) {
				var opcode:Opcode = opcodes[i];
				
				var args:Vector.<Variable> = opcode.args;
				if (args != null && args.length == 2) {
					var arg0:Variable = args[0];
					var arg1:Variable = args[1];
					
					var isNumber0:Boolean = Util.isNumber(arg0.name, arg0.component);
					var isNumber1:Boolean = Util.isNumber(arg1.name, arg1.component);
					
					if ((isNumber0 || args[0].type == _getConstant() || _isConstantProperty(arg0)) &&
						(isNumber1 || args[1].type == _getConstant() || _isConstantProperty(arg1))) {
						if (opcode.dest != null) {
							var op:Opcode = new Opcode();
							op.func = BaseFunctionType._MOVE;
							op.args = new Vector.<Variable>();
							op.args[0] = opcode.args[0];
							
							if (opcode.dest.type == _getTemporary()) {
								op.dest = opcode.dest.clone();
							} else {
								isUsed = true;
								
								_insertLineToPool(i);
								
								var maskCount:uint = op.args[0].component == null ? 4 : op.args[0].component.length;
								var td:TemporaryData = _getTemporaryFromPool(maskCount, i, i + 1, opcodes.length - 1);
								
								op.dest = new Variable();
								op.dest.setName(null, _getTemporary() + td.index);
								op.dest.type = _getTemporary();
								op.dest.component = td.mask;
								
								_putTemporaryToPool(td.index, td.mask, i + 1, opcodes.length - 1);
							}
							
							opcode.args[0] = op.dest.clone();
							
							opcodes.splice(i, 0, op);
							
							i++;
							len++;
						}
					}
				}
			}
			
			if (isUsed) _usingMaxTemporary++;
		}
		private function _replaceProperty(opcodes:Vector.<Opcode>):void {
			var len:uint = opcodes.length;
			
			for (var i:int = 0; i < len; i++) {
				var opcode:Opcode = opcodes[i];
				
				var args:Vector.<Variable> = opcode.args;
				if (args != null) {
					var num:int = args.length;
					for (var j:int = 0; j < num; j++) {
						var arg1:Variable = args[j];
						if (_isProperty(arg1)) {
							var data:FunctionData = _mm.getProperty(arg1.name);
							var params:String = '';
							for (var key:String in data.optionalParams) {
								params += key + ':' + data.optionalParams[key] + ';';
							}
							
							if (params != '') params = '@' + params;
							
							arg1.setName(arg1.scope, '#' + arg1.name + '#');
						}
					}
				}
			}
		}
		private function _getTemporary():String {
			if (_programType == Context3DProgramType.VERTEX) {
				return BaseVariableType.VERTEX_TEMPORARY;
			} else if (_programType == Context3DProgramType.FRAGMENT) {
				return BaseVariableType.FRAGMENT_TEMPORARY;
			} else {
				return null;
			}
		}
		private function _getConstant():String {
			if (_programType == Context3DProgramType.VERTEX) {
				return BaseVariableType.VERTEX_CONSTANT;
			} else if (_programType == Context3DProgramType.FRAGMENT) {
				return BaseVariableType.FRAGMENT_CONSTANT;
			} else {
				return null;
			}
		}
		private function _getOutput():String {
			if (_programType == Context3DProgramType.VERTEX) {
				return BaseVariableType.VERTEX_OUTPUT;
			} else if (_programType == Context3DProgramType.FRAGMENT) {
				return BaseVariableType.FRAGMENT_OUTPUT;
			} else {
				return null;
			}
		}
	}
}
import asgl.shaders.scripts.compiler.Variable;


class ScopeInfo {
	private static var maskIndexMap:Object = {'x':0, 'y':1, 'z':2, 'w':3};
	public var startMask:String;
	public var startLine:uint;
	public var maxMask:String;
	public var freeMasks:Vector.<String> = new Vector.<String>();
	public var freeLines:Vector.<uint> = new Vector.<uint>();
	public var useVariables:Vector.<Variable> = new Vector.<Variable>();
	
	public function appendMask(mask:String):void {
		var len:uint = mask.length;
		for (var i:int = 0; i < len; i++) {
			var s:String = mask.charAt(i);
			if (maxMask.indexOf(s) == -1) {
				var n:Number = maskIndexMap[s];
				var len2:int = maxMask.length;
				var index:int = -1;
				for (var j:int = 0; j < len2; j++) {
					var n2:Number = maskIndexMap[maxMask.charAt(j)];
					if (n < n2) {
						index = j;
						break;
					}
				}
				
				if (index == -1) {
					maxMask += s;
				} else {
					maxMask = maxMask.substr(0, index) + s + maxMask.substr(index);
				}
			}
		}
	}
}
class NeedScope {
	public var info:ScopeInfo;
	public var mask:String;
}
class TemporaryData {
	public var index:int;
	public var mask:String;
	public var start:int;
	public var end:int;
	public var pools:Vector.<TemporaryData>;
}