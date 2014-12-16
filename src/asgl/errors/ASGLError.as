package asgl.errors {
	public class ASGLError extends Error {
		public static const PARAMETERS_ERROR:String = 'parametersError';
		public static const REGISTER_USABLE_AMOUNT_ERROR:String = 'registerUsableAmountError';
		public static const SHADER_TYPE_ERROR:String = 'shaderTypeError';
		public static const SKINNED_MESH_MAX_VERTEX_BLEND_AMOUNT_ERROR:String = 'skinnedMeshMaxVertexBlendAmountError';
		public static const SPECULAR_TYPE_ERROR:String = 'specularTypeError';
		
		public function ASGLError(message:*="", id:*=0) {
			super(message, id);
		}
	}
}