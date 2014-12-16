package asgl.events {
	import flash.events.Event;
	
	public class ASGLEvent extends Event {
		public static const CREATE:String = 'create';
		public static const DISPOSE:String = 'dispose';
		public static const DISPOSE_SHADER_PROGRAM:String = 'disposeShaderProgram';
		public static const LOST:String = 'lost';
		public static const RECOVERY:String = 'recovery';
		public static const UPDATE_SHADER_PROGRAM:String = 'updateShaderProgram';
		public static const UPLOAD:String = 'upload';
		
		public function ASGLEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
	}
}