package asgl.geometries.primitives {
	import asgl.entities.Coordinates3D;
	import asgl.geometries.MeshAsset;
	import asgl.geometries.MeshElement;
	import asgl.geometries.MeshElementType;
	import asgl.geometries.MeshElementValueMappingType;
	import asgl.math.Float3;
	import asgl.math.Float4;
	import asgl.math.Matrix4x4;
	
	public class SimpleSphere {
		public static function create(radius:Number, segments:uint=4, generateTexCoords:Boolean=true):MeshAsset {
			if (radius < 0) radius = 0;
			if (segments < 4) segments = 4;
			
			var mo:MeshAsset = new MeshAsset();
			mo.name = 'SimpleSphere';
			
			var numV:uint = uint((segments - 4) * 0.5) + 1;
			var d:Number = radius * 2;
			var coordX:Coordinates3D = new Coordinates3D();
			var coordY:Coordinates3D = new Coordinates3D();
			coordY.addChild(coordX);
			var f3:Float3 = new Float3();
			var opFloat3:Float3 = new Float3();
			var angleX:Number = Math.PI / (numV + 1);
			var angleY:Number = Math.PI * 2 / segments;
			
			var vertexElement:MeshElement = new MeshElement();
			vertexElement.numDataPreElement = 3;
			vertexElement.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
			var vertices:Vector.<Number> = new Vector.<Number>();
			vertexElement.values = vertices;
			mo.elements[MeshElementType.VERTEX] = vertexElement;
			
			vertices.push(0, radius, 0);
			
			var max:int;
			var texCoords:Vector.<Number>;
			if (generateTexCoords) {
				var texCoordElement:MeshElement = new MeshElement();
				texCoordElement.numDataPreElement = 2;
				texCoordElement.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
				texCoords = new Vector.<Number>();
				texCoordElement.values = texCoords;
				mo.elements[MeshElementType.TEXCOORD] = texCoordElement;
				
				texCoords.push(0.5, 0);
				max = numV + 1;
			}
			
			var j:uint;
			var currentV:Number;
			var m:Matrix4x4 = new Matrix4x4();
			for (var i:uint = 1; i <= numV; i++) {
				f3.y = radius;
				coordX.appendLocalRotation(Float4.createEulerXQuaternion(angleX), false);
				coordY.identity(false);
				if (generateTexCoords) currentV = i/max;
				for (j = 0; j <= segments; j++) {
					if (j == segments) coordY.identity(false);
					coordY.appendLocalRotation(Float4.createEulerYQuaternion(angleY));
					m = coordX.getWorldMatrix(m);
					
					include '../../math/Matrix4x4_transform3x4Float3.define';
					
					vertices.push(opFloat3.x, opFloat3.y, opFloat3.z);
					if (generateTexCoords) texCoords.push(j / segments, currentV);
				}
			}
			vertices.push(0, -radius, 0);
			if (generateTexCoords) texCoords.push(0.5, 1);
			
			var vertexIndices:Vector.<uint> = new Vector.<uint>();
			mo.triangleIndices = vertexIndices;
			for (i = 1; i <= segments; i++) {
				vertexIndices.push(0, i, i + 1);
			}
			numV--;
			for (i = 0; i < numV; i++) {
				var h1:uint = 1 + i * (segments + 1);
				var h2:uint = h1 + segments + 1;
				for (j = 0; j < segments; j++) {
					var index1:uint = h1 + j;
					var index2:uint = h2 + j;
					var index3:uint = index2 + 1;
					vertexIndices.push(index1 + 1, index1, index3, index1, index2, index3);
				}
			}
			var last:int = vertices.length / 3 - 1;
			var index:int = last - segments - 2;
			for (i = 1; i <= segments; i++) {
				j = index + i;
				vertexIndices.push(last, j + 1, j);
			}
			
			return mo;
		}
	}
}