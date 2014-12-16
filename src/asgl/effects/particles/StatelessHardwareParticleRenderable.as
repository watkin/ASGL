package asgl.effects.particles {
	import asgl.asgl_protected;
	import asgl.entities.Camera3D;
	import asgl.renderers.BaseRenderContext;
	import asgl.shaders.scripts.Shader3D;
	import asgl.shaders.scripts.Shader3DHelper;
	import asgl.shaders.scripts.ShaderPropertyType;
	import asgl.system.Device3D;
	
	use namespace asgl_protected;

	public class StatelessHardwareParticleRenderable extends BaseParticleRenderable {
		private var _particleData:AbstractStatelessHardwareParticleData;
		private var _changeCount:int;
		
		public function StatelessHardwareParticleRenderable() {
		}
		public function get particleData():AbstractStatelessHardwareParticleData {
			return _particleData;
		}
		public function set particleData(value:AbstractStatelessHardwareParticleData):void {
			if (_particleData != value) {
				_particleData = value;
				
				_changeCount = 0;
			}
		}
		
		public override function collectRenderObject(device:Device3D, camera:Camera3D, context:BaseRenderContext):void {
			if (_particleData != null && _particleData._numParticles > 0) {
				context.pushRenderable(this);
			}
		}
		public override function preRender(device:Device3D, camera:Camera3D):void {
			Shader3D.setGlobalConstants(ShaderPropertyType.PARTICLE_ATTRIBUTE, _particleData._particleAttribute);
			Shader3DHelper.setGlobalBillboardMatrix(_object3D, camera, _billboardType);
		}
		public override function postRender(device:Device3D, camera:Camera3D):void {
			Shader3D.setGlobalConstants(ShaderPropertyType.PARTICLE_ATTRIBUTE, null);
			Shader3D.setGlobalConstants(ShaderPropertyType.BILLBOARD_MATRIX, null);
		}
	}
}