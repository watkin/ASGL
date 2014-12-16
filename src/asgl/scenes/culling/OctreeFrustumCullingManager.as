package asgl.scenes.culling {
	import asgl.asgl_protected;
	import asgl.bounds.BoundingAxisAlignedBox;
	
	use namespace asgl_protected;
	
	public class OctreeFrustumCullingManager extends SpaceSubdivisionFrustumCullingManager {
		private var _bound:BoundingAxisAlignedBox;
		private var _segmentLenX:Number;
		private var _segmentLenY:Number;
		private var _segmentLenZ:Number;
		private var _digitX:uint;
		private var _digitY:uint;
		private var _segmentNum:uint;
		
		public function OctreeFrustumCullingManager(type:uint, bound:BoundingAxisAlignedBox, depthLevel:uint, looseMultiple:Number=1, offsetX:Number=0, offsetY:Number=0, offsetZ:Number=0) {
			super(null, type);
			_constructor2(bound, depthLevel, looseMultiple, offsetX, offsetY, offsetZ);
		}
		protected override function _constructor(rootNode:SpaceSubdivisionNode, offsetX:Number, offsetY:Number, offsetZ:Number):void {
			//empty
		}
		private function _constructor2(bound:BoundingAxisAlignedBox, depthLevel:uint, looseMultiple:Number, offsetX:Number, offsetY:Number, offsetZ:Number):void {
			if (depthLevel > 9) throw new RangeError();
			_bound = bound.clone();
			_segmentNum = Math.pow(2, depthLevel);
			_segmentLenX = (_bound.maxX - _bound.minX) / _segmentNum;
			_segmentLenY = (_bound.maxY - _bound.minY) / _segmentNum;
			_segmentLenZ = (_bound.maxZ - _bound.minZ) / _segmentNum;
			_digitY = Math.pow(10, _segmentNum.toString().length);
			_digitX = _digitY * _digitY;
			
			super._constructor(SpaceSubdivisionNode.createOctree(_bound, depthLevel, looseMultiple), offsetX, offsetY, offsetZ);
		}
		public override function getLeafKey(node:SpaceSubdivisionNode):uint {
			var bound:BoundingAxisAlignedBox = node.bound;
			
			var x:Number = bound.minX + (bound.maxX - bound.minX) * 0.5;
			var sx:int = (x - _bound.minX) / _segmentLenX;
			if (sx < 0 || sx >= _segmentNum) {
				return uint.MAX_VALUE;
			} else {
				var y:Number = bound.minY + (bound.maxY - bound.minY) * 0.5;
				var sy:int = (y - _bound.minY) / _segmentLenY;
				if (sy < 0 || sy >= _segmentNum) {
					return uint.MAX_VALUE;
				} else {
					var z:Number = bound.minZ + (bound.maxZ - bound.minZ) * 0.5;
					var sz:int = (z - _bound.minZ) / _segmentLenZ;
					if (sz < 0 || sz >= _segmentNum) {
						return uint.MAX_VALUE;
					} else {
						return _digitX * sx + _digitY * sy + sz;
					}
				}
			}
		}
		public override function updateObject(co:ICullingObject, bound:BoundingAxisAlignedBox, x:Number, y:Number, z:Number, computeOffset:Boolean=true):void {
			var obj:* = co;
			
			var newNode:SpaceSubdivisionNode;
			
			var sx:int;
			var sy:int;
			var sz:int;
			
			var minX:Number;
			var maxX:Number;
			var minY:Number;
			var maxY:Number;
			var minZ:Number;
			var maxZ:Number;
			
			if (computeOffset) {
				sx = (x - _offsetX - _bound.minX) / _segmentLenX;
				if (sx < 0 || sx >= _segmentNum) {
					newNode = _outsideNode;
				} else {
					sy = (y - _offsetY - _bound.minY) / _segmentLenY;
					if (sy < 0 || sy >= _segmentNum) {
						newNode = _outsideNode;
					} else {
						sz = (z - _offsetZ - _bound.minZ) / _segmentLenZ;
						if (sz < 0 || sz >= _segmentNum) {
							newNode = _outsideNode;
						} else {
							newNode = _leafNodeMap[int(_digitX * sx + _digitY * sy + sz)];
						}
					}
				}
				
				minX = bound.minX - _offsetX;
				maxX = bound.maxX - _offsetX;
				minY = bound.minY - _offsetY;
				maxY = bound.maxY - _offsetY;
				minZ = bound.minZ - _offsetZ;
				maxZ = bound.maxZ - _offsetZ;
			} else {
				sx = (x - _bound.minX) / _segmentLenX;
				if (sx < 0 || sx >= _segmentNum) {
					newNode = _outsideNode;
				} else {
					sy = (y - _bound.minY) / _segmentLenY;
					if (sy < 0 || sy >= _segmentNum) {
						newNode = _outsideNode;
					} else {
						sz = (z - _bound.minZ) / _segmentLenZ;
						if (sz < 0 || sz >= _segmentNum) {
							newNode = _outsideNode;
						} else {
							newNode = _leafNodeMap[int(_digitX * sx + _digitY * sy + sz)];
						}
					}
				}
				
				minX = bound.minX;
				maxX = bound.maxX;
				minY = bound.minY;
				maxY = bound.maxY;
				minZ = bound.minZ;
				maxZ = bound.maxZ;
			}
			
			while (true) {
				var nodeBound:BoundingAxisAlignedBox = newNode.bound;
				if (nodeBound.minX <= minX && nodeBound.maxX >= maxX &&
					nodeBound.minY <= minY && nodeBound.maxY >= maxY &&
					nodeBound.minZ <= minZ && nodeBound.maxZ >= maxZ) {
					break;
				}
				
				if (newNode.parent == null) {
					break;
				} else {
					newNode = newNode.parent;
				}
			}
			
			include 'SpaceSubdivisionFrustumCullingManager_updateObject.define';
		}
	}
}