package asgl.geometries.primitives {
	import asgl.geometries.MeshAsset;
	import asgl.geometries.MeshElement;
	import asgl.geometries.MeshElementType;
	import asgl.geometries.MeshElementValueMappingType;
	
	public class SimplePyramid {
		public static function create(width:Number, depth:Number, height:Number, widthSegs:int=1, depthSegs:int=1, heightSegs:int=1, generateTexCoords:Boolean=true):MeshAsset {
			if (widthSegs < 1) widthSegs = 1;
			if (depthSegs < 1) depthSegs = 1;
			if (heightSegs < 1) heightSegs = 1;
			var halfWidth:Number = width * 0.5;
			var halfDepth:Number = depth * 0.5;
			
			var meshAsset:MeshAsset = new MeshAsset();
			meshAsset.name = 'SimplePyramid';
			
			var vertexElement:MeshElement = new MeshElement();
			vertexElement.numDataPreElement = 3;
			vertexElement.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
			var vertices:Vector.<Number> = new Vector.<Number>();
			vertexElement.values = vertices;
			meshAsset.elements[MeshElementType.VERTEX] = vertexElement;
			
			vertices.push(0, 0, 0, -halfWidth, 0, -halfDepth);
			
			var texCoords:Vector.<Number>;
			if (generateTexCoords) {
				var texCoordElement:MeshElement = new MeshElement();
				texCoordElement.numDataPreElement = 2;
				texCoordElement.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
				texCoords = new Vector.<Number>();
				texCoordElement.values = texCoords;
				meshAsset.elements[MeshElementType.TEXCOORD] = texCoordElement;
				
				texCoords.push(0.5, 0.5, 0, 0);
			}
			for (var i:int = 1; i < widthSegs; i++) {
				vertices.push(width * i / widthSegs - halfWidth, 0, -halfDepth);
				if (generateTexCoords) texCoords.push(i / widthSegs, 0);
			}
			vertices.push(halfWidth, 0, -halfDepth);
			if (generateTexCoords) texCoords.push(1, 0);
			var vertexIndices:Vector.<uint> = new Vector.<uint>();
			meshAsset.triangleIndices = vertexIndices;
			for (i = 1; i <= widthSegs; i++) {
				vertexIndices.push(0, i, i + 1);
			}
			var index:int = vertices.length / 3 - 1;
			vertices.push(-halfWidth, 0, halfDepth);
			if (generateTexCoords) texCoords.push(0, 1);
			for (i = 1; i < widthSegs; i++) {
				vertices.push(width * i / widthSegs - halfWidth, 0, halfDepth);
				if (generateTexCoords) texCoords.push(i / widthSegs, 1);
			}
			vertices.push(halfWidth, 0, halfDepth);
			if (generateTexCoords) texCoords.push(1, 1);
			for (i = 1; i <= widthSegs; i++) {
				vertexIndices.push(0, index + i + 1, index + i);
			}
			index = vertices.length / 3 - 1;
			vertices.push(-halfWidth, 0, -halfDepth);
			if (generateTexCoords) texCoords.push(0, 0);
			for (i = 1; i < depthSegs; i++) {
				vertices.push(-halfWidth, 0, depth * i / depthSegs - halfDepth);
				if (generateTexCoords) texCoords.push(0, i / depthSegs);
			}
			vertices.push(-halfWidth, 0, halfDepth);
			if (generateTexCoords) texCoords.push(0, 1);
			for (i = 1; i <= depthSegs; i++) {
				vertexIndices.push(0, index + i + 1, index + i);
			}
			index = vertices.length / 3 - 1;
			vertices.push(halfWidth, 0, -halfDepth);
			if (generateTexCoords) texCoords.push(1, 0);
			for (i = 1; i < depthSegs; i++) {
				vertices.push(halfWidth, 0, depth * i / depthSegs - halfDepth);
				if (generateTexCoords) texCoords.push(1, i / depthSegs);
			}
			vertices.push(halfWidth, 0, halfDepth);
			if (generateTexCoords) texCoords.push(1, 1);
			for (i = 1; i <= depthSegs; i++) {
				vertexIndices.push(0, index + i, index + i + 1);
			}
			vertices.push(0, height, 0);
			if (generateTexCoords) texCoords.push(0.5, 0);
			index = vertices.length / 3 - 1;
			var start:int;
			var k:Number;
			var x:Number;
			var y:Number;
			var z:Number;
			var j:int;
			var index1:int;
			var index2:int;
			var index3:int;
			var index4:int;
			var v:Number;
			var mul:int;
			for (var m:int = 0; m < 2; m++) {
				mul = m == 0 ? -1 : 1;
				start = vertices.length / 3 - 1;
				for (i = 1; i <= heightSegs; i++) {
					k = i / heightSegs;
					x = halfWidth * k;
					var x2:Number = x * 2;
					y = height * (1 - k);
					z = halfDepth * k * mul;
					vertices.push(-x, y, z);
					if (generateTexCoords) {
						v = k;
						texCoords.push(0.5 * (1 + k * mul), v);
					}
					for (j = 1; j < widthSegs; j++) {
						var tx:Number = x2 * j / widthSegs - x;
						vertices.push(tx, y, z);
						if (generateTexCoords) {
							if (tx < 0) tx = -tx;
							texCoords.push(0.5 * (1 + mul * tx / halfWidth), v);
						}
					}
					vertices.push(x, y, z);
					if (generateTexCoords) texCoords.push(0.5 * (1 + k * mul), v);
					if (i == 1) {
						for (j = 1; j <= widthSegs; j++) {
							if (m == 0) {
								vertexIndices.push(index, start + j + 1, start + j);
							} else {
								vertexIndices.push(index, start + j, start + j + 1);
							}
						}
					} else {
						for (j = 0; j < widthSegs; j++) {
							index3 = vertices.length / 3 - 1 - widthSegs + j;
							index1 = index3 - 1 - widthSegs;
							index2 = index1 + 1;
							index4 = index3 + 1;
							if (m == 0) {
								vertexIndices.push(index1, index2, index3, index2, index4, index3);
							} else {
								vertexIndices.push(index1, index3, index2, index2, index3, index4);
							}
						}
					}
				}
			}
			for (m = 0; m < 2; m++) {
				mul = m == 0 ? -1 : 1;
				start = vertices.length / 3 - 1;
				for (i = 1; i <= heightSegs; i++) {
					k = i / heightSegs;
					x = halfWidth * k * mul;
					y = height * (1 - k);
					z = halfDepth * k;
					var z2:Number = z * 2;
					vertices.push(x, y, -z);
					if (generateTexCoords) {
						v = k;
						texCoords.push(0.5 * (1 + k * mul), v);
					}
					for (j = 1; j < depthSegs; j++) {
						var tz:Number = z2 * j / depthSegs - z;
						vertices.push(x, y, tz);
						if (generateTexCoords) {
							if (tz < 0) tz = -tz;
							texCoords.push(0.5 * (1 + mul * tz / halfDepth), v);
						}
					}
					vertices.push(x, y, z);
					if (generateTexCoords) texCoords.push(0.5 * (1 + k * mul), v);
					if (i == 1) {
						for (j = 1; j <= depthSegs; j++) {
							if (m == 0) {
								vertexIndices.push(index, start + j, start + j + 1);
							} else {
								vertexIndices.push(index, start + j + 1, start + j);
							}
						}
					} else {
						for (j = 0; j < depthSegs; j++) {
							index3 = vertices.length / 3 - 1 - depthSegs + j;
							index1 = index3 - 1 - depthSegs;
							index2 = index1 + 1;
							index4 = index3 + 1;
							if (m == 0) {
								vertexIndices.push(index1, index3, index2, index2, index3, index4);
							} else {
								vertexIndices.push(index1, index2, index3, index2, index4, index3);
							}
						}
					}
				}
			}
			
			return meshAsset;
		}
	}
}