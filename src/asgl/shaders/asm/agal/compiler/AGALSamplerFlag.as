package asgl.shaders.asm.agal.compiler {
	import flash.display3D.Context3DMipFilter;
	import flash.display3D.Context3DTextureFilter;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DWrapMode;
	
	import asgl.system.Context3DSampleDimension;
	import asgl.system.Context3DSampleSpecial;

	public class AGALSamplerFlag {
		public static const FILTER:Object = _createFilter();
		public static const MIPMAP:Object = _createMipmap();
		public static const WRAP:Object = _createWrap();
		public static const SPECIAL:Object = _createSpecial();
		public static const DIMENSION:Object = _createDim();
		public static const FORMAT:Object = _createFormat();
		public function AGALSamplerFlag() {
		}
		private static function _createFilter():Object {
			var map:Object = {};
			
			map[Context3DTextureFilter.NEAREST] = 0;
			map[Context3DTextureFilter.LINEAR] = 1;
			
			return map;
		}
		private static function _createMipmap():Object {
			var map:Object = {};
			
			map[Context3DMipFilter.MIPNONE] = 0;
			map[Context3DMipFilter.MIPNEAREST] = 1;
			map[Context3DMipFilter.MIPLINEAR] = 2;
			
			return map;
		}
		private static function _createWrap():Object {
			var map:Object = {};
			
			map[Context3DWrapMode.CLAMP] = 0;
			map[Context3DWrapMode.REPEAT] = 1;
			
			return map;
		}
		private static function _createSpecial():Object {
			var map:Object = {};
			
			map[Context3DSampleSpecial.SPECIALNONE] = 0;
			map[Context3DSampleSpecial.IGNORESAMPLER] = 4;
			
			return map;
		}
		private static function _createDim():Object {
			var map:Object = {};
			
			map[Context3DSampleDimension.D2] = 0;
			map[Context3DSampleDimension.CUBE] = 1;
			
			return map;
		}
		private static function _createFormat():Object {
			var map:Object = {};
			
			map[Context3DTextureFormat.BGRA] = 0;
			map[Context3DTextureFormat.BGR_PACKED] = 0;
			map[Context3DTextureFormat.BGRA_PACKED] = 0;
			map[Context3DTextureFormat.COMPRESSED] = 1;
			map[Context3DTextureFormat.COMPRESSED_ALPHA] = 2;
			
			return map;
		}
	}
}