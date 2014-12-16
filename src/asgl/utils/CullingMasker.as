package asgl.utils {
	public class CullingMasker {
		public function CullingMasker() {
		}
		public static function change(index:uint, src:uint, value:Boolean):uint {
			if (index > 31) throw new RangeError('max index is 31');
			
			var index1:uint;
			
			var left:uint;
			var right:uint;
			
			if (index == 31) {
				left = 0;
				
				index1 = 32 - index;
				right = src << index1 >>> index1;
			} else {
				index1 = index + 1;
				left = (src >>> index1) << index1;
				
				if (index == 0) {
					right = 0;
				} else {
					index1 = 32 - index;
					right = src << index1 >>> index1;
				}
			}
			
			return left | ((value ? 1 : 0) << index) | right;
		}
	}
}