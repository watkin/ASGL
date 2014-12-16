package asgl.shaders.scripts.compiler {
	public class CompileParameter {
		public static const EACH:String = 'each';
		
		public var name:String;
		
		public function CompileParameter(name:String) {
			this.name = name;
		}
		public static function create(code:String):CompileParameter {
			code = Util.formatSpace(code);
			
			var name:String = code.split(' ')[0];
			if (name == EACH) {
				return new CompileEach(EACH, code.substr(EACH.length + 1));
			}
			
			return null;
		}
	}
}