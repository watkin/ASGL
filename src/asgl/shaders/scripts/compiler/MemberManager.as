package asgl.shaders.scripts.compiler {
	public class MemberManager implements IMemberManager {
		private var _anonymousAccumulator:uint;
		private var _typeMap:Object;
		private var _structMap:Object;
		private var _customStructMap:Object;
		private var _refMap:Object;
		private var _propertyMap:Object;
		private var _customPropertyMap:Object;
		
		public function MemberManager() {
			_anonymousAccumulator = 0;
			_typeMap = {};
			_structMap = {};
			_customStructMap = {};
			_refMap = {};
			_propertyMap = {};
			_customPropertyMap = {};
		}
		public function reset():void {
			_anonymousAccumulator = 0;
			_typeMap = {};
			
			for (var name:String in _customStructMap) {
				delete _structMap[name];
			}
			_customStructMap = {};
			
			_refMap = {};
			
			for (name in _customPropertyMap) {
				delete _propertyMap[name];
			}
			_customPropertyMap = {};
		}
		public function createVariableName():String {
			return 'var_' + (_anonymousAccumulator++);
		}
		public function createVariable(type:String=null, scope:String=null):Variable {
			var sv:Variable = new Variable();
			sv.setName(scope, createVariableName());
			sv.type = type;
			return sv;
		}
		public function addStructPrototype(struct:Struct, isInternal:Boolean):void {
			_structMap[struct.name] = struct;
			if (!isInternal) _customStructMap[struct.name] = true;
		}
		public function getStructPrototype(name:String):Struct {
			return _structMap[name];
		}
		public function getType(name:String):String {
			return _typeMap[name];
		}
		public function setType(name:String, type:String):uint {
			if (type == null) return 0;
			
			var old:String = _typeMap[name];
			if (old != type) {
				if (old == null) {
					_typeMap[name] = type;
				} else {
					throw new Error();
					
					return 0;
				}
			}
			
			return 1;
		}
		public function setTypeFromVariable(variable:Variable):uint {
			return setType(variable.fullName, variable.type);
		}
		public function setReference(name:String, ref:Variable):void {
			_refMap[name] = ref;
		}
		public function getReference(name:String):Variable {
			return _refMap[name];
		}
		public function setProperty(name:String, data:FunctionData, isInternal:Boolean):void {
			_propertyMap[name] = data;
			if (!isInternal) _customPropertyMap[name] = true;
		}
		public function getProperty(name:String):FunctionData {
			return _propertyMap[name];
		}
		public function getProperties():Vector.<FunctionData> {
			var v:Vector.<FunctionData> = new Vector.<FunctionData>();
			
			for each (var fd:FunctionData in _propertyMap) {
				v.push(fd);
			}
			
			return v;
		}
	}
}