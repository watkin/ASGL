package asgl.entities {
	import asgl.asgl_protected;
	import asgl.math.Float3;
	import asgl.math.Float4;
	import asgl.math.Matrix4x4;
	
	use namespace asgl_protected;

	public class Coordinates3D {
		private static var _tempMatrix:Matrix4x4 = new Matrix4x4();
		
		private static var _instanceIDAccumulator:uint = 0;
		
		asgl_protected var _instanceID:uint;
		
		public var name:String;
		
		asgl_protected var _parent:Coordinates3D;
		asgl_protected var _root:Coordinates3D;
		
		asgl_protected var _containerIndex:int;
		
		asgl_protected var _delayChildren:Vector.<Coordinates3D>;
		asgl_protected var _delayNumChildren:int;
		asgl_protected var _numChildren:int;
		asgl_protected var _isLooping:Boolean;
		
		asgl_protected var _priority:Number;
		
		asgl_protected var _localRotation:Float4;
		asgl_protected var _localScale:Float3;
		
		asgl_protected var _localMatrix:Matrix4x4;
		
		asgl_protected var _worldRotation:Float4;
		asgl_protected var _worldMatrix:Matrix4x4;
		
		asgl_protected var _localMatrixUpdate:Boolean;
		asgl_protected var _worldMatrixUpdate:Boolean;
		asgl_protected var _worldRotationUpdate:int;
		asgl_protected var _sendUpdate:Boolean;
		
		public function Coordinates3D() {
			_instanceID = ++_instanceIDAccumulator;
			
			_priority = 0;
			
			_constructor();
		}
		protected function _constructor():void {
			_localMatrixUpdate = false;
			_worldMatrixUpdate = false;
			_worldRotationUpdate = 0;
			_sendUpdate = false;
			
			_localRotation = new Float4();
			_localScale = new Float3(1, 1, 1);
			
			_worldRotation = new Float4();
			
			_localMatrix = new Matrix4x4();
			_worldMatrix = new Matrix4x4();
			
			_root = this;
			
			_delayChildren = new Vector.<Coordinates3D>();
		}
		public function get instanceID():uint {
			return _instanceID;
		}
		public function get numChildren():int {
			return _numChildren;
		}
		public function get priority():Number {
			return _priority;
		}
		public function set priority(value:Number):void {
			_priority = value;
		}
		public function get parent():Coordinates3D {
			return _parent;
		}
		public function get root():Coordinates3D {
			return _root;
		}
		asgl_protected function _setHierarchy(root:Coordinates3D, parent:Coordinates3D):void {
			_root = root;
			_parent = parent;
			
			include 'Coordinates3D_loopChildrenUpperHalf.define';
			child._setHierarchy(_root, this);
			include 'Coordinates3D_loopChildrenBottomHalf.define';
			
			_worldRotationUpdate = 2;
			_worldMatrixUpdate = true;
			_sendUpdate = false;
		}
		public function getLocalPosition(op:Float3=null):Float3 {
			if (op == null) {
				return new Float3(_localMatrix.m30, _localMatrix.m31, _localMatrix.m32);
			} else {
				op.x = _localMatrix.m30;
				op.y = _localMatrix.m31;
				op.z = _localMatrix.m32;
				
				return op;
			}
		}
		public function setLocalPosition(x:Number, y:Number, z:Number, transmit:Boolean=true):void {
			_localMatrix.m30 = x;
			_localMatrix.m31 = y;
			_localMatrix.m32 = z;
			
			_worldMatrixUpdate = true;
			_sendUpdate = true;
			
			if (transmit) {
				include 'Coordinates3D_transmit.define';
			}
		}
		public function appendLocalTranslate(x:Number=0, y:Number=0, z:Number=0, transmit:Boolean=true):void {
			//rotationFloat3FromQuaternion
			var w1:Number = -_localRotation.x * x - _localRotation.y * y - _localRotation.z * z;
			var x1:Number = _localRotation.w * x + _localRotation.y * z - _localRotation.z * y;
			var y1:Number = _localRotation.w * y - _localRotation.x * z + _localRotation.z * x;
			var z1:Number = _localRotation.w * z + _localRotation.x * y - _localRotation.y * x;
			
			_localMatrix.m30 += -w1 * _localRotation.x + x1 * _localRotation.w - y1 * _localRotation.z + z1 * _localRotation.y;
			_localMatrix.m31 += -w1 * _localRotation.y + x1 * _localRotation.z + y1 * _localRotation.w - z1 * _localRotation.x;
			_localMatrix.m32 += -w1 * _localRotation.z - x1 * _localRotation.y + y1 * _localRotation.x + z1 * _localRotation.w;
			
			_worldMatrixUpdate = true;
			_sendUpdate = true;
			
			if (transmit) {
				include 'Coordinates3D_transmit.define';
			}
		}
		public function getWorldPosition(op:Float3=null):Float3 {
			updateWorldMatrix();
			
			if (op == null) {
				return new Float3(_worldMatrix.m30, _worldMatrix.m31, _worldMatrix.m32);
			} else {
				op.x = _worldMatrix.m30;
				op.y = _worldMatrix.m31;
				op.z = _worldMatrix.m32;
				
				return op;
			}
		}
		public function setWorldPosition(x:Number, y:Number, z:Number, transmit:Boolean=true):void {
			updateWorldMatrix();
			
			_worldMatrix.m30 = x;
			_worldMatrix.m31 = y;
			_worldMatrix.m32 = z;
			
			if (_parent == null) {
				_localMatrix.m30 = _worldMatrix.m30;
				_localMatrix.m31 = _worldMatrix.m31;
				_localMatrix.m32 = _worldMatrix.m32;
			} else {
				var m:Matrix4x4 = _parent._worldMatrix;
				var opMatrix:Matrix4x4 = _tempMatrix;
				
				include '../math/Matrix4x4_static_invert.define';
				
				x = _localMatrix.m30;
				y = _localMatrix.m31;
				z = _localMatrix.m32;
				_localMatrix.m30 = x * m.m00 + y * m.m10 + z * m.m20 + m.m30;
				_localMatrix.m31 = x * m.m01 + y * m.m11 + z * m.m21 + m.m31;
				_localMatrix.m32 = x * m.m02 + y * m.m12 + z * m.m22 + m.m32;
			}
			
			_sendUpdate = true;
			
			if (transmit) {
				include 'Coordinates3D_transmit.define';
			}
		}
		public function appendWorldTranslate(x:Number=0, y:Number=0, z:Number=0, transmit:Boolean=true):void {
			updateWorldMatrix();
			
			var m:Matrix4x4 = _worldMatrix;
			
			include '../math/Matrix4x4_prependTranslation.define';
			
			if (_parent == null) {
				_localMatrix.m30 = _worldMatrix.m30;
				_localMatrix.m31 = _worldMatrix.m31;
				_localMatrix.m32 = _worldMatrix.m32;
			} else {
				m = _parent._worldMatrix;
				var opMatrix:Matrix4x4 = _tempMatrix;
				
				include '../math/Matrix4x4_static_invert.define';
				
				x = _localMatrix.m30;
				y = _localMatrix.m31;
				z = _localMatrix.m32;
				_localMatrix.m30 = x * opMatrix.m00 + y * opMatrix.m10 + z * opMatrix.m20 + opMatrix.m30;
				_localMatrix.m31 = x * opMatrix.m01 + y * opMatrix.m11 + z * opMatrix.m21 + opMatrix.m31;
				_localMatrix.m32 = x * opMatrix.m02 + y * opMatrix.m12 + z * opMatrix.m22 + opMatrix.m32;
			}
			
			_sendUpdate = true;
			
			if (transmit) {
				include 'Coordinates3D_transmit.define';
			}
		}
		public function getLocalRotation(op:Float4=null):Float4 {
			if (op == null) {
				return new Float4(_localRotation.x, _localRotation.y, _localRotation.z, _localRotation.w);
			} else {
				op.x = _localRotation.x;
				op.y = _localRotation.y;
				op.z = _localRotation.z;
				op.w = _localRotation.w;
				
				return op;
			}
		}
		public function setLocalRotation(quat:Float4, transmit:Boolean=true):void {
			_localRotation.x = quat.x;
			_localRotation.y = quat.y;
			_localRotation.z = quat.z;
			_localRotation.w = quat.w;
			
			_localMatrixUpdate = true;
			_worldRotationUpdate = 2;
			_worldMatrixUpdate = true;
			_sendUpdate = true;
			
			if (transmit) {
				include 'Coordinates3D_transmit.define';
			}
		}
		public function appendLocalRotation(quat:Float4, transmit:Boolean=true):void {
			var f4:Float4 = _localRotation;
			
			include '../math/Float4_multiplyQuaternion.define';
			
			_localMatrixUpdate = true;
			_worldRotationUpdate = 2;
			_worldMatrixUpdate = true;
			_sendUpdate = true;
			
			if (transmit) {
				include 'Coordinates3D_transmit.define';
			}
		}
		public function appendParentRotation(quat:Float4, transmit:Boolean=true):void {
			var w1:Number = quat.w * _localRotation.w - quat.x * _localRotation.x - quat.y * _localRotation.y - quat.z * _localRotation.z;
			var x1:Number = quat.w * _localRotation.x + quat.x * _localRotation.w + quat.y * _localRotation.z - quat.z * _localRotation.y;
			var y1:Number = quat.w * _localRotation.y + quat.y * _localRotation.w + quat.z * _localRotation.x - quat.x * _localRotation.z;
			var z1:Number = quat.w * _localRotation.z + quat.z * _localRotation.w + quat.x * _localRotation.y - quat.y * _localRotation.x;
			
			_localRotation.x = x1;
			_localRotation.y = y1;
			_localRotation.z = z1;
			_localRotation.w = w1;
			
			_localMatrixUpdate = true;
			_worldRotationUpdate = 2;
			_worldMatrixUpdate = true;
			_sendUpdate = true;
			
			if (transmit) {
				include 'Coordinates3D_transmit.define';
			}
		}
		public function getWorldRotation(op:Float4=null):Float4 {
			include 'Coordinates3D_updateWorldRotation.define';
			
			if (op == null) {
				return new Float4(_worldRotation.x, _worldRotation.y, _worldRotation.z, _worldRotation.w);
			} else {
				op.x = _worldRotation.x;
				op.y = _worldRotation.y;
				op.z = _worldRotation.z;
				op.w = _worldRotation.w;
				
				return op;
			}
		}
		public function setWorldRotation(quat:Float4, transmit:Boolean=true):void {
			_worldRotation.x = quat.x;
			_worldRotation.y = quat.y;
			_worldRotation.z = quat.z;
			_worldRotation.w = quat.w;
			
			if (_parent == null) {
				_localRotation.x = _worldRotation.x;
				_localRotation.y = _worldRotation.y;
				_localRotation.z = _worldRotation.z;
				_localRotation.w = _worldRotation.w;
			} else {
				if (_parent._worldRotationUpdate == 2) _parent.updateWorldRotation();
				
				_localRotation.x = -_parent._worldRotation.x;
				_localRotation.y = -_parent._worldRotation.y;
				_localRotation.z = -_parent._worldRotation.z;
				_localRotation.w = _parent._worldRotation.w;
				
				var f4:Float4 = _localRotation;
				quat = _worldRotation;
				
				include '../math/Float4_multiplyQuaternion.define';
			}
			
			_localMatrixUpdate = true;
			_worldRotationUpdate = 1;
			_worldMatrixUpdate = true;
			_sendUpdate = true;
			
			if (transmit) {
				include 'Coordinates3D_transmit.define';
			}
		}
		public function calculateLocalRotationFromWorldRotation(quat:Float4, op:Float4=null):Float4 {
			op ||= new Float4();
			
			if (_parent == null) {
				op.x = quat.x;
				op.y = quat.y;
				op.z = quat.z;
				op.w = quat.w;
			} else {
				if (_parent._worldRotationUpdate == 2) _parent.updateWorldRotation();
				
				op.x = -_parent._worldRotation.x;
				op.y = -_parent._worldRotation.y;
				op.z = -_parent._worldRotation.z;
				op.w = _parent._worldRotation.w;
				
				var f4:Float4 = op;
				
				include '../math/Float4_multiplyQuaternion.define';
			}
			
			return op;
		}
		public function appendWorldRotation(quat:Float4, transmit:Boolean=true):void {
			include 'Coordinates3D_updateWorldRotation.define';
			
			var f4:Float4 = _worldRotation;
			
			include '../math/Float4_multiplyQuaternion.define';
			
			if (_parent == null) {
				_localRotation.x = _worldRotation.x;
				_localRotation.y = _worldRotation.y;
				_localRotation.z = _worldRotation.z;
				_localRotation.w = _worldRotation.w;
			} else {
				if (_parent._worldRotationUpdate == 2) _parent.updateWorldRotation();
				
				_localRotation.x = -_parent._worldRotation.x;
				_localRotation.y = -_parent._worldRotation.y;
				_localRotation.z = -_parent._worldRotation.z;
				_localRotation.w = _parent._worldRotation.w;
				
				f4 = _localRotation;
				quat = _worldRotation;
				
				include '../math/Float4_multiplyQuaternion.define';
			}
			
			_localMatrixUpdate = true;
			_worldRotationUpdate = 1;
			_worldMatrixUpdate = true;
			_sendUpdate = true;
			
			if (transmit) {
				include 'Coordinates3D_transmit.define';
			}
		}
		public function getLocalScale(op:Float3=null):Float3 {
			if (op == null) {
				return new Float3(_localScale.x, _localScale.y, _localScale.z);
			} else {
				op.x = _localScale.x;
				op.y = _localScale.y;
				op.z = _localScale.z;
				
				return op;
			}
		}
		public function setLocalScale(x:Number, y:Number, z:Number, transmit:Boolean=true):void {
			_localScale.x = x;
			_localScale.y = y;
			_localScale.z = z;
			
			_localMatrixUpdate = true;
			_worldMatrixUpdate = true;
			_sendUpdate = true;
			
			if (transmit) {
				include 'Coordinates3D_transmit.define';
			}
		}
		public function getLocalMatrix(opMatrix:Matrix4x4=null):Matrix4x4 {
			include 'Coordinates3D_updateLocalMatrix.define';
			
			var m:Matrix4x4 = _localMatrix;
			
			include '../math/Matrix4x4_clone.define';
			
			return opMatrix;
		}
		public function setLocalMatrix(lm:Matrix4x4, transmit:Boolean=true):void {
			var m:Matrix4x4 = _localMatrix;
			var sm:Matrix4x4 = lm;
			
			include '../math/Matrix4x4_copyDataFromMatrix3x4.define';
			
			_localMatrix.decomposition(_tempMatrix, _localScale);
			
			m = _tempMatrix;
			var opFloat4:Float4 = _localRotation;
			
			include '../math/Matrix4x4_getQuaternion.define';
			
			_localMatrixUpdate = false;
			_worldMatrixUpdate = true;
			_worldRotationUpdate = 2;
			_sendUpdate = true;
			
			if (transmit) {
				include 'Coordinates3D_transmit.define';
			}
		}
		public function getWorldMatrix(op:Matrix4x4=null):Matrix4x4 {
			updateWorldMatrix();
			
			var m:Matrix4x4 = _worldMatrix;
			var opMatrix:Matrix4x4 = op;
			
			include '../math/Matrix4x4_clone.define';
			
			return opMatrix;
		}
		public function setWorldMatrix(wm:Matrix4x4, transmit:Boolean=true):void {
			var lm:Matrix4x4;
			
			var m:Matrix4x4 = _worldMatrix;
			var sm:Matrix4x4 = wm;
			
			include '../math/Matrix4x4_copyDataFromMatrix3x4.define';
			
			if (_parent == null) {
				m = _localMatrix;
				lm = _worldMatrix;
				
				include '../math/Matrix4x4_copyDataFromMatrix3x4.define';
			} else {
				if (_parent._worldMatrixUpdate) _parent.updateWorldMatrix();
				
				m = _parent._worldMatrix;
				var opMatrix:Matrix4x4 = _tempMatrix;
				
				include '../math/Matrix4x4_static_invert.define';
				
				m = _worldMatrix;
				lm = _tempMatrix;
				opMatrix = _localMatrix;
				
				include '../math/Matrix4x4_static_append3x4.define';
			}
			
			_localMatrix.decomposition(_tempMatrix, _localScale);
			
			m = _tempMatrix;
			var opFloat4:Float4 = _localRotation;
			
			include '../math/Matrix4x4_getQuaternion.define';
			
			_localMatrixUpdate = false;
			_worldMatrixUpdate = false;
			_worldRotationUpdate = 2;
			_sendUpdate = true;
			
			if (transmit) {
				include 'Coordinates3D_transmit.define';
			}
		}
		public function identity(transmit:Boolean=true):void {
			var m:Matrix4x4 = _localMatrix;
			
			include '../math/Matrix4x4_identity.define';
			
			_localRotation.x = 0;
			_localRotation.y = 0;
			_localRotation.z = 0;
			_localRotation.w = 1;
			
			_localScale.x = 1;
			_localScale.y = 1;
			_localScale.z = 1;
			
			_localMatrixUpdate = false;
			_worldMatrixUpdate = true;
			_worldRotationUpdate = 2;
			_sendUpdate = true;
			
			if (transmit) {
				include 'Coordinates3D_transmit.define';
			}
		}
		public function getIterator(iterator:Coordinates3DIterator=null):Coordinates3DIterator {
			if (iterator == null) {
				iterator = new Coordinates3DIterator(this);
			} else {
				if (iterator._coord != null) iterator.clear();
				iterator._coord = this;
				iterator._index = 0;
			}
			
			return iterator;
		}
		public function addChild(child:Coordinates3D):int {
			var parent:Coordinates3D = child._parent;
			
			if (parent == this) return 0;
			if (child == this) return -1;
			
			var result:int;
			
			if (parent == null) {
				result = 2;
			} else {
				parent._removeChild(child);
				
				result = 1;
			}
			
			_delayChildren[_delayNumChildren] = child;
			child._containerIndex = _delayNumChildren++;
			
			_numChildren++;
			
			child._setHierarchy(_root, this);
					
			return result;
		}
		public function contains(coord:Coordinates3D, depth:uint=uint.MAX_VALUE):int {
			if (coord == this) {
				return 0;
			} else if (depth > 0) {
				if (coord._parent == this) {
					return 1;
				} else if (depth > 1) {
					include 'Coordinates3D_loopChildrenUpperHalf.define';
					var lv:int = child.contains(coord, depth - 1);
					if (lv != -1) return lv + 1;
					include 'Coordinates3D_loopChildrenBottomHalf.define';
					
					return -1;
				}
				
				return -1;
			} else {
				return -1;
			}
		}
		public function getChildFromName(name:String, depth:uint=uint.MAX_VALUE):Coordinates3D {
			if (this.name == name) return this;
			
			if (depth > 0) {
				include 'Coordinates3D_loopChildrenUpperHalf.define';
				if (child.name == name) return child;
				include 'Coordinates3D_loopChildrenBottomHalf.define';
				
				if (depth > 1) {
					include 'Coordinates3D_loopChildrenUpperHalf.define';
					var c:Coordinates3D = child.getChildFromName(name, depth - 1);
					if (c != null) return c;
					include 'Coordinates3D_loopChildrenBottomHalf.define';
				}
			}
			
			return null;
		}
		public function getChildren(op:Vector.<Coordinates3D>=null):Vector.<Coordinates3D> {
			if (op == null) {
				op = new Vector.<Coordinates3D>(_numChildren);
			} else if (!op.fixed) {
				op.length = _numChildren;
			}
			
			var index:int = 0;
			
			include 'Coordinates3D_loopChildrenUpperHalf.define';
			op[index++] = child;
			include 'Coordinates3D_loopChildrenBottomHalf.define';
			
			return op;
		}
		public function getChildrenDuplicate():Vector.<Coordinates3D> {
			return _delayChildren.concat();
		}
		public function removeChild(child:Coordinates3D):Boolean {
			if (child._parent == this) {
				if (_isLooping) {
					_delayChildren[child._containerIndex] = null;
				} else {
					var trail:Coordinates3D = _delayChildren[--_delayNumChildren];
					if (trail != null) trail._containerIndex = child._containerIndex;
					_delayChildren[child._containerIndex] = trail;
				}
				
				_numChildren--;
				
				child._setHierarchy(child, null);
				
				return true;
			} else {
				return false;
			}
		}
		public function removeChildren():void {
			include 'Coordinates3D_loopChildrenUpperHalf.define';
			_delayChildren[child._containerIndex] = null;
			child._setHierarchy(child, null);
			include 'Coordinates3D_loopChildrenBottomHalf.define';
			
			if (!_isLooping) _delayNumChildren = 0;
			_numChildren = 0;
		}
		public function removeSelf():Boolean {
			if (_parent == null) {
				return false;
			} else {
				return _parent.removeChild(this);
			}
		}
		public function transmit():void {
			if (_sendUpdate) {
				include 'Coordinates3D_transmit.define';
			}
		}
		public function updateLocalMatrix():void {
			include 'Coordinates3D_updateLocalMatrix.define';
		}
		public function updateWorldMatrix():void {
			if (_worldMatrixUpdate) {
				_worldMatrixUpdate = false;
				
				include 'Coordinates3D_updateLocalMatrix.define';
				
				if (_parent == null) {
					_worldMatrix.m00 = _localMatrix.m00;
					_worldMatrix.m01 = _localMatrix.m01;
					_worldMatrix.m02 = _localMatrix.m02;
					
					_worldMatrix.m10 = _localMatrix.m10;
					_worldMatrix.m11 = _localMatrix.m11;
					_worldMatrix.m12 = _localMatrix.m12;
					
					_worldMatrix.m20 = _localMatrix.m20;
					_worldMatrix.m21 = _localMatrix.m21;
					_worldMatrix.m22 = _localMatrix.m22;
					
					_worldMatrix.m30 = _localMatrix.m30;
					_worldMatrix.m31 = _localMatrix.m31;
					_worldMatrix.m32 = _localMatrix.m32;
				} else {
					if (_parent._worldMatrixUpdate) _parent.updateWorldMatrix();
					
					var m:Matrix4x4 = _localMatrix;
					var lm:Matrix4x4 = _parent._worldMatrix;
					var opMatrix:Matrix4x4 = _worldMatrix;
					
					include '../math/Matrix4x4_static_append3x4.define';
				}
			}
		}
		public function updateWorldRotation():void {
			include 'Coordinates3D_updateWorldRotation.define';
		}
		public function sort():Boolean {
			if (_isLooping) {
				return false;
			} else {
				_quickSort(_delayChildren, 0, _numChildren - 1);
				
				for (var i:int = 0; i < _delayNumChildren; i++) {
					var child:Coordinates3D = _delayChildren[i];
					if (child != null) child._containerIndex = i;
				}
				
				return true;
			}
		}
		protected function _removeChild(child:Coordinates3D):void {
			if (_isLooping) {
				_delayChildren[child._containerIndex] = null;
			} else {
				var trail:Coordinates3D = _delayChildren[--_delayNumChildren];
				if (trail != null) trail._containerIndex = child._containerIndex;
				_delayChildren[child._containerIndex] = trail;
			}
			
			_numChildren--;
		}
		protected function _parentUpdate(rotation:Boolean):void {
			if (rotation) _worldRotationUpdate = 2;
			_worldMatrixUpdate = true;
			
			include 'Coordinates3D_transmit.define';
		}
		private static function _quickSort(data:Vector.<Coordinates3D>, left:int, right:int):void {
			if (left < right) {
				var c:Coordinates3D = data[int((left + right) * 0.5)];
				var middle:Number = c == null ? 0 : c._priority;
				
				var i:int = left - 1;
				var j:int = right + 1;
				
				while (true) {
					while (true) {
						c = data[++i];
						if (c == null) {
							if (0 >= middle) break;
						} else {
							if (c._priority >= middle) break;
						}
					}
					
					while (true) {
						c = data[--j];
						if (c == null) {
							if (0 <= middle) break;
						} else {
							if (c._priority <= middle) break;
						}
					}
					
					if (i >= j) break;
					
					var temp:Coordinates3D = data[i];
					data[i] = data[j];
					data[j] = temp;
				}
				
				_quickSort(data, left, i - 1);
				_quickSort(data, j + 1, right);
			}
		}
	}
}