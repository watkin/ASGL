package asgl.renderables {
	import asgl.asgl_protected;
	import asgl.geometries.MeshAsset;
	
	use namespace asgl_protected;
	
	public class MeshRenderable extends BaseRenderable {
		
		public function MeshRenderable() {
		}
		public function set meshAsset(value:MeshAsset):void {
			_meshAsset = value;
		}
	}
}