package asgl.system {
	import flash.events.EventDispatcher;
	
	import asgl.asgl_protected;
	
	use namespace asgl_protected;
	
	[Event(name="dispose", type="asgl.events.ASGLEvent")]

	public class DeviceData extends EventDispatcher {
		private static var _instanceIDAccumulator:uint = 0;
		
		asgl_protected var _valid:Boolean;
		asgl_protected var _device:Device3D;
		asgl_protected var _instanceID:uint;
		asgl_protected var _rootInstancID:uint;
		
		public function DeviceData(device:Device3D) {
			_instanceID = ++_instanceIDAccumulator;
			_rootInstancID = _instanceID;
			
			_device = device;
		}
		public function get device():Device3D {
			return _device;
		}
		public function get instanceID():uint {
			return _instanceID;
		}
		public function get valid():Boolean {
			return _valid;
		}
		public function dispose():void {
			_device = null;
		}
		asgl_protected function _clearCache():void {
		}
		asgl_protected function _lost():void {
		}
		asgl_protected function _recovery():void {
		}
	}
}