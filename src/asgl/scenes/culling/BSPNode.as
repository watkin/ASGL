package asgl.scenes.culling {
	public class BSPNode {
		public var backNode:BSPNode;
		public var frontNode:BSPNode;
		
		public var posX:Number;
		public var posY:Number;
		public var posZ:Number;
		
		public var normalX:Number;
		public var normalY:Number;
		public var normalZ:Number;
		
		public var cullingObject:ICullingObject;
		public var backCullingObject:ICullingObject;
		public var frontCullingObject:ICullingObject;
		
		public function BSPNode() {
		}
	}
}