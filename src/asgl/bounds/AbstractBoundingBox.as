package asgl.bounds {
	import asgl.asgl_protected;
	import asgl.math.Float3;
	import asgl.math.Matrix4x4;
	import asgl.physics.Ray;
	
	use namespace asgl_protected;
	
	/**
	 * AxisAlignedBoundingBox and OrientedBoundingBox
	 */
	
	public class AbstractBoundingBox extends BoundingVolume {
		private static var _tempVertices:Vector.<Number> = new Vector.<Number>();
		
		public var maxX:Number;
		public var maxY:Number;
		public var maxZ:Number;
		public var minX:Number;
		public var minY:Number;
		public var minZ:Number;
		
		public function AbstractBoundingBox(minX:Number=0, maxX:Number=0, minY:Number=0, maxY:Number=0, minZ:Number=0, maxZ:Number=0) {
			this.minX = minX;
			this.maxX = maxX;
			this.minY = minY;
			this.maxY = maxY;
			this.minZ = minZ;
			this.maxZ = maxZ;
		}
		public function copy(bound:AbstractBoundingBox):void {
			minX = bound.minX;
			maxX = bound.maxX;
			minY = bound.minY;
			maxY = bound.maxY;
			minZ = bound.minZ;
			maxZ = bound.maxZ;
		}
		public override function hitRay(ray:Ray):Boolean {
			var rayOrigin:Float3 = ray.origin;
			var rayDir:Float3 = ray.direction;
			
			if (rayOrigin == null || rayDir == null) return false;
			
			if (rayOrigin.x >= minX && rayOrigin.x <= maxX && rayOrigin.y >= minY && rayOrigin.y <= maxY && rayOrigin.z >= minZ && rayOrigin.z <= maxZ) return true;
			
			var t:Number;
			var ix:Number;
			var iy:Number;
			var iz:Number;
			
			if (rayOrigin.x <= minX && rayDir.x > 0) {
				t = (minX - rayOrigin.x ) / rayDir.x;
				if (t >= 0) {
					iy = rayOrigin.y + rayDir.y * t;
					iz = rayOrigin.z + rayDir.z * t;
					if (iy >= minY && iy <= maxY && iz >= minZ  && iz <= maxZ) return true;
				}
			}
			
			if (rayOrigin.x >= maxX && rayDir.x < 0) {
				t = (maxX - rayOrigin.x ) / rayDir.x;
				if (t >= 0) {
					iy = rayOrigin.y + rayDir.y * t;
					iz = rayOrigin.z + rayDir.z * t;
					if (iy >= minY && iy <= maxY && iz >= minZ  && iz <= maxZ) return true;
				}
			}
			
			if (rayOrigin.y <= minY && rayDir.y > 0) {
				t = (minY - rayOrigin.y ) / rayDir.y;
				if (t >= 0) {
					ix = rayOrigin.x + rayDir.x * t;
					iz = rayOrigin.z + rayDir.z * t;
					if (ix >= minX && ix <= maxX && iz >= minZ  && iz <= maxZ) return true;
				}
			}
			
			if (rayOrigin.y >= maxY && rayDir.y < 0) {
				t = (maxY - rayOrigin.y ) / rayDir.y;
				if (t >= 0) {
					ix = rayOrigin.x + rayDir.x * t;
					iz = rayOrigin.z + rayDir.z * t;
					if (ix >= minX && ix <= maxX && iz >= minZ  && iz <= maxZ) return true;
				}
			}
			
			if (rayOrigin.z <= minZ && rayDir.z > 0) {
				t = (minZ - rayOrigin.z ) / rayDir.z;
				if (t >= 0) {
					ix = rayOrigin.x + rayDir.x * t;
					iy = rayOrigin.y + rayDir.y * t;
					if (ix >= minX && ix <= maxX && iy >= minY  && iy <= maxY) return true;
				}
			}
			
			if (rayOrigin.z >= maxZ && rayDir.z < 0) {
				t = (maxZ - rayOrigin.z ) / rayDir.z;
				if (t >= 0) {
					ix = rayOrigin.x + rayDir.x * t;
					iy = rayOrigin.y + rayDir.y * t;
					if (ix >= minX && ix <= maxX && iy >= minY  && iy <= maxY) return true;
				}
			}
			
			return false;
		}
		public override function intersectRay(ray:Ray):Number {
			var rayOrigin:Float3 = ray.origin;
			var rayDir:Float3 = ray.direction;
			
			if (rayOrigin == null || rayDir == null) return -1;
			
			if (rayOrigin.x >= minX && rayOrigin.x <= maxX && rayOrigin.y >= minY && rayOrigin.y <= maxY && rayOrigin.z >= minZ && rayOrigin.z <= maxZ) return 0;
			
			var t:Number;
			var min:Number = Number.POSITIVE_INFINITY;
			var ix:Number;
			var iy:Number;
			var iz:Number;
			
			if (rayOrigin.x <= minX && rayDir.x > 0) {
				t = (minX - rayOrigin.x ) / rayDir.x;
				if (t >= 0) {
					iy = rayOrigin.y + rayDir.y * t;
					iz = rayOrigin.z + rayDir.z * t;
					if (t < min  && iy >= minY && iy <= maxY && iz >= minZ  && iz <= maxZ) min = t;
				}
			}
			
			if (rayOrigin.x >= maxX && rayDir.x < 0) {
				t = (maxX - rayOrigin.x ) / rayDir.x;
				if (t >= 0) {
					iy = rayOrigin.y + rayDir.y * t;
					iz = rayOrigin.z + rayDir.z * t;
					if (t < min  && iy >= minY && iy <= maxY && iz >= minZ  && iz <= maxZ) min = t;
				}
			}
			
			if (rayOrigin.y <= minY && rayDir.y > 0) {
				t = (minY - rayOrigin.y ) / rayDir.y;
				if (t >= 0) {
					ix = rayOrigin.x + rayDir.x * t;
					iz = rayOrigin.z + rayDir.z * t;
					if (t < min  && ix >= minX && ix <= maxX && iz >= minZ  && iz <= maxZ) min = t;
				}
			}
			
			if (rayOrigin.y >= maxY && rayDir.y < 0) {
				t = (maxY - rayOrigin.y ) / rayDir.y;
				if (t >= 0) {
					ix = rayOrigin.x + rayDir.x * t;
					iz = rayOrigin.z + rayDir.z * t;
					if (t < min  && ix >= minX && ix <= maxX && iz >= minZ  && iz <= maxZ) min = t;
				}
			}
			
			if (rayOrigin.z <= minZ && rayDir.z > 0) {
				t = (minZ - rayOrigin.z ) / rayDir.z;
				if (t >= 0) {
					ix = rayOrigin.x + rayDir.x * t;
					iy = rayOrigin.y + rayDir.y * t;
					if (t < min  && ix >= minX && ix <= maxX && iy >= minY  && iy <= maxY) min = t;
				}
			}
			
			if (rayOrigin.z >= maxZ && rayDir.z < 0) {
				t = (maxZ - rayOrigin.z ) / rayDir.z;
				if (t >= 0) {
					ix = rayOrigin.x + rayDir.x * t;
					iy = rayOrigin.y + rayDir.y * t;
					if (t < min  && ix >= minX && ix <= maxX && iy >= minY  && iy <= maxY) min = t;
				}
			}
			
			return min == Number.POSITIVE_INFINITY ? -1 : min;
		}
		public function updateFromVertices(vertices:Vector.<Number>, m:Matrix4x4=null):void {
			var length:int = vertices.length;
			if (length == 0) {
				minX = 0;
				maxX = 0;
				minY = 0;
				maxY = 0;
				minZ = 0;
				maxZ = 0;
			} else {
				if (m != null) {
					_tempVertices.length = vertices.length;
					vertices = m.transform3x4Vector3(vertices, _tempVertices);
				}
				
				minX = Number.MAX_VALUE;
				maxX = Number.MIN_VALUE;
				minY = minX;
				maxY = maxX;
				minZ = minX;
				maxZ = maxZ;
				for (var i:int = 0; i < length; i += 3) {
					var x:Number = vertices[i];
					var y:Number = vertices[int(i + 1)];
					var z:Number = vertices[int(i + 2)];
					if (minX > x) minX = x;
					if (maxX < x) maxX = x;
					if (minY > y) minY = y;
					if (maxY < y) maxY = y;
					if (minZ > z) minZ = z;
					if (maxZ < z) maxZ = z;
				}
				
				if (m != null) _tempVertices.length = 0;
			}
		}
		public function toString():String {
			return 'boundingBox (minX:'+minX+' '+'maxX:'+maxX+' '+'minY:'+minY+' '+'maxY:'+maxY+' '+'minZ:'+minZ+' '+'maxZ:'+maxZ+')';
		}
	}
}

