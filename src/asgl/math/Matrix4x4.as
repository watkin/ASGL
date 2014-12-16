package asgl.math {
	import flash.geom.Matrix3D;
	import flash.utils.ByteArray;
	
	/**
	 * Matrix4*4</p>
	 * 
	 * m00 m01 m02 m03  axisX<br>
	 * m10 m11 m12 m13  axisY<br>
	 * m20 m21 m22 m23  axisZ<br>
	 * m30 m31 m32 m33<br>
	 * x   y   z   w</p>
	 * 
	 * x' = x~~m00+y~~m10+z~~m20+w~~m30<br>
	 * y' = x~~m01+y~~m11+z~~m21+w~~m31<br>
	 * z' = x~~m02+y~~m12+z~~m22+w~~m32<br>
	 * w' = x~~m03+y~~m13+z~~m23+w~~m33
	 */
	
	public class Matrix4x4 {
		protected static var _tempFloat4_1:Float4 = new Float4();
		protected static var _tempFloat4_2:Float4 = new Float4();
		protected static var _tempMatrix_1:Matrix4x4 = new Matrix4x4();
		
		public var m00:Number;
		public var m01:Number;
		public var m02:Number;
		public var m03:Number;
		public var m10:Number;
		public var m11:Number;
		public var m12:Number;
		public var m13:Number;
		public var m20:Number;
		public var m21:Number;
		public var m22:Number;
		public var m23:Number;
		public var m30:Number;
		public var m31:Number;
		public var m32:Number;
		public var m33:Number;
		
		private var m:Matrix4x4;
		
		public function Matrix4x4(m00:Number=1, m01:Number=0, m02:Number=0, m03:Number=0, 
								  m10:Number=0, m11:Number=1, m12:Number=0, m13:Number=0, 
								  m20:Number=0, m21:Number=0, m22:Number=1, m23:Number=0, 
								  m30:Number=0, m31:Number=0, m32:Number=0, m33:Number=1) {
			this.m00 = m00;
			this.m01 = m01;
			this.m02 = m02;
			this.m03 = m03;
			this.m10 = m10;
			this.m11 = m11;
			this.m12 = m12;
			this.m13 = m13;
			this.m20 = m20;
			this.m21 = m21;
			this.m22 = m22;
			this.m23 = m23;
			this.m30 = m30;
			this.m31 = m31;
			this.m32 = m32;
			this.m33 = m33;
			
			m = this;
		}
		public static function createLookAtLHMatrix(eye:Float3, at:Float3, up:Float3, opMatrix:Matrix4x4=null):Matrix4x4 {
			include 'Matrix4x4_createLookAtLHMatrix.define';
			
			return opMatrix;
		}
		public static function createOrthoLHMatrix(width:Number, height:Number, zNear:Number, zFar:Number, op:Matrix4x4=null):Matrix4x4 {
			if(op == null) {
				return new Matrix4x4(2 / width, 0, 0, 0,
									 0, 2 / height, 0, 0,
									 0, 0, 1 / (zFar - zNear), 0,
									 0, 0, zNear / (zNear - zFar));
			} else {
				op.m00 = 2 / width;
				op.m01 = 0;
				op.m02 = 0;
				op.m03 = 0;
				
				op.m10 = 0;
				op.m11 = 2 / height;
				op.m12 = 0;
				op.m13 = 0;
				
				op.m20 = 0;
				op.m21 = 0;
				op.m22 = 1 / (zFar - zNear);
				op.m23 = 0;
				
				op.m30 = 0;
				op.m31 = 0;
				op.m32 = zNear / (zNear - zFar);
				op.m33 = 1;
				
				return op;
			}
		}
		public static function createRotationAxisMatrix(axis:Float3, radian:Number, opMatrix:Matrix4x4=null):Matrix4x4 {
			include 'Matrix4x4_createRotationAxisMatrix.define';
			
			return opMatrix;
		}
		/**
		 * direction:(0, 1, 0) to (0, 0, 1)
		 */
		public static function createRotationXMatrix(radian:Number, op:Matrix4x4=null):Matrix4x4 {
			var sin:Number = Math.sin(radian);
			var cos:Number = Math.cos(radian);
			
			if (op == null) {
				return new Matrix4x4(1, 0, 0, 0,
					0, cos, sin, 0,
					0, -sin, cos);
			} else {
				op.m00 = 1;
				op.m01 = 0;
				op.m02 = 0;
				op.m03 = 0;
				
				op.m10 = 0;
				op.m11 = cos;
				op.m12 = sin;
				op.m13 = 0;
				
				op.m20 = 0;
				op.m21 = -sin;
				op.m22 = cos;
				op.m23 = 0;
				
				op.m30 = 0;
				op.m31 = 0;
				op.m32 = 0;
				op.m33 = 1;
				
				return op;
			}
		}
		/**
		 * direction:(1, 0, 0) to (0, 0, -1)
		 */
		public static function createRotationYMatrix(radian:Number, op:Matrix4x4=null):Matrix4x4 {
			var sin:Number = Math.sin(radian);
			var cos:Number = Math.cos(radian);
			
			if (op == null) {
				return new Matrix4x4(cos, 0, -sin, 0,
					0, 1, 0, 0,
					sin, 0, cos);
			} else {
				op.m00 = cos;
				op.m01 = 0;
				op.m02 = -sin;
				op.m03 = 0;
				
				op.m10 = 0;
				op.m11 = 1;
				op.m12 = 0;
				op.m13 = 0;
				
				op.m20 = sin;
				op.m21 = 0;
				op.m22 = cos;
				op.m23 = 0;
				
				op.m30 = 0;
				op.m31 = 0;
				op.m32 = 0;
				op.m33 = 1;
				
				return op;
			}
		}
		/**
		 * direction:(1, 0, 0) to (0, 1, 0)
		 */
		public static function createRotationZMatrix(radian:Number, op:Matrix4x4=null):Matrix4x4 {
			var sin:Number = Math.sin(radian);
			var cos:Number = Math.cos(radian);
			
			if (op == null) {
				return new Matrix4x4(cos, sin, 0, 0,
					-sin, cos);
			} else {
				op.m00 = cos;
				op.m01 = sin;
				op.m02 = 0;
				op.m03 = 0;
				
				op.m10 = -sin;
				op.m11 = cos;
				op.m12 = 0;
				op.m13 = 0;
				
				op.m20 = 0;
				op.m21 = 0;
				op.m22 = 1;
				op.m23 = 0;
				
				op.m30 = 0;
				op.m31 = 0;
				op.m32 = 0;
				op.m33 = 1;
				
				return op;
			}
		}
		/**
		 * @param aspectRatio = width / height
		 */
		public static function createPerspectiveFieldOfViewLHMatrix(fieldOfViewY:Number, aspectRatio:Number, zNear:Number, zFar:Number, op:Matrix4x4=null):Matrix4x4 {
			var yScale:Number = 1 / Math.tan(fieldOfViewY * 0.5);
			var xScale:Number = yScale / aspectRatio;
			
			if(op == null) {
				return new Matrix4x4(xScale, 0, 0, 0,
									 0, yScale, 0, 0,
									 0, 0, zFar / (zFar - zNear), 1,
									 0, 0, zNear * zFar / (zNear - zFar), 0);
			} else {
				op.m00 = xScale;
				op.m01 = 0;
				op.m02 = 0;
				op.m03 = 0;
				
				op.m10 = 0;
				op.m11 = yScale;
				op.m12 = 0;
				op.m13 = 0;
				
				op.m20 = 0;
				op.m21 = 0;
				op.m22 = zFar / (zFar - zNear);
				op.m23 = 1;
				
				op.m30 = 0;
				op.m31 = 0;
				op.m32 = zNear * zFar / (zNear - zFar);
				op.m33 = 0;
				
				return op;
			}
		}
		public static function createPerspectiveLHMatrix(width:Number, height:Number, zNear:Number, zFar:Number, op:Matrix4x4=null):Matrix4x4 {
			if(op == null) {
				return new Matrix4x4(2 * zNear / width, 0, 0, 0,
									 0, 2 * zNear / height, 0, 0,
									 0, 0, zFar / (zFar - zNear), 1,
									 0, 0, zNear * zFar / (zNear - zFar), 0);
			} else {
				op.m00 = 2 * zNear / width;
				op.m01 = 0;
				op.m02 = 0;
				op.m03 = 0;
				
				op.m10 = 0;
				op.m11 = 2 * zNear / height;
				op.m12 = 0;
				op.m13 = 0;
				
				op.m20 = 0;
				op.m21 = 0;
				op.m22 = zFar / (zFar - zNear);
				op.m23 = 1;
				
				op.m30 = 0;
				op.m31 = 0;
				op.m32 = zNear * zFar / (zNear - zFar);
				op.m33 = 0;
				
				return op;
			}
		}
		public static function createScaleMatrix(sx:Number, sy:Number, sz:Number, opMatrix:Matrix4x4=null):Matrix4x4 {
			include 'Matrix4x4_createScaleMatrix.define';
				
			return opMatrix;
		}
		public static function createTranslationMatrix(tx:Number, ty:Number, tz:Number, op:Matrix4x4=null):Matrix4x4 {
			if (op == null) {
				return new Matrix4x4(1, 0, 0, 0,
									 0, 1, 0, 0,
									 0, 0, 1, 0,
									 tx, ty, tz);
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
				
				op.m30 = tx;
				op.m31 = ty;
				op.m32 = tz;
				op.m33 = 1;
				
				return op;
			}
		}
		/**
		 * @param translation relative to parent.
		 * @param rotation relative to self.
		 * @param scale relative to self.
		 */
		public static function createTRSMatrix(translation:Float3, rotation:Float4, scale:Float3, op:Matrix4x4=null):Matrix4x4 {
			/*
			var sx:Number = scale.x;
			var sy:Number = scale.y;
			var sz:Number = scale.z;
			var opMatrix:Matrix4x4 = op;
			
			include 'Matrix4x4_createScaleMatrix.define';
			
			op = opMatrix;
			
			var f4:Float4 = rotation;
			opMatrix = _tempMatrix_1;
			
			include 'Float4_getMatrixFromQuaternion.define';
			
			var m:Matrix4x4 = op;
			var rm:Matrix4x4 = _tempMatrix_1;
			
			include 'Matrix4x4_prepend.define';
			
			var x:Number = translation.x;
			var y:Number = translation.y;
			var z:Number = translation.z;
			
			include 'Matrix4x4_appendTranslation.define';
			
			return op;
			*/
			
			if (op == null) op = new Matrix4x4();
			
			var x2:Number = rotation.x * 2;
			var y2:Number = rotation.y * 2;
			var z2:Number = rotation.z * 2;
			var xx:Number = rotation.x * x2;
			var xy:Number = rotation.x * y2;
			var xz:Number = rotation.x * z2;
			var yy:Number = rotation.y * y2;
			var yz:Number = rotation.y * z2;
			var zz:Number = rotation.z * z2;
			var wx:Number = rotation.w * x2;
			var wy:Number = rotation.w * y2;
			var wz:Number = rotation.w * z2;
			op.m00 = (1 - yy - zz) * scale.x;
			op.m01 = (xy + wz) * scale.x;
			op.m02 = (xz - wy) * scale.x;
			op.m03 = 0;
			
			op.m10 = (xy - wz) * scale.y;
			op.m11 = (1 - xx - zz) * scale.y;
			op.m12 = (yz + wx) * scale.y;
			op.m13 = 0;
			
			op.m20 = (xz + wy) * scale.z;
			op.m21 = (yz - wx) * scale.z;
			op.m22 = (1 - xx - yy) * scale.z;
			op.m23 = 0;
			
			op.m30 = translation.x;
			op.m31 = translation.y;
			op.m32 = translation.z;
			op.m33 = 1;
			
			return op;
		}
		//opMatrix != m && opMatrix != rm
		public static function append3x4(m:Matrix4x4, lm:Matrix4x4, opMatrix:Matrix4x4=null):Matrix4x4 {
			if (opMatrix == null) opMatrix = new Matrix4x4();
			
			include 'Matrix4x4_static_append3x4.define';
			
			return opMatrix;
		}
		//opMatrix != m && opMatrix != rm
		public static function append4x4(m:Matrix4x4, lm:Matrix4x4, opMatrix:Matrix4x4=null):Matrix4x4 {
			if (opMatrix == null) opMatrix = new Matrix4x4();
			
			include 'Matrix4x4_static_append4x4.define';
			
			return opMatrix;
		}
		//opMatrix != m
		public static function invert(m:Matrix4x4, opMatrix:Matrix4x4=null):Matrix4x4 {
			if (opMatrix == null) opMatrix = new Matrix4x4();
			
			include 'Matrix4x4_static_invert.define';
			
			if (success) {
				return opMatrix;
			} else {
				return null;
			}
		}
		public function decomposition(rotation:Matrix4x4, scale:Float3):void {
			rotation.m00 = m00;
			rotation.m01 = m01;
			rotation.m02 = m02;
			rotation.m03 = 1;
			
			var len:Number = m00 * m00 + m01 * m01 + m02 * m02;
			if (len != 1 && len != 0) {
				len = Math.sqrt(len);
				
				rotation.m00 /= len;
				rotation.m01 /= len;
				rotation.m02 /= len;
			}
			
			var dot:Number = rotation.m00 * m10 + rotation.m01 * m11 + rotation.m02 * m12;
			rotation.m10 = m10 - rotation.m00 * dot;
			rotation.m11 = m11 - rotation.m01 * dot;
			rotation.m12 = m12 - rotation.m02 * dot;
			
			len = rotation.m10 * rotation.m10 + rotation.m11 * rotation.m11 + rotation.m12 * rotation.m12;
			if (len != 1 && len != 0) {
				len = Math.sqrt(len);
				
				rotation.m10 /= len;
				rotation.m11 /= len;
				rotation.m12 /= len;
			}
			
			dot = rotation.m00 * m20 + rotation.m01 * m21 + rotation.m02 * m22;
			rotation.m20 = m20 - rotation.m00 * dot;
			rotation.m21 = m21 - rotation.m01 * dot;
			rotation.m22 = m22 - rotation.m02 * dot;
			
			dot = rotation.m10 * m20 + rotation.m11 * m21 + rotation.m12 * m22;
			rotation.m20 -= rotation.m10 * dot;
			rotation.m21 -= rotation.m11 * dot;
			rotation.m22 -= rotation.m12 * dot;
			
			len = rotation.m20 * m20 + rotation.m21 * m21 + rotation.m22 * m22;
			if (len != 1 && len != 0) {
				len = Math.sqrt(len);
				
				rotation.m20 /= len;
				rotation.m21 /= len;
				rotation.m22 /= len;
			}
			
			dot = rotation.m00 * rotation.m11 * rotation.m22 + 
				rotation.m10 * rotation.m21 * rotation.m02 + 
				rotation.m20 * rotation.m01 * rotation.m12 - 
				rotation.m20 * rotation.m11 * rotation.m02 -
				rotation.m10 * rotation.m01 * rotation.m22 -
				rotation.m00 * rotation.m21 * rotation.m12;
			
			if (dot < 0) {
				rotation.m00 = -rotation.m00;
				rotation.m01 = -rotation.m01;
				rotation.m02 = -rotation.m02;
				rotation.m10 = -rotation.m10;
				rotation.m11 = -rotation.m11;
				rotation.m12 = -rotation.m12;
				rotation.m20 = -rotation.m20;
				rotation.m21 = -rotation.m21;
				rotation.m22 = -rotation.m22;
			}
			
			scale.x = rotation.m00 * m00 + rotation.m01 * m01 + rotation.m02 * m02;
			scale.y = rotation.m10 * m10 + rotation.m11 * m11 + rotation.m12 * m12;
			scale.z = rotation.m20 * m20 + rotation.m21 * m21 + rotation.m22 * m22;
		}
		public function getAxisX(op:Float3=null):Float3 {
			if (op == null) {
				return new Float3(m00, m01, m02);
			} else {
				op.x = m00;
				op.y = m01;
				op.z = m02;
				return op;
			}
		}
		public function setAxisX(x:Number, y:Number, z:Number):void {
			m00 = x;
			m01 = y;
			m02 = z;
		}
		public function getAxisY(op:Float3=null):Float3 {
			if (op == null) {
				return new Float3(m10, m11, m12);
			} else {
				op.x = m10;
				op.y = m11;
				op.z = m12;
				return op;
			}
		}
		public function setAxisY(x:Number, y:Number, z:Number):void {
			m10 = x;
			m11 = y;
			m12 = z;
		}
		public function getAxisZ(op:Float3=null):Float3 {
			if (op == null) {
				return new Float3(m20, m21, m22);
			} else {
				op.x = m20;
				op.y = m21;
				op.z = m22;
				return op;
			}
		}
		public function setAxisZ(x:Number, y:Number, z:Number):void {
			m20 = x;
			m21 = y;
			m22 = z;
		}
		public function getLocation(op:Float3=null):Float3 {
			if (op == null) {
				return new Float3(m30, m31, m32);
			} else {
				op.x = m30;
				op.y = m31;
				op.z = m32;
				return op;
			}
		}
		public function setLocation(tx:Number=0, ty:Number=0, tz:Number=0):void {
			m30 = tx;
			m31 = ty;
			m32 = tz;
		}
		public function setLocationFromFloat3(f3:Float3):void {
			m30 = f3.x;
			m31 = f3.y;
			m32 = f3.z;
		}
		public function addFromMatrix4x4(m:Matrix4x4):void {
			m00 += m.m00;
			m01 += m.m01;
			m02 += m.m02;
			m03 += m.m03;
			
			m10 += m.m10;
			m11 += m.m11;
			m12 += m.m12;
			m13 += m.m13;
			
			m20 += m.m20;
			m21 += m.m21;
			m22 += m.m22;
			m23 += m.m23;
			
			m30 += m.m30;
			m31 += m.m31;
			m32 += m.m32;
			m33 += m.m33;
		}
		/**
		 * lm ~~ this<br>
		 * result = this -> lm;
		 */
		public function append4x4(lm:Matrix4x4):void {
			include 'Matrix4x4_append4x4.define';
		}
		public function appendRotationX(radian:Number):void {
			include 'Matrix4x4_appendRotationX.define';
		}
		public function appendRotationY(radian:Number):void {
			include 'Matrix4x4_appendRotationY.define';
		}
		public function appendRotationZ(radian:Number):void {
			include 'Matrix4x4_appendRotationZ.define';
		}
		public function appendScale(sx:Number, sy:Number, sz:Number):void {
			m00 *= sx;
			m01 *= sy;
			m02 *= sz;
			
			m10 *= sx;
			m11 *= sy;
			m12 *= sz;
			
			m20 *= sx;
			m21 *= sy;
			m22 *= sz;
		}
		public function appendTranslation(x:Number, y:Number, z:Number):void {
			include 'Matrix4x4_appendTranslation.define';
		}
		public function clone(opMatrix:Matrix4x4=null):Matrix4x4 {
			include 'Matrix4x4_clone.define';
			
			return opMatrix;
		}
		public function copyDataFromBytes3x4(bytes:ByteArray):void {
			m00 = bytes.readFloat();
			m01 = bytes.readFloat();
			m02 = bytes.readFloat();
			m10 = bytes.readFloat();
			m11 = bytes.readFloat();
			m12 = bytes.readFloat();
			m20 = bytes.readFloat();
			m21 = bytes.readFloat();
			m22 = bytes.readFloat();
			m30 = bytes.readFloat();
			m31 = bytes.readFloat();
			m32 = bytes.readFloat();
		}
		public function copyDataFromBytes4x4(bytes:ByteArray):void {
			m00 = bytes.readFloat();
			m01 = bytes.readFloat();
			m02 = bytes.readFloat();
			m03 = bytes.readFloat();
			m10 = bytes.readFloat();
			m11 = bytes.readFloat();
			m12 = bytes.readFloat();
			m13 = bytes.readFloat();
			m20 = bytes.readFloat();
			m21 = bytes.readFloat();
			m22 = bytes.readFloat();
			m23 = bytes.readFloat();
			m30 = bytes.readFloat();
			m31 = bytes.readFloat();
			m32 = bytes.readFloat();
			m33 = bytes.readFloat();
		}
		public function copyDataFromMatrix3D(m:Matrix3D):void {
			var v:Vector.<Number> = m.rawData;
			m00 = v[0];
			m01 = v[1];
			m02 = v[2];
			m03 = v[3];
			m10 = v[4];
			m11 = v[5];
			m12 = v[6];
			m13 = v[7];
			m20 = v[8];
			m21 = v[9];
			m22 = v[10];
			m23 = v[11];
			m30 = v[12];
			m31 = v[13];
			m32 = v[14];
			m33 = v[15];
		}
		public function copyDataFromMatrix3x4(sm:Matrix4x4):void {
			include 'Matrix4x4_copyDataFromMatrix3x4.define';
		}
		public function copyDataFromMatrix4x4(sm:Matrix4x4):void {
			include 'Matrix4x4_copyDataFromMatrix4x4.define';
		}
		public function copyDataFromVector(v:Vector.<Number>, transpose:Boolean=false):void {
			if (transpose) {
				m00 = v[0];
				m10 = v[1];
				m20 = v[2];
				m30 = v[3];
				m01 = v[4];
				m11 = v[5];
				m21 = v[6];
				m31 = v[7];
				m02 = v[8];
				m12 = v[9];
				m22 = v[10];
				m32 = v[11];
				m03 = v[12];
				m13 = v[13];
				m23 = v[14];
				m33 = v[15];
			} else {
				m00 = v[0];
				m01 = v[1];
				m02 = v[2];
				m03 = v[3];
				m10 = v[4];
				m11 = v[5];
				m12 = v[6];
				m13 = v[7];
				m20 = v[8];
				m21 = v[9];
				m22 = v[10];
				m23 = v[11];
				m30 = v[12];
				m31 = v[13];
				m32 = v[14];
				m33 = v[15];
			}
		}
		public function equals(m:Matrix4x4):Boolean {
			return m00 == m.m00 && m01 == m.m01 && m02 == m.m02 && m03 == m.m03 &&
				   m10 == m.m10 && m11 == m.m11 && m12 == m.m12 && m13 == m.m13 &&
				   m20 == m.m20 && m21 == m.m21 && m22 == m.m22 && m23 == m.m23 &&
				   m30 == m.m30 && m31 == m.m31 && m32 == m.m32 && m33 == m.m33;
		}
		public function getElement(row:uint, column:uint):Number {
			if (row == 0) {
				if (column == 0) {
					return m00;
				} else if (column == 1) {
					return m01;
				} else if (column == 2) {
					return m02;
				} else if (column == 3) {
					return m03;
				} else {
					return NaN;
				}
			} else if (row == 1) {
				if (column == 0) {
					return m10;
				} else if (column == 1) {
					return m11;
				} else if (column == 2) {
					return m12;
				} else if (column == 3) {
					return m13;
				} else {
					return NaN;
				}
			} else if (row == 2) {
				if (column == 0) {
					return m20;
				} else if (column == 1) {
					return m21;
				} else if (column == 2) {
					return m22;
				} else if (column == 3) {
					return m23;
				} else {
					return NaN;
				}
			} else if (row == 3) {
				if (column == 0) {
					return m30;
				} else if (column == 1) {
					return m31;
				} else if (column == 2) {
					return m32;
				} else if (column == 3) {
					return m33;
				} else {
					return NaN;
				}
			} else {
				return NaN;
			}
		}
		public function setElement(row:uint, column:uint, value:Number):void {
			if (row == 0) {
				if (column == 0) {
					m00 = value;
				} else if (column == 1) {
					m01 = value;
				} else if (column == 2) {
					m02 = value;
				} else if (column == 3) {
					m03 = value;
				}
			} else if (row == 1) {
				if (column == 0) {
					m10 = value;
				} else if (column == 1) {
					m11 = value;
				} else if (column == 2) {
					m12 = value;
				} else if (column == 3) {
					m13 = value;
				}
			} else if (row == 2) {
				if (column == 0) {
					m20 = value;
				} else if (column == 1) {
					m21 = value;
				} else if (column == 2) {
					m22 = value;
				} else if (column == 3) {
					m23 = value;
				}
			} else if (row == 3) {
				if (column == 0) {
					m30 = value;
				} else if (column == 1) {
					m31 = value;
				} else if (column == 2) {
					m32 = value;
				} else if (column == 3) {
					m33 = value;
				}
			}
		}
		public function getQuaternion(opFloat4:Float4=null):Float4 {
			include 'Matrix4x4_getQuaternion.define';
			
			return opFloat4;
		}
		/*
		public function getQuaternion2():Float4 {
			var op:Float4 = new Float4();
			
			var tq:Array = [];
			tq[0] = 1 + m00 + m11 + m22;
			tq[1] = 1 + m00 + m11 - m22;
			tq[2] = 1 - m00 + m11 - m22;
			tq[3] = 1 - m00 - m11 + m22;
			
			var j:int = 0;
			
			for (var i:int = 0; i < 4; i++) {
				if (tq[i] > tq[j]) j = i;
			}
				
			if (j == 0) {
				op.w = tq[0];
				op.x = m12 - m21;
				op.y = m20 - m02;
				op.z = m01 - m10;
			} else if (j == 1) {
				op.w = m12 - m21;
				op.x = tq[1];
				op.y = m01 - m10;
				op.z = m20 - m02;
			} else if (j == 2) {
				op.w = m20 - m02;
				op.x = m01 - m10;
				op.y = tq[2];
				op.z = m12 - m21;
			} else {
				op.w = m01 - m10;
				op.x = m20 - m02;
				op.y = m12 - m21;
				op.z = tq[3];
			}
			
			var s:Number = Math.sqrt(0.25 / tq[j]);
			
			op.w *= s;
			op.x *= s;
			op.y *= s;
			op.z *= s;
			
			return op;
		}
		*/
		public function identity():void {
			include 'Matrix4x4_identity.define';
		}
		/**
		 * no scale
		 * 
		 * @param t the t is 0-1.
		 */
		public static function slerp(m0:Matrix4x4, m1:Matrix4x4, t:Number, op:Matrix4x4=null):Matrix4x4 {
			if (t < 0) {
				t = 0;
			} else if (t > 1) {
				t = 1;
			}
			
			var q0:Float4 = _tempFloat4_1;
			var q1:Float4 = _tempFloat4_2;
			
			var m:Matrix4x4 = m1;
			var opFloat4:Float4 = q1;
			
			include 'Matrix4x4_getQuaternion.define';
			
			m = m0;
			opFloat4 = q0;
			
			include 'Matrix4x4_getQuaternion.define';
			
			include 'Float4_slerpQuaternion.define';
			
			var f4:Float4 = q0;
			var opMatrix:Matrix4x4 = op;
			
			include 'Float4_getMatrixFromQuaternion.define';
			
			var d:Number = m1.m30 - m0.m30;
			op.m30 = m0.m30 + d * t;
			d = m1.m31 - m0.m31;
			op.m31 = m0.m31 + d * t;
			d = m1.m32 - m0.m32;
			op.m32 = m0.m32 + d * t;
			
			return op;
		}
		public function invert():Boolean {
			include 'Matrix4x4_invert.define';
			
			return success;
		}
		public function multiplyFromMatrix4x4(m:Matrix4x4):void {
			m00 *= m.m00;
			m01 *= m.m01;
			m02 *= m.m02;
			m03 *= m.m03;
			
			m10 *= m.m10;
			m11 *= m.m11;
			m12 *= m.m12;
			m13 *= m.m13;
			
			m20 *= m.m20;
			m21 *= m.m21;
			m22 *= m.m22;
			m23 *= m.m23;
			
			m30 *= m.m30;
			m31 *= m.m31;
			m32 *= m.m32;
			m33 *= m.m33;
		}
		public function multiplyFromNumber(value:Number):void {
			m00 *= value;
			m01 *= value;
			m02 *= value;
			m03 *= value;
			
			m10 *= value;
			m11 *= value;
			m12 *= value;
			m13 *= value;
			
			m20 *= value;
			m21 *= value;
			m22 *= value;
			m23 *= value;
			
			m30 *= value;
			m31 *= value;
			m32 *= value;
			m33 *= value;
		}
		/**
		 * this ~~ rm<br>
		 * result = rm -> this
		 */
		public function prepend4x4(rm:Matrix4x4):void {
			include 'Matrix4x4_prepend4x4.define';
		}
		/**
		 * local ratate
		 */
		public function prependRotationX(radian:Number):void {
			include 'Matrix4x4_prependRotationX.define';
		}
		/**
		 * local ratate
		 */
		public function prependRotationY(radian:Number):void {
			include 'Matrix4x4_prependRotationY.define';
		}
		/**
		 * local ratate
		 */
		public function prependRotationZ(radian:Number):void {
			include 'Matrix4x4_prependRotationZ.define';
		}
		/**
		 * local scale
		 */
		public function prependScale(sx:Number=1, sy:Number=1, sz:Number=1):void {
			include 'Matrix4x4_prependScale.define';
		}
		/**
		 * local translation
		 */
		public function prependTranslation(x:Number, y:Number, z:Number):void {
			include 'Matrix4x4_prependTranslation.define';
		}
		/**
		 * local translation
		 */
		public function prependTranslationX(x:Number):void {
			include 'Matrix4x4_prependTranslationX.define';
		}
		/**
		 * local translation
		 */
		public function prependTranslationY(y:Number):void {
			include 'Matrix4x4_prependTranslationY.define';
		}
		/**
		 * local translation
		 */
		public function prependTranslationZ(z:Number):void {
			include 'Matrix4x4_prependTranslationZ.define';
		}
		public function toMatrix3D(transpose:Boolean=false, op:Matrix3D=null):Matrix3D {
			if (op == null) op = new Matrix3D();
			var raw:Vector.<Number> = op.rawData;
			raw = this.toVector4x4(transpose, raw);
			op.rawData = raw;
			return op;
		}
		public function toString():String {
			return 'matrix4x4 (\n' + 
				   ' ' + m00 + ', ' + m01 + ', ' + m02 + ', ' + m03 + '\n' +
				   ' ' + m10 + ', ' + m11 + ', ' + m12 + ', ' + m13 + '\n' +
				   ' ' + m20 + ', ' + m21 + ', ' + m22 + ', ' + m23 + '\n' +
				   ' ' + m30 + ', ' + m31 + ', ' + m32 + ', ' + m33 + '\n' +
				   ')';
		}
		public function toVector3x4(transpose:Boolean=false, op:Vector.<Number>=null):Vector.<Number> {
			if (op == null) {
				op = new Vector.<Number>(12);
			} else if (op.length != 12) {
				if (op.fixed) {
					if (op.length < 12) return null;
				} else {
					op.length = 12;
				}
			}
			
			if (transpose) {
				op[0] = m00;
				op[1] = m10;
				op[2] = m20;
				op[3] = m30;
				op[4] = m01;
				op[5] = m11;
				op[6] = m21;
				op[7] = m31;
				op[8] = m02;
				op[9] = m12;
				op[10] = m22;
				op[11] = m32;
			} else {
				op[0] = m00;
				op[1] = m01;
				op[2] = m02;
				op[3] = m10;
				op[4] = m11;
				op[5] = m12;
				op[6] = m20;
				op[7] = m21;
				op[8] = m22;
				op[9] = m30;
				op[10] = m31;
				op[11] = m32;
			}
			return op;
		}
		public function toVector4x4(transpose:Boolean=false, op:Vector.<Number>=null):Vector.<Number> {
			if (op == null) {
				op = new Vector.<Number>(16);
			} else if (op.length != 16) {
				if (op.fixed) {
					if (op.length < 16) return null;
				} else {
					op.length = 16;
				}
			}
			
			if (transpose) {
				op[0] = m00;
				op[1] = m10;
				op[2] = m20;
				op[3] = m30;
				op[4] = m01;
				op[5] = m11;
				op[6] = m21;
				op[7] = m31;
				op[8] = m02;
				op[9] = m12;
				op[10] = m22;
				op[11] = m32;
				op[12] = m03;
				op[13] = m13;
				op[14] = m23;
				op[15] = m33;
			} else {
				op[0] = m00;
				op[1] = m01;
				op[2] = m02;
				op[3] = m03;
				op[4] = m10;
				op[5] = m11;
				op[6] = m12;
				op[7] = m13;
				op[8] = m20;
				op[9] = m21;
				op[10] = m22;
				op[11] = m23;
				op[12] = m30;
				op[13] = m31;
				op[14] = m32;
				op[15] = m33;
			}
			return op;
		}
		public function transform3x3Float3(f3:Float3, opFloat3:Float3=null):Float3 {
			include 'Matrix4x4_transform3x3Float3.define';
			
			return opFloat3;
		}
		public function transform3x3Vector3(v:Vector.<Number>, op:Vector.<Number>=null):Vector.<Number> {
			var length:int = v.length;
			
			if (op == null) {
				op = new Vector.<Number>(length);
			} else if (op.length != length) {
				if (op.fixed) {
					if (op.length < length) return null;
				} else {
					op.length = length;
				}
			}
			
			var index:int = 0;
			
			for (var i:int = 0; i<length; i += 3) {
				var x0:Number = v[i];
				var y0:Number = v[int(i + 1)];
				var z0:Number = v[int(i + 2)];
				
				op[index++] = x0 * m00 + y0 * m10 + z0 * m20;
				op[index++] = x0 * m01 + y0 * m11 + z0 * m21;
				op[index++] = x0 * m02 + y0 * m12 + z0 * m22;
			}
			
			return op;
		}
		public function transform3x4Float3(f3:Float3, opFloat3:Float3=null):Float3 {
			include 'Matrix4x4_transform3x4Float3.define';
			
			return opFloat3;
		}
		public function transform3x4Vector3(v:Vector.<Number>, op:Vector.<Number>=null):Vector.<Number> {
			var length:int = v.length;
			
			if (op == null) {
				op = new Vector.<Number>(length);
			} else if (op.length != length) {
				if (op.fixed) {
					if (op.length < length) return null;
				} else {
					op.length = length;
				}
			}
			
			var index:int = 0;
			
			for (var i:int = 0; i<length; i += 3) {
				var x0:Number = v[i];
				var y0:Number = v[int(i + 1)];
				var z0:Number = v[int(i + 2)];
				
				op[index++] = x0 * m00 + y0 * m10 + z0 * m20 + m30;
				op[index++] = x0 * m01 + y0 * m11 + z0 * m21 + m31;
				op[index++] = x0 * m02 + y0 * m12 + z0 * m22 + m32;
			}
			
			return op;
		}
		public function transform4x4Float3(f3:Float3, op:Float3=null):Float3 {
			var w:Number = f3.x * m03 + f3.y * m13 + f3.z * m23 + m33;
			if (op == null) {
				return new Float3((f3.x * m00 + f3.y * m10 + f3.z * m20 + m30) / w, 
								  (f3.x * m01 + f3.y * m11 + f3.z * m21 + m31) / w, 
								  (f3.x * m02 + f3.y * m12 + f3.z * m22 + m32) / w);
			} else {
				var x:Number = f3.x * m00 + f3.y * m10 + f3.z * m20 + m30;
				var y:Number = f3.x * m01 + f3.y * m11 + f3.z * m21 + m31;
				var z:Number = f3.x * m02 + f3.y * m12 + f3.z * m22 + m32;
				
				op.x = x / w;
				op.y = y / w;
				op.z = z / w;
				return op;
			}
		}
		public function transform4x4Float4(f4:Float4, op:Float4=null):Float4 {
			if (op == null) {
				return new Float4(f4.x * m00 + f4.y * m10 + f4.z * m20 + f4.w * m30, 
								  f4.x * m01 + f4.y * m11 + f4.z * m21 + f4.w * m31, 
								  f4.x * m02 + f4.y  *m12 + f4.z * m22 + f4.w * m32, 
								  f4.x * m03 + f4.y * m13 + f4.z * m23 + f4.w * m33);
			} else {
				var x:Number = f4.x * m00 + f4.y * m10 + f4.z * m20 + f4.w * m30;
				var y:Number = f4.x * m01 + f4.y * m11 + f4.z * m21 + f4.w * m31;
				var z:Number = f4.x * m02 + f4.y * m12 + f4.z * m22 + f4.w * m32;
				var w:Number = f4.x * m03 + f4.y * m13 + f4.z * m23 + f4.w * m33;
				
				op.x = x;
				op.y = y;
				op.z = z;
				op.w = w;
				return op;
			}
		}
		public function transform4x4Number3(x:Number, y:Number, z:Number, op:Float3=null):Float3 {
			var w:Number = x * m03 + y * m13 + z * m23 + m33;
			if (op == null) {
				return new Float3((x * m00 + y * m10 + z * m20 + m30) / w, 
								  (x * m01 + y * m11 + z * m21 + m31) / w, 
								  (x * m02 + y * m12 + z * m22 + m32) / w);
			} else {
				op.x = (x * m00 + y * m10 + z * m20 + m30) / w;
				op.y = (x * m01 + y * m11 + z * m21 + m31) / w;
				op.z = (x * m02 + y * m12 + z * m22 + m32) / w;
				return op;
			}
		}
		public function transform4x4Vector3(v:Vector.<Number>, op:Vector.<Number>=null):Vector.<Number> {
			var length:int = v.length;
			
			var max:int = length * 3;
			
			if (op == null) {
				op = new Vector.<Number>(max);
			} else if (op.length != max) {
				if (op.fixed) {
					if (op.length < max) return null;
				} else {
					op.length = max;
				}
			}
			
			var index:int = 0;
			
			for (var i:int = 0; i < length; i += 3) {
				var x0:Number = v[i];
				var y0:Number = v[int(i + 1)];
				var z0:Number = v[int(i + 2)];
				
				op[index++] = x0 * m00 + y0 * m10 + z0 * m20 + m30;
				op[index++] = x0 * m01 + y0 * m11 + z0 * m21 + m31;
				op[index++] = x0 * m02 + y0 * m12 + z0 * m22 + m32;
			}
			return op;
		}
		public function transform4x4Vector4(v:Vector.<Number>, op:Vector.<Number>=null):Vector.<Number> {
			var length:int = v.length;
			
			var max:int = length * 4;
			
			if (op == null) {
				op = new Vector.<Number>(max);
			} else if (op.length != max) {
				if (op.fixed) {
					if (op.length < max) return null;
				} else {
					op.length = max;
				}
			}
			
			var index:int = 0;
			
			for (var i:int = 0; i < length; i += 4) {
				var x0:Number = v[i];
				var y0:Number = v[int(i + 1)];
				var z0:Number = v[int(i + 2)];
				var w0:Number = v[int(i + 3)];
				
				op[index++] = x0 * m00 + y0 * m10 + z0 * m20 + w0 * m30;
				op[index++] = x0 * m01 + y0 * m11 + z0 * m21 + w0 * m31;
				op[index++] = x0 * m02 + y0 * m12 + z0 * m22 + w0 * m32;
				op[index++] = x0 * m03 + y0 * m13 + z0 * m23 + w0 * m33;
			}
			return op;
		}
		/**
		 * transform axisY and axisZ
		 */
		public function transformLRH():void {
			var temp:Number = m10;
			m10 = m20;
			m20 = temp;
			
			temp = m01;
			m01 = m02;
			m02 = temp;
			
			temp = m11;
			m11 = m22;
			m22 = temp;
			
			temp = m21;
			m21 = m12;
			m12 = temp;
			
			temp = m31;
			m31 = m32;
			m32 = temp;
		}
		public function transpose():void {
			var n01:Number = m01;
			var n02:Number = m02;
			var n03:Number = m03;
			var n10:Number = m10;
			var n11:Number = m11;
			var n12:Number = m12;
			var n13:Number = m13;
			var n20:Number = m20;
			var n21:Number = m21;
			var n22:Number = m22;
			var n23:Number = m23;
			var n30:Number = m30;
			var n31:Number = m31;
			var n32:Number = m32;
			
			m01 = n10;
			m02 = n20;
			m03 = n30;
			m10 = n01;
			m11 = n11;
			m12 = n21;
			m13 = n31;
			m20 = n02;
			m21 = n12;
			m22 = n22;
			m23 = n32;
			m30 = n03;
			m31 = n13;
			m32 = n23;
		}
	}
}