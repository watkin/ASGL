package asgl.scenes.culling {
	import asgl.bounds.BoundingAxisAlignedBox;

	public class SpaceSubdivisionNode {
		public var isUnused:Boolean;
		public var visible:Boolean;
		public var bound:BoundingAxisAlignedBox;
		public var totalEntities:uint;
		public var firstChild:SpaceSubdivisionNode;
		public var next:SpaceSubdivisionNode;
		public var prev:SpaceSubdivisionNode;
		public var parent:SpaceSubdivisionNode;
		public var unusedFirstChild:SpaceSubdivisionNode;
		public var currentNodeCullingObjectMap:Object;
		
		public function SpaceSubdivisionNode() {
		}
		public static function createOctree(bound:BoundingAxisAlignedBox, depthLevel:uint, looseMultiple:Number=1):SpaceSubdivisionNode {
			return _createOctree(bound.clone(), null, depthLevel, looseMultiple);
		}
		public static function createOutsideNode():SpaceSubdivisionNode {
			var node:SpaceSubdivisionNode = new SpaceSubdivisionNode();
			node.isUnused = true;
			node.bound = new BoundingAxisAlignedBox();
			node.currentNodeCullingObjectMap = {};
			return node;
		}
		public static function createQuadtree(bound:BoundingAxisAlignedBox, depthLevel:uint, looseMultiple:Number=1):SpaceSubdivisionNode {
			return _createQuadtree(bound.clone(), null, depthLevel, looseMultiple);
		}
		private static function _createOctree(bound:BoundingAxisAlignedBox, parent:SpaceSubdivisionNode, residualDepth:uint, looseMultiple:Number):SpaceSubdivisionNode {
			var node:SpaceSubdivisionNode = new SpaceSubdivisionNode();
			node.currentNodeCullingObjectMap = {};
			node.parent = parent;
			node.bound = bound;
			node.isUnused = true;
			
			if (residualDepth > 0) {
				residualDepth--;
				
				var minX:Number = bound.minX;
				var minY:Number = bound.minY;
				var minZ:Number = bound.minZ;
				var maxX:Number = bound.maxX;
				var maxY:Number = bound.maxY;
				var maxZ:Number = bound.maxZ;
				
				var midX:Number = minX + (maxX - minX) * 0.5;
				var midY:Number = minY + (maxY - minY) * 0.5;
				var midZ:Number = minZ + (maxZ - minZ) * 0.5;
				
				var curNode:SpaceSubdivisionNode;
				var childNode:SpaceSubdivisionNode;
				
				node.unusedFirstChild = _createOctree(new BoundingAxisAlignedBox(minX, midX, minY, midY, minZ, midZ), node, residualDepth, looseMultiple);
				
				childNode = _createOctree(new BoundingAxisAlignedBox(midX, maxX, minY, midY, minZ, midZ), node, residualDepth, looseMultiple);
				node.unusedFirstChild.next = childNode;
				childNode.prev = node.unusedFirstChild;
				curNode = childNode;
				
				childNode = _createOctree(new BoundingAxisAlignedBox(minX, midX, minY, midY, midZ, maxZ), node, residualDepth, looseMultiple);
				curNode.next = childNode;
				childNode.prev = curNode;
				curNode = childNode;
				
				childNode = _createOctree(new BoundingAxisAlignedBox(midX, maxX, minY, midY, midZ, maxZ), node, residualDepth, looseMultiple);
				curNode.next = childNode;
				childNode.prev = curNode;
				curNode = childNode;
				
				childNode = _createOctree(new BoundingAxisAlignedBox(minX, midX, midY, maxY, minZ, midZ), node, residualDepth, looseMultiple);
				curNode.next = childNode;
				childNode.prev = curNode;
				curNode = childNode;
				
				childNode = _createOctree(new BoundingAxisAlignedBox(midX, maxX, midY, maxY, minZ, midZ), node, residualDepth, looseMultiple);
				curNode.next = childNode;
				childNode.prev = curNode;
				curNode = childNode;
				
				childNode = _createOctree(new BoundingAxisAlignedBox(minX, midX, midY, maxY, midZ, maxZ), node, residualDepth, looseMultiple);
				curNode.next = childNode;
				childNode.prev = curNode;
				curNode = childNode;
				
				childNode = _createOctree(new BoundingAxisAlignedBox(midX, maxX, midY, maxY, midZ, maxZ), node, residualDepth, looseMultiple);
				curNode.next = childNode;
				childNode.prev = curNode;
			}
			
			if (looseMultiple != 1) {
				var m:Number = (looseMultiple - 1) * 0.5;
				var len:Number = (bound.maxX - bound.minX) * m;
				bound.minX -= len;
				bound.maxX += len;
				len = (bound.maxY - bound.minY) * m;
				bound.minY -= len;
				bound.maxY += len;
				len = (bound.maxZ - bound.minZ) * m;
				bound.minZ -= len;
				bound.maxZ += len;
			}
			
			return node;
		}
		private static function _createQuadtree(bound:BoundingAxisAlignedBox, parent:SpaceSubdivisionNode, residualDepth:uint, looseMultiple:Number):SpaceSubdivisionNode {
			var node:SpaceSubdivisionNode = new SpaceSubdivisionNode();
			node.currentNodeCullingObjectMap = {};
			node.parent = parent;
			node.bound = bound;
			node.isUnused = true;
			
			if (residualDepth>0) {
				residualDepth--;
				
				var minX:Number = bound.minX;
				var minY:Number = bound.minY;
				var minZ:Number = bound.minZ;
				var maxX:Number = bound.maxX;
				var maxY:Number = bound.maxY;
				var maxZ:Number = bound.maxZ;
				
				var midX:Number = minX + (maxX - minX) * 0.5;
				var midZ:Number = minZ + (maxZ - minZ) * 0.5;
				
				var curNode:SpaceSubdivisionNode;
				var childNode:SpaceSubdivisionNode;
				
				node.unusedFirstChild = _createQuadtree(new BoundingAxisAlignedBox(minX, midX, minY, maxY, minZ, midZ), node, residualDepth, looseMultiple);
				
				childNode = _createQuadtree(new BoundingAxisAlignedBox(midX, maxX, minY, maxY, minZ, midZ), node, residualDepth, looseMultiple);
				node.unusedFirstChild.next = childNode;
				childNode.prev = node.unusedFirstChild;
				curNode = childNode;
				
				childNode = _createQuadtree(new BoundingAxisAlignedBox(minX, midX, minY, maxY, midZ, maxZ), node, residualDepth, looseMultiple);
				curNode.next = childNode;
				childNode.prev = curNode;
				curNode = childNode;
				
				childNode = _createQuadtree(new BoundingAxisAlignedBox(midX, maxX, minY, maxY, midZ, maxZ), node, residualDepth, looseMultiple);
				curNode.next = childNode;
				childNode.prev = curNode;
			}
			
			if (looseMultiple != 1) {
				var m:Number = (looseMultiple - 1) * 0.5;
				var len:Number = (bound.maxX - bound.minX) * m;
				bound.minX -= len;
				bound.maxX += len;
				len = (bound.maxY - bound.minY) * m;
				bound.minY -= len;
				bound.maxY += len;
				len = (bound.maxZ - bound.minZ) * m;
				bound.minZ -= len;
				bound.maxZ += len;
			}
			
			return node;
		}
	}
}