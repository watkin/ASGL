package asgl.shaders.scripts.compiler {

	public class Variable {
		public static var simpleToString:Boolean = false;
		
		public var tag:String;
		public var type:String;
		public var component:String;
		
		public var parent:Variable;
		public var memberName:String;
		public var members:Object;
		
		public var args:Vector.<Variable>;
		
		private var _scope:String;
		private var _name:String;
		private var _fullName:String;
		
		public function Variable() {
		}
		public static function getFullName(scope:String, name:String):String {
			return scope+'::'+name;
		}
		public function get scope():String {
			return _scope;
		}
		public function get name():String {
			return _name;
		}
		public function get nameWithComponent():String {
			var n:String = _name;
			if (component != null) n += '.' + component;
			return n;
		}
		public function get fullName():String {
			return _fullName;
		}
		public function hasVar(v:Variable):Boolean {
			var fn:String = v.fullName;
			
			if (fn == null) return false;
			
			if (_fullName == fn) {
				return true;
			} else if (args == null) {
				return false;
			} else {
				var len:int = args.length;
				for (var i:int = 0; i < len; i++) {
					v = args[i];
					
					if (v.fullName == fn) return true;
					
					if (v.args != null) {
						var len2:int = v.args.length;
						for (var j:int = 0; j < len2; j++) {
							if (fn == v.args[j].fullName) return true;
						}
					}
				}
				
				return false;
			}
		}
		public function getTypeWithComponent(mm:IMemberManager):String {
			if (component == null) {
				return type;
			} else {
				if (Util.isNumber(name, component)) {
					return BaseVariableType.FLOAT;
				} else {
					var t:String;
					if (BaseVariableType.isEquivalenceFloat4(type)) {
						t = BaseVariableType.FLOAT_4;
					} else {
						t = type;
					}
					
					var arr:Array = component.split('.');
					var len:uint = arr.length;
					for (var i:uint = 0; i < len; i++) {
						var c:String = arr[i];
						
						if (BaseVariableType.isFloats(t)) {
							t = BaseVariableType.getFloatTypeFromComponent(t, c);
						} else {
							var struct:Struct = mm.getStructPrototype(t);
							if (struct != null) {
								var v:Variable = struct.getMember(c);
								if (v != null) {
									t = v.type;
								}
							}
						}
					}
					
					return t;
				}
			}
		}
		public function setName(scope:String, name:String):void {
			if (name.search(/:/) != -1) {
				var arr:Array = name.split(':');
				name = Util.formatSpace(arr[0]);
				tag = Util.formatSpace(arr[1]);
			}
			
			_scope = scope;
			_name = name;
			
			_fullName = getFullName(_scope, _name);
		}
		//aaa bbb
		//aaa
		public function setValue(code:String):void {
			var index:int = code.search(/ /);
			if (index == -1) {
				if (Util.isString(code)) type = BaseVariableType.FLOAT;
				
				setName(_scope, code);
			} else {
				type = code.substr(0, index);
				if (type == 'any') type = null;
				setName(_scope, code.substr(index + 1));
			}
		}
		public function copy(target:Variable, mm:IMemberManager=null):void {
			if (target != null) {
				setName(target.scope, target.name);
				tag = target.tag;
				component = target.component;
				
				if (mm == null) {
					if (target.type != null) type = target.type;
				} else {
					setType(mm);
					
					if (type == null) {
						if (target.type != null) type = target.type;
					}
				}
			}
		}
		public function setType(mm:IMemberManager):void {
			type = mm.getType(fullName);
			if (type == null) {
				var data:FunctionData = mm.getProperty(name);
				if (data != null) type = data.returnType;
			}
		}
		public function getMemberReference(mm:IMemberManager):Variable {
			var ref:Variable = mm.getReference(this.fullName);
			if (ref != null) {
				var com:String = this.component;
				if (com == null) com = '';
				
				var isSimpleType:Boolean = BaseVariableType.getFloatAvailableComponentCount(ref.type);
				
				while (!isSimpleType) {
					var index:int = com.search(/\./);
					if (index == -1) {
						if (com.length != 0) {
							ref = ref.members[com];
							com = '';
						}
						
						break;
					} else {
						var name:String = com.substr(0, index);
						com = com.substr(index + 1);
						
						ref = ref.members[name];
						
						isSimpleType = BaseVariableType.getFloatAvailableComponentCount(ref.type);
					}
				}
				
				if (ref != null) {
					ref.component = com.length == 0 ? null : com;
				}
			}
			
			return ref;
		}
		public function clone():Variable {
			var sv:Variable = new Variable();
			sv.type = type;
			sv.setName(_scope, _name);
			sv.component = component;
			sv.tag = tag;
			
			if (args != null) {
				sv.args = new Vector.<Variable>();
				var len:uint = args.length;
				for (var i:uint = 0; i<len; i++) {
					sv.args[i] = args[i].clone();
				}
			}
			
			sv.memberName = memberName;
			sv.parent = parent;
			sv.members = members;
			
			return sv;
		}
		/*
		public function setTypeFromParams(params:Vector.<SSLVariable>, scope:String=null):void {
			if (type == null && params != null) {
				var len:uint = params.length;
				for (var i:uint = 0; i<len; i++) {
					var param:SSLVariable = params[i];
					var fullName:String = param.name;
					if (scope != null) fullName = scope+fullName;
					if (fullName == name) {
						type = param.type;
						return;
					}
				}
			}
		}
		*/
		public function toString():String {
			var str:String;
			
			if (simpleToString) {
				str = '';
			} else {
				str = '[' + (type == null ? 'any' : type) + ']' + '<' + _scope + '>';
			}
			
			if (name == null) {
				str += '{';
				if (args != null) {
					var len:uint = args.length;
					for (var i:uint = 0; i < len; i++) {
						str += args[i];
						if (i + 1 != len)  str += ' , ';
					}
				}
				str += '}';
			} else {
				str += name;
			}
			if (component != null) str += '.' + component;
			
			return str;
		}
	}
}