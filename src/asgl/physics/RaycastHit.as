package asgl.physics {
	import asgl.entities.Object3D;

	public class RaycastHit {
		public var t:Number;
		public var object:Object3D;
		
		public function RaycastHit() {
			t = -1;
		}
		public function clear():void {
			t = -1;
			object = null;
		}
		public function toString():String {
			return 'raycastHit [t : ' + t + ', object : ' + object + ']';
		}
	}
}