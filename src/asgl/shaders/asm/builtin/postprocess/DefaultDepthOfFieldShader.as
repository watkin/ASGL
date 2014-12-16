package asgl.shaders.asm.builtin.postprocess {
	import asgl.shaders.asm.IShaderCoder;
	import asgl.shaders.asm.agal.RegisterType;
	import asgl.shaders.asm.RegisterManager;
	
	public class DefaultDepthOfFieldShader extends BaseDepthOfFieldShader {
		private var _blurColorHandler:Function;
		private var _completeHandler:Function;
		private var _pixelDepthHandler:Function;
		private var _sourceColorHandler:Function;
		private var _constIndex:uint;
		public function DefaultDepthOfFieldShader(vs:IShaderCoder=null, fs:IShaderCoder=null) {
			super(vs, fs);
		}
		public static function getFragmentConstants(focusDepth:Number, nearFocusRange:Number, farFocusRange:Number):Vector.<Number> {
			var vec:Vector.<Number> = new Vector.<Number>(8);
			vec[0] = focusDepth-nearFocusRange;
			vec[1] = focusDepth;
			vec[2] = nearFocusRange;
			vec[3] = farFocusRange;
			vec[4] = 1;
			return vec;
		}
		public function setDefaultCode(rm:RegisterManager, constIndex:uint, pixelDepthHandler:Function, sourceColorHandler:Function, blurColorHandler:Function, completeHandler:Function):void {
			_constIndex = constIndex;
			_pixelDepthHandler = pixelDepthHandler;
			_sourceColorHandler = sourceColorHandler;
			_blurColorHandler = blurColorHandler;
			_completeHandler = completeHandler;
			
			this.setCode(rm, Vector.<String>([RegisterType.FRAGMENT_CONSTANT + (_constIndex + 1) + '.x']));
			
			_pixelDepthHandler = null;
			_sourceColorHandler = null;
			_blurColorHandler = null;
			_completeHandler = null;
		}
		protected override function _complete(rm:RegisterManager, finalColor:String):void {
			if (_completeHandler != null) _completeHandler(rm, finalColor);
		}
		protected override function _getBlurColor(dest:String, rm:RegisterManager):void {
			if (_blurColorHandler != null) _blurColorHandler(dest, rm);
		}
		protected override function _getFarFocusRange(rm:RegisterManager):String {
			return RegisterType.FRAGMENT_CONSTANT + _constIndex + '.w';
		}
		protected override function _getFocusDepth(rm:RegisterManager):String {
			return RegisterType.FRAGMENT_CONSTANT + _constIndex + '.y';
		}
		protected override function _getNearBlurDepth(rm:RegisterManager):String {
			return RegisterType.FRAGMENT_CONSTANT + _constIndex + '.x';
		}
		protected override function _getNearFocusRange(rm:RegisterManager):String {
			return RegisterType.FRAGMENT_CONSTANT + _constIndex + '.z';
		}
		protected override function _getPixelDepth(dest:String, rm:RegisterManager):void {
			if (_pixelDepthHandler != null) _pixelDepthHandler(dest, rm);
		}
		protected override function _getSourceColor(dest:String, rm:RegisterManager):void {
			if (_sourceColorHandler != null) _sourceColorHandler(dest, rm);
		}
	}
}