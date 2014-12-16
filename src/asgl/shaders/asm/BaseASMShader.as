package asgl.shaders.asm {
	import flash.display3D.Context3DProgramType;
	import flash.utils.ByteArray;
	
	import asgl.asgl_protected;
	import asgl.shaders.asm.agal.compiler.AGALCompiler;
	
	use namespace asgl_protected;

	public class BaseASMShader {
		public static const XYZW:Vector.<String> = Vector.<String>(['x', 'y', 'z', 'w']);
		
		private static const COMPILER:AGALCompiler = new AGALCompiler();
		
		protected var _vs:IShaderCoder;
		protected var _fs:IShaderCoder;
		private var _curShaderCoder:IShaderCoder;
		private var _curShaderType:String;
		public function BaseASMShader(vs:IShaderCoder=null, fs:IShaderCoder=null) {
			_vs = vs;
			_fs = fs;
			if (_vs == null) _vs = new ShaderCoder();
			if (_fs == null) _fs = new ShaderCoder();
		}
		public function get currentShaderCoder():IShaderCoder {
			if (_curShaderType == Context3DProgramType.VERTEX) {
				return _vs;
			} else if (_curShaderType == Context3DProgramType.FRAGMENT) {
				return _fs;
			} else {
				return null;
			}
		}
		public function get currentShaderType():String {
			return _curShaderType;
		}
		public function set currentShaderType(value:String):void {
			if (value == Context3DProgramType.VERTEX || value == Context3DProgramType.FRAGMENT || value == null) _curShaderType = value;
		}
		public function get fragmentShaderCoder():IShaderCoder {
			return _fs;
		}
		public function get vertexShaderCoder():IShaderCoder {
			return _vs;
		}
		public function getProgram(programType:String, version:uint=0, op:ByteArray=null):ByteArray {
			if (programType == Context3DProgramType.VERTEX) {
				return COMPILER.compile(programType, _vs.code, version, op);
			} else if (programType == Context3DProgramType.FRAGMENT) {
				return COMPILER.compile(programType, _fs.code, version, op);
			} else {
				return null;
			}
		}
		public function clearCode():void {
			_vs.clear();
			_fs.clear();
		}
		public function clearShaderType(rm:RegisterManager):void {
			this.currentShaderType = null;
			if (rm != null) rm.currentShaderType = null;
		}
		public function getShaderCoder(type:String):IShaderCoder {
			if (type == Context3DProgramType.VERTEX) {
				return _vs;
			} else if (type == Context3DProgramType.FRAGMENT) {
				return _fs;
			} else {
				return null;
			}
		}
	}
}