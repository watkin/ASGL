package asgl.shaders.scripts {
	import asgl.asgl_protected;
	
	use namespace asgl_protected;
	
	public class ShaderPropertyType {
		public static const ATTRIBUTE_BUFFERS:Vector.<String> = Shader3D._createIndexConstants('attributeBuffer', 5);
		public static const COLOR_BUFFERS:Vector.<String> = Shader3D._createIndexConstants('colorBuffer', 2);
		public static const BONE_INDEX_BUFFER:String = 'boneIndexBuffer';
		public static const NORMAL_BUFFER:String = 'normalBuffer';
		public static const TANGENT_BUFFER:String = 'tangentBuffer';
		public static const TEXCOORD_BUFFER:String = 'texCoordBuffer';
		public static const VERTEX_BUFFER:String = 'vertexBuffer';
		public static const WEIGHT_BUFFER:String = 'weightBuffer';
		
		public static const DIFFUSE_TEX:String = 'diffuseTex';
		public static const NORMAL_TEX:String = 'normalTex';
		public static const SOURCE_TEX:String = 'sourceTex';
		public static const SHADOW_TEXS:Vector.<String> = Shader3D._createIndexConstants('shadowTex', 2);
		
		public static const SOURCE_TEX_ATTRIBUTE:String = 'sourceTexAttribute';
		
		public static const LOCAL_TO_PROJ_MATRIX:String = 'localToProjMatrix';
		public static const LOCAL_TO_VIEW_MATRIX:String = 'localToViewMatrix';
		public static const LOCAL_TO_WORLD_MATRIX:String = 'localToWorldMatrix';
		public static const PROJ_TO_VIEW_MATRIX:String = 'projToViewMatrix';
		public static const PROJ_TO_WORLD_MATRIX:String = 'projToWorldMatrix';
		public static const VIEW_TO_PROJ_MATRIX:String = 'viewToProjMatrix';
		public static const WORLD_TO_PROJ_MATRIX:String = 'worldToProjMatrix';
		public static const BILLBOARD_MATRIX:String = 'billboardMatrix';
		
		public static const FILTER_MATRIX_33:String = 'filterMatrix33';
		public static const FILTER_MATRIX_55:String = 'filterMatrix55';
		
		/**
		 * x(threshold), y(threshold ~~ threshold)
		 */
		public static const THRESHOLD:String = 'threshold';
		
		/**
		 * x(x0), y(y0), z(z0)
		 */
		public static const VIEW_WORLD_POSITION:String = 'viewWorldPosition';
		
		/**
		 * red factor(x0), green factor(y0), blue factor(z0), alpha factor(w0)
		 */
		public static const ADDITIVE_COLOR:String = 'additiveColor';
		
		public static const BACKGROUND_COLOR:String = 'backgroundColor';
		
		/**
		 * red factor(x0), green factor(y0), blue factor(z0), alpha factor(w0)
		 */
		public static const MULTIPLY_COLOR:String = 'multiplyColor';
		
		public static const COLOR_ATTRIBUTE:String = 'colorAttribute';
		
		/**
		 * left top(0, 0), right bottom(1, 1)
		 * x(x0), y(y0), width(z0), height(w0)
		 */
		public static const DIFFUSE_TEX_REGION:String = 'diffuseTexRegion';
		
		/**
		 * total time(x0), isLoop(y0)
		 * acceleration(x1, y1, z1)
		 */
		public static const PARTICLE_ATTRIBUTE:String = 'particleAttribute';
		
		public static const BONE_DATA:String = 'boneData';
		
		/**
		 * ambient factor(x0), depth offset(y0)
		 */
		public static const LIGHTING_GLOBAL_FRAG_ATT:String = 'lightingGlobalFragAtt';
		
		public static const LIGHTING_VERT_ATTS:Vector.<String> = Shader3D._createIndexConstants('lightingVertAtt', 2);
		public static const LIGHTING_FRAG_ATTS:Vector.<String> = Shader3D._createIndexConstants('lightingFragAtt', 2);
		
		public static const WORLD_TO_LIGHT_MATRICES:Vector.<String> = Shader3D._createIndexConstants('worldToLightMatrix', 2);
		
		public function ShaderPropertyType() {
		}
	}
}