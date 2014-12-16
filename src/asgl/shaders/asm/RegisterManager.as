package asgl.shaders.asm {
	import flash.display3D.Context3DProgramType;
	import asgl.shaders.asm.agal.RegisterType;

	public class RegisterManager {
		private var _fc:RegisterAllocator;
		private var _ft:RegisterAllocator;
		private var _v:RegisterAllocator;
		private var _vc:RegisterAllocator;
		private var _vt:RegisterAllocator;
		
		private var _curShaderType:String;
		public function RegisterManager(maxNumVertexTemporaty:int=8, maxNumVertexConstant:int=128, 
										 maxNumFragmentTemporaty:int=8, maxNumFragmentConstant:int=28, 
										 maxNumVaryingTemporaty:int=8) {
			_vt = new RegisterAllocator(RegisterType.VERTEX_TEMPORARY, maxNumVertexTemporaty);
			_vc = new RegisterAllocator(RegisterType.VERTEX_CONSTANT, maxNumVertexConstant);
			_ft = new RegisterAllocator(RegisterType.FRAGMENT_TEMPORARY, maxNumFragmentTemporaty);
			_fc = new RegisterAllocator(RegisterType.FRAGMENT_CONSTANT, maxNumFragmentConstant);
			_v = new RegisterAllocator(RegisterType.VARYING_V1, maxNumVaryingTemporaty);
		}
		public function get currentConstant():RegisterAllocator {
			if (_curShaderType == Context3DProgramType.VERTEX) {
				return _vc;
			} else if (_curShaderType == Context3DProgramType.FRAGMENT) {
				return _fc;
			} else {
				return null;
			}
		}
		public function get currentOutput():String {
			if (_curShaderType == Context3DProgramType.VERTEX) {
				return RegisterType.VERTEX_CONSTANT;
			} else if (_curShaderType == Context3DProgramType.FRAGMENT) {
				return RegisterType.FRAGMENT_OUTPUT_V1;
			} else {
				return null;
			}
		}
		public function get currentTemporary():RegisterAllocator {
			if (_curShaderType == Context3DProgramType.VERTEX) {
				return _vt;
			} else if (_curShaderType == Context3DProgramType.FRAGMENT) {
				return _ft;
			} else {
				return null;
			}
		}
		public function get fragmentTemporary():RegisterAllocator {
			return _ft;
		}
		public function get currentShaderType():String {
			return _curShaderType;
		}
		public function set currentShaderType(value:String):void {
			if (value == Context3DProgramType.VERTEX || value == Context3DProgramType.FRAGMENT || value == null) _curShaderType = value;
		}
		public function get varying():RegisterAllocator {
			return _v;
		}
		public function get vertexTemporary():RegisterAllocator {
			return _vt;
		}
		public function getConstant(type:String):RegisterAllocator {
			if (type == Context3DProgramType.VERTEX) {
				return _vc;
			} else if (type == Context3DProgramType.FRAGMENT) {
				return _fc;
			} else {
				return null;
			}
		}
		public function getOutput(type:String):String {
			if (type == Context3DProgramType.VERTEX) {
				return RegisterType.VERTEX_CONSTANT;
			} else if (type == Context3DProgramType.FRAGMENT) {
				return RegisterType.FRAGMENT_OUTPUT_V1;
			} else {
				return null;
			}
		}
		public function getTemporary(type:String):RegisterAllocator {
			if (type == Context3DProgramType.VERTEX) {
				return _vt;
			} else if (type == Context3DProgramType.FRAGMENT) {
				return _ft;
			} else {
				return null;
			}
		}
	}
}