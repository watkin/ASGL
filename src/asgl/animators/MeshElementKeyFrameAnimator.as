package asgl.animators {
	import asgl.asgl_protected;
	import asgl.geometries.MeshElement;
	
	use namespace asgl_protected;
	
	public class MeshElementKeyFrameAnimator extends BaseAnimator {
		asgl_protected var _meshElement:MeshElement;
		asgl_protected var _oldValues:Vector.<Number>;
		
		public function MeshElementKeyFrameAnimator() {
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
		protected override function _update(lerp:Boolean):void {
			if (_meshElement == null) return;
			var curData:Vector.<Vector.<Number>> = _currentClip._data;
			if (curData == null) return;
			
			_meshElement.values = curData[_globalCurrentTileFrame];
			
			_updateCount++;
		}
	}
}