package asgl.shaders.scripts.compiler {
	public class CodeSegment {
		public var name:String = '';
		public var body:Variable;
		public var component:String = '';
		public var operator:String = '';
		public var type:String = '';
		public var bodies:Vector.<CodeSegment>;
		
		public function CodeSegment() {
		}
		
		public function isEmpty():Boolean {
			return name == '' && body == null && bodies == null && operator == '';
		}
		
		public function clone():CodeSegment {
			var cs:CodeSegment = new CodeSegment();
			
			cs.name = name;
			cs.body = body;
			cs.component = component;
			cs.operator = operator;
			if (bodies != null) {
				cs.bodies = new Vector.<CodeSegment>();
				var len:uint = bodies.length;
				for (var i:uint = 0; i < len; i++) {
					cs.bodies[i] = bodies[i].clone();
				}
			}
			
			return cs;
		}
		
		public function toString():String {
			return 'name:' + name + ' ' + (bodies == null ? 'body:' + (type == '' ? '' : '[' + type + ']') + body : 'bodies:' + bodies) + ' com:' + component + ' operator:' + operator;
		}
	}
}