package asgl.utils {
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	public class Profiler {
		private var _do:DisplayObject;
		private var _fps:Number;
		private var _count:int;
		private var _time:Number;
		private var _timer:Timer;
		
		public function Profiler():void {
			_do = new Shape();
			_timer = new Timer(1000);
		}
		public function get fps():Number {
			return _fps;
		}
		public function start():void {
			_time = getTimer();
			_do.addEventListener(Event.ENTER_FRAME, _enterFrameHandler, false, 0, true);
			_timer.addEventListener(TimerEvent.TIMER, _timerHandler, false, 0, true);
			_timer.start();
		}
		public function stop():void {
			_do.removeEventListener(Event.ENTER_FRAME, _enterFrameHandler);
			_timer.removeEventListener(TimerEvent.TIMER, _timerHandler);
		}
		private function _enterFrameHandler(event:Event):void {
			_count++;
		}
		private function _timerHandler(e:Event):void {
			var time:Number = getTimer();
			_fps = _count / ((time - _time) * 0.001);
			_time = time;
			_count = 0;
		}
	}
}