package asgl.geometries {
	import com.adobe.crypto.MD5;
	
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	import asgl.animators.SkinnedMeshAsset;
	import asgl.animators.SkinnedVertex;
	import asgl.lights.AbstractLight;
	import asgl.math.Float3;
	import asgl.math.Matrix4x4;

	public class MeshHelper {
		public function MeshHelper() {
		}
		public static function calculateBinormals(normals:Vector.<Number>, tangents:Vector.<Number>, op:Vector.<Number>=null):Vector.<Number> {
			var len1:uint = normals.length;
			var len2:uint = tangents.length;
			var length:uint;
			if (len1 > len2) {
				length = len2;
			} else {
				length = len1;
			}
			
			if (op == null) {
				op = new Vector.<Number>(length);
			} else if (op.length != length) {
				if (op.fixed) {
					if (op.length < length) return null;
				} else {
					op.length = length;
				}
			}
			
			var index:uint = 0;
			
			for (var i:uint = 0; i < length; i++) {
				var nx:Number = normals[i];
				var tx:Number = tangents[i++];
				var ny:Number = normals[i];
				var ty:Number = tangents[i++];
				var nz:Number = normals[i];
				var tz:Number = tangents[i];
				
				op[index++] = ny * tz - nz * ty;
				op[index++] = nz * tx - nx * tz;
				op[index++] = nx * ty - ny * tx;
			}
			
			return op;
		}
		public static function calculateSubRegionTexCoords(texCoords:Vector.<Number>, rect:Rectangle, op:Vector.<Number>=null):Vector.<Number> {
			var length:uint = texCoords.length;
			
			if (op == null) {
				op = new Vector.<Number>(length);
			} else if (op.length != length) {
				if (op.fixed) {
					if (op.length < length) return null;
				} else {
					op.length = length;
				}
			}
			
			for (var i:uint = 0; i < length; i++) {
				op[i] = rect.x + rect.width * texCoords[i];
				i++;
				op[i] = rect.y + rect.height * texCoords[i];
			}
			
			return op;
		}
		public static function calculateSurfaceNormals(indices:Vector.<uint>, vertices:Vector.<Number>, op:Vector.<Number>=null):Vector.<Number> {
			var length:uint = indices.length;
			
			if (op == null) {
				op = new Vector.<Number>(length);
			} else if (op.length != length) {
				if (op.fixed) {
					if (op.length < length) return null;
				} else {
					op.length = length;
				}
			}
			
			var index:uint = 0;
			
			for (var i:uint = 0; i < length; i++) {
				var i0:uint = indices[i++] * 3;
				var i1:uint = indices[i++] * 3;
				var i2:uint = indices[i] * 3;
				
				var x0:Number = vertices[i0++];
				var y0:Number = vertices[i0++];
				var z0:Number = vertices[i0];
				
				var x1:Number = vertices[i1++];
				var y1:Number = vertices[i1++];
				var z1:Number = vertices[i1];
				
				var x2:Number = vertices[i2++];
				var y2:Number = vertices[i2++];
				var z2:Number = vertices[i2];
				
				var abX:Number = x1 - x0;
				var abY:Number = y1 - y0;
				var abZ:Number = z1 - z0;
				var acX:Number = x2 - x0;
				var acY:Number = y2 - y0;
				var acZ:Number = z2 - z0;
				
				op[index++] = abY * acZ - abZ * acY;
				op[index++] = abZ * acX - abX * acZ;
				op[index++] = abX * acY - abY * acX;
			}
			return op;
		}
		public static function calculateSurfaceTangentsAndBinormals(indices:Vector.<uint>, vertices:Vector.<Number>, texCoords:Vector.<Number>, outTangents:Vector.<Number>=null, outBinormals:Vector.<Number>=null):void {
			if (outTangents != null) outTangents.length = 0;
			if (outBinormals != null) outBinormals.length = 0;
			
			var length:uint = indices.length;
			for (var i:uint = 0; i < length; i++) {
				var i0:uint = indices[i++];
				var i1:uint = indices[i++];
				var i2:uint = indices[i];
				
				var index:uint = i0 * 3;
				
				var x0:Number = vertices[index++];
				var y0:Number = vertices[index++];
				var z0:Number = vertices[index];
				
				index = i1 * 3;
				
				var x1:Number = vertices[index++];
				var y1:Number = vertices[index++];
				var z1:Number = vertices[index];
				
				index = i2 * 3;
				
				var x2:Number = vertices[index++];
				var y2:Number = vertices[index++];
				var z2:Number = vertices[index];
				
				var abX:Number = x1 - x0;
				var abY:Number = y1 - y0;
				var abZ:Number = z1 - z0;
				var acX:Number = x2 - x0;
				var acY:Number = y2 - y0;
				var acZ:Number = z2 - z0;
				
				index = i0 * 2;
				
				var s0:Number = texCoords[index++];
				var t0:Number = texCoords[index];
				
				index = i1 * 2;
				
				var s1:Number = texCoords[index++];
				var t1:Number = texCoords[index];
				
				index = i2 * 2;
				
				var s2:Number = texCoords[index++];
				var t2:Number = texCoords[index];
				
				var abS:Number = s1 - s0;
				var abT:Number = t1 - t0;
				var acS:Number = s2 - s0;
				var acT:Number = t2 - t0;
				
				var k:Number = abS * acT - acS * abT;
				if (k == 0) {
					k = 1;
				} else {
					k = 1 / k;
				}
				
				if (outTangents != null) outTangents.push((acT * abX - abT * acX) / k, (acT * abY - abT * acY) / k, (acT * abZ - abT * acZ) / k);
				
				if (outBinormals != null) outBinormals.push((abS * acX - acS * abX) / k, (abS * acY - acS * abY) / k, (abS * acZ - acS * abZ) / k);
			}
		}
		public static function calculateVertexLerpNormals(indices:Vector.<uint>, vertices:Vector.<Number>, op:Vector.<Number>=null):Vector.<Number> {
			var normals:Vector.<Number> = calculateVertexNormals(indices, vertices, op);
			
			var length:uint = vertices.length;
			
			var map:Object = {};
			var i:uint;
			
			for (i = 0; i < length; i += 3) {
				var key:Number = int(vertices[i] * 100000) * 100 + int(vertices[int(i + 1)] * 100000) * 10 + int(vertices[int(i + 2)] * 100000);
				if (map[key] == null) {
					map[key] = [i];
				} else {
					map[key].push(i);
				}
			}
			
			for each (var arr:Array in map) {
				var x:Number = 0;
				var y:Number = 0;
				var z:Number = 0;
				length = arr.length;
				var index:uint;
				for (i = 0; i < length; i++) {
					index = arr[i];
					x += normals[index++];
					y += normals[index++];
					z += normals[index];
				}
				for (i = 0; i < length; i++) {
					index = arr[i];
					normals[index++] = x;
					normals[index++] = y;
					normals[index] = z;
				}
			}
			
			return normals;
		}
		public static function calculateVertexNormals(indices:Vector.<uint>, vertices:Vector.<Number>, op:Vector.<Number>=null):Vector.<Number> {
			var max:uint = vertices.length;
			
			if (op == null) {
				op = new Vector.<Number>(max);
			} else if (op.length != max) {
				if (op.fixed) {
					if (op.length < max) return null;
				} else {
					op.length = max;
				}
			}
			
			var map:Object = {};
			
			var length:uint = indices.length;
			for (var i:uint = 0; i < length; i++) {
				var i0:uint = indices[i++] * 3;
				var i1:uint = indices[i++] * 3;
				var i2:uint = indices[i] * 3;
				
				var x0:Number = vertices[i0];
				var y0:Number = vertices[int(i0 + 1)];
				var z0:Number = vertices[int(i0 + 2)];
				
				var x1:Number = vertices[i1];
				var y1:Number = vertices[int(i1 + 1)];
				var z1:Number = vertices[int(i1 + 2)];
				
				var x2:Number = vertices[i2];
				var y2:Number = vertices[int(i2 + 1)];
				var z2:Number = vertices[int(i2 + 2)];
				
				var abX:Number = x1 - x0;
				var abY:Number = y1 - y0;
				var abZ:Number = z1 - z0;
				var acX:Number = x2 - x0;
				var acY:Number = y2 - y0;
				var acZ:Number = z2 - z0;
				
				var nx:Number = abY * acZ - abZ * acY;
				var ny:Number = abZ * acX - abX * acZ;
				var nz:Number = abX * acY - abY * acX;
				
				if (map[i0] == null) {
					map[i0] = true;
					op[i0++] = nx;
					op[i0++] = ny;
					op[i0] = nz;
				} else {
					op[i0++] += nx;
					op[i0++] += ny;
					op[i0] += nz;
				}
				if (map[i1] == null) {
					map[i1] = true;
					op[i1++] = nx;
					op[i1++] = ny;
					op[i1] = nz;
				} else {
					op[i1++] += nx;
					op[i1++] += ny;
					op[i1] += nz;
				}
				if (map[i2] == null) {
					map[i2] = true;
					op[i2++] = nx;
					op[i2++] = ny;
					op[i2] = nz;
				} else {
					op[i2++] += nx;
					op[i2++] += ny;
					op[i2] += nz;
				}
			}
			
			return op;
		}
		public static function calculateVertexTangents(indices:Vector.<uint>, vertices:Vector.<Number>, texCoords:Vector.<Number>, op:Vector.<Number>=null):Vector.<Number> {
			var length:uint = vertices.length;
			
			if (op == null) {
				op = new Vector.<Number>(length);
			} else if (op.length != length) {
				if (op.fixed) {
					if (op.length < length) return null;
				} else {
					op.length = length;
				}
			}
			
			length = indices.length;
			for (var i:uint = 0; i < length; i++) {
				var i0:uint = indices[i++];
				var i1:uint = indices[i++];
				var i2:uint = indices[i];
				
				var index0:uint = i0 * 3;
				var index0_1:uint = index0 + 1;
				var index0_2:uint = index0 + 2;
				
				var x0:Number = vertices[index0];
				var y0:Number = vertices[index0_1];
				var z0:Number = vertices[index0_2];
				
				var index1:uint = i1 * 3;
				var index1_1:uint = index1+1;
				var index1_2:uint = index1+2;
				
				var x1:Number = vertices[index1];
				var y1:Number = vertices[index1_1];
				var z1:Number = vertices[index1_2];
				
				var index2:uint = i2 * 3;
				var index2_1:uint = index2+1;
				var index2_2:uint = index2+2;
				
				var x2:Number = vertices[index2];
				var y2:Number = vertices[index2_1];
				var z2:Number = vertices[index2_2];
				
				var abX:Number = x1 - x0;
				var abY:Number = y1 - y0;
				var abZ:Number = z1 - z0;
				var acX:Number = x2 - x0;
				var acY:Number = y2 - y0;
				var acZ:Number = z2 - z0;
				
				var index:uint = i0 * 2;
				
				var s0:Number = texCoords[index++];
				var t0:Number = texCoords[index];
				
				index = i1 * 2;
				
				var s1:Number = texCoords[index++];
				var t1:Number = texCoords[index];
				
				index = i2 * 2;
				
				var s2:Number = texCoords[index++];
				var t2:Number = texCoords[index];
				
				var abS:Number = s1 - s0;
				var abT:Number = t1 - t0;
				var acS:Number = s2 - s0;
				var acT:Number = t2 - t0;
				
				var k:Number = abS * acT - acS * abT;
				if (k == 0) {
					k = 1;
				} else {
					k = 1 / k;
				}
				
				var x:Number;
				var y:Number;
				var z:Number;
				
				x = (acT * abX - abT * acX) / k;
				y = (acT * abY - abT * acY) / k;
				z = (acT * abZ - abT * acZ) / k;
				op[index0] = x;
				op[index1] = x;
				op[index2] = x;
				op[index0_1] = y;
				op[index1_1] = y;
				op[index2_1] = y;
				op[index0_2] = z;
				op[index1_2] = z;
				op[index2_2] = z;
			}
			
			return op;
		}
		public static function calculateVertexTangentsAndBinormals(indices:Vector.<uint>, vertices:Vector.<Number>, texCoords:Vector.<Number>, outTangents:Vector.<Number>, outBinormals:Vector.<Number>):void {
			var length:uint = vertices.length;
			
			if (outTangents == null) {
				outTangents = new Vector.<Number>(length);
			} else if (outTangents.length != length) {
				if (outTangents.fixed) {
					if (outTangents.length < length) return;
				} else {
					outTangents.length = length;
				}
			}
			
			if (outBinormals == null) {
				outBinormals = new Vector.<Number>(length);
			} else if (outBinormals.length != length) {
				if (outBinormals.fixed) {
					if (outBinormals.length < length) return;
				} else {
					outBinormals.length = length;
				}
			}
			
			length = indices.length;
			for (var i:uint = 0; i < length; i++) {
				var i0:uint = indices[i++];
				var i1:uint = indices[i++];
				var i2:uint = indices[i];
				
				var index0:uint = i0 * 3;
				var index0_1:uint = index0 + 1;
				var index0_2:uint = index0 + 2;
				
				var x0:Number = vertices[index0];
				var y0:Number = vertices[index0_1];
				var z0:Number = vertices[index0_2];
				
				var index1:uint = i1 * 3;
				var index1_1:uint = index1+1;
				var index1_2:uint = index1+2;
				
				var x1:Number = vertices[index1];
				var y1:Number = vertices[index1_1];
				var z1:Number = vertices[index1_2];
				
				var index2:uint = i2 * 3;
				var index2_1:uint = index2 + 1;
				var index2_2:uint = index2 + 2;
				
				var x2:Number = vertices[index2];
				var y2:Number = vertices[index2_1];
				var z2:Number = vertices[index2_2];
				
				var abX:Number = x1 - x0;
				var abY:Number = y1 - y0;
				var abZ:Number = z1 - z0;
				var acX:Number = x2 - x0;
				var acY:Number = y2 - y0;
				var acZ:Number = z2 - z0;
				
				var index:uint = i0 * 2;
				
				var s0:Number = texCoords[index++];
				var t0:Number = texCoords[index];
				
				index = i1 * 2;
				
				var s1:Number = texCoords[index++];
				var t1:Number = texCoords[index];
				
				index = i2 * 2;
				
				var s2:Number = texCoords[index++];
				var t2:Number = texCoords[index];
				
				var abS:Number = s1 - s0;
				var abT:Number = t1 - t0;
				var acS:Number = s2 - s0;
				var acT:Number = t2 - t0;
				
				var k:Number = abS * acT - acS * abT;
				if (k == 0) {
					k = 1;
				} else {
					k = 1 / k;
				}
				
				var x:Number;
				var y:Number;
				var z:Number;
				
				if (outTangents != null) {
					x = (acT * abX - abT * acX) / k;
					y = (acT * abY - abT * acY) / k;
					z = (acT * abZ - abT * acZ) / k;
					outTangents[index0] = x;
					outTangents[index1] = x;
					outTangents[index2] = x;
					outTangents[index0_1] = y;
					outTangents[index1_1] = y;
					outTangents[index2_1] = y;
					outTangents[index0_2] = z;
					outTangents[index1_2] = z;
					outTangents[index2_2] = z;
				}
				
				if (outBinormals != null) {
					x = (abS * acX - acS * abX) / k;
					y = (abS * acY - acS * abY) / k;
					z = (abS * acZ - acS * abZ) / k;
					outBinormals[index0] = x;
					outBinormals[index1] = x;
					outBinormals[index2] = x;
					outBinormals[index0_1] = y;
					outBinormals[index1_1] = y;
					outBinormals[index2_1] = y;
					outBinormals[index0_2] = z;
					outBinormals[index1_2] = z;
					outBinormals[index2_2] = z;
				}
			}
		}
		public static function createPostProcessAsset(z:Number=0):MeshAsset {
			var vertices:MeshElement = new MeshElement();
			vertices.numDataPreElement = 3;
			vertices.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
			vertices.values = new Vector.<Number>(12);
			vertices.values[0] = -1;
			vertices.values[1] = 1;
			vertices.values[2] = z;
			vertices.values[3] = 1;
			vertices.values[4] = 1;
			vertices.values[5] = z;
			vertices.values[6] = 1;
			vertices.values[7] = -1;
			vertices.values[8] = z;
			vertices.values[9] = -1;
			vertices.values[10] = -1;
			vertices.values[11] = z;
			
			var texCoords:MeshElement = new MeshElement();
			texCoords.numDataPreElement = 2;
			texCoords.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
			texCoords.values = new Vector.<Number>(8);
			texCoords.values[0] = 0;
			texCoords.values[1] = 0;
			texCoords.values[2] = 1;
			texCoords.values[3] = 0;
			texCoords.values[4] = 1;
			texCoords.values[5] = 1;
			texCoords.values[6] = 0;
			texCoords.values[7] = 1;
			
			var indices:Vector.<uint> = new Vector.<uint>(6);
			indices[0] = 0;
			indices[1] = 1;
			indices[2] = 3;
			indices[3] = 1;
			indices[4] = 2;
			indices[5] = 3;
			
			var mo:MeshAsset = new MeshAsset();
			mo.elements[MeshElementType.VERTEX] = vertices;
			mo.elements[MeshElementType.TEXCOORD] = texCoords;
			mo.triangleIndices = indices;
			
			return mo;
		}
		public static function createQuadTriangleIndices(numQuads:uint):Vector.<uint> {
			var indices:Vector.<uint> = new Vector.<uint>(numQuads * 6);
			
			var index:int = 0;
			var count:int = 0;
			
			for (var i:int = 0; i < numQuads; i++) {
				indices[index++] = count;
				indices[index++] = count + 1;
				indices[index++] = count + 2;
				indices[index++] = count;
				indices[index++] = count + 2;
				indices[index++] = count + 3;
				
				count += 4;
			}
			
			return indices;
		}
		/**
		 * general use for 2D render.
		 * 
		 * meshAsset.triangleIndices = [0, 1, 2, 0, 2, 3, 4, 5, 6, 4, 6, 7, .....].
		 */
		public static function formatToQuad(ma:MeshAsset, sma:SkinnedMeshAsset=null):void {
			var triangleIndices:Vector.<uint> = ma.triangleIndices;
			var len:uint = triangleIndices.length;
			
			var elements:Object = {};
			for (var type:* in ma.elements) {
				elements[type] = ma.getElement(type).clone();
			}
			
			var opTriangleIndices:Vector.<uint> = new Vector.<uint>(len);
			var numOpTriangleIndices:uint = 0;
			
			var indices1:Vector.<uint> = new Vector.<uint>(3);
			var indices2:Vector.<uint> = new Vector.<uint>(3);
			
			var srcIndices:Vector.<uint> = new Vector.<uint>(4);
			
			var srcSkinnedVertices:Vector.<SkinnedVertex>;
			var opSkinnedVertices:Vector.<SkinnedVertex>;
			if (sma != null) {
				srcSkinnedVertices = sma.skinnedVertices;
				opSkinnedVertices = new Vector.<SkinnedVertex>(srcSkinnedVertices.length);
			}
			
			var indexCount:uint;
			
			var element:MeshElement;
			
			for (var i:int = 0; i < len; i++) {
				indices1.length = 0;
				indices2.length = 0;
				
				var i0:uint = triangleIndices[i++];
				var i1:uint = triangleIndices[i++];
				var i2:uint = triangleIndices[i++];
				
				indices1[0] = i0;
				indices1[1] = i1;
				indices1[2] = i2;
				
				var isBad:Boolean = true;
				
				if (i < len) {
					var i3:uint = triangleIndices[i++];
					var i4:uint = triangleIndices[i++];
					var i5:uint = triangleIndices[i];
					
					indices2[0] = i3;
					indices2[1] = i4;
					indices2[2] = i5;
					
					var count:uint = 0;
					
					for (var j:int = 0; j < 3; j++) {
						if (indices1.indexOf(indices2[j]) != -1) count++;
					}
					
					if (count == 2) {
						var index:uint;
						
						for (j = 0; j < 3; j++) {
							if (indices2.indexOf(indices1[j]) == -1) {
								index = j;
								break;
							}
						}
						
						if (index == 0) {
							indices1[0] = i2;
							indices1[1] = i0;
							indices1[2] = i1;
						} else if (index == 2) {
							indices1[0] = i1;
							indices1[1] = i2;
							indices1[2] = i0;
						}
						
						for (j = 0; j < 3; j++) {
							if (indices1.indexOf(indices2[j]) == -1) {
								index = j;
								break;
							}
						}
						
						if (index == 0) {
							indices2[0] = i4;
							indices2[1] = i5;
							indices2[2] = i3;
						} else if (index == 1) {
							indices2[0] = i5;
							indices2[1] = i3;
							indices2[2] = i4;
						}
						
						if (indices1[0] == indices2[0] && indices1[2] == indices2[1]) {
							srcIndices[0] = indices1[0];
							srcIndices[1] = indices1[1];
							srcIndices[2] = indices1[2];
							srcIndices[3] = indices2[2];
							
							_formatToQuadAppendElementValues(elements, ma.elements, opSkinnedVertices, srcSkinnedVertices, indexCount, srcIndices);
							
							_formatToQuadAppendTriangleIndices(opTriangleIndices, numOpTriangleIndices, indexCount);
							numOpTriangleIndices += 6;
							indexCount += 4;
							
							isBad = false;
						}
					}
					
					if (isBad) {
						srcIndices[0] = indices1[0];
						srcIndices[1] = indices1[1];
						srcIndices[2] = indices1[2];
						srcIndices[3] = indices1[0];
						
						_formatToQuadAppendElementValues(elements, ma.elements, opSkinnedVertices, srcSkinnedVertices, indexCount, srcIndices);
						
						_formatToQuadAppendTriangleIndices(opTriangleIndices, numOpTriangleIndices, indexCount);
						numOpTriangleIndices += 6;
						indexCount += 4;
						
						srcIndices[0] = indices2[0];
						srcIndices[1] = indices2[1];
						srcIndices[2] = indices2[2];
						srcIndices[3] = indices2[0];
						
						_formatToQuadAppendElementValues(elements, ma.elements, opSkinnedVertices, srcSkinnedVertices, indexCount, srcIndices);
						
						_formatToQuadAppendTriangleIndices(opTriangleIndices, numOpTriangleIndices, indexCount);
						numOpTriangleIndices += 6;
						indexCount += 4;
					}
				} else {
					srcIndices[0] = indices1[0];
					srcIndices[1] = indices1[1];
					srcIndices[2] = indices1[2];
					srcIndices[3] = indices1[0];
					
					_formatToQuadAppendElementValues(elements, ma.elements, opSkinnedVertices, srcSkinnedVertices, indexCount, srcIndices);
					
					_formatToQuadAppendTriangleIndices(opTriangleIndices, numOpTriangleIndices, indexCount);
					numOpTriangleIndices += 6;
					indexCount += 4;
				}
			}
			
			ma.elements = elements;
			ma.triangleIndices = opTriangleIndices;
			
			if (sma != null) sma.skinnedVertices = opSkinnedVertices;
		}
		private static function _formatToQuadAppendTriangleIndices(indices:Vector.<uint>, index:int, count:uint):void {
			indices[index++] = count;
			indices[index++] = count + 1;
			indices[index++] = count + 2;
			indices[index++] = count;
			indices[index++] = count + 2;
			indices[index] = count + 3;
		}
		private static function _formatToQuadAppendElementValues(destElements:Object, srcElements:Object, destSkinnedVertices:Vector.<SkinnedVertex>, srcSkinnedVertices:Vector.<SkinnedVertex>, destQuadStartIndex:uint, srcQuadIndices:Vector.<uint>):void {
			var count:uint = 0;
			
			for (var type:* in destElements) {
				var destElement:MeshElement = destElements[type];
				var srcElement:MeshElement = srcElements[type];
				
				for (var i:int = 0; i < 4; i++) {
					var num:uint = destElement.numDataPreElement;
					
					var srcQuadIndex:uint = srcQuadIndices[i];
					var destQuadIndex:uint = destQuadStartIndex + i;
					
					var srcIndex:uint = srcQuadIndex * num;
					var destIndex:uint = destQuadIndex * num;
					
					for (var j:int = 0; j < num; j++) {
						destElement.values[int(destIndex + j)] = srcElement.values[int(srcIndex + j)];
					}
					
					if (count == 0 && destSkinnedVertices != null) {
						destSkinnedVertices[destQuadIndex] = srcSkinnedVertices[srcQuadIndex].clone();
					}
				}
				
				count++;
			}
		}
		public static function createShadowVolumeMesh(indices:Vector.<uint>, vertices:Vector.<Number>, light:AbstractLight, lightMatrix:Matrix4x4, extensionLength:Number, meshesNormal:Vector.<Number>=null):MeshAsset {
			var mo:MeshAsset = new MeshAsset();
			
			if (meshesNormal == null) meshesNormal = calculateSurfaceNormals(indices, vertices);
			
			var opIndices:Vector.<uint> = new Vector.<uint>();
			mo.triangleIndices = opIndices;
			
			var opVertices:MeshElement = new MeshElement();
			opVertices.numDataPreElement = 3;
			opVertices.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
			opVertices.values = new Vector.<Number>();
			mo.elements[MeshElementType.VERTEX] = opVertices;
			
			var f3_1:Float3 = new Float3();
			var f3_2:Float3 = new Float3();
			var f3_3:Float3 = new Float3();
			
			var map:Object = {};
			var map2:Object = {};
			var map3:Object = {};
			
			var f3:Float3;
			
			var lenght:int = meshesNormal.length;
			for (var i:int = 0; i < lenght; i += 3) {
				f3_3.x = meshesNormal[i];
				f3_3.y = meshesNormal[int(i + 1)];
				f3_3.z = meshesNormal[int(i + 2)];
				
				var i0:int = indices[i] * 3;
				
				f3_1.x = vertices[i0];
				f3_1.y = vertices[int(i0 + 1)];
				f3_1.z = vertices[int(i0 + 2)];
				
				f3_2 = light.getLightingDirection(lightMatrix, f3_1, f3_2);
				
				if (!f3_2.isZero) {
					f3 = f3_2;
					
					include '../math/Float3_normalize.define';
					
					f3 = f3_3;
					
					include '../math/Float3_normalize.define';
					
					if (Float3.dotProduct(f3_2, f3_3) < 0) {
						i0 = indices[i] * 3;
						var value:* = map[i0];
						var i1:uint;
						if (value == null) {
							i1 = opVertices.values.length;
							map[i0] = i1;
							f3_1.x = vertices[i0];
							f3_1.y = vertices[int(i0 + 1)];
							f3_1.z = vertices[int(i0 + 2)];
							opVertices.values.push(f3_1.x, f3_1.y, f3_1.z);
						} else {
							i1 = value;
							f3_1.x = vertices[i0];
							f3_1.y = vertices[int(i0 + 1)];
							f3_1.z = vertices[int(i0 + 2)];
						}
						opIndices.push(i1 / 3);
						
						i0 = indices[int(i + 1)] * 3;
						value = map[i0];
						var i2:uint;
						if (value == null) {
							i2 = opVertices.values.length;
							map[i0] = i2;
							f3_2.x = vertices[i0];
							f3_2.y = vertices[int(i0 + 1)];
							f3_2.z = vertices[int(i0 + 2)];
							opVertices.values.push(f3_2.x, f3_2.y, f3_2.z);
						} else {
							i2 = value;
							f3_2.x = vertices[i0];
							f3_2.y = vertices[int(i0 + 1)];
							f3_2.z = vertices[int(i0 + 2)];
						}
						opIndices.push(i2 / 3);
						
						i0 = indices[int(i + 2)] * 3;
						value = map[i0];
						var i3:uint;
						if (value == null) {
							i3 = opVertices.values.length;
							map[i0] = i3;
							f3_3.x = vertices[i0];
							f3_3.y = vertices[int(i0 + 1)];
							f3_3.z = vertices[int(i0 + 2)];
							opVertices.values.push(f3_3.x, f3_3.y, f3_3.z);
						} else {
							i3 = value;
							f3_3.x = vertices[i0];
							f3_3.y = vertices[int(i0 + 1)];
							f3_3.z = vertices[int(i0 + 2)];
						}
						opIndices.push(i3 / 3);
						
						var key1:String = f3_1.x + '|' + f3_1.y + '|' + f3_1.z;
						var key2:String = f3_2.x + '|' + f3_2.y + '|' + f3_2.z;
						var key3:String = f3_3.x + '|' + f3_3.y + '|' + f3_3.z;
						
						var key:String = key1 + '|' + key2;
						value = map2[key];
						if (value == null) {
							key = key2 + '|' + key1;
							value = map2[key];
							if (value == null) {
								map2[key] = 1;
								map3[key] = i1 + '|' + i2 + '|' + i3;
							} else {
								map2[key] = value + 1;
								if (value == 1) delete map3[key];
							}
						} else {
							map2[key] = value + 1;
							if (value == 1) delete map3[key];
						}
						
						key = key2 + '|' + key3;
						value = map2[key];
						if (value == null) {
							key = key3 + '|' + key2;
							value = map2[key];
							if (value == null) {
								map2[key] = 1;
								map3[key] = i2 + '|' + i3 + '|' + i1;
							} else {
								map2[key] = value + 1;
								if (value == 1) delete map3[key];
							}
						} else {
							map2[key] = value + 1;
							if (value == 1) delete map3[key];
						}
						
						key = key3 + '|' + key1;
						value = map2[key];
						if (value == null) {
							key = key1 + '|' + key3;
							value = map2[key];
							if (value == null) {
								map2[key] = 1;
								map3[key] = i3 + '|' + i1 + '|' + i2;
							} else {
								map2[key] = value + 1;
								if (value == 1) delete map3[key];
							}
						} else {
							map2[key] = value + 1;
							if (value == 1) delete map3[key];
						}
					}
				}
			}
			
			var extVertices:Vector.<Number> = new Vector.<Number>();
			lenght = opVertices.values.length;
			for (i = 0; i < lenght; i += 3) {
				f3_1.x = opVertices[i];
				f3_1.y = opVertices[int(i + 1)];
				f3_1.z = opVertices[int(i + 2)];
				
				f3_2 = light.getLightingDirection(lightMatrix, f3_1, f3_2);
				
				f3 = f3_2;
				
				include '../math/Float3_normalize.define';
				
				extVertices.push(f3_1.x + f3_2.x * extensionLength, f3_1.y + f3_2.y * extensionLength, f3_1.z + f3_2.z * extensionLength);
			}
			
			lenght /= 3;
			
			for each (var str:String in map3) {
				var arr:Array = str.split('|');
				var i4:uint = arr[0];
				var i5:uint = arr[1];
				var i6:uint = arr[2];
				
				opVertices.values.push(extVertices[i4], extVertices[i4+1], extVertices[i4+2],
								extVertices[i5], extVertices[i5+1], extVertices[i5+2],
								extVertices[i6], extVertices[i6+1], extVertices[i6+2]);
				
				i5 /= 3;
				
				opIndices.push(i5, i4 / 3, lenght, i5, lenght, lenght + 1, lenght, lenght + 1, lenght + 2);
				
				lenght += 3;
			}
			
			return mo;
		}
		public static function flipVertexIndices(indices:Vector.<uint>, op:Vector.<uint>=null):Vector.<uint> {
			var length:uint = indices.length;
			
			if (op == null) {
				op = new Vector.<uint>(length);
			} else if (op.length != length) {
				if (op.fixed) {
					if (op.length < length) return null;
				} else {
					op.length = length;
				}
			}
			
			var index:uint = 0;
			
			for (var i:int = 0; i < length;) {
				var i0:uint = indices[i++];
				
				op[index++] = indices[i++];
				op[index++] = i0;
				op[index++] = indices[i++];
			}
			
			return op;
		}
		public static function format(ma:MeshAsset, sma:SkinnedMeshAsset=null):void {
			var triangleIndices:Vector.<uint> = ma.triangleIndices;
			
			if (triangleIndices != null && triangleIndices.length > 0) {
				var passElements:Vector.<MeshElement> = new Vector.<MeshElement>();
				var notPassElements:Vector.<MeshElement> = new Vector.<MeshElement>();
				var numPassElements:int = 0;
				var numNotPassElements:int = 0;
				
				for each (var element:MeshElement in ma.elements) {
					if (element.valueMappingType == MeshElementValueMappingType.TRIANGLE_INDEX) {
						passElements[numPassElements++] = element;
					} else {
						notPassElements[numNotPassElements++] = element;
					}
				}
				
				if (numNotPassElements > 0) {
					var status:Vector.<uint> = new Vector.<uint>();
					
					for (var i:int = 0; i < numNotPassElements; i++) {
						var notPassElement:MeshElement = notPassElements[i];
						
						if (notPassElement.valueMappingType == MeshElementValueMappingType.SELF_TRIANGLE_INDEX ||
							notPassElement.valueMappingType == MeshElementValueMappingType.EACH_TRIANGLE_INDEX) {
							
							var numTriangleIndices:int = triangleIndices.length;
							
							var numValues:uint = 0;
							for (var j:int = 0; j < numTriangleIndices; j++) {
								if (numValues < triangleIndices[j]) numValues = triangleIndices[j];
							}
							
							numValues++;
							
							status.length = 0;
							status.length = numValues;
							
							var newValues:Vector.<Number> = new Vector.<Number>(numValues * notPassElement.numDataPreElement);
							
							var isEachIndex:Boolean = notPassElement.valueMappingType == MeshElementValueMappingType.EACH_TRIANGLE_INDEX;
							
							var k:uint;
							
							var left:uint;
							var right:uint;
							
							for (j = 0; j < numTriangleIndices; j++) {
								var triangleIndex:uint = triangleIndices[j];
								var selfIndex:uint = isEachIndex ? j : notPassElement.indices[j];
								var statusValue:uint = status[triangleIndex];
								if (statusValue == 0) {
									left = triangleIndex * notPassElement.numDataPreElement;
									right = selfIndex * notPassElement.numDataPreElement;
									
									for (k = 0; k < notPassElement.numDataPreElement; k++) {
										newValues[int(left + k)] = notPassElement.values[int(right + k)];
									}
									
									status[triangleIndex] = triangleIndex + 1;
								} else {
									statusValue--;
									var trailTriangleIndex:uint = triangleIndex;
									
									var findTriangleIndex:int = -1;
									while (findTriangleIndex != -1) {
										findTriangleIndex = trailTriangleIndex;
										
										left = trailTriangleIndex * notPassElement.numDataPreElement;
										right = selfIndex * notPassElement.numDataPreElement;
										
										for (k = 0; k < notPassElement.numDataPreElement; k++) {
											if (newValues[int(left + k)] != notPassElement.values[int(right + k)]) {
												findTriangleIndex = -1;
												break;
											}
										}
										
										if (statusValue == trailTriangleIndex) {
											break;
										} else if (findTriangleIndex == -1) {
											trailTriangleIndex = statusValue;
											statusValue = status[trailTriangleIndex] - 1;
										}
									}
									
									if (findTriangleIndex == -1) {
										for (var m:int = 0; m < numPassElements; m++) {
											var passElement:MeshElement = passElements[m];
											
											left = numValues * passElement.numDataPreElement;
											right = triangleIndex * passElement.numDataPreElement;
											
											for (k = 0; k < passElement.numDataPreElement; k++) {
												passElement.values[int(left + k)] = passElement.values[int(right + k)];
											}
											
											if (sma != null) {
												var sv:SkinnedVertex = sma.skinnedVertices[triangleIndex];
												if (sv == null) {
													sma.skinnedVertices[numValues] = null;
												} else {
													sma.skinnedVertices[numValues] = sv.clone();
												}
											}
										}
										
										triangleIndices[j] = numValues;
										status[trailTriangleIndex] = numValues;
										
										left = numValues * notPassElement.numDataPreElement;
										right = selfIndex * notPassElement.numDataPreElement;
										
										for (k = 0; k < notPassElement.numDataPreElement; k++) {
											newValues[int(left + k)] = notPassElement.values[int(right + k)];
										}
										
										numValues++;
									} else {
										triangleIndices[j] = findTriangleIndex;
									}
								}
							}
							
							notPassElement.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
							notPassElement.values = newValues;
							notPassElement.indices = null;
							
							passElements[numPassElements++] = notPassElement;
						}
					}
				}
			}
		}
		public static function orderVertexIndicesFromDepth(indices:Vector.<uint>, vertices:Vector.<Number>, op:Vector.<uint>=null):Vector.<uint> {
			var length:uint = indices.length;
			
			if (op == null) {
				op = new Vector.<uint>(length);
			} else if (op.length != length) {
				if (op.fixed) {
					if (op.length < length) return null;
				} else {
					op.length = length;
				}
			}
			
			var map:Object = {};
			var arr:Array = [];
			var pos:uint = 0;
			
			for (var i:uint = 0; i < length; i += 3) {
				var index0:uint = indices[i] * 3;
				var index1:uint = indices[int(i + 1)] * 3;
				var index2:uint = indices[int(i + 2)] * 3;
				
				var z:Number = vertices[int(index0 + 2)] + vertices[int(index1 + 2)] + vertices[int(index2 + 2)];
				
				arr[pos++] = z;
				map[z] = i;
			}
			
			arr = arr.sort(Array.NUMERIC|Array.DESCENDING);
			
			var j:uint = 0;
			
			for (i = 0; i < pos; i++) {
				var index:uint = map[arr[i]];
				
				op[j++] = indices[index];
				op[j++] = indices[int(index + 1)];
				op[j++] = indices[int(index + 2)];
			}
			
			return op;
		}
		public static function triangleIndicesTransformLRH(indices:Vector.<uint>):void {
			var len:uint = indices.length;
			for (var i:uint = 0; i < len; i += 3) {
				var temp:uint = indices[i];
				indices[i] = indices[int(i + 1)];
				indices[int(i + 1)] = temp;
			}
		}
		public static function verticesCheckValue(values:Vector.<Number>):String {
			var bytes:ByteArray = new ByteArray();
			
			var len:uint = values.length;
			for (var i:uint = 0; i < len; i++) {
				bytes.writeDouble(values[i]);
			}
			
			return MD5.hashBinary(bytes);
		}
	}
}