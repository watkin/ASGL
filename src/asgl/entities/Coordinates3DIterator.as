package asgl.entities {
	import asgl.asgl_protected;
	import asgl.utils.IIterator;
	
	use namespace asgl_protected;

	public class Coordinates3DIterator implements IIterator {
		asgl_protected var _coord:Coordinates3D;
		asgl_protected var _index:int;
		asgl_protected var _isLocked:Boolean;
		asgl_protected var _isLooping:Boolean;
		
		public function Coordinates3DIterator(coord:Coordinates3D) {
			_coord = coord;
		}
		public function get isTrail():Boolean {
			return _coord == null || _index >= _coord._delayNumChildren;
		}
		public function begin():void {
			_index = 0;
		}
		public function clear():void {
			if (_coord != null) {
				_coord = null;
				
				if (_isLocked) {
					_isLocked = false;
					if (!_isLooping) _coord._isLooping = false;
				}
			}
		}
		public function lock():void {
			if (_coord != null && !_isLocked) {
				_isLocked = true;
				
				_isLooping = _coord._isLooping;
				_coord._isLooping = true;
			}
		}
		public function next():* {
			if (_coord != null && _index < _coord._delayNumChildren) {
				var child:Coordinates3D;
				
				if (_isLocked) {
					child = _coord._delayChildren[_index];
					if (child == null) {
						for (var i:int = _coord._delayNumChildren - 1; i > _index; i--) {
							child = _coord._delayChildren[--_coord._delayNumChildren];
							if (child != null) break;
						}
						
						if (child != null) {
							child._containerIndex = _index;
							_coord._delayChildren[_index] = child;
						}
					}
					
					_index++;
					
					return child;
				} else {
					do {
						child = _coord._delayChildren[_index++];
						if (child != null) return child;
					} while (_index < _coord._delayNumChildren);
					
					return null;
				}
			} else {
				return null;
			}
			
			return null;
		}
		public function unlock():void {
			if (_coord != null && _isLocked) {
				_isLocked = false;
				if (!_isLooping) _coord._isLooping = false;
			}
		}
	}
}