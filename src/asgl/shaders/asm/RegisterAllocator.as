package asgl.shaders.asm {
	import asgl.utils.IndexAllocator;

	public class RegisterAllocator {
		private var _indexAllocator:IndexAllocator;
		private var _typeLen:int;
		private var _type:String;
		public function RegisterAllocator(type:String, maxNum:int=-1) {
			_type = type;
			_typeLen = _type.length;
			_indexAllocator = new IndexAllocator(maxNum);
		}
		public function get type():String {
			return _type;
		}
		public function get usableAmount():uint {
			return _indexAllocator.usableAmount;
		}
		public function allocate(index:int=-1):String {
			index = _indexAllocator.allocate(index);
			return index == -1 ? null : _type+index;
		}
		public function free(reg:String):Boolean {
			var type:String = reg.substr(0, _typeLen);
			if (type == _type) {
				return _indexAllocator.free(int(reg.substr(_typeLen)));
			} else {
				return false;
			}
		}
		public function freeAll():void {
			_indexAllocator.freeAll();
		}
	}
}