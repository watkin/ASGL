package asgl.shaders.asm.builtin.realtime {
	import asgl.errors.ASGLError;
	import asgl.shaders.asm.BaseASMShader;
	import asgl.shaders.asm.IShaderCoder;
	import asgl.shaders.asm.RegisterAllocator;
	import asgl.shaders.asm.RegisterManager;
	import asgl.shaders.asm.agal.AGALBase;
	
	public class BaseHorisonFogShader extends BaseASMShader {
		public function BaseHorisonFogShader(vs:IShaderCoder=null, fs:IShaderCoder=null) {
			super(vs, fs);
		}
		public function setCode(rm:RegisterManager, shaderType:String):void {
			this.currentShaderType = shaderType;
			var sc:IShaderCoder = this.currentShaderCoder;
			if (sc == null) {
				this.clearShaderType(rm);
				throw new ASGLError(ASGLError.SHADER_TYPE_ERROR);
			}
			
			rm.currentShaderType = shaderType;
			var reg:RegisterAllocator = rm.currentTemporary;
			if (reg == null) {
				this.clearShaderType(rm);
				throw new ASGLError(ASGLError.SHADER_TYPE_ERROR);
			}
			
			if (reg.usableAmount>1) {
				var tmp1:String = reg.allocate();
				
				var curDepth:String = _getCurrentDepth(rm);
				
				sc.appendCode(AGALBase.sub(tmp1 + '.x', _getCurrentDepth(rm), _getFoucsDepth(rm)));
				sc.appendCode(AGALBase.div(tmp1 + '.x', tmp1 + '.x', _getGradualProgressDistance(rm)));
				sc.appendCode(AGALBase.saturate(tmp1 + '.x', tmp1 + '.x'));
				
				this.clearShaderType(rm);
				
				_complete(rm, shaderType, tmp1 + '.x');
			} else {
				this.clearShaderType(rm);
				throw new ASGLError(ASGLError.REGISTER_USABLE_AMOUNT_ERROR)
			}
		}
		/**
		 * computed stringth of fog.
		 */
		protected function _complete(rm:RegisterManager, shaderType:String, strength:String):void {
			
		}
		/**
		 * must override.
		 */
		protected function _getCurrentDepth(rm:RegisterManager):String {
			return null;
		}
		/**
		 * must override.
		 */
		protected function _getFoucsDepth(rm:RegisterManager):String {
			return null;
		}
		/**
		 * must override.
		 */
		protected function _getGradualProgressDistance(rm:RegisterManager):String {
			return null;
		}
	}
}