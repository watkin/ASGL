package asgl.entities {
	import asgl.asgl_protected;
	import asgl.math.Float3;
	import asgl.math.Matrix4x4;
	import asgl.physics.Ray;
	import asgl.renderers.BaseRenderContext;
	import asgl.system.ClearData;
	import asgl.system.Device3D;
	
	use namespace asgl_protected;

	public class Camera3D extends Object3D {
		asgl_protected var _clearData:ClearData;
		
		asgl_protected var _projectionMatrix:Matrix4x4;
		asgl_protected var _zNear:Number;
		asgl_protected var _zFar:Number;
		asgl_protected var _aspectRatio:Number;
		
		public var cullingMask:uint = 0xFFFFFFFF;
		
		public function Camera3D() {
			_clearData = new ClearData();
		}
		protected override function _constructor():void {
			super._constructor();
			
			_projectionMatrix = new Matrix4x4();
		}
		public function get aspectRatio():Number {
			return _aspectRatio;
		}
		public function get clearData():ClearData {
			return _clearData;
		}
		public function get zFar():Number {
			return _zFar;
		}
		public function get zNear():Number {
			return _zNear;
		}
		public function getProjectionMatrix(opMatrix:Matrix4x4=null):Matrix4x4 {
			var m:Matrix4x4 = _projectionMatrix;
			
			include '../math/Matrix4x4_clone.define';
			
			return opMatrix;
		}
		public function setProjectionMatrix(projMatrix:Matrix4x4):void {
			var m:Matrix4x4 = _projectionMatrix;
			var sm:Matrix4x4 = projMatrix;
			
			include '../math/Matrix4x4_copyDataFromMatrix4x4.define';
			
			_zNear = -_projectionMatrix.m32 / _projectionMatrix.m22;
			
			if (_projectionMatrix.m33 == 1) {
				_zFar = 1 / _projectionMatrix.m22 + _zNear;
			} else {
				_zFar = (_zNear * _projectionMatrix.m22) / (_projectionMatrix.m22 - 1);
			}
			
			_aspectRatio = _projectionMatrix.m11 / _projectionMatrix.m00;
		}
		public function getWorldToProjectionMatrix(op:Matrix4x4=null):Matrix4x4 {
			updateWorldMatrix();
			
			var m:Matrix4x4 = _worldMatrix;
			op ||= new Matrix4x4();
			var opMatrix:Matrix4x4 = op;
			
			include '../math/Matrix4x4_static_invert.define';
			
			m = op;
			var lm:Matrix4x4 = _projectionMatrix;
			
			include '../math/Matrix4x4_append4x4.define';
			
			return op;
		}
		/**
		 * foucs (0, 0) = (left, top)
		 */
		public function getRay(screenWidth:Number, screenHeight:Number, focusX:Number, focusY:Number, op:Ray=null):Ray {
			op ||= new Ray();
			
			var originX:Number;
			var originY:Number;
			var originZ:Number;
			
			var dirX:Number;
			var dirY:Number;
			var dirZ:Number;
			
			if (_projectionMatrix.m33 == 1) {
				var w:Number = 2 / _projectionMatrix.m00;
				var h:Number = 2 / _projectionMatrix.m11;
				
				w /= screenWidth;
				h /= screenHeight;
				
				screenWidth *= w;
				screenHeight *= h;
				focusX *= w;
				focusY *= h;
				
				originX = focusX - screenWidth * 0.5;
				originY = screenHeight * 0.5 - focusY;
				originZ = _zNear;
				
				dirX = 0;
				dirY = 0;
				dirZ = 1;
			} else {
				dirX = (focusX / screenWidth) * 2 - 1;
				dirY = 1 - (focusY / screenHeight) * 2;
				
				dirX = dirX * _zNear / _projectionMatrix.m00;
				dirY = dirY * _zNear / _projectionMatrix.m11;
				dirZ = _zNear;
				
				var d:Number = dirX * dirX + dirY * dirY + dirZ * dirZ;
				d = Math.sqrt(d);
				dirX /= d;
				dirY /= d;
				dirZ /= d;
				
				var t:Number = _zNear / dirZ;
				
				originX = dirX * t;
				originY = dirY * t;
				originZ = _zNear;
			}
			
			if (op.origin == null) {
				op.origin = new Float3(originX, originY, originZ);
			} else {
				op.origin.x = originX;
				op.origin.y = originY;
				op.origin.z = originZ;
			}
			
			if (op.direction == null) {
				op.direction = new Float3(dirX, dirY, dirZ);
			} else {
				op.direction.x = dirX;
				op.direction.y = dirY;
				op.direction.z = dirZ;
			}
			
			return op;
		}
		
		public function postRender(device:Device3D, context:BaseRenderContext):void {
		}
		public function preRender(device:Device3D, context:BaseRenderContext):void {
		}
	}
}