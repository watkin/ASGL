package asgl.scenes.culling {
	import asgl.asgl_protected;
	import asgl.bounds.BoundingAxisAlignedBox;
	import asgl.bounds.BoundingFrustum;
	import asgl.math.Matrix4x4;
	
	use namespace asgl_protected;

	public class SpaceSubdivisionFrustumCullingManager {
		protected var _offsetX:Number;
		protected var _offsetY:Number;
		protected var _offsetZ:Number;
		protected var _globalCullingObjectMap:Object;
		protected var _leafNodeMap:Object;
		protected var _outsideNode:SpaceSubdivisionNode;
		private var _matrix:Matrix4x4;
		private var _rootNode:SpaceSubdivisionNode;
		private var _deleteIDs:Vector.<uint>;
		
		private var frustum:BoundingFrustum;
		private var _type:uint;
		
		public function SpaceSubdivisionFrustumCullingManager(rootNode:SpaceSubdivisionNode, type:uint, offsetX:Number=0, offsetY:Number=0, offsetZ:Number=0) {
			_deleteIDs = new Vector.<uint>();
			_type = type;
			
			_constructor(rootNode, offsetX, offsetY, offsetZ);
		}
		protected function _constructor(rootNode:SpaceSubdivisionNode, offsetX:Number, offsetY:Number, offsetZ:Number):void {
			frustum = new BoundingFrustum();
			
			_leafNodeMap = {};
			_globalCullingObjectMap = {};
			_matrix = new Matrix4x4();
			
			_rootNode = rootNode;
			_rootNode.isUnused = false;
			
			_outsideNode = SpaceSubdivisionNode.createOutsideNode();
			
			_setLeafNode(_rootNode);
			
			setOffset(offsetX, offsetY, offsetZ);
		}
		/**
		 * general conditions:<br>
		 * cullingMatrix  = cameraWorldMatrix -> appendOffsetMatrix -> invert ->appendProjectionMatrix
		 */
		public function culling(matrix:Matrix4x4):void {
			frustum.setMatrix(matrix);
			
			if (_type == FrustumCullingType.OBJECT_PASS) {
				_cullingByPass(_rootNode);
			} else if (_type == FrustumCullingType.OBJECT_VISIBLE || _type == FrustumCullingType.NODE_VISIBLE) {
				_cullingByVisible(_rootNode);
			}
		}
		public function cullingFrom(cameraWorldMatrix:Matrix4x4, projectionMatrix:Matrix4x4, computeOffset:Boolean=true):void {
			var m:Matrix4x4 = _matrix;
			
			var sm:Matrix4x4 = cameraWorldMatrix;
			
			include '../../math/Matrix4x4_copyDataFromMatrix4x4.define';
			
			if (computeOffset) {
				var x:Number = -_offsetX;
				var y:Number = -_offsetY;
				var z:Number = -_offsetZ;
				
				include '../../math/Matrix4x4_appendTranslation.define';
			}
			
			include '../../math/Matrix4x4_invert.define';
			
			var lm:Matrix4x4 = projectionMatrix;
			
			include '../../math/Matrix4x4_append4x4.define';
			
			frustum.setMatrix(_matrix);
			
			if (_type == FrustumCullingType.OBJECT_PASS) {
				_cullingByPass(_rootNode);
			} else if (_type == FrustumCullingType.OBJECT_VISIBLE || _type == FrustumCullingType.NODE_VISIBLE) {
				_cullingByVisible(_rootNode);
			}
		}
		public function getCullingOffsetMatrix(op:Matrix4x4=null):Matrix4x4 {
			if (op == null) {
				return new Matrix4x4(1, 0, 0, 0,
									 0, 1, 0, 0,
									 0, 0, 1, 0,
									 -_offsetX, -_offsetY, -_offsetZ);
			} else {
				op.m00 = 1;
				op.m01 = 0;
				op.m02 = 0;
				op.m03 = 0;
				
				op.m10 = 0;
				op.m11 = 1;
				op.m12 = 0;
				op.m13 = 0;
				
				op.m20 = 0;
				op.m21 = 0;
				op.m22 = 1;
				op.m23 = 0;
				
				op.m30 = -_offsetX;
				op.m31 = -_offsetY;
				op.m32 = -_offsetZ;
				op.m33 = 1;
				
				return op;
			}
		}
		public function getLeafKey(node:SpaceSubdivisionNode):uint {
			//override
			return 0;
		}
		public function query(obj:ICullingObject):Boolean {
			var co:* = obj;
			var id:uint = co._instanceID;
			
			var node:SpaceSubdivisionNode = _globalCullingObjectMap[id];
			
			if (node == null) {
				return false;
			} else {
				return node.visible;
			}
		}
		public function queryFromInstanceID(id:uint):Boolean {
			var node:SpaceSubdivisionNode = _globalCullingObjectMap[id];
			
			if (node == null) {
				return false;
			} else {
				return node.visible;
			}
		}
		public function removeAllObjects(removeObjects:Vector.<ICullingObject>=null):void {
			var id:uint;
			var oldNode:SpaceSubdivisionNode;
			var obj:*;//ICullingObject;
			
			var parent:SpaceSubdivisionNode;
			var prev:SpaceSubdivisionNode;
			var next:SpaceSubdivisionNode;
			
			var max:uint = 0;
			for (id in _globalCullingObjectMap) {
				_deleteIDs[max++] = id;
			}
			
			var i:uint;
			
			if (removeObjects == null) {
				for (i = 0; i < max; i++) {
					id = _deleteIDs[i];
					oldNode = _globalCullingObjectMap[id];
					obj = oldNode.currentNodeCullingObjectMap[id];
					
					include 'SpaceSubdivisionFrustumCullingManager_removeObject.define';
					
					if (obj._frustumCullingVisible) obj.setFrustumCullingVisible(false);
				}
			} else {
				var len:uint = removeObjects.length;
				for (i = 0; i < max; i++) {
					id = _deleteIDs[i];
					oldNode = _globalCullingObjectMap[id];
					obj = oldNode.currentNodeCullingObjectMap[id];
					
					removeObjects[len++] = obj;
					
					include 'SpaceSubdivisionFrustumCullingManager_removeObject.define';
					
					if (obj._frustumCullingVisible) obj.setFrustumCullingVisible(false);
				}
			}
		}
		public function removeObject(obj:ICullingObject):void {
			var co:* = obj;
			
			var id:uint = co._instanceID;
			var oldNode:SpaceSubdivisionNode = _globalCullingObjectMap[id];
			if (oldNode != null) {
				var parent:SpaceSubdivisionNode;
				var prev:SpaceSubdivisionNode;
				var next:SpaceSubdivisionNode;
				
				include 'SpaceSubdivisionFrustumCullingManager_removeObject.define';
				
				if (co._frustumCullingVisible) obj.frustumCullingVisible = false;
			}
		}
		/**
		 * offset of worldspace
		 */
		public function setOffset(offsetX:Number=0, offsetY:Number=0, offsetZ:Number=0):void {
			_offsetX = offsetX;
			_offsetY = offsetY;
			_offsetZ = offsetZ;
		}
		/**
		 * in worldspace
		 * 
		 * @param bound is AABB.
		 */
		public function updateObject(obj:ICullingObject, bound:BoundingAxisAlignedBox, x:Number, y:Number, z:Number, computeOffset:Boolean=true):void {
			//override
		}
		//obj:ICullingObject
		protected function _updateObject(obj:*, newNode:SpaceSubdivisionNode):void {
			include 'SpaceSubdivisionFrustumCullingManager_updateObject.define';
		}
		private function _cullingByPass(node:SpaceSubdivisionNode):void {
			include 'SpaceSubdivisionFrustumCullingManager_culling.define';
			
			if (state == 1) {
				node.visible = true;
				entityMap = node.currentNodeCullingObjectMap;
				for each (entity in entityMap) {
					entity.frustumCullingPass();
				}
				
				node = node.firstChild;
				while (node != null) {
					_cullingByPass(node);
					node = node.next;
				}
			} else {
				var visible:Boolean = state == 2;
				
				node.visible = visible;
				
				if (visible) {
					entityMap = node.currentNodeCullingObjectMap;
					for each (entity in entityMap) {
						entity.frustumCullingPass();
					}
					
					node = node.firstChild;
					while (node != null) {
						_setNodePass(node);
						node = node.next;
					}
				}
			}
		}
		private function _cullingByVisible(node:SpaceSubdivisionNode):void {
			include 'SpaceSubdivisionFrustumCullingManager_culling.define';
			
			if (state == 1) {
				if (!node.visible) {
					node.visible = true;
					
					if (_type == FrustumCullingType.OBJECT_VISIBLE) {
						entityMap = node.currentNodeCullingObjectMap;
						for each (entity in entityMap) {
							entity.setFrustumCullingVisible(true);
						}
					}
				}
				
				node = node.firstChild;
				while (node != null) {
					_cullingByVisible(node);
					node = node.next;
				}
			} else {
				var visible:Boolean = state == 2;
				
				var traverse:Boolean = !(!visible && !node.visible);
				
				if (node.visible != visible) {
					node.visible = visible;
					
					if (_type == FrustumCullingType.OBJECT_VISIBLE) {
						entityMap = node.currentNodeCullingObjectMap;
						for each (entity in entityMap) {
							entity.setFrustumCullingVisible(visible);
						}
					}
				}
				
				if (traverse) {
					node = node.firstChild;
					while (node != null) {
						_setNodeVisible(node, visible);
						node = node.next;
					}
				}
			}
		}
		private function _setNodePass(node:SpaceSubdivisionNode):void {
			node.visible = true;
			
			var entityMap:Object = node.currentNodeCullingObjectMap;
			for each (var entity:ICullingObject in entityMap) {
				entity.frustumCullingPass();
			}
			
			node = node.firstChild;
			while (node != null) {
				_setNodePass(node);
				node = node.next;
			}
		}
		private function _setNodeVisible(node:SpaceSubdivisionNode, visible:Boolean):void {
			if (node.visible != visible) {
				node.visible = visible;
				
				var entityMap:Object = node.currentNodeCullingObjectMap;
				for each (var entity:ICullingObject in entityMap) {
					entity.frustumCullingVisible = visible;
				}
			}
			
			node = node.firstChild;
			while (node != null) {
				_setNodeVisible(node, visible);
				node = node.next;
			}
		}
		private function _setLeafNode(node:SpaceSubdivisionNode):void {
			var next:SpaceSubdivisionNode = node.unusedFirstChild;
			if (next == null) {
				_leafNodeMap[getLeafKey(node)] = node;
			} else {
				do {
					_setLeafNode(next);
					next = next.next;
				} while (next != null);
			}
		}
	}
}