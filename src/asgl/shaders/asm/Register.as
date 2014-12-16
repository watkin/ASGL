package asgl.shaders.asm {
	public class Register {
		private var _index:int;
		private var _type:String;
		public function Register(type:String=null, index:int=-1) {
			_type = type;
			_index = index;
		}
		public function get index():int {
			return _index;
		}
		public function set index(value:int):void {
			_index = value;
		}
		public function get type():String {
			return _type;
		}
		public function set type(value:String):void {
			_type = value;
		}
		public function setFromString(str:String):void {
			var arr:Array = str.split('.');
			str = arr[0];
			var length:int = str.length;
			for (var i:int = 0; i<length; i++) {
				var code:int = str.charCodeAt(i);
				if (code>=48 && code<=57) {
					_type = str.substr(0, i);
					_index = int(str.substr(i));
					break;
				}
			}
			if (i>=length) _type = str;
		}
		public function toString(scalars:String=null):String {
			var str:String = _type;
			if (_index>=0) str += _index;
			if (scalars != null) str += '.'+scalars;
			return str;
		}
	}
}