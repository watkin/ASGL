package asgl.geometries.primitives {
	import asgl.entities.Coordinates3D;
	import asgl.geometries.MeshAsset;
	import asgl.geometries.MeshElement;
	import asgl.geometries.MeshElementType;
	import asgl.math.Float4;
	import asgl.math.Matrix4x4;
	
	public class SimpleBox {
		public static function create(length:Number, width:Number, height:Number, lengthSegs:int=1, widthSegs:int=1, heightSegs:int=1, generateTexCoords:Boolean=true):MeshAsset {
			var halfLength:Number = length * 0.5;
			var halfWidth:Number = width * 0.5;
			var halfHegiht:Number = height * 0.5;
			
			var meshAsset:MeshAsset = new MeshAsset();
			meshAsset.name = 'SimpleBox';
			
			var mo:MeshAsset = SimplePlane.create(length, width, lengthSegs, widthSegs, generateTexCoords);
			var vertices:MeshElement;
			var indices:Vector.<uint>;
			vertices = mo.elements[MeshElementType.VERTEX];
			var max:uint = vertices.values.length;
			indices = mo.triangleIndices;
			var total:uint = indices.length;
			for (var i:uint = 0; i < total; i += 3) {
				var tmp:uint = indices[i];
				indices[i] = indices[int(i + 1)];
				indices[int(i + 1)] = tmp;
			}
			
			var meshVertices:MeshElement = mo.getElement(MeshElementType.VERTEX).clone();
			var meshTexCoords:MeshElement;
			
			meshAsset.elements[MeshElementType.VERTEX] = meshVertices;
			
			if (generateTexCoords) {
				meshTexCoords = mo.getElement(MeshElementType.TEXCOORD).clone();
				meshAsset.elements[MeshElementType.TEXCOORD] = meshTexCoords;
			}
			meshAsset.triangleIndices = mo.triangleIndices.concat();
			var index:int = max / 3;
			
			mo = SimplePlane.create(length, width, lengthSegs, widthSegs, generateTexCoords);
			vertices = mo.elements[MeshElementType.VERTEX];
			max = vertices.values.length;
			for (i = 1; i < max; i += 3) {
				vertices.values[i] += height;
			}
			meshVertices.appendValues(vertices.values);
			if (generateTexCoords) meshTexCoords.appendValues(mo.getElement(MeshElementType.TEXCOORD).values);
			indices = mo.triangleIndices;
			total = indices.length;
			var j:int;
			for (i = 0; i < total; i += 3) {
				indices[i] += index;
				indices[int(i + 1)] += index;
				indices[int(i + 2)] += index;
			}
			meshAsset.triangleIndices = meshAsset.triangleIndices.concat(indices);
			index += max / 3;
			
			mo = SimplePlane.create(length, height, lengthSegs, heightSegs, generateTexCoords);
			var coord:Coordinates3D = new Coordinates3D();
			coord.appendLocalRotation(Float4.createEulerXQuaternion(-Math.PI * 0.5), false);
			coord.appendLocalTranslate(0, halfWidth, 0, false);
			var m:Matrix4x4 = coord.getWorldMatrix();
			vertices = mo.elements[MeshElementType.VERTEX];
			var vertices1:Vector.<Number> = m.transform3x4Vector3(vertices.values);
			max = vertices.values.length;
			for (i = 0; i < max; i += 3) {
				vertices.values[i] = vertices1[i];
				vertices.values[int(i + 1)] = vertices1[int(i + 1)] + halfHegiht;
				vertices.values[int(i + 2)] = vertices1[int(i + 2)];
			}
			meshVertices.appendValues(vertices.values);
			if (generateTexCoords) meshTexCoords.appendValues(mo.getElement(MeshElementType.TEXCOORD).values);
			indices = mo.triangleIndices;
			total = indices.length;
			for (i = 0; i < total; i += 3) {
				indices[i] += index;
				indices[int(i + 1)] += index;
				indices[int(i + 2)] += index;
			}
			meshAsset.triangleIndices = meshAsset.triangleIndices.concat(indices);
			index += max / 3;
			
			mo = SimplePlane.create(length, height, lengthSegs, heightSegs, generateTexCoords);
			coord.identity(false);
			coord.appendLocalRotation(Float4.createEulerXYZQuaternion(-Math.PI * 0.5, 0, Math.PI), false);
			coord.appendLocalTranslate(0, halfWidth, 0, false);
			m = coord.getWorldMatrix(m);
			vertices = mo.elements[MeshElementType.VERTEX];
			vertices1 = m.transform3x4Vector3(vertices.values, vertices1);
			max = vertices.values.length;
			for (i = 0; i < max; i += 3) {
				vertices.values[i] = vertices1[i];
				vertices.values[int(i + 1)] = vertices1[int(i + 1)] + halfHegiht;
				vertices.values[int(i + 2)] = vertices1[int(i + 2)];
			}
			meshVertices.appendValues(vertices.values);
			if (generateTexCoords) meshTexCoords.appendValues(mo.getElement(MeshElementType.TEXCOORD).values);
			indices = mo.triangleIndices;
			total = indices.length;
			for (i = 0; i < total; i += 3) {
				indices[i] += index;
				indices[int(i + 1)] += index;
				indices[int(i + 2)] += index;
			}
			meshAsset.triangleIndices = meshAsset.triangleIndices.concat(indices);
			index += max / 3;
			
			mo = SimplePlane.create(width, height, widthSegs, heightSegs, generateTexCoords);
			coord.identity(false);
			coord.appendLocalRotation(Float4.createEulerXYZQuaternion(-Math.PI * 0.5, 0, Math.PI * 0.5), false);
			coord.appendLocalTranslate(0, halfLength, 0, false);
			m = coord.getWorldMatrix(m);
			vertices = mo.elements[MeshElementType.VERTEX];
			vertices1 = m.transform3x4Vector3(vertices.values, vertices1);
			max = vertices.values.length;
			for (i = 0; i < max; i += 3) {
				vertices.values[i] = vertices1[i];
				vertices.values[int(i + 1)] = vertices1[int(i + 1)] + halfHegiht;
				vertices.values[int(i + 2)] = vertices1[int(i + 2)];
			}
			meshVertices.appendValues(vertices.values);
			if (generateTexCoords) meshTexCoords.appendValues(mo.getElement(MeshElementType.TEXCOORD).values);
			indices = mo.triangleIndices;
			total = indices.length;
			for (i = 0; i < total; i += 3) {
				indices[i] += index;
				indices[int(i + 1)] += index;
				indices[int(i + 2)] += index;
			}
			meshAsset.triangleIndices = meshAsset.triangleIndices.concat(indices);
			index += max / 3;
			
			mo = SimplePlane.create(width, height, widthSegs, heightSegs, generateTexCoords);
			coord.identity(false);
			coord.appendLocalRotation(Float4.createEulerXYZQuaternion(-Math.PI * 0.5, 0, -Math.PI * 0.5), false);
			coord.appendLocalTranslate(0, halfLength, 0, false);
			m = coord.getWorldMatrix(m);
			vertices = mo.elements[MeshElementType.VERTEX];
			vertices1 = m.transform3x4Vector3(vertices.values, vertices1);
			max = vertices.values.length;
			for (i = 0; i < max; i += 3) {
				vertices.values[i] = vertices1[i];
				vertices.values[int(i + 1)] = vertices1[int(i + 1)] + halfHegiht;
				vertices.values[int(i + 2)] = vertices1[int(i + 2)];
			}
			meshVertices.appendValues(vertices.values);
			if (generateTexCoords) meshTexCoords.appendValues(mo.getElement(MeshElementType.TEXCOORD).values);
			indices = mo.triangleIndices;
			total = indices.length;
			for (i = 0; i < total; i += 3) {
				indices[i] += index;
				indices[int(i + 1)] += index;
				indices[int(i + 2)] += index;
			}
			meshAsset.triangleIndices = meshAsset.triangleIndices.concat(indices);
			
			return meshAsset;
		}
	}
}