package asgl.lights {
	import asgl.asgl_protected;
	import asgl.math.Float3;
	import asgl.math.Matrix4x4;
	
	use namespace asgl_protected;

	public class DirectionalLight extends AbstractLight {
		private static var _tempFloat3:Float3 = new Float3();
		
		public function DirectionalLight() {
			_lightType = LightType.DIRECTIONAL;
		}
		public override function getLightingDirection(lightMatrix:Matrix4x4, targetPos:Float3, op:Float3=null):Float3 {
			if (op == null) op = new Float3();
			
			op = lightMatrix.getAxisZ(op);
			
			return op;
		}
	}
}