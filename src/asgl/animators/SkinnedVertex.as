package asgl.animators {
	public class SkinnedVertex {
		public var weights:Vector.<Number>;
		public var boneNameIndices:Vector.<uint>;
		
		public function SkinnedVertex() {
		}
		public function clone():SkinnedVertex {
			var op:SkinnedVertex = new SkinnedVertex();
			
			if (weights != null) op.weights = weights.concat();
			if (boneNameIndices != null) op.boneNameIndices = boneNameIndices.concat();
			
			return op;
		}
	}
}