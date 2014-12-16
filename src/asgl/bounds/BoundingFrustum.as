package asgl.bounds {
	import asgl.math.Matrix4x4;
	
	public class BoundingFrustum {
		public var leftX:Number;
		public var leftY:Number;
		public var leftZ:Number;
		public var leftW:Number;
		public var rightX:Number;
		public var rightY:Number;
		public var rightZ:Number;
		public var rightW:Number;
		public var farX:Number;
		public var farY:Number;
		public var farZ:Number;
		public var farW:Number;
		public var nearX:Number;
		public var nearY:Number;
		public var nearZ:Number;
		public var nearW:Number;
		public var topX:Number;
		public var topY:Number;
		public var topZ:Number;
		public var topW:Number;
		public var bottomX:Number;
		public var bottomY:Number;
		public var bottomZ:Number;
		public var bottomW:Number;
		
		private var frustum:BoundingFrustum;
		
		public function BoundingFrustum(matrix:Matrix4x4=null) {
			frustum = this;
			
			if (matrix != null) this.setMatrix(matrix);
		}
		/**
		 * @param matrix if test vertex in local space, matrix = world to proj Matrix.</br>
		 * 				 if test vertex in world space, matrix = view to proj Matrix.</br>
		 * 				 if test vertex in view space, matrix = projMatrix.
		 */
		public function setMatrix(matrix:Matrix4x4):void {
			var x:Number = matrix.m03 - matrix.m00;
			var y:Number = matrix.m13 - matrix.m10;
			var z:Number = matrix.m23 - matrix.m20;
			var w:Number = matrix.m33 - matrix.m30;
			var t:Number = Math.sqrt(x * x + y * y + z * z);
			rightX = x / t;
			rightY = y / t;
			rightZ = z / t;
			rightW = w / t;
			
			x = matrix.m03 + matrix.m00;
			y = matrix.m13 + matrix.m10;
			z = matrix.m23 + matrix.m20;
			w = matrix.m33 + matrix.m30;
			t = Math.sqrt(x * x + y * y + z * z);
			leftX = x / t;
			leftY = y / t;
			leftZ = z / t;
			leftW = w / t;
			
			x = matrix.m03 - matrix.m01;
			y = matrix.m13 - matrix.m11;
			z = matrix.m23 - matrix.m21;
			w = matrix.m33 - matrix.m31;
			t = Math.sqrt(x * x + y * y + z * z);
			topX = x / t;
			topY = y / t;
			topZ = z / t;
			topW = w / t;
			
			x = matrix.m03 + matrix.m01;
			y = matrix.m13 + matrix.m11;
			z = matrix.m23 + matrix.m21;
			w = matrix.m33 + matrix.m31;
			t = Math.sqrt(x * x + y * y + z * z);
			bottomX = x / t;
			bottomY = y / t;
			bottomZ = z / t;
			bottomW = w / t;
			
			x = matrix.m03 - matrix.m02;
			y = matrix.m13 - matrix.m12;
			z = matrix.m23 - matrix.m22;
			w = matrix.m33 - matrix.m32;
			t = Math.sqrt(x * x + y * y + z * z);
			farX = x / t;
			farY = y / t;
			farZ = z / t;
			farW = w / t;
			
			x = matrix.m03 + matrix.m02;
			y = matrix.m13 + matrix.m12;
			z = matrix.m23 + matrix.m22;
			w = matrix.m33 + matrix.m32;
			t = Math.sqrt(x * x + y * y + z * z);
			nearX = x / t;
			nearY = y / t;
			nearZ = z / t;
			nearW = w / t;
		}
		public function isBoxInFrustum(minX:Number, maxX:Number, minY:Number, maxY:Number, minZ:Number, maxZ:Number):int {
			include 'BoundingFrustum_isBoxInFrustum.define';
			
			return state;
		}
		public function pointToRightDistance(x:Number, y:Number, z:Number):Number {
			return rightX * x + rightY * y + rightZ * z + rightW;
		}
		public function pointToLeftDistance(x:Number, y:Number, z:Number):Number {
			return leftX * x + leftY * y + leftZ * z + leftW;
		}
		public function pointToTopDistance(x:Number, y:Number, z:Number):Number {
			return topX * x + topY * y + topZ * z + topW;
		}
		public function pointToBottomDistance(x:Number, y:Number, z:Number):Number {
			return bottomX * x + bottomY * y + bottomZ * z + bottomW;
		}
		public function pointToFarDistance(x:Number, y:Number, z:Number):Number {
			return farX * x + farY * y + farZ * z + farW;
		}
		public function pointToNearDistance(x:Number, y:Number, z:Number):Number {
			return nearX * x + nearY * y + nearZ * z + nearW;
		}
		public function isPointInFrustum(x:Number, y:Number, z:Number):Boolean {
			if (rightX * x + rightY * y + rightZ * z + rightW <= 0) {
				return false;
			} else if (leftX * x + leftY * y + leftZ * z + leftW <= 0) {
				return false;
			} else if (topX * x + topY * y + topZ * z + topW <= 0) {
				return false;
			} else if (bottomX * x + bottomY * y + bottomZ * z + bottomW <= 0) {
				return false;
			} else if (farX * x + farY * y + farZ * z + farW <= 0) {
				return false;
			} else if (nearX * x + nearY * y + nearZ * z + nearW <= 0) {
				return false;
			}
			
			return true;
		}
		public function isPolygonInFrustum(vertices:Vector.<Number>):Boolean {
			var length:int = vertices.length;
			for (var i:int = 0; i < length; i += 3) {
				if (rightX * vertices[i] + rightY * vertices[int(i + 1)] + rightZ * vertices[int(i + 2)] + vertices[int(i + 3)] > 0) break;
			}
			if (i == length) return false;
			
			for (i = 0; i < length; i += 3) {
				if (leftX * vertices[i] + leftY * vertices[int(i + 1)] + leftZ * vertices[int(i + 2)] + vertices[int(i + 3)] > 0) break;
			}
			if (i == length) return false;
			
			for (i = 0; i < length; i += 3) {
				if (topX * vertices[i] + topY * vertices[int(i + 1)] + topZ * vertices[int(i + 2)] + vertices[int(i + 3)] > 0) break;
			}
			if (i == length) return false;
			
			for (i = 0; i < length; i += 3) {
				if (bottomX * vertices[i] + bottomY * vertices[int(i + 1)] + bottomZ * vertices[int(i + 2)] + vertices[int(i + 3)] > 0) break;
			}
			if (i == length) return false;
			
			for (i = 0; i < length; i += 3) {
				if (farX * vertices[i] + farY * vertices[int(i + 1)] + farZ * vertices[int(i + 2)] + vertices[int(i + 3)] > 0) break;
			}
			if (i == length) return false;
			
			for (i = 0; i < length; i += 3) {
				if (nearX * vertices[i] + nearY * vertices[int(i + 1)] + nearZ * vertices[int(i + 2)] + vertices[int(i + 3)] > 0) break;
			}
			if (i == length) return false;
			
			return true;
		}
		public function isSphereInFrustum(x:Number, y:Number, z:Number, radius:Number):int {
			var state:int = 0;
			var side:int = 0;
			
			var d:Number = rightX * x + rightY * y + rightZ * z + rightW;
			if (d > -radius) {
				if (d>radius) side++;
				d = leftX * x + leftY * y + leftZ * z + leftW;
				if (d > -radius) {
					if (d>radius) side++;
					d = topX * x + topY * y + topZ * z + topW;
					if (d > -radius) {
						if (d>radius) side++;
						d = bottomX * x + bottomY * y + bottomZ * z + bottomW;
						if (d > -radius) {
							if (d>radius) side++;
							d = farX * x + farY * y + farZ * z + farW;
							if (d > -radius) {
								if (d>radius) side++;
								d = nearX * x + nearY * y + nearZ * z + nearW;
								if (d > -radius && d>radius) side++;
							}
						}
					}
				}
			}
			
			if (side > 0) {
				if (side == 6) {
					state = 2;
				} else {
					state = 1;
				}
			}
			
			return state;
		}
		public function toString():String {
			return 'left  :' + leftX + ' ' + leftY + ' ' + leftZ + ' ' + leftW + '\n' +
				   'right :' + rightX + ' ' + rightY + ' ' + rightZ + ' ' + rightW + '\n' +
				   'top   :' + topX + ' ' + topY + ' ' + topZ + ' ' + topW + '\n' +
				   'bottom:' + bottomX + ' ' + bottomY + ' ' + bottomZ + ' ' + bottomW + '\n' +
				   'near  :' + nearX + ' ' + nearY + ' ' + nearZ + ' ' + nearW + '\n' +
				   'far   :' + farX + ' ' + farY + ' ' + farZ + ' ' + farW;
		}
	}
}