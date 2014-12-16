package asgl.shaders.scripts.compiler {
	public class FunctionTable {
		private var _funcTable:Object;
		private var _customTable:Object;
		
		public function FunctionTable() {
			_funcTable = {};
			_customTable = {};
		}
		public function clear():void {
			for each (var value:* in _customTable) {
				var func:FunctionBlock = value;
				delete _funcTable[func.data.name][func.data.paramsFeature];
			}
			_customTable = {};
		}
		public function getFuncType(funcName:String, params:Vector.<Variable>, mm:IMemberManager):String {
			var func:FunctionBlock = _getFunc(funcName, params, mm);
			if (func == null) {
				return null;
			} else {
				return func.data.returnType;
			}
		}
		public function expand(opcode:Opcode, parser:ShaderScriptCompiler, mm:IMemberManager):Vector.<Opcode> {
			var opcodes:Vector.<Opcode>;
			
			if (opcode.func != null) {
				var func:FunctionBlock = _getFunc(opcode.func, opcode.args, mm);
				
				if (func != null && !func.isInterface) {
					opcodes = func.expansion(opcode, parser, mm);
				}
			}
			
			/*
			if (opcode.func == 'blur') {
				trace(Opcode.toString(opcodes));
				trace();
			}
			*/
			
			return opcodes;
		}
		public function setFunc(data:FunctionData, isInternal:Boolean):void {
			var polymorphism:Object = _funcTable[data.name];
			if (polymorphism == null) {
				polymorphism = {};
				_funcTable[data.name] = polymorphism;
			}
			
			var func:FunctionBlock = new FunctionBlock(data);
			
			if (polymorphism[data.paramsFeature] == null) {
				polymorphism[data.paramsFeature] = func;
				if (!isInternal) _customTable[func.data.name + '::' + func.data.paramsFeature] = func;
			} else {
				throw new Error('can not overide function:'+data.name);
			}
		}
		private function _getFunc(funcName:String, params:Vector.<Variable>, mm:IMemberManager):FunctionBlock {
			//if (funcName == 'constant') {
				//trace();
			//}
			
			var func:FunctionBlock;
			
			var polymorphism:Object = _funcTable[funcName];
			if (polymorphism != null) {
				var feature:String = FunctionData.getParamsFeature(params, mm);
				
				func = polymorphism[feature];
				
				if (func == null) {
					var reg:RegExp = new RegExp(FunctionData.getParamsFuzzyFeature(params, mm));
					for (var name:String in polymorphism) {
						if (name.replace(reg, '') == '') {
							func = polymorphism[name];
							break;
						}
					}
				}
			}
			
			return func;
		}
	}
}