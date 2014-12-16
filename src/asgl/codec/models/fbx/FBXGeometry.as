package asgl.codec.models.fbx {
	import asgl.geometries.MeshAsset;
	import asgl.geometries.MeshElement;
	import asgl.geometries.MeshElementType;
	import asgl.geometries.MeshElementValueMappingType;

	public class FBXGeometry extends FBXNode {
		public var id:Number;
		public var triangleIndices:Vector.<uint>;
		public var elements:Object;
		
		private var _numVertexPrePolygon:uint;
		
		public function FBXGeometry() {
			name = FBXNodeName.GEOMETRY;
			
			elements = {};
		}
		public function createMeshAsset(transformLRH:Boolean):MeshAsset {
			var ma:MeshAsset = new MeshAsset();
			
			var e:MeshElement;
			
			ma.triangleIndices = triangleIndices.concat();
			for (var name:* in elements) {
				e = elements[name];
				ma.elements[name] = e.clone();
			}
			
			if (transformLRH) {
				var i:uint;
				var len:uint;
				
				len = ma.triangleIndices.length;
				for (i = 0; i < len; i += 3) {
					var i0:uint = ma.triangleIndices[i];
					
					ma.triangleIndices[i] = ma.triangleIndices[int(i + 1)];
					ma.triangleIndices[int(i + 1)] = i0;
				}
				
				for each (e in ma.elements) {
					e.transformLRH();
				}
			}
			
			return ma;
		}
		public override function update():void {
			id = properties[0].numberValue;
			
			var len:uint = children.length;
			for (var i:uint = 0; i < len; i++) {
				var child:FBXNode = children[i];
				var name:String = child.name;
				if (name == FBXNodeName.VERTICES) {
					_parseVertices(child);
				} else if (name == FBXNodeName.POLYGON_VERTEX_INDEX) {
					_parsePolygonVertexIndex(child);
				} else if (name == FBXNodeName.LAYER_ELEMENT_NORMAL) {
					_parseLayerElementNormal(child);
				} else if (name == FBXNodeName.LAYER_ELEMENT_UV) {
					_parseLayerElementUV(child);
				}
			}
		}
		private function _parseLayerElementUV(node:FBXNode):void {
			var element:MeshElement = new MeshElement();
			element.numDataPreElement = 2;
			elements[MeshElementType.TEXCOORD] = element;
			
			var valueNode:FBXNode;
			var indexNode:FBXNode;
			
			var len:uint = node.children.length;
			for (var i:uint = 0; i < len; i++) {
				var child:FBXNode = node.children[i];
				var name:String = child.name;
				if (name == FBXNodeName.UV) {
					valueNode = child;
					var values:Vector.<Number> = valueNode.properties[0].arrayNumberValue;
					var len1:uint = values.length;
					for (var j:uint = 1; j < len1; j += 2) {
						values[j] = 1 - values[j];
					}
				} else if (name == FBXNodeName.UV_INDEX) {
					indexNode = child;
				} else if (name == FBXNodeName.REFERENCE_INFORMATION_TYPE) {
					_parseReferenceInformationType(child, element);
				}
			}
			
			_setElementValues(element, valueNode, indexNode);
		}
		private function _parseVertices(node:FBXNode):void {
			if (node.properties.length > 0) {
				var element:MeshElement = new MeshElement();
				element.numDataPreElement = 3;
				element.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
				element.values = node.properties[0].arrayNumberValue.concat();
				elements[MeshElementType.VERTEX] = element;
			}
		}
		private function _parsePolygonVertexIndex(node:FBXNode):void {
			if (node.properties.length > 0) {
				var src:Vector.<int> = node.properties[0].arrayIntValue;
				var len:uint = src.length;
				
				for (var i:uint = 0; i < len; i++) {
					if (src[i] < 0) {
						_numVertexPrePolygon = i + 1;
						break;
					}
				}
				
				if (_numVertexPrePolygon == 3) {
					triangleIndices = new Vector.<uint>(len);
					for (i = 0; i < len; i ++) {
						triangleIndices[i] = src[i];
						i++;
						triangleIndices[i] = src[i];
						i++;
						triangleIndices[i] = ~src[i];
					}
				} else if (_numVertexPrePolygon == 4) {
					triangleIndices = new Vector.<uint>(len * 0.25 * 6);
					var index:uint = 0;
					for (i = 0; i < len; i += 4) {
						triangleIndices[index++] = src[i];
						triangleIndices[index++] = src[int(i + 1)];
						triangleIndices[index++] = src[int(i + 2)];
						
						triangleIndices[index++] = src[i];
						triangleIndices[index++] = src[int(i + 2)];
						triangleIndices[index++] = ~src[int(i + 3)];
					}
				}
			}
		}
		private function _parseLayerElementNormal(node:FBXNode):void {
			var element:MeshElement = new MeshElement();
			element.numDataPreElement = 3;
			elements[MeshElementType.NORMAL] = element;
			
			var valueNode:FBXNode;
			var indexNode:FBXNode;
			
			var len:uint = node.children.length;
			for (var i:uint = 0; i < len; i++) {
				var child:FBXNode = node.children[i];
				var name:String = child.name;
				if (name == FBXNodeName.NORMALS) {
					valueNode = child;
				} else if (name == FBXNodeName.REFERENCE_INFORMATION_TYPE) {
					_parseReferenceInformationType(child, element);
				}
			}
			
			_setElementValues(element, valueNode, indexNode);
		}
		private function _parseReferenceInformationType(node:FBXNode, element:MeshElement):void {
			if (node.properties.length > 0) {
				var p:FBXNodeProperty = node.properties[0];
				if (p.stringValue == FBXNodePropertyValue.DIRECT) {
					element.valueMappingType = MeshElementValueMappingType.EACH_TRIANGLE_INDEX;
				} else if (p.stringValue == FBXNodePropertyValue.INDEX_TO_DIRECT) {
					element.valueMappingType = MeshElementValueMappingType.SELF_TRIANGLE_INDEX;
				}
			}
		}
		private function _setElementValues(element:MeshElement, valueNode:FBXNode, indexNode:FBXNode):void {
			var values:Vector.<Number>;
			var indices:Vector.<uint>;
			var srcValue:Vector.<Number>;
			var srcIndex:Vector.<int>;
			
			var i:uint;
			var len:uint;
			var index:uint;
			
			if (element.valueMappingType == MeshElementValueMappingType.SELF_TRIANGLE_INDEX) {
				values = valueNode.properties[0].arrayNumberValue.concat();
				
				srcIndex = indexNode.properties[0].arrayIntValue;
				
				if (_numVertexPrePolygon == 3) {
					indices = Vector.<uint>(srcIndex);
				} else if (_numVertexPrePolygon == 4) {
					len = srcIndex.length;
					
					indices = new Vector.<uint>(len * 0.25 * 6);
					index = 0;
					for (i = 0; i < len; i += 4) {
						indices[index++] = srcIndex[i];
						indices[index++] = srcIndex[int(i + 1)];
						indices[index++] = srcIndex[int(i + 2)];
						
						indices[index++] = srcIndex[i];
						indices[index++] = srcIndex[int(i + 2)];
						indices[index++] = srcIndex[int(i + 3)];
					}
				}
			} else if (element.valueMappingType == MeshElementValueMappingType.EACH_TRIANGLE_INDEX) {
				srcValue = valueNode.properties[0].arrayNumberValue;
				
				if (_numVertexPrePolygon == 3) {
					values = srcValue.concat();
				} else if (_numVertexPrePolygon == 4) {
					len = srcValue.length;
					
					values = new Vector.<Number>(len * 0.25 * 6);
					var num:uint = element.numDataPreElement * 4;
					index = 0;
					for (i = 0; i < len; i += num) {
						var k:uint = i + element.numDataPreElement * 0;
						for (var j:uint = 0; j < element.numDataPreElement; j++) {
							values[index++] = srcValue[k + j];
						}
						
						k = i + element.numDataPreElement * 1;
						for (j = 0; j < element.numDataPreElement; j++) {
							values[index++] = srcValue[k + j];
						}
						
						k = i + element.numDataPreElement * 2;
						for (j = 0; j < element.numDataPreElement; j++) {
							values[index++] = srcValue[k + j];
						}
						
						k = i + element.numDataPreElement * 0;
						for (j = 0; j < element.numDataPreElement; j++) {
							values[index++] = srcValue[k + j];
						}
						
						k = i + element.numDataPreElement * 2;
						for (j = 0; j < element.numDataPreElement; j++) {
							values[index++] = srcValue[k + j];
						}
						
						k = i + element.numDataPreElement * 3;
						for (j = 0; j < element.numDataPreElement; j++) {
							values[index++] = srcValue[k + j];
						}
					}
				}
			}
			
			element.values = values;
			element.indices = indices;
		}
	}
}