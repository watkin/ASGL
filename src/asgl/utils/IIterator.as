package asgl.utils {
	public interface IIterator {
		function get isTrail():Boolean;
		function begin():void;
		function clear():void;
		function lock():void;
		function next():*;
		function unlock():void;
	}
}