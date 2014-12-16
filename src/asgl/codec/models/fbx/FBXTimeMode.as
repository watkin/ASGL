package asgl.codec.models.fbx {
	public class FBXTimeMode {
		private static var _framesPreSecondMap:Object = _createFramesPreSecondMap();
		
		public static const DEFAULT_MODE:uint = 0;
		public static const FRAMES120:uint = 1;
		public static const FRAMES100:uint = 2;
		public static const FRAMES60:uint = 3;
		public static const FRAMES50:uint = 4;
		public static const FRAMES48:uint = 5;
		public static const FRAMES30:uint = 6;
		public static const FRAMES30_DROP:uint = 7;
		public static const NTSC_DROP_FRAME:uint = 8;
		public static const NTSC_FULL_FRAME:uint = 9;
		public static const PAL:uint = 10;
		public static const CINEMA:uint = 11;
		public static const FRAMES1000:uint = 12;
		public static const CINEMA_ND:uint = 13;
		public static const CUSTOM :uint = 14;
		public static const TIME_MODE_COUNT :uint = 15;
		
		public function FBXTimeMode() {
		}
		public static function getFramesPreSecond(timeMode:uint):Number {
			return _framesPreSecondMap[timeMode];
		}
		private static function _createFramesPreSecondMap():Object {
			var map:Object = {};
			
			map[DEFAULT_MODE] = 30;
			map[FRAMES120] = 120;
			map[FRAMES120] = 100;
			map[FRAMES60] = 60;
			map[FRAMES50] = 50;
			map[FRAMES48] = 48;
			map[FRAMES30] = 30;
			map[FRAMES30_DROP] = 30;
			map[NTSC_DROP_FRAME] = 30;//29.97
			map[NTSC_FULL_FRAME] = 30;//29.97
			map[PAL] = 25;
			map[CINEMA] = 24;//
			map[FRAMES1000] = 1000;
			map[CINEMA_ND] = 24;//
			map[CUSTOM] = 30;//
			map[TIME_MODE_COUNT] = 30;//
			
			return map;
		}
	}
}