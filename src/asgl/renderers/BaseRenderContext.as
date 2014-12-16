package asgl.renderers {
	import asgl.entities.Camera3D;
	import asgl.entities.Object3D;
	import asgl.materials.Material;
	import asgl.renderables.BaseRenderable;
	import asgl.system.AbstractTextureData;
	import asgl.system.Device3D;
	
	public class BaseRenderContext {
		public var cullingMask:uint = 0xFFFFFFFF;
		
		public function BaseRenderContext() {
		}
		public function dispose():void {
		}
		public function pushRenderable(renderable:BaseRenderable):Boolean {
			return false;
		}
		public function render(device:Device3D, camera:Camera3D, root:Object3D, renderTarget:AbstractTextureData=null, material:Material=null):void {
		}
	}
}