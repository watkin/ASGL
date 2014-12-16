package asgl.shaders.scripts.compiler {
	public class BaseVariableType {
		public static const VOID:String = 'void';
		
		public static const FLOAT:String = 'float';
		public static const FLOAT_2:String = 'float2';
		public static const FLOAT_3:String = 'float3';
		public static const FLOAT_4:String = 'float4';
		
		public static const VERTEX_ATTRIBUTE:String = 'va';
		public static const VERTEX_OUTPUT:String = 'vo';
		public static const VERTEX_CONSTANT:String = 'vc';
		public static const VERTEX_TEMPORARY:String = 'vt';
		
		public static const VARYING:String = 'v';
		
		public static const FRAGMENT_OUTPUT:String = 'fo';
		public static const FRAGMENT_CONSTANT:String = 'fc';
		public static const FRAGMENT_TEMPORARY:String = 'ft';
		
		public function BaseVariableType() {
		}
		
		public static function isFloats(type:String):Boolean {
			return type == FLOAT || type == FLOAT_2 || type == FLOAT_3 || type == FLOAT_4;
		}
		public static function isEquivalenceFloat4(type:String):Boolean {
			if (type == VERTEX_ATTRIBUTE ||
				type == VERTEX_CONSTANT ||
				type == VARYING ||
				type == VERTEX_OUTPUT ||
				type == VERTEX_TEMPORARY ||
				type == FRAGMENT_CONSTANT ||
				type == FRAGMENT_OUTPUT ||
				type == FRAGMENT_TEMPORARY) {
				return true;
			} else {
				return false;
			}
		}
		
		public static function getFloatAvailableComponentCount(type:String):uint {
			if (type == FLOAT) {
				return 1;
			} else if (type == FLOAT_2) {
				return 2;
			} else if (type == FLOAT_3) {
				return 3;
			} else if (type == FLOAT_4) {
				return 4;
			} else {
				return 0;
			}
		}
		public static function getFloatUseComponentCount(type:String, component:String):uint {
			var count:uint = getFloatAvailableComponentCount(type);
			
			if (component == null) {
				return count;
			} else {
				var num:uint = 0;
				var map:Object = {};
				var len:uint = component.length;
				for (var i:uint = 0; i < len; i++) {
					var s:String = component.charAt(i);
					if (map[s] == null) {
						map[s] = true;
						num++;
					}
				}
				return num;
			}
		}
		public static function getFloatTypeFromComponent(type:String, component:String, repeatComponentValid:Boolean=true):String {
			if (getFloatAvailableComponentCount(type) > 0) {
				if (component == null) {
					return type;
				} else {
					var count:uint;
					var len:uint = component.length;
					
					if (repeatComponentValid) {
						count = len;
					} else {
						var map:Object = {};
						
						for (var i:uint = 0; i < len; i++) {
							var s:String = component.charAt(i);
							if (!(s in map)) {
								map[s] = true;
								count++;
							}
						}
					}
					
					if (count == 0) {
						return type;
					} else if (count == 1) {
						return FLOAT;
					} else if (count == 2) {
						return FLOAT_2;
					} else if (count == 3) {
						return FLOAT_3;
					} else if (count == 4) {
						return FLOAT_4;
					} else {
						return null;
					}
				}
			} else {
				return null;
			}
		}
	}
}