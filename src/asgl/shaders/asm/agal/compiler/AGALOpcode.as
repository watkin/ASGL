package asgl.shaders.asm.agal.compiler {
	import asgl.asgl_protected;
	
	use namespace asgl_protected;

	public class AGALOpcode {
		public static const MOV:AGALOpcode = new AGALOpcode(0x00, AGALScopeType.VERTEX|AGALScopeType.FRAGMENT, true, 1, 1);
		public static const ADD:AGALOpcode = new AGALOpcode(0x01, AGALScopeType.VERTEX|AGALScopeType.FRAGMENT, true, 2, 1);
		public static const SUB:AGALOpcode = new AGALOpcode(0x02, AGALScopeType.VERTEX|AGALScopeType.FRAGMENT, true, 2, 1);
		public static const MUL:AGALOpcode = new AGALOpcode(0x03, AGALScopeType.VERTEX|AGALScopeType.FRAGMENT, true, 2, 1);
		public static const DIV:AGALOpcode = new AGALOpcode(0x04, AGALScopeType.VERTEX|AGALScopeType.FRAGMENT, true, 2, 1);
		public static const RCP:AGALOpcode = new AGALOpcode(0x05, AGALScopeType.VERTEX|AGALScopeType.FRAGMENT, true, 1, 1);
		public static const MIN:AGALOpcode = new AGALOpcode(0x06, AGALScopeType.VERTEX|AGALScopeType.FRAGMENT, true, 2, 1);
		public static const MAX:AGALOpcode = new AGALOpcode(0x07, AGALScopeType.VERTEX|AGALScopeType.FRAGMENT, true, 2, 1);
		public static const FRC:AGALOpcode = new AGALOpcode(0x08, AGALScopeType.VERTEX|AGALScopeType.FRAGMENT, true, 1, 1);
		public static const SQT:AGALOpcode = new AGALOpcode(0x09, AGALScopeType.VERTEX|AGALScopeType.FRAGMENT, true, 1, 1);
		public static const RSQ:AGALOpcode = new AGALOpcode(0x0A, AGALScopeType.VERTEX|AGALScopeType.FRAGMENT, true, 1, 1);
		public static const POW:AGALOpcode = new AGALOpcode(0x0B, AGALScopeType.VERTEX|AGALScopeType.FRAGMENT, true, 2, 1);
		public static const LOG:AGALOpcode = new AGALOpcode(0x0C, AGALScopeType.VERTEX|AGALScopeType.FRAGMENT, true, 1, 1);
		public static const EXP:AGALOpcode = new AGALOpcode(0x0D, AGALScopeType.VERTEX|AGALScopeType.FRAGMENT, true, 1, 1);
		public static const NRM:AGALOpcode = new AGALOpcode(0x0E, AGALScopeType.VERTEX|AGALScopeType.FRAGMENT, true, 1, 1);
		public static const SIN:AGALOpcode = new AGALOpcode(0x0F, AGALScopeType.VERTEX|AGALScopeType.FRAGMENT, true, 1, 1);
		public static const COS:AGALOpcode = new AGALOpcode(0x10, AGALScopeType.VERTEX|AGALScopeType.FRAGMENT, true, 1, 1);
		public static const CRS:AGALOpcode = new AGALOpcode(0x11, AGALScopeType.VERTEX|AGALScopeType.FRAGMENT, true, 2, 1);
		public static const DP3:AGALOpcode = new AGALOpcode(0x12, AGALScopeType.VERTEX|AGALScopeType.FRAGMENT, true, 2, 1);
		public static const DP4:AGALOpcode = new AGALOpcode(0x13, AGALScopeType.VERTEX|AGALScopeType.FRAGMENT, true, 2, 1);
		public static const ABS:AGALOpcode = new AGALOpcode(0x14, AGALScopeType.VERTEX|AGALScopeType.FRAGMENT, true, 1, 1);
		public static const NEG:AGALOpcode = new AGALOpcode(0x15, AGALScopeType.VERTEX|AGALScopeType.FRAGMENT, true, 1, 1);
		public static const SAT:AGALOpcode = new AGALOpcode(0x16, AGALScopeType.VERTEX|AGALScopeType.FRAGMENT, true, 1, 1);
		public static const M33:AGALOpcode = new AGALOpcode(0x17, AGALScopeType.VERTEX|AGALScopeType.FRAGMENT, true, 2, 1);
		public static const M44:AGALOpcode = new AGALOpcode(0x18, AGALScopeType.VERTEX|AGALScopeType.FRAGMENT, true, 2, 1);
		public static const M34:AGALOpcode = new AGALOpcode(0x19, AGALScopeType.VERTEX|AGALScopeType.FRAGMENT, true, 2, 1);
		public static const DDX:AGALOpcode = new AGALOpcode(0x1A, AGALScopeType.FRAGMENT, true, 1, 2);
		public static const DDY:AGALOpcode = new AGALOpcode(0x1B, AGALScopeType.FRAGMENT, true, 1, 2);
		public static const IFE:AGALOpcode = new AGALOpcode(0x1C, AGALScopeType.FRAGMENT, false, 2, 2);
		public static const INE:AGALOpcode = new AGALOpcode(0x1D, AGALScopeType.FRAGMENT, false, 2, 2);
		public static const IFG:AGALOpcode = new AGALOpcode(0x1E, AGALScopeType.FRAGMENT, false, 2, 2);
		public static const IFL:AGALOpcode = new AGALOpcode(0x1F, AGALScopeType.FRAGMENT, false, 2, 2);
		public static const ELS:AGALOpcode = new AGALOpcode(0x20, AGALScopeType.FRAGMENT, false, 0, 2);
		public static const EIF:AGALOpcode = new AGALOpcode(0x21, AGALScopeType.FRAGMENT, false, 0, 2);
		public static const KIL:AGALOpcode = new AGALOpcode(0x27, AGALScopeType.FRAGMENT, false, 1, 1);
		public static const TEX:AGALOpcode = new AGALOpcode(0x28, AGALScopeType.FRAGMENT, true, 2, 1);
		public static const SGE:AGALOpcode = new AGALOpcode(0x29, AGALScopeType.VERTEX|AGALScopeType.FRAGMENT, true, 2, 1);
		public static const SLT:AGALOpcode = new AGALOpcode(0x2A, AGALScopeType.VERTEX|AGALScopeType.FRAGMENT, true, 2, 1);
		public static const SEQ:AGALOpcode = new AGALOpcode(0x2C, AGALScopeType.VERTEX|AGALScopeType.FRAGMENT, true, 2, 1);
		public static const SNE:AGALOpcode = new AGALOpcode(0x2D, AGALScopeType.VERTEX|AGALScopeType.FRAGMENT, true, 2, 1);
		
		asgl_protected var _hasDest:Boolean;
		asgl_protected var _numRegisters:uint;
		asgl_protected var _scope:uint;
		asgl_protected var _type:uint;
		asgl_protected var _version:uint;
		
		public function AGALOpcode(type:uint, scope:uint, hasDest:Boolean, numRegisters:uint, version:uint) {
			_type = type;
			_scope = scope;
			_hasDest = hasDest;
			_numRegisters = numRegisters;
			_version = version;
		}
		public function get hasDest():Boolean {
			return _hasDest;
		}
		public function get numRegisters():uint {
			return _numRegisters;
		}
		public function get scope():uint {
			return _scope;
		}
		public function get type():uint {
			return _type;
		}
		public function get version():uint {
			return _version;
		}
	}
}