package asgl.shaders.scripts.compiler {
	public class CompileEach extends CompileParameter {
		public var define:Vector.<CompileEachDefine>;
		
		public function CompileEach(name:String, code:String) {
			super(name);
			
			define = new Vector.<CompileEachDefine>();
			
			code = Util.formatSpace(code);
			if (code != '') {
				var arr:Array = code.split(',');
				var len:uint = arr.length;
				for (var i:uint = 0; i < len; i++) {
					define[i] = _getValue(arr[i]);
				}
			}
		}
		private function _getValue(code:String):CompileEachDefine {
			var cell:CompileEachDefine = new CompileEachDefine();
			
			var startIndex:int = code.indexOf('<');
			if (startIndex == -1) {
				cell.name = Util.formatSpace(code);
				cell.min = 0;
				cell.max = 1;
				cell.values.push(0, 1);
				
				cell.calculateBits();
				return cell;
			} else {
				var endIndex:int = code.lastIndexOf('>');
				
				cell.name = Util.formatSpace(code.substring(0, startIndex));
				
				var values:Array;
				var i:int;
				var len:int;
				
				var str:String = Util.formatSpace(code.substring(startIndex + 1, endIndex));
				
				values = str.split(' ');
				if (values.length == 3 && values[1] == 'to') {
					i = int(values[0]);
					len = int(values[2]);
					
					cell.min = i;
					cell.max = len;
					
					for (; i <= len; i++) {
						cell.values.push(i);
					}
					
					cell.calculateBits();
					return cell;
				} else {
					len = values.length;
					
					for (i = 0; i < len; i++) {
						var value:int = int(values[i]);
						if (cell.min > value) cell.min = value;
						if (cell.max < value) cell.max = value;
						cell.values.push(value);
					}
					
					cell.calculateBits();
					return cell;
				}
			}
		}
	}
}