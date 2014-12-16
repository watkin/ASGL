package asgl.codec.models.md5 {
	import asgl.animators.SkinnedMeshAsset;
	import asgl.animators.SkinnedVertex;
	import asgl.entities.EntityAsset;
	import asgl.entities.Object3D;
	import asgl.geometries.MeshAsset;
	import asgl.geometries.MeshElement;
	import asgl.geometries.MeshElementType;
	import asgl.geometries.MeshElementValueMappingType;
	import asgl.math.Float3;
	import asgl.math.Float4;
	import asgl.math.Matrix4x4;
	
	public class MD5MeshDecoder {
		public var entityAsset:EntityAsset;
		public var skinnedMeshAssets:Object;
		public var meshAssets:Vector.<MeshAsset>;
		
		private var _meshNameIndex:uint;
		
		public function MD5MeshDecoder(data:String=null, transformLRH:Boolean=false) {
			if (data == null) {
				clear();
			} else {
				decode(data, transformLRH);
			}
		}
		public function clear():void {
			entityAsset = null;
			skinnedMeshAssets = null;
			meshAssets = null;
			_meshNameIndex = 0;
		}
		public function decode(data:String, transformLRH:Boolean=false):void {
			clear();
			
			var meshNames:Object = {};
			
			skinnedMeshAssets = {};
			meshAssets = new Vector.<MeshAsset>();
			var dataList:Array = data.split('\n');
			var mainLength:int = dataList.length;
			var index:int;
			var numBones:uint;
			var j:int;
			var max:int;
			var list:Array;
			var weightInfoList:Vector.<int>;
			var boneMatrices:Vector.<Matrix4x4>;
			var bones:Vector.<Object3D>;
			var vertexIndices:Vector.<uint>;
			var m:Matrix4x4;
			for (var i:int = 0; i < mainLength; i++) {
				var line:String = dataList[i];
				if (line.indexOf('joints {') != -1) {
					index = line.indexOf('//');
					if (index != -1) line = line.substr(0, index);
					var quat:Float4 = new Float4();
					if (entityAsset == null) entityAsset = new EntityAsset();
					entityAsset.rootEntities = new Vector.<Object3D>();
					bones = new Vector.<Object3D>();
					entityAsset.entities = bones;
					boneMatrices = new Vector.<Matrix4x4>();
					while (true) {
						i++;
						line = dataList[i];
						if (line.indexOf('}') != 0) {
							var bone:Object3D = new Object3D();
							index = line.lastIndexOf('"');
							var name:String = line.substring(line.indexOf('"') + 1, index);
							bone.name = name
							line = line.substr(index + 1);
							index = line.indexOf('(');
							var parentIndex:int = int(line.substr(0, index));
							bones[numBones] = bone;
							if (parentIndex == -1) {
								entityAsset.rootEntities.push(bone);
							} else {
								bones[parentIndex].addChild(bone);
							}
							list = line.substring(index + 1, line.indexOf(')')).split(' ');
							_removeEmptyArrayElement(list);
							var tx:Number = list[0];
							var ty:Number = list[1];
							var tz:Number = list[2];
							var jointsInfo:Array = [parentIndex];
							line = line.substr(line.indexOf(')') + 1);
							list = line.substring(line.indexOf('(') + 1, line.lastIndexOf(')')).split(' ');
							_removeEmptyArrayElement(list);
							quat.x = list[0];
							quat.y = list[1];
							quat.z = list[2];
							quat.calculateQuaternionW();
							var matrix:Matrix4x4 = quat.getMatrixFromQuaternion();
							matrix.setLocation(tx, ty, tz);
							if (transformLRH) matrix.transformLRH();
							boneMatrices[numBones] = matrix;
							numBones++;
						} else {
							break;
						}
					}
				} else if (line.indexOf('mesh {') != -1) {
					var meshAsset:MeshAsset = new MeshAsset();
					meshAssets.push(meshAsset);
					weightInfoList = new Vector.<int>();
					while (true) {
						i++;
						line = dataList[i];
						if (line.indexOf('}') != 0) {
							if (line.indexOf('// meshes:') != -1) {
								meshAsset.name = line.substr(line.indexOf('// meshes:') + 11);
								if (meshAsset.name in meshNames) meshAsset.name += '_' + (++_meshNameIndex);
								meshNames[meshAsset.name] = true;
							} else if (line.indexOf('shader') != -1) {
								//todo shader path
							} else if (line.indexOf('numverts') != -1) {
								max = int(line.substr(line.indexOf('numverts') + 8));
								var texCoords:MeshElement = new MeshElement();
								texCoords.numDataPreElement = 2;
								texCoords.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
								texCoords.values = new Vector.<Number>(max * 2);
								meshAsset.elements[MeshElementType.TEXCOORD] = texCoords;
								
								var texCoordIndex:uint = 0;
								
								for (j = 0; j < max; j++) {
									i++;
									line = dataList[i];
									index = line.lastIndexOf(')');
									list = line.substring(line.indexOf('(') + 1, index).split(' ');
									_removeEmptyArrayElement(list);
									texCoords.values[texCoordIndex++] = list[0];
									texCoords.values[texCoordIndex++] = list[1];
									list = line.substr(index+1).split(' ');
									_removeEmptyArrayElement(list);
									weightInfoList.push(list[0], list[1]);
								}
							} else if (line.indexOf('numtris') != -1) {
								max = int(line.substr(line.indexOf('numtris')+7));
								vertexIndices = new Vector.<uint>();
								meshAsset.triangleIndices = vertexIndices;
								for (j = 0; j < max; j++) {
									i++;
									line = dataList[i];
									list = line.substr(line.indexOf('tri') + 3).split(' ');
									_removeEmptyArrayElement(list);
									if (transformLRH) {
										vertexIndices.push(list[2], list[1], list[3]);
									} else {
										vertexIndices.push(list[1], list[2], list[3]);
									}
								}
							} else if (line.indexOf('numweights') != -1) {
								max = int(line.substr(line.indexOf('numweights') + 10));
								var weightList:Vector.<Number> = new Vector.<Number>();
								
								for (j = 0; j < max; j++) {
									i++;
									line = dataList[i];
									index = line.indexOf('(');
									list = line.substring(line.indexOf('weight') + 6, index).split(' ');
									_removeEmptyArrayElement(list);
									weightList.push(list[1], list[2]);
									list = line.substring(index+1, line.lastIndexOf(')')).split(' ');
									_removeEmptyArrayElement(list);
									weightList.push(list[0], list[1], list[2]);
								}
								
								max = weightInfoList.length * 0.5;
								
								var boneNames:Vector.<String> = new Vector.<String>();
								var offsetMatrices:Object = {};
								var skinnedVertices:Vector.<SkinnedVertex> = new Vector.<SkinnedVertex>(max);
								var sma:SkinnedMeshAsset = new SkinnedMeshAsset();
								skinnedMeshAssets[meshAsset.name] = sma;
								sma.preOffsetMatrices = offsetMatrices;
								sma.boneNames = boneNames;
								sma.skinnedVertices = skinnedVertices;
								
								var vertices:MeshElement = new MeshElement();
								vertices.numDataPreElement = 3;
								vertices.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
								vertices.values = new Vector.<Number>(max * 3);
								meshAsset.elements[MeshElementType.VERTEX] = vertices;
								
								var vertexIndex:uint = 0;
								
								var tempMatrix:Matrix4x4 = new Matrix4x4();
								var tempFloat:Float3 = new Float3();
								var boneMap:Object = {};
								for (j = 0; j < max; j++) {
									var k:int = j * 2;
									var weightStartIndex:int = weightInfoList[k];
									var numWeights:int = weightInfoList[int(k + 1)];
									var x:Number = 0;
									var y:Number = 0;
									var z:Number = 0;
									for (var n:int = 0; n < numWeights; n++) {
										k = (weightStartIndex + n) * 5;
										var boneIndex:int = weightList[k];
										var weight:Number = weightList[int(k+1)];
										tempFloat.x = weightList[int(k+2)];
										if (transformLRH) {
											tempFloat.y = weightList[int(k+4)];
											tempFloat.z = weightList[int(k+3)];
										} else {
											tempFloat.y = weightList[int(k+3)];
											tempFloat.z = weightList[int(k+4)];
										}
										m = tempMatrix;
										var sm:Matrix4x4 = boneMatrices[boneIndex];
										
										include '../../../math/Matrix4x4_copyDataFromMatrix4x4.define';
										
										tempFloat = tempMatrix.transform3x4Float3(tempFloat, tempFloat);
										x += weight * tempFloat.x;
										y += weight * tempFloat.y;
										z += weight * tempFloat.z;
										
										bone = bones[boneIndex];
										var boneName:String = bone.name;
										var boneNameIndex:* = boneMap[boneName];
										if (boneNameIndex == null) {
											boneNameIndex = boneNames.length;
											boneMap[boneName] = boneNameIndex;
											boneNames[boneNameIndex] = boneName;
											
											offsetMatrices[boneName] = Matrix4x4.invert(sm);
										}
										
										var svd:SkinnedVertex = skinnedVertices[j];
										if (svd == null) {
											svd.boneNameIndices = new Vector.<uint>();
											svd.weights = new Vector.<Number>();
											skinnedVertices[j] = svd;
										}
										
										index = svd.boneNameIndices.length;
										
										svd.boneNameIndices[index] = boneNameIndex;
										svd.weights[index] = weight;
										//svd.offsetMatrixIndices[index] = boneIndex;
									}
									
									vertices.values[vertexIndex++] = x;
									vertices.values[vertexIndex++] = y;
									vertices.values[vertexIndex++] = z;
								}
							}
						} else {
							break;
						}
					}
				}
			}
		}
		private function _removeEmptyArrayElement(list:Array):void {
			var length:int = list.length;
			for (var i:int = 0; i < length; i++) {
				if (list[i] == '') {
					list.splice(i, 1);
					i--;
					length--;
				}
			}
		}
	}
}