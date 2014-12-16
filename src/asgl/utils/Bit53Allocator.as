package asgl.utils {
	import asgl.asgl_protected;
	
	use namespace asgl_protected;

	public class Bit53Allocator implements IBitAllocator {
		private static const CONST:uint = 1048576;
		
		asgl_protected var _bits:Number;
		
		private var _allocatedLength:uint;
		private var _bitsLeft:uint;
		private var _bitsRight:uint;
		private var _allocatedMap:Object;
		
		public function Bit53Allocator() {
			_constructor();
		}
		private function _constructor():void {
			_allocatedMap = {};
		}
		public function get bits():Number {
			return _bits;
		}
		public function get usableLength():uint {
			return 52-_allocatedLength;
		}
		public function allocate(length:uint):int {
			if (_allocatedLength + length > 53 || length == 0) {
				return -1;
			} else {
				var index:uint = _allocatedLength;
				_allocatedLength += length;
				_allocatedMap[index] = length;
				return index;
			}
		}
		public function change(index:uint, value:uint):Boolean {
			var length:uint = _allocatedMap[index];
			if (length > 0) {
				var max:uint = length == 32 ? 0xFFFFFFFF : (1 << length) - 1;
				if (value>max) return false;
				
				var last:uint;
				var right:uint;
				var left:uint;
				
				if (index > 31) {
					index -= 32;
					
					last = index + length;
					right = (1 << index) - 1;
					left = ((1 << (32 - last)) - 1) << last;
					_bitsLeft = (_bitsLeft & left) | (value << index) | (_bitsLeft & right);
				} else if (index + length < 33) {
					last = index + length;
					right = (1 << index) - 1;
					left = ((1 << (32 - last)) - 1) << last;
					_bitsRight = (_bitsRight & left) | (value << index) | (_bitsRight & right);
				} else {
					var lenRight:uint = 32 - index;
					var lenLeft:uint = length - lenRight;
					
					var valueRight:uint = value&((1 << lenRight) - 1);
					var valueLeft:uint = (value >> lenRight) & ((1 << lenLeft) - 1);
					
					right = (1 << index) - 1;
					_bitsRight = (valueRight << index) | (_bitsRight & right);
					
					left = ((1 << (32 - lenLeft)) - 1) << lenLeft;
					_bitsLeft = (_bitsLeft & left) | valueLeft;
				}
				
				_bits = _bitsLeft * CONST + _bitsRight;
				
				return true;
			} else {
				return false;
			}
		}
		public function getValue(index:uint):uint {
			var length:uint = _allocatedMap[index];
			if (length > 0) {
				var and:uint;
				
				if (index > 31) {
					index -= 32;
					
					and = length == 32 ? 0xFFFFFFFF : (1 << length) - 1;
					return (_bitsLeft >> index) & and;
				} else if (index + length < 33) {
					and = length == 32 ? 0xFFFFFFFF : (1 << length) - 1;
					return (_bitsRight >> index) & and;
				} else {
					var lenRight:uint = 32 - index;
					var lenLeft:uint = length - lenRight;
					
					and = (1 << lenRight) - 1;
					var valueRight:uint = (_bitsRight >> index) & and;
					
					and = (1 << lenLeft) - 1;
					var valueLeft:uint = _bitsLeft & and;
					
					return (valueLeft << lenRight) | valueRight;
				}
				
			} else {
				return 0;
			}
		}
	}
}