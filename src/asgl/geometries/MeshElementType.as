package asgl.geometries {
	import asgl.shaders.scripts.ShaderPropertyType;

	public class MeshElementType {
		public static const SHADER_PROPERTY_MAPPING:Object = _getShaderPropertyMapping();
		
		public static const VERTEX:int = 0;
		public static const TEXCOORD:int = 1;
		public static const NORMAL:int = 2;
		public static const TANGENT:int = 3;
		public static const BINORMAL:int = 4;
		public static const ATTRIBUTE0:int = 5;
		public static const ATTRIBUTE1:int = 6;
		public static const ATTRIBUTE2:int = 7;
		public static const ATTRIBUTE3:int = 8;
		public static const ATTRIBUTE4:int = 9;
		public static const COLOR0:int = 10;
		public static const COLOR1:int = 11;
		public static const BONE_INDEX:int = 12;
		public static const WEIGHT:int = 13;
		
		public function MeshElementType() {
		}
		private static function _getShaderPropertyMapping():Object {
			var map:Object = {};
			
			map[VERTEX] = ShaderPropertyType.VERTEX_BUFFER;
			map[TEXCOORD] = ShaderPropertyType.TEXCOORD_BUFFER;
			map[NORMAL] = ShaderPropertyType.NORMAL_BUFFER;
			map[TANGENT] = ShaderPropertyType.TANGENT_BUFFER;
			map[ATTRIBUTE0] = ShaderPropertyType.ATTRIBUTE_BUFFERS[0];
			map[ATTRIBUTE1] = ShaderPropertyType.ATTRIBUTE_BUFFERS[1];
			map[ATTRIBUTE2] = ShaderPropertyType.ATTRIBUTE_BUFFERS[2];
			map[ATTRIBUTE3] = ShaderPropertyType.ATTRIBUTE_BUFFERS[3];
			map[ATTRIBUTE4] = ShaderPropertyType.ATTRIBUTE_BUFFERS[4];
			map[COLOR0] = ShaderPropertyType.COLOR_BUFFERS[0];
			map[COLOR1] = ShaderPropertyType.COLOR_BUFFERS[1];
			map[BONE_INDEX] = ShaderPropertyType.BONE_INDEX_BUFFER;
			map[WEIGHT] = ShaderPropertyType.WEIGHT_BUFFER;
			
			return map;
		}
	}
}