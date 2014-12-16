package asgl.shadows {
	import asgl.math.Matrix4x4;
	import asgl.system.AbstractTextureData;

	public class ShadowMapData {
		public var depthTexture:AbstractTextureData;
		public var worldToLightMatrix:Matrix4x4;
		
		public function ShadowMapData() {
		}
	}
}