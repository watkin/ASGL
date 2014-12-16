package asgl.effects.geometries.decal {
	import asgl.geometries.MeshAsset;
	import asgl.geometries.MeshElement;
	import asgl.geometries.MeshElementType;
	import asgl.geometries.MeshElementValueMappingType;
	import asgl.bounds.BoundingFrustum;
	import asgl.math.Float3;
	import asgl.math.Float4;
	import asgl.math.Matrix4x4;
	
	public class MeshDecal {
		private static var _tempMatrix:Matrix4x4 = new Matrix4x4();
		private static var _planes:Vector.<Float4> = Vector.<Float4>([new Float4(), new Float4(), new Float4(), new Float4(), new Float4(), new Float4()]);
		private static var _planePoints:Vector.<Float3> = Vector.<Float3>([new Float3(), new Float3(), new Float3(), new Float3(), new Float3(), new Float3()]);
		
		private static var _frustum:BoundingFrustum = new BoundingFrustum();
		private static var _frustumMatrix:Matrix4x4 = new Matrix4x4();
		
		private static var _headFloat3:DecalVertex;
		private static var _invalidNum:int;
		private static var _invalid:Vector.<DecalVertex> = _createVertices();
		
		public function MeshDecal() {
		}
		private static function _createVertices():Vector.<DecalVertex> {
			var invalid:Vector.<DecalVertex> = new Vector.<DecalVertex>(6);
			
			_invalidNum = 6;
			for (var i:int = 0; i < _invalidNum; i++) {
				invalid[i] = new DecalVertex();
			}
			
			return invalid;
		}
		public static function changeFrustumMatrix(frustumMatrix:Matrix4x4):void {
			_frustumMatrix.copyDataFromMatrix4x4(frustumMatrix);
			
			_frustum.setMatrix(frustumMatrix);
			
			var f4:Float4 = _planes[0];
			f4.x = _frustum.rightX;
			f4.y = _frustum.rightY;
			f4.z = _frustum.rightZ;
			f4.w = _frustum.rightW;
			
			f4 = _planes[1];
			f4.x = _frustum.leftX;
			f4.y = _frustum.leftY;
			f4.z = _frustum.leftZ;
			f4.w = _frustum.leftW;
			
			f4 = _planes[2];
			f4.x = _frustum.topX;
			f4.y = _frustum.topY;
			f4.z = _frustum.topZ;
			f4.w = _frustum.topW;
			
			f4 = _planes[3];
			f4.x = _frustum.bottomX;
			f4.y = _frustum.bottomY;
			f4.z = _frustum.bottomZ;
			f4.w = _frustum.bottomW;
			
			f4 = _planes[4];
			f4.x = _frustum.farX;
			f4.y = _frustum.farY;
			f4.z = _frustum.farZ;
			f4.w = _frustum.farW;
			
			f4 = _planes[5];
			f4.x = _frustum.nearX;
			f4.y = _frustum.nearY;
			f4.z = _frustum.nearZ;
			f4.w = _frustum.nearW;
			
			_tempMatrix.copyDataFromMatrix4x4(frustumMatrix);
			_tempMatrix.invert();
			
			var left:Float3 = _planePoints[1];
			_tempMatrix.transform4x4Number3(-1, 1, 0, left);
			
			var top:Float3 = _planePoints[2];
			top.x = left.x;
			top.y = left.y;
			top.z = left.z;
			
			var near:Float3 = _planePoints[5];
			near.x = left.x;
			near.y = left.y;
			near.z = left.z;
			
			var right:Float3 = _planePoints[0];
			_tempMatrix.transform4x4Number3(1, -1, 1, right);
			
			var bottom:Float3 = _planePoints[3];
			bottom.x = right.x;
			bottom.y = right.y;
			bottom.z = right.z;
			
			var far:Float3 = _planePoints[4];
			far.x = right.x;
			far.y = right.y;
			far.z = right.z;
		}
		/**
		 * before call the method, need set frustumMatrix.
		 */
		public static function createDecalMesh(indices:Vector.<uint>, vertices:Vector.<Number>, normals:Vector.<Number>, offset:Number=0.001, cullingBack:Boolean=true):MeshAsset {
			var mesh:MeshAsset;
			var destVertices:Vector.<Number>;
			var destNormals:Vector.<Number>;
			var destIndices:Vector.<uint>;
			var destTexCoords:Vector.<Number>;
			
			var count:int = 0;
			
			var len:int = indices.length;
			for (var i:int = 0; i < len; i++) {
				var i0:int = indices[i++] * 3;
				var i1:int = indices[i++] * 3;
				var i2:int = indices[i] * 3;
				
				var x0:Number = vertices[i0];
				var y0:Number = vertices[int(i0 + 1)];
				var z0:Number = vertices[int(i0 + 2)];
				
				var x1:Number = vertices[i1];
				var y1:Number = vertices[int(i1 + 1)];
				var z1:Number = vertices[int(i1 + 2)];
				
				var x2:Number = vertices[i2];
				var y2:Number = vertices[int(i2 + 1)];
				var z2:Number = vertices[int(i2 + 2)];
				
				if (cullingBack) {
					var mx0:Number = x0 * _frustumMatrix.m00 + y0 * _frustumMatrix.m10 + z0 * _frustumMatrix.m20 + _frustumMatrix.m30;
					var my0:Number = x0 * _frustumMatrix.m01 + y0 * _frustumMatrix.m11 + z0 * _frustumMatrix.m21 + _frustumMatrix.m31;
					
					var abX:Number = (x1 * _frustumMatrix.m00 + y1 * _frustumMatrix.m10 + z1 * _frustumMatrix.m20 + _frustumMatrix.m30) - mx0;
					var abY:Number = (x1 * _frustumMatrix.m01 + y1 * _frustumMatrix.m11 + z1 * _frustumMatrix.m21 + _frustumMatrix.m31) - my0;
					var acX:Number = (x2 * _frustumMatrix.m00 + y2 * _frustumMatrix.m10 + z2 * _frustumMatrix.m20 + _frustumMatrix.m30) - mx0;
					var acY:Number = (x2 * _frustumMatrix.m01 + y2 * _frustumMatrix.m11 + z2 * _frustumMatrix.m21 + _frustumMatrix.m31) - my0;
					
					if (abX * acY - abY * acX >= 0) continue;
				}
				
				_headFloat3 = _invalid[--_invalidNum];
				var vertex1:DecalVertex = _invalid[--_invalidNum];
				var vertex2:DecalVertex = _invalid[--_invalidNum];
				
				_headFloat3.x = x0;
				_headFloat3.y = y0;
				_headFloat3.z = z0;
				_headFloat3.nx = normals[i0];
				_headFloat3.ny = normals[int(i0 + 1)];
				_headFloat3.nz = normals[int(i0 + 2)];
				
				vertex1.x = x1;
				vertex1.y = y1;
				vertex1.z = z1;
				vertex1.nx = normals[i1];
				vertex1.ny = normals[int(i1 + 1)];
				vertex1.nz = normals[int(i1 + 2)];
				
				vertex2.x = x2;
				vertex2.y = y2;
				vertex2.z = z2;
				vertex2.nx = normals[i2];
				vertex2.ny = normals[int(i2 + 1)];
				vertex2.nz = normals[int(i2 + 2)];
				
				_headFloat3.prev = vertex2;
				_headFloat3.next = vertex1;
				
				vertex1.prev = _headFloat3;
				vertex1.next = vertex2;
				
				vertex2.next = _headFloat3;
				vertex2.prev = vertex1;
				
				//culling
				var numVertices:int = 3;
				
				var allIn:Boolean = true;
				
				var df:DecalVertex = _headFloat3;
				
				for (var j:int = 0; j < 3; j++) {
					include 'MeshDecal_computeMask.define';
					
					if (df.mask != 0) allIn = false;
					
					df = df.next;
				}
				
				if (!allIn) {
					for (j = 0; j < 6; j++) {
						var planeMask:uint = 1 << j;
						
						var inNum:int = 0;
						var outNum:int = 0;
						
						var inVertex0:DecalVertex = null;
						var inVertex1:DecalVertex = null;
						var outVertex0:DecalVertex = null;
						var outVertex1:DecalVertex = null;
						
						df = _headFloat3;
						
						for (var jj:int = 0; jj < numVertices; jj++) {
							if ((df.mask & planeMask) == 0) {
								df.valid = true;
								inNum++;
							} else {
								df.valid = false;
								
								if (outNum == 0) {
									outVertex0 = df;
								} else {
									outVertex1 = df;
								}
								
								outNum++;
							}
							
							df = df.next;
						}
						
						if (inNum == numVertices) {
							continue;
						} else if (outNum == numVertices) {
							df = _headFloat3;
							while (outNum > 0) {
								_invalid[_invalidNum++] = df;
								df = df.next;
								outNum--;
							}
							
							numVertices = 0;
							break;
						} else {
							var outVertex:DecalVertex;
							var inVertex:DecalVertex;
							var toVertex:DecalVertex;
							
							var plane:Float4 = _planes[j];
							var planePoint:Float3 = _planePoints[j];
							
							var prev:DecalVertex;
							var next:DecalVertex;
							
							if (outNum == 1) {
								numVertices++;
								
								next = outVertex0.next;
								
								var newOutVertex:DecalVertex = _invalid[--_invalidNum];
								next.prev = newOutVertex;
								newOutVertex.next = next;
								outVertex0.next = newOutVertex;
								newOutVertex.prev = outVertex0;
								
								outVertex = outVertex0;
								inVertex = next;
								toVertex = newOutVertex;
								
								include 'MeshDecal_computeIntersectPoint.define';
								
								inVertex = outVertex0.prev;
								toVertex = outVertex0;
								
								include 'MeshDecal_computeIntersectPoint.define';
								
								df = newOutVertex;
								
								include 'MeshDecal_computeMask.define';
								
								df = outVertex0;
								
								include 'MeshDecal_computeMask.define';
							} else {
								if (outVertex0.next.valid) {
									var tmp:DecalVertex = outVertex0;
									outVertex0 = outVertex1;
									outVertex1 = tmp;
								}
								
								if (outNum > 2) {
									next = outVertex0.next;
									do {
										numVertices--;
										
										outVertex0.next = next.next;
										next.next.prev = outVertex0;
										
										_invalid[_invalidNum++] = next;
										
										if (next == _headFloat3) _headFloat3 = outVertex0;
										
										next = outVertex0.next;
									} while (next != outVertex1);
								}
								
								outVertex = outVertex0;
								inVertex = outVertex0.prev;
								toVertex = outVertex0;
								
								include 'MeshDecal_computeIntersectPoint.define';
								
								outVertex = outVertex1;
								inVertex = outVertex1.next;
								toVertex = outVertex1;
								
								include 'MeshDecal_computeIntersectPoint.define';
								
								df = outVertex0;
								
								include 'MeshDecal_computeMask.define';
								
								df = outVertex1;
								
								include 'MeshDecal_computeMask.define';
							}
						}
					}
				}
				//
				
				if (numVertices > 0) {
					if (mesh == null) {
						mesh = new MeshAsset();
						destVertices = new Vector.<Number>();
						destNormals = new Vector.<Number>();
						destIndices = new Vector.<uint>();
						destTexCoords = new Vector.<Number>();
						
						var meshVertices:MeshElement = new MeshElement();
						meshVertices.numDataPreElement = 3;
						meshVertices.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
						meshVertices.values = destVertices;
						mesh.elements[MeshElementType.VERTEX] = meshVertices;
						
						var meshTexCoords:MeshElement = new MeshElement();
						meshTexCoords.numDataPreElement = 2;
						meshTexCoords.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
						meshTexCoords.values = destTexCoords;
						mesh.elements[MeshElementType.TEXCOORD] = meshTexCoords;
						
						var meshNormals:MeshElement = new MeshElement();
						meshNormals.numDataPreElement = 3;
						meshNormals.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
						meshNormals.values = destNormals;
						mesh.elements[MeshElementType.NORMAL] = meshNormals;
						
						mesh.triangleIndices = destIndices;
					}
					
					var vertex:DecalVertex = _headFloat3;
					for (var kk:int = 0; kk < numVertices; kk++) {
						destVertices.push(vertex.x + vertex.nx * offset, vertex.y + vertex.ny * offset, vertex.z + vertex.nz * offset);
						destNormals.push(vertex.nx, vertex.ny, vertex.nz);
						
						var w:Number = vertex.x * _frustumMatrix.m03 + vertex.y * _frustumMatrix.m13 + vertex.z * _frustumMatrix.m23 + _frustumMatrix.m33;
						
						destTexCoords.push(((vertex.x * _frustumMatrix.m00 + vertex.y * _frustumMatrix.m10 + vertex.z * _frustumMatrix.m20 + _frustumMatrix.m30) / w + 1) * 0.5, 
										   (1 - (vertex.x * _frustumMatrix.m01 + vertex.y * _frustumMatrix.m11 + vertex.z * _frustumMatrix.m21 + _frustumMatrix.m31) / w) * 0.5);
						
						_invalid[_invalidNum++] = vertex;
						
						vertex = vertex.next;
					}
					
					if (numVertices == 3) {
						destIndices.push(count, count + 1, count + 2);
					} else if (numVertices == 4) {
						destIndices.push(count, count + 1, count + 2, count, count + 2, count + 3);
					} else if (numVertices == 5) {
						destIndices.push(count, count + 1, count + 2, count, count + 2, count + 3, count, count + 3, count + 4);
					} else if (numVertices == 6) {
						destIndices.push(count, count + 1, count + 2, count, count + 2, count + 3, count, count + 3, count + 4, count, count + 4, count + 5);
					} else {
						throw new Error();
					}
					
					count += numVertices;
				}
			}
			
			return mesh;
		}
	}
}