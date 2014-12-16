package asgl.lights {
	import asgl.asgl_protected;
	import asgl.entities.Object3D;
	import asgl.math.Float3;
	import asgl.math.Matrix4x4;
	
	use namespace asgl_protected;
	
	public class AbstractLight extends Object3D {
		public var cullingMask:uint = 0xFFFFFFFF;
		
		asgl_protected var _color:uint;
		asgl_protected var _colorRed:Number;
		asgl_protected var _colorGreen:Number;
		asgl_protected var _colorBlue:Number;
		
		asgl_protected var _intensity:Number;
		
		asgl_protected var _lightType:int;
		
		public function AbstractLight() {
			_color = 0xFFFFFF;
			_colorRed = 1;
			_colorGreen = 1;
			_colorBlue = 1;
			
			_intensity = 1;
		}
		public function get color():uint {
			return _color;
		}
		public function set color(value:uint):void {
			_color = value;
			_colorRed = (_color >> 16 & 0xFF) / 0xFF;
			_colorGreen = (_color >> 8 & 0xFF) / 0xFF;
			_colorBlue = (_color & 0xFF) / 0xFF;
		}
		public function get intensity():Number {
			return _intensity;
		}
		public function set intensity(value:Number):void {
			_intensity = value;
		}
		public function get lightType():int {
			return _lightType;
		}
		public function getLightingDirection(lightMatrix:Matrix4x4, targetPos:Float3, op:Float3=null):Float3 {
			if (op == null) {
				return new Float3();
			} else {
				op.x = 0;
				op.y = 0;
				op.z = 0;
				return op;
			}
		}
	}
}