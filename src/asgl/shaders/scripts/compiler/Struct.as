package asgl.shaders.scripts.compiler {
	public class Struct {
		public var name:String;
		public var members:Vector.<Variable>;
		public var membersMap:Object;
		
		public function Struct(name:String, membersCode:String) {
			this.name = name;
			
			members = new Vector.<Variable>();
			membersMap = {};
			
			var lines:Array = membersCode.split(';');
			var len:uint = lines.length;
			if (len > 0) len--;
			for (var i:uint = 0; i < len; i++) {
				var line:String = lines[i];
				var member:Variable = new Variable();
				member.setValue(Util.formatSpace(line));
				members[i] = member;
				
				membersMap[member.name] = member;
			}
		}
		public function getMember(name:String):Variable {
			var len:uint = members.length;
			for (var i:uint = 0; i < len; i++) {
				if (members[i].name == name) {
					return members[i];
				}
			}
			return null;
		}
		/*
		public static function getScopeOfMember(name:String, scope:String):String {
			return scope+'::'+name+'_';
		}
		public static function getMemberFullName(v:SSLVariable):String {
			var scope:String = v.scope;
			var name:String = v.name;
			var com:String = v.component;
			if (com == null) com = '';
			
			while (true) {
				var index:int = com.search(/\./);
				if (index == -1) {
					if (com != '') {
						scope = getScopeOfMember(name, scope);
						
						name = com;
					}
					
					break;
				} else {
					scope = getScopeOfMember(name, scope);
					
					name = com.substr(0, index);
					com = com.substr(index+1);
				}
			}
			
			return SSLVariable.getFullName(scope, name);
		}
		*/
		public function toString():String {
			var str:String = 'struct name:' + name + ' members:';
			var len:uint = members.length;
			for (var i:uint = 0; i < len; i++) {
				str += members[i] + ' ';
			}
			return str;
		}
	}
}