package asgl.utils {
	import asgl.asgl_protected;
	
	use namespace asgl_protected;

	public class IncrementController {
		asgl_protected var _value:Number;
		
		private var _loop:Number;
		private var _max:Number;
		private var _min:Number;
		
		public function IncrementController() {
			_max = Number.POSITIVE_INFINITY;
			_min = Number.NEGATIVE_INFINITY;
			_value = 0;
			_loop = 0;
		}
		public function get value():Number {
			return _value;
		}
		public function append(value:Number):Number {
			var total:Number = _value + value;
			
			if (total < _min) {
				value = _min - _value;
			} else if (total > _max) {
				value = _max - _value;
			}
			
			_value += value;
			
			if (_loop != 0) _value %= _loop;
			
			return value;
		}
		public function reset():void {
			_value = 0;
		}
		public function setLoop(value:Number):void {
			_loop = value;
		}
		public function setRange(min:Number, max:Number):void {
			if (_max<_min) _max = _min;
			_min = min;
			_max = max;
		}
	}
}