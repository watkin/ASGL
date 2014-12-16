package asgl.system {
	import flash.display3D.Context3DMipFilter;
	import flash.display3D.Context3DTextureFilter;
	import flash.display3D.Context3DWrapMode;
	
	import asgl.asgl_protected;
	import asgl.shaders.asm.agal.compiler.AGALSamplerFlag;
	
	use namespace asgl_protected;

	public class SamplerStateData {
		private static var _defaultSamplerStateValue:uint = _getDefaultSamplerStateValue();
		
		asgl_protected var _wrap:String;
		asgl_protected var _filter:String;
		asgl_protected var _mipmap:String;
		
		asgl_protected var _samplerStateValue:uint;
		
		public function SamplerStateData(wrap:String=Context3DWrapMode.CLAMP, filter:String=Context3DTextureFilter.LINEAR, mipmap:String=Context3DMipFilter.MIPNONE) {
			_wrap = wrap;
			_filter = filter;
			_mipmap = mipmap;
			
			_samplerStateValue = _defaultSamplerStateValue;
		}
		private static function _getDefaultSamplerStateValue():uint {
			var w:int = AGALSamplerFlag.WRAP[Context3DWrapMode.CLAMP];
			var f:int = AGALSamplerFlag.FILTER[Context3DTextureFilter.LINEAR];
			var m:int = AGALSamplerFlag.MIPMAP[Context3DMipFilter.MIPNONE];
			
			var s:int = AGALSamplerFlag.SPECIAL[Context3DSampleSpecial.IGNORESAMPLER];
			
			return (f << 28) | (m << 24) | (w << 20) | (s << 16) | 5;
		}
		public function get filter():String {
			return _filter;
		}
		public function get mipmap():String {
			return _mipmap;
		}
		public function get wrap():String {
			return _wrap;
		}
		public function copySamplerState(data:SamplerStateData):void {
			_wrap = data._wrap;
			_filter = data._filter;
			_mipmap = data._mipmap;
			
			var w:int = AGALSamplerFlag.WRAP[_wrap];
			var f:int = AGALSamplerFlag.FILTER[_filter];
			var m:int = AGALSamplerFlag.MIPMAP[_mipmap];
			
			_samplerStateValue = (f << 28) | (m << 24) | (w << 20) | (_samplerStateValue & 0xFFFFF);
		}
		public function setSamplerState(wrap:String, filter:String, mipmap:String):void {
			if (wrap != null) _wrap = wrap;
			if (filter != null) _filter = filter;
			if (mipmap != null) _mipmap = mipmap;
			
			var w:int = AGALSamplerFlag.WRAP[_wrap];
			var f:int = AGALSamplerFlag.FILTER[_filter];
			var m:int = AGALSamplerFlag.MIPMAP[_mipmap];
			
			_samplerStateValue = (f << 28) | (m << 24) | (w << 20) | (_samplerStateValue & 0xFFFFF);
		}
	}
}