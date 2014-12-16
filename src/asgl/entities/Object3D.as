package asgl.entities {
	import asgl.asgl_protected;
	import asgl.bounds.BoundingVolume;
	import asgl.renderables.BaseRenderable;
	import asgl.renderers.BaseRenderContext;
	import asgl.scenes.culling.ICullingObject;
	import asgl.system.Device3D;
	
	use namespace asgl_protected;
	
	public class Object3D extends Coordinates3D implements ICullingObject {
		public var cullingLabel:uint = 0x1;
		public var isStatic:Boolean;
		
		asgl_protected var _boundingVolume:BoundingVolume;
		asgl_protected var _renderable:BaseRenderable;
		asgl_protected var _enabled:Boolean;
		asgl_protected var _alpha:Number;
		asgl_protected var _multipliedAlpha:Number;
		asgl_protected var _dynamicSortEnabled:Boolean;
		
		asgl_protected var _frustumCullingVisible:Boolean;
		
		public function Object3D() {
		}
		protected override function _constructor():void {
			super._constructor();
			
			_enabled = true;
			_alpha = 1;
			_dynamicSortEnabled = true;
			
			_frustumCullingVisible = true;
		}
		public function get alpha():Number {
			return _alpha;
		}
		public function set alpha(value:Number):void {
			if (value < 0) {
				_alpha = 0;
			} else if (value > 1) {
				_alpha = 1;
			} else {
				_alpha = value;
			}
		}
		public function get boundingVolume():BoundingVolume {
			return _boundingVolume;
		}
		public function set boundingVolume(value:BoundingVolume):void {
			_boundingVolume = value;
		}
		public function get dynamicSortEnabled():Boolean {
			return _dynamicSortEnabled;
		}
		public function set dynamicSortEnabled(value:Boolean):void {
			_dynamicSortEnabled = value;
		}
		public function get enabled():Boolean {
			return _enabled;
		}
		public function set enabled(value:Boolean):void {
			_enabled = value;
		}
		public function get renderable():BaseRenderable {
			return _renderable;
		}
		public function set renderable(value:BaseRenderable):void {
			if (_renderable != value) {
				if (_renderable != null) _renderable._object3D = null;
				
				if (value == null) {
					_renderable = null;
				} else {
					if (value._object3D != null) value._object3D._renderable = null;
					_renderable = value;
					_renderable._object3D = this;
				}
			}
		}
		public function updateMultipliedAlpha():void {
			if (_parent == null) {
				_multipliedAlpha = _alpha;
			} else {
				var p:* = _parent;
				while (true) {
					if (p is Object3D) {
						break;
					} else {
						p = p._parent;
					}
				}
				
				if (p == null) {
					_multipliedAlpha = _alpha;
				} else if (p is Object3D) {
					p.updateMultipliedAlpha();
					_multipliedAlpha = p._multipliedAlpha * _alpha;
				}
			}
		}
		
		public function get frustumCullingVisible():Boolean {
			return _frustumCullingVisible;
		}
		public function set frustumCullingVisible(value:Boolean):void {
			_frustumCullingVisible = value;
		}
		public function frustumCullingPass():void {
			
		}
		
		public function collectRenderObject(device:Device3D, camera:Camera3D, context:BaseRenderContext):void {
			if (_renderable != null && (camera.cullingMask & cullingLabel) != 0) _renderable.collectRenderObject(device, camera, context);
		}
	}
}