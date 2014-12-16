package asgl.utils {
	import asgl.asgl_protected;
	
	use namespace asgl_protected;

	public class Bit32Allocator implements IBitAllocator {
		asgl_protected var _bits:uint;
		
		private var _allocatedLength:uint;
		private var _allocatedMap:Object;
		
		public function Bit32Allocator() {
			_constructor();
		}
		private function _constructor():void {
			_allocatedMap = {};
		}
		public function get bits():Number {
			return _bits;
		}
		public function get usableLength():uint {
			return 32-_allocatedLength;
		}
		public function allocate(length:uint):int {
			if (_allocatedLength + length > 32 || length == 0) {
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
				if (value > max) return false;
				
				var last:uint = index + length;
				var right:uint = (1 << index) - 1;
				var left:uint = ((1 << (32 - last)) - 1) << last;
				_bits = (_bits & left) | (value << index) | (_bits & right);
				
				return true;
			} else {
				return false;
			}
		}
		public function getValue(index:uint):uint {
			var length:uint = _allocatedMap[index];
			if (length > 0) {
				var and:uint = length == 32 ? 0xFFFFFFFF : (1 << length) - 1;
				return (_bits >> index) & and;
			} else {
				return 0;
			}
		}
	}
}