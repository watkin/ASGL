package asgl.animators {
	import flash.geom.Rectangle;
	
	import asgl.asgl_protected;
	import asgl.geometries.MeshElement;
	
	use namespace asgl_protected;
	
	public class SpriteSheetAnimator extends BaseAnimator {
		asgl_protected var _meshElement:MeshElement;
		asgl_protected var _oldValues:Vector.<Number>;
		
		asgl_protected var _region:Rectangle;
		
		public function SpriteSheetAnimator() {
		}
		public function get meshElement():MeshElement {
			return _meshElement;
		}
		public function set meshElement(value:MeshElement):void {
			if (_meshElement != null) {
				_meshElement.values = _oldValues;
			}
			
			_meshElement = value;
			_oldValues = _meshElement == null ? null : _meshElement.values;
		}
		public function get region():Rectangle {
			return _region;
		}
		public function set region(value:Rectangle):void {
			_region = value;
		}
		protected override function _update(lerp:Boolean):void {
			var curData:Vector.<SpriteSheetAsset> = _currentClip._data;
			if (curData == null) return;
			
			var asset:SpriteSheetAsset = curData[_globalCurrentTileFrame];
			
			if (_region != null) {
				var region:Rectangle = asset.textureRegion;
				_region.x = region.x;
				_region.y = region.y;
				_region.width = region.width;
				_region.height = region.height;
			}
			
			if (_meshElement != null) {
				_meshElement.values = asset.vertices;
			}
			
			_updateCount++;
		}
	}
}