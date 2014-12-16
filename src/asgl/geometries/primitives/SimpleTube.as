package asgl.geometries.primitives {
	import asgl.entities.Coordinates3D;
	import asgl.geometries.MeshAsset;
	import asgl.geometries.MeshElement;
	import asgl.geometries.MeshElementType;
	import asgl.geometries.MeshElementValueMappingType;
	import asgl.math.Float3;
	import asgl.math.Float4;
	import asgl.math.Matrix4x4;
	
	public class SimpleTube {
		public static function create(radius1:Number, radius2:Number, height:Number, heightSegs:uint=1, capSegs:uint=1, sides:uint=3, generateTexCoords:Boolean=true):MeshAsset {
			if (heightSegs <1 ) heightSegs = 1;
			if (capSegs < 1) capSegs = 1;
			if (sides < 3) sides = 3;
			
			var mo:MeshAsset = new MeshAsset();
			mo.name = 'SimpleTube';
			
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
			var coord:Coordinates3D = new Coordinates3D();
			var m:Matrix4x4 = new Matrix4x4();
			var v:Float3 = new Float3(radius2);
			var wv:Float3 = new Float3();
			var v2:Float3 = new Float3(0.5);
			if (generateTexCoords) texCoords.push(0.5, 0.5);
			var unitAngle:Number = Math.PI * 2 / sides;
			var unitRadius:Number = (radius2 - radius1) / capSegs;
			var maxR:Number = radius2;
			if (radius1 > radius2) maxR = radius1;
			var abs:Number = radius2 - radius1;
			if (abs < 0) abs = -abs;
			var unitUV:Number;
			if (maxR == 0) {
				unitUV = 1 / capSegs;
			} else {
				unitUV = abs / maxR / capSegs;
			}
			var d:int = sides + 1;
			var j:uint;
			var index:int;
			var index1:int;
			var index2:int;
			var index3:int;
			var index4:int;
			for (var i:uint = 0; i <= capSegs; i++) {
				if (i != 0) {
					v.x -= unitRadius;
					if (generateTexCoords) v2.x -= unitUV;
				}
				coord.identity(false);
				m = coord.getWorldMatrix(m);
				wv = m.transform3x4Float3(v, wv);
				vertices.push(wv.x, height, wv.z);
				if (generateTexCoords) {
					wv = m.transform3x4Float3(v2, wv);
					texCoords.push(0.5 + wv.x, 0.5 - wv.z);
				}
				for (j = 0; j < sides; j++) {
					coord.appendLocalRotation(Float4.createEulerYQuaternion(unitAngle), false);
					m = coord.getWorldMatrix(m);
					wv = m.transform3x4Float3(v, wv);
					vertices.push(wv.x, height, wv.z);
					if (generateTexCoords) {
						wv = m.transform3x4Float3(v2, wv);
						texCoords.push(0.5 + wv.x, 0.5 - wv.z);
					}
				}
				if (i != 0) {
					for (j = 0; j < sides; j++) {
						index3 = d * i + j;
						index4 = index3 + 1;
						index1 = index3 - d;
						index2 = index1 + 1;
						vertexIndices.push(index1, index2, index3, index3, index2, index4);
					}
				}
			}
			
			index = vertices.length / 3;
			v.x = radius2;
			v2.x = 0.5;
			for (i = 0; i <= capSegs; i++) {
				if (i != 0) {
					v.x -= unitRadius;
					if (generateTexCoords) v2.x -= unitUV;
				}
				coord.identity(false);
				m = coord.getWorldMatrix(m);
				wv = m.transform3x4Float3(v, wv);
				vertices.push(wv.x, 0, wv.z);
				if (generateTexCoords) {
					wv = m.transform3x4Float3(v2, wv);
					texCoords.push(0.5 + wv.x, 0.5 - wv.z);
				}
				for (j = 0; j < sides; j++) {
					coord.appendLocalRotation(Float4.createEulerYQuaternion(unitAngle), false);
					m = coord.getWorldMatrix(m);
					wv = m.transform3x4Float3(v, wv);
					vertices.push(wv.x, 0, wv.z);
					if (generateTexCoords) {
						wv = m.transform3x4Float3(v2, wv);
						texCoords.push(0.5 + wv.x, 0.5 - wv.z);
					}
				}
				if (i != 0) {
					for (j = 0; j < sides; j++) {
						index3 = d * i + j + index;
						index4 = index3 + 1;
						index1 = index3 - d;
						index2 = index1 + 1;
						vertexIndices.push(index2, index1, index3, index2, index3, index4);
					}
				}
			}
			
			var unitH:Number = height / heightSegs;
			var h:Number = height;
			v.x = radius2;
			index = vertices.length / 3;
			var currentV:Number;
			for (i = 0; i <= heightSegs; i++) {
				if (i != 0) h -= unitH;
				coord.identity(false);
				if (generateTexCoords) currentV = i / heightSegs;
				for (j = 0; j <= sides; j++) {
					if (j != 0) coord.appendLocalRotation(Float4.createEulerYQuaternion(unitAngle), false);
					m = coord.getWorldMatrix(m);
					wv = m.transform3x4Float3(v, wv);
					vertices.push(wv.x, h, wv.z);
					if (generateTexCoords) texCoords.push(j / sides, currentV);
				}
				if (i != 0) {
					for (j = 0; j < sides; j++) {
						index3 = i * d + index + j;
						index4 = index3 + 1;
						index1 = index3 - d;
						index2 = index1 + 1;
						vertexIndices.push(index1, index4, index2, index1, index3, index4);
					}
				}
			}
			
			h = height;
			v.x = radius1;
			index = vertices.length / 3;
			for (i = 0; i <= heightSegs; i++) {
				if (i != 0) h -= unitH;
				coord.identity(false);
				if (generateTexCoords) currentV = i / heightSegs;
				for (j = 0; j <= sides; j++) {
					if (j != 0) coord.appendLocalRotation(Float4.createEulerYQuaternion(unitAngle), false);
					m = coord.getWorldMatrix(m);
					wv = m.transform3x4Float3(v, wv);
					vertices.push(wv.x, h, wv.z);
					if (generateTexCoords) texCoords.push(j / sides, currentV);
				}
				if (i != 0) {
					for (j = 0; j < sides; j++) {
						index3 = i * d + index + j;
						index4 = index3 + 1;
						index1 = index3 - d;
						index2 = index1 + 1;
						vertexIndices.push(index4, index1, index2, index3, index1, index4);
					}
				}
			}
			
			return mo;
		}
	}
}