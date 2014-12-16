package asgl.geometries.primitives {
	import asgl.geometries.MeshAsset;
	import asgl.geometries.MeshElement;
	import asgl.geometries.MeshElementType;
	import asgl.geometries.MeshElementValueMappingType;
	
	public class SimplePlane {
		public static function create(length:Number, width:Number, lengthSegs:int=1, widthSegs:int=1, generateTexCoords:Boolean=true):MeshAsset {
			if (length <0 ) length = 0;
			if (width < 0) width = 0;
			if (lengthSegs < 1) lengthSegs = 1;
			if (widthSegs < 1) widthSegs = 1;
			
			var unitLength:Number = length / widthSegs;
			var unitWidth:Number = width / lengthSegs;
			length *= 0.5;
			width *= 0.5;
			
			var mo:MeshAsset = new MeshAsset();
			mo.name = 'SimplePlane';
			
			var vertexElement:MeshElement = new MeshElement();
			vertexElement.numDataPreElement = 3;
			vertexElement.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
			var vertices:Vector.<Number> = new Vector.<Number>();
			vertexElement.values = vertices;
			mo.elements[MeshElementType.VERTEX] = vertexElement;
			
			var texCoords:Vector.<Number>;
			if (generateTexCoords) {
				var texCoordElement:MeshElement = new MeshElement();
				texCoordElement.numDataPreElement = 2;
				texCoordElement.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
				texCoords = new Vector.<Number>();
				texCoordElement.values = texCoords;
				mo.elements[MeshElementType.TEXCOORD] = texCoordElement;
			}
			
			var vertexMap:Object = {};
			var tv:Number;
			for (var l:int = 0; l <= lengthSegs; l++) {
				var z:Number = width - l * unitWidth;
				if (generateTexCoords) tv = 1 - (z + width) / (2 * width);
				var head:String = l.toString() + '_';
				for (var w:int = 0; w <= widthSegs; w++) {
					var lx:Number = w * unitLength - length;
					vertices.push(lx, 0, z);
					vertexMap[head+w.toString()] = vertices.length / 3 - 1;
					if (generateTexCoords) texCoords.push((lx + length) / (2 * length), tv);
				}
			}
			var vertexIndices:Vector.<uint> = new Vector.<uint>();
			mo.triangleIndices = vertexIndices;
			var max:uint = lengthSegs * widthSegs;
			for (var i:uint = 0; i < max; i++) {
				var h:int = Math.floor(i / widthSegs);
				var v:int = i % widthSegs;
				var h0:String = h.toString()+'_';
				var h1:String = (h + 1).toString()+'_';
				var v0:String = v.toString();
				var v1:String = (v + 1).toString();
				var index1:int = vertexMap[h0 + v0];
				var index2:int = vertexMap[h0 + v1];
				var index3:int = vertexMap[h1 + v0];
				var index4:int = vertexMap[h1 + v1];
				vertexIndices.push(index1, index2, index3, index2, index4, index3);
			}
			return mo;
		}
	}
}