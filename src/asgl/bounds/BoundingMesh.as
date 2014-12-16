package asgl.bounds {
	import asgl.asgl_protected;
	import asgl.geometries.MeshAsset;
	import asgl.geometries.MeshElementType;
	import asgl.math.Float3;
	import asgl.physics.Ray;
	
	use namespace asgl_protected;

	public class BoundingMesh extends BoundingVolume {
		public var asset:MeshAsset;
		
		public function BoundingMesh(asset:MeshAsset) {
			_type = BoundingVolumeType.MESH;
			
			this.asset = asset;
		}
		public override function hitRay(ray:Ray):Boolean {
			var rayOrigin:Float3 = ray.origin;
			var rayDir:Float3 = ray.direction;
			
			var vertices:Vector.<Number> = asset.getElement(MeshElementType.VERTEX).values;
			var indices:Vector.<uint> = asset.triangleIndices;
			
			if (rayOrigin == null || rayDir == null || vertices == null || indices == null) return false;
			
			var length:int = indices.length;
			for (var i:int = 0; i < length; i++) {
				var i0:int = indices[i++] * 3;
				var i1:int = indices[i++] * 3;
				var i2:int = indices[i] * 3;
				
				var v0x:Number = vertices[i0];
				var v0y:Number = vertices[int(i0 + 1)];
				var v0z:Number = vertices[int(i0 + 2)];
				
				var v1x:Number = vertices[i1];
				var v1y:Number = vertices[int(i1 + 1)];
				var v1z:Number = vertices[int(i1 + 2)];
				
				var v2x:Number = vertices[i2];
				var v2y:Number = vertices[int(i2 + 1)];
				var v2z:Number = vertices[int(i2 + 2)];
				
				var edge1x:Number = v1x - v0x;
				var edge1y:Number = v1y - v0y;
				var edge1z:Number = v1z - v0z;
				
				var edge2x:Number = v2x - v0x;
				var edge2y:Number = v2y - v0y;
				var edge2z:Number = v2z - v0z;
				
				var pvecx:Number = rayDir.y * edge2z - rayDir.z * edge2y;
				var pvecy:Number = rayDir.z * edge2x - rayDir.x * edge2z;
				var pvecz:Number = rayDir.x * edge2y - rayDir.y * edge2x;
				
				var det:Number = edge1x * pvecx + edge1y * pvecy + edge1z * pvecz;
				
				var tvecx:Number;
				var tvecy:Number;
				var tvecz:Number;
				
				if (det > 0) {
					tvecx = rayOrigin.x - v0x;
					tvecy = rayOrigin.y - v0y;
					tvecz = rayOrigin.z - v0z;
				} else {
					tvecx = v0x - rayOrigin.x;
					tvecy = v0y - rayOrigin.y;
					tvecz = v0z - rayOrigin.z;
					
					det = -det;
				}
				
				var t:Number = NaN;
				
				if (det < 0.0001) {
					//return
				} else {
					var u:Number = tvecx * pvecx + tvecy * pvecy + tvecz * pvecz;
					
					if (u < 0 || u>det) {
						//return
					} else {
						var qvecx:Number = tvecy * edge1z - tvecz * edge1y;
						var qvecy:Number = tvecz * edge1x - tvecx * edge1z;
						var qvecz:Number = tvecx * edge1y - tvecy * edge1x;
						
						var v:Number = rayDir.x * qvecx + rayDir.y * qvecy + rayDir.z * qvecz;
						
						if (v < 0 || u + v > det) {
							//return
						} else {
							return true;
						}
					}
				}
			}
			
			return false;
		}
		public override function intersectRay(ray:Ray):Number {
			var rayOrigin:Float3 = ray.origin;
			var rayDir:Float3 = ray.direction;
			
			var vertices:Vector.<Number> = asset.getElement(MeshElementType.VERTEX).values;
			var indices:Vector.<uint> = asset.triangleIndices;
			
			if (rayOrigin == null || rayDir == null || vertices == null || indices == null) return -1;
			
			var min:Number = Number.POSITIVE_INFINITY;
			
			var length:int = indices.length;
			for (var i:int = 0; i < length; i++) {
				var i0:int = indices[i++] * 3;
				var i1:int = indices[i++] * 3;
				var i2:int = indices[i] * 3;
				
				var v0x:Number = vertices[i0];
				var v0y:Number = vertices[int(i0 + 1)];
				var v0z:Number = vertices[int(i0 + 2)];
				
				var v1x:Number = vertices[i1];
				var v1y:Number = vertices[int(i1 + 1)];
				var v1z:Number = vertices[int(i1 + 2)];
				
				var v2x:Number = vertices[i2];
				var v2y:Number = vertices[int(i2 + 1)];
				var v2z:Number = vertices[int(i2 + 2)];
				
				var edge1x:Number = v1x - v0x;
				var edge1y:Number = v1y - v0y;
				var edge1z:Number = v1z - v0z;
				
				var edge2x:Number = v2x - v0x;
				var edge2y:Number = v2y - v0y;
				var edge2z:Number = v2z - v0z;
				
				var pvecx:Number = rayDir.y * edge2z - rayDir.z * edge2y;
				var pvecy:Number = rayDir.z * edge2x - rayDir.x * edge2z;
				var pvecz:Number = rayDir.x * edge2y - rayDir.y * edge2x;
				
				var det:Number = edge1x * pvecx + edge1y * pvecy + edge1z * pvecz;
				
				var tvecx:Number;
				var tvecy:Number;
				var tvecz:Number;
				
				if (det > 0) {
					tvecx = rayOrigin.x - v0x;
					tvecy = rayOrigin.y - v0y;
					tvecz = rayOrigin.z - v0z;
				} else {
					tvecx = v0x - rayOrigin.x;
					tvecy = v0y - rayOrigin.y;
					tvecz = v0z - rayOrigin.z;
					
					det = -det;
				}
				
				var t:Number = NaN;
				
				if (det < 0.0001) {
					//return
				} else {
					var u:Number = tvecx * pvecx + tvecy * pvecy + tvecz * pvecz;
					
					if (u < 0 || u>det) {
						//return
					} else {
						var qvecx:Number = tvecy * edge1z - tvecz * edge1y;
						var qvecy:Number = tvecz * edge1x - tvecx * edge1z;
						var qvecz:Number = tvecx * edge1y - tvecy * edge1x;
						
						var v:Number = rayDir.x * qvecx + rayDir.y * qvecy + rayDir.z * qvecz;
						
						if (v < 0 || u + v > det) {
							//return
						} else {
							t = edge2x * qvecx + edge2y * qvecy + edge2z * qvecz;
							
							//							var invDet:Number = 1/det;
							t /= det;
							//							u *= invDet;
							//							v *= invDet;
						}
					}
				}
				
				if (t == t && t < min) min = t;
			}
			
			return min == Number.POSITIVE_INFINITY ? -1 : min;
		}
	}
}