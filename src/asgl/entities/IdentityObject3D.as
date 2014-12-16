package asgl.entities {
	import asgl.asgl_protected;
	import asgl.math.Float4;
	import asgl.math.Matrix4x4;
	
	use namespace asgl_protected;

	public class IdentityObject3D extends Object3D {
		private var _selfWorldMatrix:Matrix4x4;
		private var _selfWorldRotation:Float4;
		
		public function IdentityObject3D() {
		}
		protected override function _constructor():void {
			super._constructor();
			
			_selfWorldMatrix = _worldMatrix;
			_selfWorldRotation = _worldRotation;
		}
		asgl_protected override function _setHierarchy(root:Coordinates3D, parent:Coordinates3D):void {
			if (parent == null) {
				_worldMatrix = _selfWorldMatrix;
				_worldRotation = _selfWorldRotation;
			} else {
				_worldMatrix = parent._worldMatrix;
				_worldRotation = parent._worldRotation;
			}
			
			super._setHierarchy(root, parent);
		}
		public override function setLocalMatrix(lm:Matrix4x4, transmit:Boolean=true):void {
		}
		public override function setLocalPosition(x:Number, y:Number, z:Number, transmit:Boolean=true):void {
		}
		public override function appendLocalTranslate(x:Number=0, y:Number=0, z:Number=0, transmit:Boolean=true):void {
		}
		public override function setLocalRotation(quat:Float4, transmit:Boolean=true):void {
		}
		public override function appendLocalRotation(quat:Float4, transmit:Boolean=true):void {
		}
		public override function setLocalScale(x:Number, y:Number, z:Number, transmit:Boolean=true):void {
		}
		public override function appendParentRotation(quat:Float4, transmit:Boolean=true):void {
		}
		public override function setWorldMatrix(wm:Matrix4x4, transmit:Boolean=true):void {
		}
		public override function setWorldPosition(x:Number, y:Number, z:Number, transmit:Boolean=true):void {
		}
		public override function appendWorldTranslate(x:Number=0, y:Number=0, z:Number=0, transmit:Boolean=true):void {
		}
		public override function setWorldRotation(quat:Float4, transmit:Boolean=true):void {
		}
		public override function appendWorldRotation(quat:Float4, transmit:Boolean=true):void {
		}
		public override function updateLocalMatrix():void {
			_localMatrixUpdate = false;
		}
		public override function updateWorldMatrix():void {
			if (_worldMatrixUpdate) {
				_worldMatrixUpdate = false;
				
				if (_parent != null && _parent._worldMatrixUpdate) _parent.updateWorldMatrix();
			}
		}
		public override function updateWorldRotation():void {
			if(_worldRotationUpdate == 2) {
				_worldRotationUpdate = 0;
				
				if (_parent != null && _parent._worldRotationUpdate == 2) _parent.updateWorldRotation();
			}
		}
	}
}