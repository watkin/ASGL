package asgl.codec.models.asmesh {
	public class ASModelChunk {
		public static const MAIN:uint = 0x0001;
		
		public static const BONES:uint = 0x0101;
		
		public static const MESH_GROUP:uint = 0x0201;
		public static const VERTICES:uint = 0x0202;
		public static const TEX_COORDS:uint = 0x0203;
		public static const TRI_INDICES:uint = 0x0204;
		public static const NORMALS:uint = 0x0205;
		public static const TANGENTS:uint = 0x0206;
		public static const BINORMALS:uint = 0x0207;
		
		public static const SKINNED_MESH:uint = 0x0301;
		
		public static const ANIM_DATA:uint = 0x0401;
		public function ASModelChunk() {
		}
	}
}