package asgl.codec.models.max3ds {
	public class Max3DSChunk {
		public static const MAIN3DS:uint = 0x4D4D;
		public static const VERSION:uint = 0x0002;
		public static const EDIT3DS:uint = 0x3D3D;
		public static const KEYF3DS:uint = 0xB000;
		
		//EDIT_3DS
		public static const EDIT_CONFIG1:uint = 0x0100;
		public static const EDIT_CONFIG2:uint = 0x3D3E;
		
		public static const LIGHT:uint = 0x4600;
		
		public static const EDIT_OBJECT:uint = 0x4000;
		public static const EDIT_MATERIAL:uint = 0xAFFF;
		
		public static const MAT_NAME:uint = 0xA000;
		public static const MAT_MAP:uint = 0xA200;
		public static const MAT_PATH:uint = 0xA300;
		
		public static const OBJ_TRIMESH:uint = 0x4100;
		public static const OBJ_CAMERA:uint = 0x4700;
		
		//EIDT_OBJECT:
		public static const TRI_VERTEX:uint = 0x4110;
		public static const TRI_FACEVERT:uint = 0x4120;
		public static const TRI_FACEMAT:uint = 0x4130;
		public static const TRI_UV:uint = 0x4140;
		public static const TRI_LOCAL:uint = 0x4160;
		
		//KEYF3DS:
		public static const KEYF_OBJDES:uint = 0xB002;
		public static const KEYF_FRAMES:uint = 0xB008;
		public static const KEYF_OBJHIERARCH:uint = 0xB010;
		public static const KEYF_PIVOTPOINT:uint = 0xB013;
		public static const KEYF_OBJPIVOT:uint = 0xB020;
	}
}