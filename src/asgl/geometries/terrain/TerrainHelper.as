package asgl.geometries.terrain {
	import asgl.geometries.MeshAsset;
	import asgl.geometries.MeshElement;
	import asgl.geometries.MeshElementType;
	import asgl.geometries.MeshElementValueMappingType;
	import asgl.geometries.MeshHelper;
	import asgl.materials.SoftTexture;

	public class TerrainHelper {
		public function TerrainHelper() {
		}
		/**
		 * will change vertices, correspondence colors
		 * @param numPreVertex is 2 or 3
		 */
		public static function createHeightFromColor(vertices:Vector.<Number>, numPreVertex:uint, colors:Vector.<uint>, minY:Number, maxY:Number, channelBitRightShiftValue:uint, channelBitAndValue:uint):void {
			if (numPreVertex != 2 && numPreVertex != 3) throw new ArgumentError('numPreVertex is only 2 or 3');
			
			var unit:Number = (maxY - minY) / channelBitAndValue;
			
			var length:uint = colors.length;
			
			var i:uint;
			var color:uint;
			
			if (numPreVertex == 2) {
				for (i = 0; i < length; i++) {
					color = colors[i];
					
					color = color >> channelBitRightShiftValue & channelBitAndValue;
					vertices[i] = minY + unit * color;
				}
			} else {
				for (i = 0; i < length; i++) {
					color = colors[i];
					
					color = color >> channelBitRightShiftValue & channelBitAndValue;
					vertices[int(i * 3 + 1)] = minY + unit * color;
				}
			}
		}
		/**
		 * will change vertices
		 * @param numPreVertex is 2 or 3
		 */
		public static function createHeightFromHeightMap(vertices:Vector.<Number>, numPreVertex:uint, lengthSegs:uint, widthSegs:uint, heightMap:SoftTexture, minY:Number, maxY:Number, channelRightShiftBitsValue:uint, channelAndBitsValue:uint, filter:String, wrap:String):void {
			if (numPreVertex != 2 && numPreVertex != 3) throw new ArgumentError('numPreVertex is only 2 or 3');
			
			var unit:Number = (maxY - minY) / channelAndBitsValue;
			
			var unitU:Number = 1 / lengthSegs;
			var unitV:Number = 1 / widthSegs;
			
			var i:uint;
			var j:uint;
			var u1:Number;
			var u2:Number;
			var v1:Number;
			var v2:Number;
			var index:uint;
			var color:uint;
			
			if (numPreVertex == 2) {
				for (i = 0; i < lengthSegs; i++) {
					u1 = unitU * i;
					u2 = u1 + unitU;
					for (j = 0; j < widthSegs; j++) {
						v1 = unitV * j;
						v2 = v1 + unitV;
						
						color = heightMap.getPixel32(u1, v1, filter, wrap);
						color = color >> channelRightShiftBitsValue & channelAndBitsValue;
						vertices[index++] = minY + unit * color;
						
						color = heightMap.getPixel32(u2, v1, filter, wrap);
						color = color >> channelRightShiftBitsValue & channelAndBitsValue;
						vertices[index++] = minY + unit * color;
						
						color = heightMap.getPixel32(u2, v2, filter, wrap);
						color = color >> channelRightShiftBitsValue & channelAndBitsValue;
						vertices[index++] = minY + unit * color;
						
						color = heightMap.getPixel32(u1, v2, filter, wrap);
						color = color >> channelRightShiftBitsValue & channelAndBitsValue;
						vertices[index++] = minY + unit * color;
					}
				}
			} else {
				for (i = 0; i < lengthSegs; i++) {
					u1 = unitU * i;
					u2 = u1 + unitU;
					for (j = 0; j < widthSegs; j++) {
						v1 = unitV * j;
						v2 = v1 + unitV;
						
						color = heightMap.getPixel32(u1, v1, filter, wrap);
						color = color >> channelRightShiftBitsValue & channelAndBitsValue;
						vertices[int(index * 3 + 1)] = minY+unit*color;
						index++;
						
						color = heightMap.getPixel32(u2, v1, filter, wrap);
						color = color >> channelRightShiftBitsValue & channelAndBitsValue;
						vertices[int(index * 3 + 1)] = minY + unit * color;
						index++;
						
						color = heightMap.getPixel32(u2, v2, filter, wrap);
						color = color >> channelRightShiftBitsValue & channelAndBitsValue;
						vertices[int(index * 3 + 1)] = minY + unit * color;
						index++;
						
						color = heightMap.getPixel32(u1, v2, filter, wrap);
						color = color >> channelRightShiftBitsValue & channelAndBitsValue;
						vertices[int(index * 3 + 1)] = minY + unit * color;
						index++;
					}
				}
			}
		}
		/**
		 * will change vertices, correspondence texCoords
		 * @param numPreVertex is 2 or 3
		 */
		public static function createHeightFromTexCoordAndHeightMap(vertices:Vector.<Number>, numPreVertex:uint, texCoords:Vector.<Number>, heightMap:SoftTexture, minY:Number, maxY:Number, channelRightShiftBitsValue:uint, channelAndBitsValue:uint, filter:String, wrap:String):void {
			if (numPreVertex != 2 && numPreVertex != 3) throw new ArgumentError('numPreVertex is only 2 or 3');
			
			var unit:Number = (maxY - minY) / channelAndBitsValue;
			
			var length:uint = texCoords.length * 0.5;
			
			var i:uint;
			var index:uint;
			var color:uint;
			
			if (numPreVertex == 2) {
				for (i = 0; i < length; i++) {
					index = i * 2;
					
					color = heightMap.getPixel32(texCoords[index++], texCoords[index], filter, wrap);
					color = color >> channelRightShiftBitsValue & channelAndBitsValue;
					vertices[i] = minY + unit * color;
				}
			} else {
				for (i = 0; i < length; i++) {
					index = i * 2;
					
					color = heightMap.getPixel32(texCoords[index++], texCoords[index], filter, wrap);
					color = color >> channelRightShiftBitsValue & channelAndBitsValue;
					vertices[int(i * 3 + 1)] = minY + unit * color;
				}
			}
		}
		/**
		 * @param numPreVertex is 2 or 3
		 */
		public static function createMesh(length:Number, width:Number, lengthSegs:uint=1, widthSegs:uint=1, numPreVertex:uint=3):MeshAsset {
			if (numPreVertex != 2 && numPreVertex != 3) throw new ArgumentError('numPreVertex is only 2 or 3');
			
			if (length < 0) length = 0;
			if (width < 0) width = 0;
			
			if (lengthSegs < 1) lengthSegs = 1;
			if (widthSegs < 1) widthSegs = 1;
			
			var lw:uint = lengthSegs * widthSegs;
			
			var unitLength:Number = length / lengthSegs;
			var unitWidth:Number = width / widthSegs;
			
			var originX:Number = -length * 0.5;
			var originZ:Number = width * 0.5;
			
			var mo:MeshAsset = new MeshAsset();
			var vertices:Vector.<Number>;
			var vertexIndices:Vector.<uint> = new Vector.<uint>(lw * 6);
			mo.triangleIndices = vertexIndices;
			
			var verticesNum:uint;
			var i:uint;
			var j:uint;
			var index1:uint = 0;
			var index2:uint = 0;
			var x1:Number;
			var x2:Number;
			var z1:Number;
			var z2:Number;
			
			if (numPreVertex == 2) {
				vertices = new Vector.<Number>(lw * 8);
				
				for (i = 0; i < lengthSegs; i++) {
					x1 = originX + unitLength * i;
					x2 = x1 + unitLength;
					for (j = 0; j < widthSegs; j++) {
						z1 = originZ - unitWidth * j;
						z2 = z1 - unitWidth;
						
						vertices[index1++] = x1;
						vertices[index1++] = z1;
						vertices[index1++] = x2;
						vertices[index1++] = z1;
						vertices[index1++] = x2;
						vertices[index1++] = z2;
						vertices[index1++] = x1;
						vertices[index1++] = z2;
						
						vertexIndices[index2++] = verticesNum;
						vertexIndices[index2++] = verticesNum+1;
						vertexIndices[index2++] = verticesNum+3;
						vertexIndices[index2++] = verticesNum+1;
						vertexIndices[index2++] = verticesNum+2;
						vertexIndices[index2++] = verticesNum+3;
						
						verticesNum += 4;
					}
				}
			} else {
				vertices = new Vector.<Number>(lw * 12);
				
				for (i = 0; i < lengthSegs; i++) {
					x1 = originX + unitLength * i;
					x2 = x1 + unitLength;
					for (j = 0; j < widthSegs; j++) {
						z1 = originZ - unitWidth * j;
						z2 = z1 - unitWidth;
						
						vertices[index1++] = x1;
						vertices[index1++] = 0;
						vertices[index1++] = z1;
						vertices[index1++] = x2;
						vertices[index1++] = 0;
						vertices[index1++] = z1;
						vertices[index1++] = x2;
						vertices[index1++] = 0;
						vertices[index1++] = z2;
						vertices[index1++] = x1;
						vertices[index1++] = 0;
						vertices[index1++] = z2;
						
						vertexIndices[index2++] = verticesNum;
						vertexIndices[index2++] = verticesNum+1;
						vertexIndices[index2++] = verticesNum+3;
						vertexIndices[index2++] = verticesNum+1;
						vertexIndices[index2++] = verticesNum+2;
						vertexIndices[index2++] = verticesNum+3;
						
						verticesNum += 4;
					}
				}
			}
			
			var element:MeshElement = new MeshElement();
			element.numDataPreElement = 3;
			element.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
			element.values = vertices;
			mo.elements[MeshElementType.VERTEX] = element;
			
			return mo;
		}
		/**
		 * @param heights correspondence map(mapWidth x mapHeight, dominated row)
		 * @return the values are not normalized, correspondence map(mapWidth x mapHeight, dominated row)
		 */
		public static function createNormalFromHeight(heights:Vector.<Number>, length:Number, width:Number, lengthSegs:uint, widthSegs:uint, lerp:Boolean, op:Vector.<Number>=null):Vector.<Number> {
			if (length < 0) length = 0;
			if (width < 0) width = 0;
			
			if (lengthSegs < 1) lengthSegs = 1;
			if (widthSegs < 1) widthSegs = 1;
			
			var lw:uint = lengthSegs * widthSegs;
			
			var unitLength:Number = length / lengthSegs;
			var unitWidth:Number = width / widthSegs;
			
			var verticesNum:uint;
			
			var vertices:Vector.<Number> = new Vector.<Number>(lw * 12);
			var indices:Vector.<uint> = new Vector.<uint>(lw * 6);
			
			var pos:uint = 0;
			var index1:uint = 0;
			var index2:uint = 0;
			
			for (var i:uint = 0; i < lengthSegs; i++) {
				var x1:Number = unitLength * i;
				var x2:Number = x1 + unitLength;
				for (var j:uint = 0; j<widthSegs; j++) {
					var z1:Number = -unitWidth * j;
					var z2:Number = z1 - unitWidth;
					
					vertices[index1++] = x1;
					vertices[index1++] = heights[pos++];
					vertices[index1++] = z1;
					vertices[index1++] = x2;
					vertices[index1++] = heights[pos++];
					vertices[index1++] = z1;
					vertices[index1++] = x2;
					vertices[index1++] = heights[pos++];
					vertices[index1++] = z2;
					vertices[index1++] = x1;
					vertices[index1++] = heights[pos++];
					vertices[index1++] = z2;
					
					indices[index2++] = verticesNum;
					indices[index2++] = verticesNum + 1;
					indices[index2++] = verticesNum + 3;
					indices[index2++] = verticesNum + 1;
					indices[index2++] = verticesNum + 2;
					indices[index2++] = verticesNum + 3;
					
					verticesNum += 4;
				}
			}
			
			if (lerp) {
				op = MeshHelper.calculateVertexLerpNormals(indices, vertices, op);
			} else {
				op = MeshHelper.calculateVertexNormals(indices, vertices, op);
			}
			
			
			return op;
		}
		public static function createNormalFromHeightMap(length:Number, width:Number, lengthSegs:uint, widthSegs:uint, heightMap:SoftTexture, minY:Number, maxY:Number, channelRightShiftBitsValue:uint, channelAndBitsValue:uint, filter:String, wrap:String, lerp:Boolean, op:Vector.<Number>=null):Vector.<Number> {
			if (length < 0) length = 0;
			if (width < 0) width = 0;
			
			if (lengthSegs < 1) lengthSegs = 1;
			if (widthSegs < 1) widthSegs = 1;
			
			var lw:uint = lengthSegs * widthSegs;
			
			var unitLength:Number = length / lengthSegs;
			var unitWidth:Number = width / widthSegs;
			
			var unitHeight:Number = (maxY - minY) / channelAndBitsValue;
			
			var unitU:Number = 1 / lengthSegs;
			var unitV:Number = 1 / widthSegs;
			
			var verticesNum:uint;
			
			var vertices:Vector.<Number> = new Vector.<Number>(lw * 12);
			var indices:Vector.<uint> = new Vector.<uint>(lw * 6);
			
			var index1:uint = 0;
			var index2:uint = 0;
			
			for (var i:uint = 0; i < lengthSegs; i++) {
				var x1:Number = unitLength * i;
				var x2:Number = x1 + unitLength;
				
				var u1:Number = unitU * i;
				var u2:Number = u1 + unitU;
				for (var j:uint = 0; j < widthSegs; j++) {
					var z1:Number = -unitWidth * j;
					var z2:Number = z1 - unitWidth;
					
					var v1:Number = unitV * j;
					var v2:Number = v1 + unitV;
					
					var color:uint = heightMap.getPixel32(u1, v1, filter, wrap);
					color = color >> channelRightShiftBitsValue & channelAndBitsValue;
					var h1:Number = minY + unitHeight * color;
					
					color = heightMap.getPixel32(u2, v1, filter, wrap);
					color = color >> channelRightShiftBitsValue & channelAndBitsValue;
					var h2:Number = minY + unitHeight * color;
					
					color = heightMap.getPixel32(u2, v2, filter, wrap);
					color = color >> channelRightShiftBitsValue & channelAndBitsValue;
					var h3:Number = minY + unitHeight * color;
					
					color = heightMap.getPixel32(u1, v2, filter, wrap);
					color = color >> channelRightShiftBitsValue & channelAndBitsValue;
					var h4:Number = minY + unitHeight * color;
					
					vertices[index1++] = x1;
					vertices[index1++] = h1;
					vertices[index1++] = z1;
					vertices[index1++] = x2;
					vertices[index1++] = h2;
					vertices[index1++] = z1;
					vertices[index1++] = x2;
					vertices[index1++] = h3;
					vertices[index1++] = z2;
					vertices[index1++] = x1;
					vertices[index1++] = h4;
					vertices[index1++] = z2;
					
					indices[index2++] = verticesNum;
					indices[index2++] = verticesNum + 1;
					indices[index2++] = verticesNum + 3;
					indices[index2++] = verticesNum + 1;
					indices[index2++] = verticesNum + 2;
					indices[index2++] = verticesNum + 3;
					
					verticesNum += 4;
				}
			}
			
			if (lerp) {
				op = MeshHelper.calculateVertexLerpNormals(indices, vertices, op);
			} else {
				op = MeshHelper.calculateVertexNormals(indices, vertices, op);
			}
			
			
			return op;
		}
		public static function createClampTexCoords(lengthSegs:uint, widthSegs:uint, op:Vector.<Number>=null):Vector.<Number> {
			if (lengthSegs == 0) lengthSegs = 1;
			if (widthSegs == 0) widthSegs = 1;
			
			var max:uint = lengthSegs * widthSegs * 8;
			
			if (op == null) {
				op = new Vector.<Number>(max);
			} else if (op.length != max) {
				if (op.fixed) {
					if (op.length < max) return null;
				} else {
					op.length = max;
				}
			}
			
			var unitU:Number = 1 / lengthSegs;
			var unitV:Number = 1 / widthSegs;
			
			var index:uint = 0;
			
			for (var i:uint = 0; i < lengthSegs; i++) {
				var u1:Number = unitU * i;
				var u2:Number = u1 + unitU;
				
				for (var j:uint = 0; j < widthSegs; j++) {
					var v1:Number = unitV * j;
					var v2:Number = v1 + unitV;
					
					op[index++] = u1;
					op[index++] = v1;
					op[index++] = u2;
					op[index++] = v1;
					op[index++] = u2;
					op[index++] = v2;
					op[index++] = u1;
					op[index++] = v2;
				}
			}
			
			return op;
		}
		public static function createRepeatTexCoord(lengthSegs:uint, widthSegs:uint, repeatLengthSegs:uint, repeatWidthSegs:uint, op:Vector.<Number>=null):Vector.<Number> {
			if (lengthSegs == 0) lengthSegs = 1;
			if (widthSegs == 0) widthSegs = 1;
			
			var max:uint = lengthSegs * widthSegs * 8;
			
			if (op == null) {
				op = new Vector.<Number>(max);
			} else if (op.length != max) {
				if (op.fixed) {
					if (op.length < max) return null;
				} else {
					op.length = max;
				}
			}
			
			if (repeatLengthSegs == 0) repeatLengthSegs = 1;
			if (repeatWidthSegs == 0) repeatWidthSegs = 1;
			
			var countU:uint = 0;
			var index:uint = 0;
			
			for (var i:uint = 0; i < lengthSegs; i++) {
				var u1:Number = countU / repeatLengthSegs;
				countU++;
				var u2:Number = countU / repeatLengthSegs;
				
				if (countU == repeatLengthSegs) countU = 0;
				
				var countV:uint = 0;
				
				for (var j:uint = 0; j < widthSegs; j++) {
					var v1:Number = countV / repeatWidthSegs;
					countV++;
					var v2:Number = countV / repeatWidthSegs;
					
					if (countV == repeatWidthSegs) countV = 0;
					
					op[index++] = u1;
					op[index++] = v1;
					op[index++] = u2;
					op[index++] = v1;
					op[index++] = u2;
					op[index++] = v2;
					op[index++] = u1;
					op[index++] = v2;
				}
			}
			
			return op;
		}
	}
}