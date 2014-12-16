package asgl.shaders.asm.builtin.realtime {
	import asgl.errors.ASGLError;
	import asgl.shaders.asm.IShaderCoder;
	import asgl.shaders.asm.RegisterManager;
	
	public class DefaultHorisonFogShader extends BaseHorisonFogShader {
		private var _completeHandler:Function;
		private var _currentDepth:String;
		private var _constants:Vector.<String>;
		public function DefaultHorisonFogShader(vs:IShaderCoder=null, fs:IShaderCoder=null) {
			super(vs, fs);
		}
		public static function getConstants(focusDepth:Number, gradualProgressDistance:Number):Vector.<Number> {
			var vec:Vector.<Number> = new Vector.<Number>(4);
			vec[0] = focusDepth;
			vec[1] = gradualProgressDistance;
			return vec;
		}
		/**
		 * @param constantsObject the value is constantsIndex:uint or constants:Vector.&ltString&gt(v.n, v.n)(value of regs = focusDepth, gradualProgressDistance)
		 */ 
		public function setDefaultCode(rm:RegisterManager, shaderType:String, constantsObject:*, currentDepth:String, completeHandler:Function):void {
			if (constantsObject is uint) {
				var index:uint = constantsObject as uint;
				_constants = new Vector.<String>(2);
				var regType:String = rm.getConstant(shaderType).type;
				_constants[0] = regType + index + '.x';
				_constants[1] = regType + index + '.y';
			} else if (constantsObject is Vector.<String>) {
				_constants = constantsObject as Vector.<String>;
			} else {
				throw new ASGLError(ASGLError.PARAMETERS_ERROR);
			}
			
			_currentDepth = currentDepth;
			_completeHandler = completeHandler;
			
			this.setCode(rm, shaderType);
			
			_completeHandler = null;
		}
		protected override function _complete(rm:RegisterManager, shaderType:String, strength:String):void {
			if (_completeHandler != null) _completeHandler(rm, shaderType, strength);
		}
		protected override function _getCurrentDepth(rm:RegisterManager):String {
			return _currentDepth;
		}
		protected override function _getFoucsDepth(rm:RegisterManager):String {
			return _constants[0];
		}
		protected override function _getGradualProgressDistance(rm:RegisterManager):String {
			return _constants[1];
		}
	}
}