package asgl.physics {
	import asgl.asgl_protected;
	import asgl.entities.Object3D;
	import asgl.math.Float3;
	import asgl.math.Matrix4x4;
	
	use namespace asgl_protected;

	public class Ray {
		private static var _ray:Ray = new Ray(new Float3(), new Float3());
		private static var _matrix:Matrix4x4 = new Matrix4x4();
		private static var _objects:Vector.<Object3D> = new Vector.<Object3D>();
		private static var _numObjects:int;
		
		public var origin:Float3;
		public var direction:Float3;
		
		public function Ray(origin:Float3=null, direction:Float3=null) {
			this.origin = origin;
			this.direction = direction;
		}
		public function getPoint(t:Number, op:Float3=null):Float3 {
			op ||= new Float3();
			
			op.x = origin.x + direction.x * t;
			op.y = origin.y + direction.y * t;
			op.z = origin.z + direction.z * t;
			
			return op;
		}
		public function transform3x4(m:Matrix4x4, ray:Ray=null):void {
			ray ||= this;
			
			if (origin != null) ray.origin = m.transform3x4Float3(origin, ray.origin);
			if (direction != null) ray.direction = m.transform3x3Float3(direction, ray.direction);
		}
		/**
		 * ray is in world space
		 */
		public function cast(obj:Object3D, cullingMask:uint=0xFFFFFFFF, priorityType:int=RaycastPriorityType.DEPTH, op:RaycastHit=null):RaycastHit {
			if (op == null) {
				op = new RaycastHit();
			} else {
				op.clear();
			}
			
			if (priorityType == RaycastPriorityType.DEPTH) {
				_castDepth(obj, cullingMask, op);
			} else if (priorityType == RaycastPriorityType.CONTAINER) {
				_castContainer(obj, cullingMask, op);
				_objects.length = 0;
				_numObjects = 0;
			}
			
			return op;
		}
		private function _castContainer(obj:Object3D, cullingMask:uint, hitInfo:RaycastHit):Boolean {
			var find:Boolean = false;
			
			if (obj._enabled) {
				var i:int;
				var child:*;
				
				if (obj._dynamicSortEnabled) {
					var start:int = _numObjects;
					
					for (i = 0; i < obj._delayNumChildren; i++) {
						child = obj._delayChildren[i];
						if (child != null) {
							_objects[_numObjects++] = child;
						}
					}
					
					var end:int = _numObjects;
					
					if (end - start > 1) _quickSort(_objects, start, end - 1);
					
					for (i = end - 1; i >= start; i--) {
						if (_castContainer(_objects[i], cullingMask, hitInfo)) {
							find = true;
							break;
						}
					}
				} else {
					for (i = obj._delayNumChildren - 1; i >= 0; i--) {
						child = obj._delayChildren[i];
						if (child != null && _castContainer(child, cullingMask, hitInfo)) {
							find = true;
							break;
						}
					}
				}
				
				if (!find && obj._boundingVolume != null && (cullingMask & obj.cullingLabel) != 0) {
					obj.updateWorldMatrix();
					Matrix4x4.invert(obj._worldMatrix, _matrix);
					transform3x4(_matrix, _ray);
					
					var t:Number = obj._boundingVolume.intersectRay(_ray);
					if (t != -1) {
						hitInfo.t = t;
						hitInfo.object = obj;
						find = true;
					}
				}
			}
			
			return find;
		}
		private function _castDepth(obj:Object3D, cullingMask:uint, hitInfo:RaycastHit):void {
			if (obj._enabled) {
				if (obj._boundingVolume != null && (cullingMask & obj.cullingLabel) != 0) {
					obj.updateWorldMatrix();
					Matrix4x4.invert(obj._worldMatrix, _matrix);
					transform3x4(_matrix, _ray);
					
					var t:Number = obj._boundingVolume.intersectRay(_ray);
					if (t != -1) {
						if (hitInfo.t == -1 || hitInfo.t > t) {
							hitInfo.t = t;
							hitInfo.object = obj;
						}
					}
				}
				
				for (var i:int = 0; i < obj._delayNumChildren; i++) {
					var child:* = obj._delayChildren[i];
					if (child != null) {
						_castDepth(child, cullingMask, hitInfo);
					}
				}
			}
		}
		public function toString():String {
			return 'ray [origin : ' + origin + ', direction : ' + direction + ']';
		}
		private function _quickSort(data:Vector.<Object3D>, left:int, right:int):void {
			if (left < right) {
				var middle:Number = data[int((left + right) * 0.5)]._priority;
				
				var i:int = left - 1;
				var j:int = right + 1;
				
				while (true) {
					while (data[++i]._priority < middle);
					
					while (data[--j]._priority > middle);
					
					if (i >= j) break;
					
					var temp:Object3D = data[i];
					data[i] = data[j];
					data[j] = temp;
				}
				
				_quickSort(data, left, i - 1);
				_quickSort(data, j + 1, right);
			}
		}
	}
}