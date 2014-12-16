package asgl.shaders.scripts.libs {
	import flash.utils.ByteArray;

	public class ShaderScriptLibs {
		[Embed(source="Base", mimeType="application/octet-stream")]
		private static var BASE:Class;
		
		[Embed(source="Codec", mimeType="application/octet-stream")]
		private static var CODEC:Class;
		
		[Embed(source="Core", mimeType="application/octet-stream")]
		private static var CORE:Class;
		
		[Embed(source="Filter", mimeType="application/octet-stream")]
		private static var FILTER:Class;
		
		[Embed(source="Geom", mimeType="application/octet-stream")]
		private static var GEOM:Class;
		
		[Embed(source="Lighting", mimeType="application/octet-stream")]
		private static var LIGHTING:Class;
		
		[Embed(source="Math", mimeType="application/octet-stream")]
		private static var MATH:Class;
		
		private static var _internalLibsMap:Object = _createLibMap();
		private static var _customLibsMap:Object = {};
		
		public function ShaderScriptLibs() {
		}
		public static function getLib(name:String):String {
			var c:Class = _internalLibsMap[name];
			
			if (c == null) {
				return _customLibsMap[name];
			} else {
				var bytes:ByteArray = new c();
				return bytes.readUTFBytes(bytes.length);
			}
		}
		public static function addLib(name:String, lib:String):void {
			_customLibsMap[name] = lib;
		}
		public static function removeLib(name:String):void {
			delete _customLibsMap[name];
		}
		private static function _createLibMap():Object {
			var map:Object = {};
			
			map['Base'] = BASE;
			map['Codec'] = CODEC;
			map['Core'] = CORE;
			map['Filter'] = FILTER;
			map['Geom'] = GEOM;
			map['Lighting'] = LIGHTING;
			map['Math'] = MATH;
			
			return map;
		}
	}
}