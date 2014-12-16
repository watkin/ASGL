package asgl.utils {
	public class NumberLong {
		public static const MAX_VALUE:Number = 9007199254740991;//0x1FFFFFFFFFFFFF 53bits
		public static const MIN_VALUE:Number = -9007199254740991;
		
		public static const MAX_HIGH_21BITS_VALUE:uint = 2097151;
		
		public static const HIGH_CONST:Number = 4294967296;
		
		public function NumberLong() {
		}
		public static function getValue(high:uint, low:uint):Number {
			var value:Number;
			
			var neg:Boolean = false;
			if ((high & 0x80000000) == 0x80000000) {
				neg = true;
				
				high = ~high;
				low = ~low;
			}
			
			if (high <= MAX_HIGH_21BITS_VALUE) {
				value = high * NumberLong.HIGH_CONST + low;
				if (neg) value *= -1;
			}
			
			return value;
		}
	}
}