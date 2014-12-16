package asgl.renderers {
	public class AbstractStaticRenderData {
		private static var _renderIDAccumulator:uint = 0;
		
		public var renderer:BaseRenderer;
		public var renderID:uint;
		
		public function AbstractStaticRenderData() {
			renderID = ++_renderIDAccumulator;
		}
		public function dispose():void {
		}
		public function recovery():void {
		}
	}
}