package asgl.animators {
	import asgl.geometries.MeshAsset;
	import asgl.geometries.MeshElement;
	import asgl.geometries.MeshElementType;
	import asgl.geometries.MeshElementValueMappingType;

	public class SkinnedMeshAsset {
		public var label:String;
		
		public var preOffsetMatrices:Object;
		public var postOffsetMatrices:Object;
		/**
		 * only contain already used bones
		 */
		public var boneNames:Vector.<String>;
		
		public var skinnedVertices:Vector.<SkinnedVertex>;
		
		public function SkinnedMeshAsset() {
		}
		public function optimizeData():void {
			var i:int;
			var j:int;
			var sv:SkinnedVertex;
			var num:int;
			
			var usedBoneNames:Object = {};
			var len:int = skinnedVertices.length;
			for (i = 0; i < len; i++) {
				sv = skinnedVertices[i];
				num = sv.weights.length;
				for (j = 0; j < num; j++) {
					if (sv.weights[j] == 0) {
						sv.weights.splice(j, 1);
						sv.boneNameIndices.splice(j, 1);
						j--;
						num--;
					} else {
						var name:String = boneNames[sv.boneNameIndices[j]];
						if (!(name in usedBoneNames)) usedBoneNames[name] = true;
					}
				}
			}
			
			var numBones:int = boneNames.length;
			for (var k:int = 0; k < numBones; k++) {
				if (!(boneNames[k] in usedBoneNames)) {
					boneNames.splice(k, 1);
					
					for (i = 0; i < len; i++) {
						sv = skinnedVertices[i];
						num = sv.boneNameIndices.length;
						for (j = 0; j < num; j++) {
							if (sv.boneNameIndices[j] > k) {
								sv.boneNameIndices[j]--;
							}
						}
					}
					
					i--;
					numBones--;
				}
			}
		}
		public function setSkinnedMeshElements(asset:MeshAsset, numBlendBone:uint):void {
			if (numBlendBone == 0) {
				numBlendBone = 1;
			} else if (numBlendBone > 4) {
				numBlendBone = 4;
			}
			
			var len:int = skinnedVertices.length;
			
			var boneIndexElement:MeshElement = new MeshElement();
			boneIndexElement.numDataPreElement = numBlendBone;
			boneIndexElement.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
			boneIndexElement.values = new Vector.<Number>(numBlendBone * len);
			var weightElement:MeshElement = new MeshElement();
			weightElement.numDataPreElement = numBlendBone;
			weightElement.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
			weightElement.values = new Vector.<Number>(numBlendBone * len);
			
			asset.elements[MeshElementType.BONE_INDEX] = boneIndexElement;
			asset.elements[MeshElementType.WEIGHT] = weightElement;
			
			for (var i:int = 0; i < len; i++) {
				var sv:SkinnedVertex = skinnedVertices[i];
				var index0:int = i * numBlendBone;
				
				var j:int;
				var index1:int;
				var numBones:int = sv.boneNameIndices.length;
				
				if (numBones > numBlendBone) {
					_quickSort(sv, 0, sv.weights.length - 1);
					
					var validWeights:Number = 0;
					for (j = 0; j < numBlendBone ; j++) {
						validWeights += sv.weights[j];
					}
					var totalWeights:Number = validWeights;
					for (; j < numBones; j++) {
						totalWeights += sv.weights[j];
					}
					
					for (j = 0; j < numBlendBone ; j++) {
						index1 = index0 + j;
						boneIndexElement.values[index1] = sv.boneNameIndices[j] * 3;
						weightElement.values[index1] = totalWeights * sv.weights[j] / validWeights;
					}
				} else {
					for (j = 0; j < numBones; j++) {
						index1 = index0 + j;
						boneIndexElement.values[index1] = sv.boneNameIndices[j] * 3;
						weightElement.values[index1] = sv.weights[j];
					}
					
					for (; j < numBlendBone; j++) {
						index1 = index0 + j;
						boneIndexElement.values[index1] = 0;
						weightElement.values[index1] = 0;
					}
				}
			}
		}
		private function _quickSort(data:SkinnedVertex, left:int, right:int):void {
			if (left < right) {
				var weights:Vector.<Number> = data.weights;
				var middle:Number = weights[int((left + right) * 0.5)];
				
				var i:int = left - 1;
				var j:int = right + 1;
				
				while (true) {
					while (weights[++i] > middle);
					
					while (weights[--j] < middle);
					
					if (i >= j) break;
					
					var temp:* = weights[i];
					weights[i] = weights[j];
					weights[j] = temp;
					
					temp = data.boneNameIndices[i];
					data.boneNameIndices[i] = data.boneNameIndices[j];
					data.boneNameIndices[j] = temp;
				}
				
				_quickSort(data, left, i - 1);
				_quickSort(data, j + 1, right);
			}
		}
	}
}