package asgl.system {
	import flash.display3D.Context3DClearMask;
	
	import asgl.asgl_protected;

	use namespace asgl_protected;
	
	public class ClearData {
		public var clearMask:uint;
		public var clearDepth:Number;
		public var clearStencil:uint;
		
		/**
		 * rgba
		 */
		asgl_protected var _backgroundColor:uint;
		asgl_protected var _backgroundColorRed:Number;
		asgl_protected var _backgroundColorGreen:Number;
		asgl_protected var _backgroundColorBlue:Number;
		asgl_protected var _backgroundColorAlpha:Number;
		
		public function ClearData() {
			clearMask = Context3DClearMask.ALL;
			clearDepth = 1;
			clearStencil = 0;
			
			_backgroundColor = 0x000000FF;
			_backgroundColorRed = 0;
			_backgroundColorGreen = 0;
			_backgroundColorBlue = 0;
			_backgroundColorAlpha = 1;
		}
		public function get backgroundColor():uint {
			return _backgroundColor;
		}
		/**
		 * rgba
		 */
		public function set backgroundColor(value:uint):void {
			_backgroundColor = value;
			_backgroundColorRed = (_backgroundColor >> 24 & 0xFF) / 0xFF;
			_backgroundColorGreen = (_backgroundColor >> 16 & 0xFF) / 0xFF;
			_backgroundColorBlue = (_backgroundColor >> 8 & 0xFF) / 0xFF;
			_backgroundColorAlpha = (_backgroundColor & 0xFF) / 0xFF;
		}
		public function copy(data:ClearData):void {
			clearMask = data.clearMask;
			clearDepth = data.clearDepth;
			clearStencil = data.clearStencil;
			
			_backgroundColor = data._backgroundColor;
			_backgroundColorRed = data._backgroundColorRed;
			_backgroundColorGreen = data._backgroundColorGreen;
			_backgroundColorBlue = data._backgroundColorBlue;
			_backgroundColorAlpha = data._backgroundColorAlpha
		}
	}
}