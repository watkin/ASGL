package asgl.shaders.asm.builtin.postprocess {
	import asgl.errors.ASGLError;
	import asgl.shaders.asm.BaseASMShader;
	import asgl.shaders.asm.IShaderCoder;
	import asgl.shaders.asm.RegisterManager;
	import asgl.shaders.asm.agal.AGALBase;
	import asgl.shaders.asm.agal.AGALMath;
	
	public class BaseDepthOfFieldShader extends BaseASMShader {
		public function BaseDepthOfFieldShader(vs:IShaderCoder=null, fs:IShaderCoder=null) {
			super(vs, fs);
		}
		/**
		 * @param constants = [v.n]</br>
		 * constants = [1]</br>
		 */
		public function setCode(rm:RegisterManager, constants:Vector.<String>):void {
			if (rm.fragmentTemporary.usableAmount > 2) {
				var tmp1:String = rm.fragmentTemporary.allocate();
				var tmp2:String = rm.fragmentTemporary.allocate();
				var tmp3:String = rm.fragmentTemporary.allocate();
				
				_getPixelDepth(tmp1 + '.z', rm);
				
				_fs.appendCode(AGALBase.sub(tmp1 + '.x', tmp1 + '.z', _getNearBlurDepth(rm)));
				_fs.appendCode(AGALBase.div(tmp1 + '.x', tmp1 + '.x', _getNearFocusRange(rm)));
				_fs.appendCode(AGALBase.sub(tmp1 + '.x', constants[0], tmp1 + '.x'));
				
				_fs.appendCode(AGALBase.sub(tmp1 + '.y', tmp1 + '.z', _getFocusDepth(rm)));
				_fs.appendCode(AGALBase.div(tmp1 + '.y', tmp1 + '.y', _getFarFocusRange(rm)));
				
				_fs.appendCode(AGALBase.saturate(tmp1 + '.xy', tmp1 + '.xy'));
				
				_fs.appendCode(AGALBase.max(tmp1 + '.x', tmp1 + '.x', tmp1 + '.y'));
				
				_getSourceColor(tmp2, rm);
				_getBlurColor(tmp3, rm);
				
				_fs.appendCode(AGALMath.lerp(tmp3, tmp2, tmp3, tmp1 + '.x'));
				
				rm.fragmentTemporary.free(tmp1);
				rm.fragmentTemporary.free(tmp2);
				
				
				_complete(rm, tmp3);
			} else {
				throw new ASGLError(ASGLError.REGISTER_USABLE_AMOUNT_ERROR);
			}
		}
		protected function _complete(rm:RegisterManager, finalColor:String):void {
			
		}
		/**
		 * must override.
		 * 
		 * @param dest = v<br>
		 * <b>example:</b></br>
		 * get color form blur texture
		 */
		protected function _getBlurColor(dest:String, rm:RegisterManager):void {
			
		}
		/**
		 * must override.
		 * 
		 * @return v.n
		 */
		protected function _getFarFocusRange(rm:RegisterManager):String {
			return null;
		}
		/**
		 * must override.
		 * 
		 * @return v.n
		 */
		protected function _getFocusDepth(rm:RegisterManager):String {
			return null;
		}
		/**
		 * must override.
		 * 
		 * @return v.n
		 */
		protected function _getNearBlurDepth(rm:RegisterManager):String {
			return null;
		}
		/**
		 * must override.
		 * 
		 * @return v.n
		 */
		protected function _getNearFocusRange(rm:RegisterManager):String {
			return null;
		}
		/**
		 * must override.</br>
		 * 
		 * @param dest = v.n<br>
		 * <b>example:</b></br>
		 * get color form depth texture
		 */
		protected function _getPixelDepth(dest:String, rm:RegisterManager):void {
			
		}
		/**
		 * must override.
		 * 
		 * @param dest = v<br>
		 */
		protected function _getSourceColor(dest:String, rm:RegisterManager):void {
			
		}
	}
}