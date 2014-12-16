package asgl.renderers {
	import asgl.asgl_protected;
	import asgl.entities.Camera3D;
	import asgl.materials.Material;
	import asgl.renderables.BaseRenderable;
	import asgl.system.Device3D;
	
	use namespace asgl_protected;
	
	public class BaseRenderer {
		private static var _instanceIDAccumulator:uint = 0;
		
		public var lockDepthTest:Boolean;
		
		asgl_protected var _instanceID:uint;
		
		/**
		 * hide
		 */
		asgl_protected var _isRunning:Boolean;
		
		public function BaseRenderer() {
			_instanceID = ++_instanceIDAccumulator;
		}
		public function dispose():void {
		}
		public function postRender(device:Device3D, camera:Camera3D, context:BaseRenderContext):void {
		}
		public function preRender(device:Device3D, camera:Camera3D, context:BaseRenderContext):void {
		}
		public function pushCheck(renderable:BaseRenderable, material:Material):Boolean {
			return false;
		}
		public function pushRenderable(renderable:BaseRenderable, device:Device3D, camera:Camera3D, material:Material, staticRenderData:Vector.<AbstractStaticRenderData>):void {
		}
		public function render(device:Device3D, staticRenderData:Vector.<AbstractStaticRenderData>):void {
		}
		public function renderStatic(device:Device3D, renderID:uint):void {
		}
		public function destroyStatic(renderID:uint):void {
		}
	}
}