package asgl.animators {
	import flash.geom.Rectangle;
	
	import asgl.asgl_protected;
	
	use namespace asgl_protected;
	
	public class RegionKeyFrameAnimator extends BaseAnimator {
		asgl_protected var _region:Rectangle;
		
		public function RegionKeyFrameAnimator() {
		}
		public function get region():Rectangle {
			return _region;
		}
		public function set region(value:Rectangle):void {
			_region = value;
		}
		protected override function _update(lerp:Boolean):void {
			if (_region == null) return;
			var curData:Vector.<Rectangle> = _currentClip._data;
			if (curData == null) return;
			
			var region:Rectangle = curData[_globalCurrentTileFrame];
			_region.x = region.x;
			_region.y = region.y;
			_region.width = region.width;
			_region.height = region.height;
			
			_updateCount++;
		}
	}
}