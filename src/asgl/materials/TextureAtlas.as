package asgl.materials {
	import flash.geom.Rectangle;

	public class TextureAtlas {
		private var _map:Object;
		private var _amount:uint;
		
		public function TextureAtlas() {
			_map = {};
		}
		public function get numRegions():uint {
			return _amount;
		}
		public function setRegion(name:String, rect:Rectangle):void {
			var hasOld:Boolean = name in _map;
			
			if (rect == null) {
				if (hasOld) {
					_amount--;
					delete _map[name];
				}
			} else {
				_map[name] = rect;
				if (!hasOld) _amount++;
			}
		}
		public function getRegion(name:String):Rectangle {
			return _map[name];
		}
		public function removeRegions():void {
			if (_amount > 0) {
				_map = {};
				_amount = 0;
			}
		}
	}
}