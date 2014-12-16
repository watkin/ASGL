package asgl.shaders.asm.agal.compiler {
	public class AGALConfiguration {
		private var _version:uint;
		private var _tokens:uint;
		
		private var _va:AGALRegister;
		private var _vc:AGALRegister;
		private var _vt:AGALRegister;
		private var _vo:AGALRegister;
		private var _v:AGALRegister;
		private var _fc:AGALRegister;
		private var _ft:AGALRegister;
		private var _fo:AGALRegister;
		private var _fs:AGALRegister;
		
		private var _registerMap:Object;
		
		public function AGALConfiguration(version:uint) {
			_version = version;
			
			if (_version == 1) {
				_tokens = 200;
				_va = new AGALRegister(AGALRegisterType.VA, 8, AGALScopeType.VERTEX);
				_vc = new AGALRegister(AGALRegisterType.VC, 128, AGALScopeType.VERTEX);
				_vt = new AGALRegister(AGALRegisterType.VT, 8, AGALScopeType.VERTEX);
				_vo = new AGALRegister(AGALRegisterType.VO, 1, AGALScopeType.VERTEX);
				_v = new AGALRegister(AGALRegisterType.V, 8, AGALScopeType.VERTEX|AGALScopeType.FRAGMENT);
				_fc = new AGALRegister(AGALRegisterType.FC, 28, AGALScopeType.FRAGMENT);
				_ft = new AGALRegister(AGALRegisterType.FT, 8, AGALScopeType.FRAGMENT);
				_fo = new AGALRegister(AGALRegisterType.FO, 1, AGALScopeType.FRAGMENT);
				_fs = new AGALRegister(AGALRegisterType.FS, 8, AGALScopeType.FRAGMENT);
			} else if (_version == 2) {
				_tokens = 1024;
				_va = new AGALRegister(AGALRegisterType.VA, 8, AGALScopeType.VERTEX);
				_vc = new AGALRegister(AGALRegisterType.VC, 250, AGALScopeType.VERTEX);
				_vt = new AGALRegister(AGALRegisterType.VT, 26, AGALScopeType.VERTEX);
				_vo = new AGALRegister(AGALRegisterType.VO, 1, AGALScopeType.VERTEX);
				_v = new AGALRegister(AGALRegisterType.V, 10, AGALScopeType.VERTEX|AGALScopeType.FRAGMENT);
				_fc = new AGALRegister(AGALRegisterType.FC, 64, AGALScopeType.FRAGMENT);
				_ft = new AGALRegister(AGALRegisterType.FT, 16, AGALScopeType.FRAGMENT);
				_fo = new AGALRegister(AGALRegisterType.FO, 4, AGALScopeType.FRAGMENT);
				_fs = new AGALRegister(AGALRegisterType.FS, 8, AGALScopeType.FRAGMENT);
			} else {
				_tokens = uint.MAX_VALUE;
				_va = new AGALRegister(AGALRegisterType.VA, uint.MAX_VALUE, AGALScopeType.VERTEX);
				_vc = new AGALRegister(AGALRegisterType.VC, uint.MAX_VALUE, AGALScopeType.VERTEX);
				_vt = new AGALRegister(AGALRegisterType.VT, uint.MAX_VALUE, AGALScopeType.VERTEX);
				_vo = new AGALRegister(AGALRegisterType.VO, uint.MAX_VALUE, AGALScopeType.VERTEX);
				_v = new AGALRegister(AGALRegisterType.V, uint.MAX_VALUE, AGALScopeType.VERTEX|AGALScopeType.FRAGMENT);
				_fc = new AGALRegister(AGALRegisterType.FC, uint.MAX_VALUE, AGALScopeType.FRAGMENT);
				_ft = new AGALRegister(AGALRegisterType.FT, uint.MAX_VALUE, AGALScopeType.FRAGMENT);
				_fo = new AGALRegister(AGALRegisterType.FO, uint.MAX_VALUE, AGALScopeType.FRAGMENT);
				_fs = new AGALRegister(AGALRegisterType.FS, uint.MAX_VALUE, AGALScopeType.FRAGMENT);
			}
			
			_registerMap = {};
			_registerMap[AGALRegisterType.VA_ID] = _va;
			_registerMap[AGALRegisterType.VC_ID] = _vc;
			_registerMap[AGALRegisterType.VT_ID] = _vt;
			_registerMap[AGALRegisterType.VO_ID] = _vo;
			_registerMap[AGALRegisterType.V_ID] = _v;
			_registerMap[AGALRegisterType.FC_ID] = _fc;
			_registerMap[AGALRegisterType.FT_ID] = _ft;
			_registerMap[AGALRegisterType.FO_ID] = _fo;
			_registerMap[AGALRegisterType.FS_ID] = _fs;
		}
		public function get version():uint {
			return _version;
		}
		public function get tokens():uint {
			return _tokens;
		}
		public function get va():AGALRegister {
			return _va;
		}
		public function get vc():AGALRegister {
			return _vc;
		}
		public function get vt():AGALRegister {
			return _vt;
		}
		public function get vo():AGALRegister {
			return _vo;
		}
		public function get v():AGALRegister {
			return _v;
		}
		public function get fc():AGALRegister {
			return _fc;
		}
		public function get ft():AGALRegister {
			return _ft;
		}
		public function get fo():AGALRegister {
			return _fo;
		}
		public function get fs():AGALRegister {
			return _fs;
		}
		public function getRegsiterFromID(id:uint):AGALRegister {
			return _registerMap[id];
		}
	}
}