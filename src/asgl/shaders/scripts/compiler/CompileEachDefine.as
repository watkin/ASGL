package asgl.shaders.scripts.compiler {
	public class CompileEachDefine {
		public var name:String;
		public var min:int;
		public var max:int;
		public var bits:uint;
		public var values:Vector.<int>;
		
		public function CompileEachDefine() {
			min = int.MAX_VALUE;
			max = int.MIN_VALUE;
			values = new Vector.<int>();
		}
		public function calculateBits():void {
			var value:int = max - min;
			
			if (value < 0) throw new Error();
			
			bits = 2;
			var pow:int = 2;
			while (true) {
				if (pow > value) {
					bits--;
					break;
				} else {
					pow *= 2;
					bits++;
				}
			}
		}
	}
}