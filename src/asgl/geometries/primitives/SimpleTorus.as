package asgl.geometries.primitives {
	import asgl.entities.Coordinates3D;
	import asgl.geometries.MeshAsset;
	import asgl.geometries.MeshElement;
	import asgl.geometries.MeshElementType;
	import asgl.geometries.MeshElementValueMappingType;
	import asgl.math.Float3;
	import asgl.math.Float4;
	import asgl.math.Matrix4x4;
	
	public class SimpleTorus {
		public static function create(radius1:Number, radius2:Number, segs:uint=3, sides:uint=3, generateTexCoords:Boolean=true):MeshAsset {
			if (segs < 3) segs = 3;
			if (sides < 3) sides = 3;
			
			var mo:MeshAsset = new MeshAsset();
			mo.name = 'SimpleTorus';
			
			var vertexElement:MeshElement = new MeshElement();
			vertexElement.numDataPreElement = 3;
			vertexElement.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
			var vertices:Vector.<Number> = new Vector.<Number>();
			vertexElement.values = vertices;
			mo.elements[MeshElementType.VERTEX] = vertexElement;
			
			var vertexIndices:Vector.<uint> = new Vector.<uint>();
			mo.triangleIndices = vertexIndices;
			
			var texCoords:Vector.<Number>;
			if (generateTexCoords) {
				var texCoordElement:MeshElement = new MeshElement();
				texCoordElement.numDataPreElement = 2;
				texCoordElement.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
				texCoords = new Vector.<Number>();
				texCoordElement.values = texCoords;
				mo.elements[MeshElementType.TEXCOORD] = texCoordElement;
			}
			
			var coord1:Coordinates3D = new Coordinates3D();
			var coord2:Coordinates3D = new Coordinates3D();
			var m:Matrix4x4 = new Matrix4x4();
			var v:Float3 = new Float3(radius2);
			var wv:Float3 = new Float3();
			var sidesList:Vector.<Float3> = new Vector.<Float3>();
			var unitAngle:Number = Math.PI * 2 / sides;
			var tv:Float3 = new Float3(radius2);
			sidesList.push(tv);
			for (var i:uint = 0; i < sides; i++) {
				coord1.appendLocalRotation(Float4.createEulerYQuaternion(unitAngle), false);
				m = coord1.getWorldMatrix(m);
				wv = m.transform3x4Float3(v, wv);
				tv = new Float3(wv.x, wv.y, wv.z);
				sidesList.push(tv);
			}
			coord1.identity(false);
			coord1.addChild(coord2);
			coord2.appendLocalRotation(Float4.createEulerXQuaternion(Math.PI * 0.5), false);
			coord2.appendLocalTranslate(radius1, 0, 0, false);
			unitAngle = Math.PI * 2 / segs;
			var total:int = sidesList.length;
			var index1:int;
			var index2:int;
			var index3:int;
			var index4:int;
			var currentV:Number;
			var t:int = total - 1;
			for (i = 0; i <= segs; i++) {
				if (i != 0) coord1.appendLocalRotation(Float4.createEulerYQuaternion(unitAngle), false);
				if (generateTexCoords) currentV = i / segs;
				m = coord2.getWorldMatrix(m);
				for (var j:int = 0; j < total; j++) {
					wv = m.transform3x4Float3(sidesList[j], wv);
					vertices.push(wv.x, wv.y, wv.z);
					if (generateTexCoords) texCoords.push(j / t, currentV);
				}
				if (i != 0){
					for (j = 0; j < sides; j++) {
						index3 = total * i + j;
						index4 = index3 + 1;
						index1 = index3 - total;
						index2 = index1 + 1;
						vertexIndices.push(index1, index3, index4, index1, index4, index2);
					}
				}
			}
			
			return mo;
		}
	}
}