package asgl.entities {
	import asgl.asgl_protected;
	import asgl.math.Float3;
	import asgl.math.Float4;
	import asgl.math.Matrix4x4;
	
	use namespace asgl_protected;

	public class Coordinates3DHelper {
		private static var _tempFloat3_1:Float3 = new Float3();
		private static var _tempFloat3_2:Float3 = new Float3();
		private static var _tempFloat3_3:Float3 = new Float3();
		private static var _tempFloat3_4:Float3 = new Float3();
		private static var _tempFloat4_1:Float4 = new Float4();
		private static var _tempFloat4_2:Float4 = new Float4();
		private static var _tempMatrix_1:Matrix4x4 = new Matrix4x4();
		
		public function Coordinates3DHelper() {
		}
		/**
		 * @param axisYInParentCoordinates, the value is normalized
		 * 
		 * @return localRotation, billboard.setLocalRotation(localRotation)
		 */
		public static function getBillboardLocalMatrixOfMaxVisualAreaToView(billboardParentCoordinates:Coordinates3D, camera:Coordinates3D, axisYInParentCoordinates:Float3, opFloat4:Float4=null):Float4 {
			var root1:Coordinates3D = billboardParentCoordinates._root;
			var root2:Coordinates3D = camera._root;
			if (root1 == root2) {
//				var viewMat:Matrix4x4 = billboardParentCoordinates.getWorldMatrix();
//				viewMat.invert();
//				
//				var worldMat:Matrix4x4 = camera.getWorldMatrix();
//				worldMat.append(viewMat);
//				
//				var see:Float3 = worldMat.transform3x3Float3(Float3.AXIS_NEGATIVE_Z);
//				see.normalize();
//				
//				var lineVec:Float3 = axisYInParentCoordinates.clone();
//				lineVec.multiplyFromNumber(-1);
//				var k:Number = Float3.dotProduct(axisYInParentCoordinates, lineVec);
//				var linePoint:Float3 = new Float3(lineVec.x+see.x, lineVec.y+see.y, lineVec.z+see.z);
//				var t0:Number = Float3.dotProduct(axisYInParentCoordinates, linePoint);
//				var t1:Number = Float3.dotProduct(axisYInParentCoordinates, new Float3());
//				var t:Number = -(t0-t1)/k;
//				var intersectPoint:Float3 = new Float3(lineVec.x*t+linePoint.x, lineVec.y*t+linePoint.y, lineVec.z*t+linePoint.z);
//				
//				intersectPoint.normalize();
//				
//				var axisX:Float3 = Float3.crossProduct(axisYInParentCoordinates, intersectPoint);
//				axisX.normalize();
//				
//				var mat:Matrix4x4 = new Matrix4x4();
//				mat.setAxisX(axisX.x, axisX.y, axisX.z);
//				mat.setAxisY(axisYInParentCoordinates.x, axisYInParentCoordinates.y, axisYInParentCoordinates.z);
//				mat.setAxisZ(intersectPoint.x, intersectPoint.y, intersectPoint.z);
//				mat.setLocation(posInParentCoordinates.x, posInParentCoordinates.y, posInParentCoordinates.z);
//				
//				return mat;
				
				var f4:Float4 = billboardParentCoordinates.getWorldRotation(_tempFloat4_1);
				f4.x = -f4.x;
				f4.y = -f4.y;
				f4.z = -f4.z;
				
				var quat:Float4 = camera.getWorldRotation(_tempFloat4_2);
				
				include '../math/Float4_multiplyQuaternion.define';
				
				var f3:Float3 = Float3.AXIS_NEGATIVE_Z;
				var opFloat3:Float3 = _tempFloat3_1;
				
				include '../math/Float4_rotationFloat3FromQuaternion.define';//see, _tempFloat3_1
				
				f3 = opFloat3;
				
				include '../math/Float3_normalize.define';
				
				_tempFloat3_2.x = -axisYInParentCoordinates.x;
				_tempFloat3_2.y = -axisYInParentCoordinates.y;
				_tempFloat3_2.z = -axisYInParentCoordinates.z;//lineVec
				
				var k:Number = axisYInParentCoordinates.x * _tempFloat3_2.x + axisYInParentCoordinates.y * _tempFloat3_2.y + axisYInParentCoordinates.z * _tempFloat3_2.z;
				var lineX:Number = _tempFloat3_2.x + _tempFloat3_1.x;
				var lineY:Number = _tempFloat3_2.y + _tempFloat3_1.y;
				var lineZ:Number = _tempFloat3_2.z + _tempFloat3_1.z;
				var t0:Number = axisYInParentCoordinates.x * lineX + axisYInParentCoordinates.y * lineY + axisYInParentCoordinates.z * lineZ;
				var t:Number = -t0 / k;
				
				_tempFloat3_2.x = _tempFloat3_2.x * t + lineX;
				_tempFloat3_2.y = _tempFloat3_2.y * t + lineY;
				_tempFloat3_2.z = _tempFloat3_2.z * t + lineZ;//intersectPoint
				
				f3 = _tempFloat3_2;
				
				include '../math/Float3_normalize.define';
				
				var f1:Float3 = axisYInParentCoordinates;
				var f2:Float3 = _tempFloat3_2;
				opFloat3 = _tempFloat3_3;
				
				include '../math/Float3_crossProduct.define';//axisX, _tempFloat3_3
				
				f3 = _tempFloat3_3;
				
				include '../math/Float3_normalize.define';
				
				var m:Matrix4x4 = _tempMatrix_1;
				
				m.m00 = _tempFloat3_3.x;
				m.m01 = _tempFloat3_3.y;
				m.m02 = _tempFloat3_3.z;
				
				m.m10 = axisYInParentCoordinates.x;
				m.m11 = axisYInParentCoordinates.y;
				m.m12 = axisYInParentCoordinates.z;
				
				m.m20 = _tempFloat3_2.x;
				m.m21 = _tempFloat3_2.y;
				m.m22 = _tempFloat3_2.z;
				
				include '../math/Matrix4x4_getQuaternion.define';
				
				return opFloat4;
			} else {
				return null;
			}
		}
		/**
		 * @param localAxis the value is normalized
		 * @param localSee the value is normalized
		 * 
		 * @return incrementLocalRotation, billboard.appendLocalRotation(incrementLocalRotation)
		 */
		public static function getBillboardIncrementLocalRotationOfMaxVisualAreaToView(billboard:Coordinates3D, camera:Coordinates3D, localAxis:Float3, localSee:Float3, opFloat4:Float4=null):Float4 {
			var root1:Coordinates3D = billboard._root;
			var root2:Coordinates3D = camera._root;
			if (root1 == root2) {
				var f4:Float4 = camera.getWorldRotation(_tempFloat4_1);
				f4.x = -f4.x;
				f4.y = -f4.y;
				f4.z = -f4.z;
				
				var quat:Float4 = billboard.getWorldRotation(_tempFloat4_2);
				
				include '../math/Float4_multiplyQuaternion.define';
				
				var f3:Float3 = localAxis;
				var opFloat3:Float3 = _tempFloat3_1;
				
				include '../math/Float4_rotationFloat3FromQuaternion.define';//viewAxis, _tempFloat3_1
				
				f3 = opFloat3;
				
				include '../math/Float3_normalize.define';
				
				_tempFloat3_2.x = -localAxis.x;
				_tempFloat3_2.y = -localAxis.y;
				_tempFloat3_2.z = -localAxis.z;//lineVec
				
				var k0:Number = _tempFloat3_1.x * _tempFloat3_2.x + _tempFloat3_1.y * _tempFloat3_2.y;
				var k:Number = k0 + _tempFloat3_1.z * _tempFloat3_2.z;
				var lineZ:Number = _tempFloat3_2.z - 1;
				var t0:Number = k0 + _tempFloat3_1.z * lineZ;
				var t:Number = -t0 / k;
				
				_tempFloat3_2.x += _tempFloat3_2.x * t;
				_tempFloat3_2.y += _tempFloat3_2.y * t;
				_tempFloat3_2.z = _tempFloat3_2.z * t + lineZ;//intersectPoint
				
				f3 = _tempFloat3_2;
				
				include '../math/Float3_normalize.define';
				
				f3 = localSee;
				opFloat3 = _tempFloat3_3;
				
				include '../math/Float4_rotationFloat3FromQuaternion.define';//viewSee, _tempFloat3_3
				
				f3 = opFloat3;
				
				include '../math/Float3_normalize.define';
				
				var val:Number = _tempFloat3_3.x * _tempFloat3_2.x + _tempFloat3_3.y * _tempFloat3_2.y + _tempFloat3_3.z * _tempFloat3_2.z;
				if (val > 1) {
					val = 1;
				} else if (val < -1) {
					val = -1;
				}
				var radian:Number = Math.acos(val);
				
				var f1:Float3 = _tempFloat3_1;
				var f2:Float3 = _tempFloat3_2;
				opFloat3 = _tempFloat3_4;
				
				include '../math/Float3_crossProduct.define';//axisX, _tempFloat3_4
				
				if (_tempFloat3_3.x * _tempFloat3_4.x + _tempFloat3_3.y * _tempFloat3_4.y + _tempFloat3_3.z * _tempFloat3_4.z < 0) radian = -radian;
				
				var axis:Float3 = localAxis;
				
				include '../math/Float4_createRotationAxisQuaternion.define';
				
				return opFloat4;
			} else {
				return null;
			}
		}
		/**
		 * @return worldRotation, billboard.setWorldRotation(worldRotation)
		 */
		public static function getBillboardWorldRotationOfParallelToViewPlane(billboard:Coordinates3D, camera:Coordinates3D, normalConcurrent:Boolean=true, op:Float4=null):Float4 {
			var root1:Coordinates3D = billboard._root;
			var root2:Coordinates3D = camera._root;
			if (root1 == root2) {
				if (normalConcurrent) {
					_tempFloat4_1 = camera.getWorldRotation(_tempFloat4_1);
				} else {
					_tempFloat4_2= Float4.createEulerYQuaternion(Math.PI, _tempFloat4_2);
					_tempFloat4_1 = camera.getWorldRotation(_tempFloat4_1);
					
					var f4:Float4 = _tempFloat4_1;
					var quat:Float4 = _tempFloat4_2;
					
					_tempFloat4_1.multiplyQuaternion(_tempFloat4_2);
					
					include '../math/Float4_multiplyQuaternion.define';
				}
				
				if (op == null) {
					return new Float4(_tempFloat4_1.x, _tempFloat4_1.y, _tempFloat4_1.z, _tempFloat4_1.w);
				} else {
					op.x = _tempFloat4_1.x;
					op.y = _tempFloat4_1.y;
					op.z = _tempFloat4_1.z;
					op.w = _tempFloat4_1.w;
					
					return op;
				}
			} else {
				return null;
			}
		}
		public static function getLocalToLocalMatrix(coordA:Coordinates3D, coordB:Coordinates3D, beforeCoordAMatrix:Matrix4x4=null, afterCoordAMatrix:Matrix4x4=null, afterCoordBMatrix:Matrix4x4=null, op:Matrix4x4=null):Matrix4x4 {
			var m1:Matrix4x4 = coordA.getWorldMatrix(op);
			
			var m:Matrix4x4;
			
			if (beforeCoordAMatrix != null) {
				m = m1;
				var rm:Matrix4x4 = beforeCoordAMatrix;
				
				include '../math/Matrix4x4_prepend4x4.define';
			}
			
			var lm:Matrix4x4;
			
			if (afterCoordAMatrix != null) {
				m = m1;
				lm = afterCoordAMatrix;
				
				include '../math/Matrix4x4_append4x4.define';
			}
			
			m = coordB.getWorldMatrix(_tempMatrix_1);
			
			include '../math/Matrix4x4_invert.define';
			
			lm = m;
			m = m1;
			
			include '../math/Matrix4x4_append4x4.define';
			
			if (afterCoordBMatrix != null) {
				lm = afterCoordBMatrix;
				
				include '../math/Matrix4x4_append4x4.define';
			}
			
			return m1;
		}
		public static function getLocalToProjectionMatrix(local:Coordinates3D, camera:Camera3D, op:Matrix4x4=null):Matrix4x4 {
			if (camera._worldMatrixUpdate) camera.updateWorldMatrix();
			
			var m:Matrix4x4 = camera._worldMatrix;
			op ||= new Matrix4x4();
			var opMatrix:Matrix4x4 = op;
			
			include '../math/Matrix4x4_static_invert.define';
			
			m = op;
			var lm:Matrix4x4 = camera._projectionMatrix;
			
			include '../math/Matrix4x4_append4x4.define';
			
			if (local._worldMatrixUpdate) local.updateWorldMatrix();
			var rm:Matrix4x4 = local._worldMatrix;
			
			include '../math/Matrix4x4_prepend4x4.define';
			
			return op;
		}
	}
}