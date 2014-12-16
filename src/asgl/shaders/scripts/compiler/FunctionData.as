package asgl.shaders.scripts.compiler {
	public class FunctionData {
		public var type:String;
		public var returnType:String;
		public var name:String;
		public var params:Vector.<Variable>;
		public var paramsFeature:String;
		public var optionalParams:Object;
		public var code:String;
			
		public function FunctionData(func:String) {
			optionalParams = {};
			
			var head:String;
			var body:String;
			
			var index:int = func.search(/\{/);
			if (index == -1) {
				head = func;
			} else {
				head = func.substr(0, index);
				body = func.substring(index+1, func.lastIndexOf('}'));
			}
			
			var index1:int = head.search(/\(/);
			var index2:int = head.search(/\)/);
			name = head.substr(0, index1);
			//name = func.substr(0, index1).replace(/\s/g, '');
			name = Util.formatSpace(name);
			
			var arr:Array = name.split(' ');
			
			type = arr[0];
			
			var i:uint;
			var len:uint;
			
			if (type == FunctionType.PROPERTY) {
				returnType = arr[1];
				name = arr[2];
				
				if (body != null) {
					var opArr:Array = body.split(';');
					len = opArr.length;
					for (i = 0; i < len; i++) {
						var op:String = opArr[i];
						var opArr1:Array = op.split('=');
						var key:String = Util.removeBothSidesSpace(opArr1[0]);
						if (key != '') {
							var value:String = Util.removeBothSidesSpace(opArr1[1]);
							if (Util.isString(value)) value = value.substr(1, value.length - 2);
							optionalParams[key] = value;
						}
					}
				}
				
				if (!(PropertyOptionalParamType.NAME in optionalParams)) {
					optionalParams[PropertyOptionalParamType.NAME] = '';
				}
				
				if (returnType == PropertyOptionalParamType.CONSTANTS) {
					var length:* = null;
					
					length = optionalParams[PropertyOptionalParamType.LENGTH];
					
					if (length == '*') {
						if (PropertyOptionalParamType.INDEX in optionalParams) delete optionalParams[PropertyOptionalParamType.INDEX];
					} else {
						length = int(length);
						
						if (length <= 0) {
							length = 1;
							optionalParams[PropertyOptionalParamType.LENGTH] = 1;
						}
						
						var values:Vector.<Number>;
						if (PropertyOptionalParamType.VALUES in optionalParams) {
							var valuesStr:String = optionalParams[PropertyOptionalParamType.VALUES];
							values = Vector.<Number>(valuesStr.substr(1, valuesStr.length - 2).split(','));
							values.length = length * 4;
							
							optionalParams[PropertyOptionalParamType.VALUES] = values;
						}
					}
				}
			} else if (type == FunctionType.STRUCT) {
				type = FunctionType.STRUCT;
				returnType = null;
				name = arr[1];
			} else if (type == FunctionType.DEFINE) {
				type = FunctionType.DEFINE;
				returnType = null;
				name = arr[1];
			} else {
				type = FunctionType.FUNCTION;
				returnType = arr[0];
				name = arr[1];
			}
			
			params = new Vector.<Variable>();
			
			var paramsStr:String = head.substring(index1 + 1, index2);
			if (paramsStr.replace(/\s/g, '').length>0) {
				arr = paramsStr.split(',');
				len = arr.length;
				for (i = 0; i < len; i++) {
					var param:String = arr[i];
					param = Util.formatSpace(param);
					
					var variable:Variable = new Variable();
					variable.setValue(param);
					params[i] = variable;
				}
			}
			
			paramsFeature = getParamsFeature(params, null);
			
			code = body;
		}
		
		public static function getParamsFeature(params:Vector.<Variable>, mm:IMemberManager):String {
			var len:uint = params.length;
			
			var feature:String = len + ':';
			
			for (var i:uint = 0; i < len; i++) {
				feature += params[i].getTypeWithComponent(mm) + ';';
			}
			
			return feature;
		}
		public static function getParamsFuzzyFeature(params:Vector.<Variable>, mm:IMemberManager):String {
			var len:uint = params.length;
			
			var feature:String = len + ':';
			
			for (var i:uint = 0; i < len; i++) {
				var type:String = params[i].getTypeWithComponent(mm);
				
				feature += type;
				
				if (type == BaseVariableType.FLOAT) {
					feature += '[234]?';
				}
				
				feature += ';';
			}
			
			return feature;
		}
	}
}