package asgl.lights {
	import asgl.asgl_protected;
	import asgl.math.Float3;
	import asgl.math.Matrix4x4;
	
	use namespace asgl_protected;
	
	public class SpotLight extends AbstractLight {
		asgl_protected var _range:Number;
		asgl_protected var _spotAngle:Number;
		
		public function SpotLight() {
			_lightType = LightType.SPOT;
			_range = 100;
			_spotAngle = Math.PI / 6;
		}
		public function get range():Number {
			return _range;
		}
		public function set range(value:Number):void {
			if (value == 0) value = 0.00001;
			_range = value;
		}
		public function get spotAngle():Number {
			return _spotAngle;
		}
		public function set spotAngle(value:Number):void {
			_spotAngle = value;
		}
		public override function getLightingDirection(lightMatrix:Matrix4x4, targetPos:Float3, op:Float3=null):Float3 {
			if (op == null) op = new Float3();
			
			op.x = targetPos.x - lightMatrix.m30;
			op.y = targetPos.y - lightMatrix.m31;
			op.z = targetPos.z - lightMatrix.m32;
			
			return op;
		}
	}
}