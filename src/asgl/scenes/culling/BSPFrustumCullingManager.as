package asgl.scenes.culling {
	import asgl.asgl_protected;
	import asgl.math.Float3;
	import asgl.math.Matrix4x4;
	
	use namespace asgl_protected;

	public class BSPFrustumCullingManager {
		private static const HALF_PI:Number = Math.PI*0.5;
		private var _rootNode:BSPNode;
		private var _cameraDirX:Number;
		private var _cameraDirY:Number;
		private var _cameraDirZ:Number;
		private var _cameraPosX:Number;
		private var _cameraPosY:Number;
		private var _cameraPosZ:Number;
		private var _maxHalfFov:Number;
		
		private var _type:uint;
		
		public function BSPFrustumCullingManager(rootNode:BSPNode, type:uint) {
			_type = type;
			_constructor(rootNode);
		}
		private function _constructor(rootNode:BSPNode):void {
			_rootNode = rootNode;
		}
		/**
		 * @param matrix = projMatrix.
		 */
		public function culling(cameraPos:Float3, cameraDir:Float3, matrix:Matrix4x4):void {
			if (_rootNode != null) {
				_cameraPosX = cameraPos.x;
				_cameraPosY = cameraPos.y;
				_cameraPosZ = cameraPos.z;
				
				_cameraDirX = cameraDir.x;
				_cameraDirY = cameraDir.y;
				_cameraDirZ = cameraDir.z;
				
				var x:Number = matrix.m00;
				var y:Number = matrix.m11;
				
				_maxHalfFov = Math.atan(1 / (x < y ? x : y));
				
				if (_type == FrustumCullingType.OBJECT_PASS) {
					_cullingByPass(_rootNode);
				} else if (_type == FrustumCullingType.OBJECT_VISIBLE) {
					_cullingByVisible(_rootNode);
				}
			}
		}
		private function _cullingByPass(node:BSPNode):void {
			include 'BSPFrustumCullingManager_culling.define';
			
			if (x * nx + y * ny + z * nz > 0) {
				if (frontNode != null) _cullingByPass(frontNode);
				
				if (angle+_maxHalfFov>HALF_PI) {
					//set self visible true
					co = node.cullingObject;
					if (co != null) co.frustumCullingPass();
					
					if (backNode != null) _cullingByPass(backNode);
				} else {
					//set self visible false
					
					//set back and all children visible false
				}
			} else {
				if (backNode != null) _cullingByPass(backNode);
				
				if (angle-_maxHalfFov<HALF_PI) {
					//set self visible true
					co = node.cullingObject;
					if (co != null) co.frustumCullingPass();
					
					if (frontNode != null) _cullingByPass(frontNode);
				} else {
					//set self visible true
					co = node.cullingObject;
					if (co != null) co.frustumCullingPass();
					
					//set front and all children visible false
				}
			}
		}
		private function _cullingByVisible(node:BSPNode):void {
			include 'BSPFrustumCullingManager_culling.define';
			
			if (x * nx + y * ny + z * nz > 0) {
				if (frontNode != null) _cullingByVisible(frontNode);
				
				if (angle+_maxHalfFov>HALF_PI) {
					//set self visible true
					co = node.cullingObject;
					if (co != null && !co._frustumCullingVisible) {
						co.setFrustumCullingVisible(true);
					}
					
					if (backNode != null) _cullingByVisible(backNode);
				} else {
					//set self visible false
					co = node.cullingObject;
					if (co != null && co._frustumCullingVisible) {
						co.setFrustumCullingVisible(false);
					}
					
					//set back and all children visible false
					if (backNode != null) _setNodeVisible(backNode, false);
				}
			} else {
				if (backNode != null) _cullingByVisible(backNode);
				
				if (angle-_maxHalfFov<HALF_PI) {
					//set self visible true
					co = node.cullingObject;
					if (co != null && !co._frustumCullingVisible) {
						co.setFrustumCullingVisible(true);
					}
					
					if (frontNode != null) _cullingByVisible(frontNode);
				} else {
					//set self visible true
					co = node.cullingObject;
					if (co != null && co._frustumCullingVisible) {
						co.setFrustumCullingVisible(false);
					}
					
					//set front and all children visible false
					if (frontNode != null) _setNodeVisible(frontNode, false);
				}
			}
		}
		private function _setNodePass(node:BSPNode):void {
			var co:ICullingObject = node.cullingObject;
			if (co != null) co.frustumCullingPass();
			
			var child:BSPNode = node.frontNode;
			if (child != null) _setNodePass(child);
			
			child = node.backNode;
			if (child != null) _setNodePass(child);
		}
		private function _setNodeVisible(node:BSPNode, visible:Boolean):void {
			var co:* = node.cullingObject;
			if (co != null && co._frustumCullingVisible != visible) co.setFrustumCullingVisible(visible);
			
			var child:BSPNode = node.frontNode;
			if (child != null) _setNodeVisible(child, visible);
			
			child = node.backNode;
			if (child != null) _setNodeVisible(child, visible);
		}
	}
}