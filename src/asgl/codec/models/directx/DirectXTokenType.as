package asgl.codec.models.directx {
	public class DirectXTokenType {
		public static const NAME:uint = 1;
		public static const STRING:uint = 2;
		public static const INTEGER:uint = 3;
		public static const GUID:uint = 5;
		public static const INTEGER_LIST:uint = 6;
		public static const FLOAT_LIST:uint = 7;
		public static const OBRACE:uint = 10;//{
		public static const CBRACE:uint = 11;//}
		public static const OPAREN:uint = 12;//(
		public static const CPAREN:uint = 13;//)
		public static const OBRACKET:uint = 14;//[
		public static const CBRACKET:uint = 15;//]
		public static const OANGLE:uint = 16;//<
		public static const CANGLE:uint = 17;//>
		public static const DOT:uint = 18;//.
		public static const COMMA:uint = 19;//,
		public static const SEMICOLON:uint = 20;//;
		public static const TEMPLATE:uint = 31;
		public static const WORD:uint = 40;
		public static const DWORD:uint = 41;
		public static const FLOAT:uint = 42;
		public static const DOUBLE:uint = 43;
		public static const CHAR:uint = 44;
		public static const UCHAR:uint = 45;
		public static const SWORD:uint = 46;
		public static const SDWORD:uint = 47;
		public static const VOID:uint = 48;
		public static const LPSTR:uint = 49;
		public static const UNICODE:uint = 50;
		public static const CSTRING:uint = 51;
		public static const ARRAY:uint = 52;
		
		public function DirectXTokenType() {
		}
	}
}