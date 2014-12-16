package asgl.effects.particles {
	import asgl.asgl_protected;
	import asgl.effects.BillboardType;
	import asgl.renderables.BaseRenderable;
	import asgl.system.BlendFactorsData;
	
	use namespace asgl_protected;

	public class BaseParticleRenderable extends BaseRenderable {
		asgl_protected var _billboardType:uint;
		
		public function BaseParticleRenderable() {
			_billboardType = BillboardType.PARALLEL_VIEW_PLANE;
			_blendFactors = BlendFactorsData.ALPHA_BLEND;
		}
		public function get billboardType():uint {
			return _billboardType;
		}
		public function set billboardType(value:uint):void {
			_billboardType = value;
		}
	}
}