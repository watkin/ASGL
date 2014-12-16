package asgl.utils {
	public interface IBitAllocator {
		/**
		 * asgl_protected::_bits
		 */
		function get bits():Number;
		function get usableLength():uint;
		function allocate(length:uint):int;
		function change(index:uint, value:uint):Boolean;
		function getValue(index:uint):uint;
	}
}