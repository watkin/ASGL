package asgl.renderables {
	import flash.geom.Rectangle;
	
	import asgl.asgl_protected;
	import asgl.animators.SpriteSheetAsset;
	import asgl.entities.Camera3D;
	import asgl.geometries.MeshAsset;
	import asgl.geometries.MeshElement;
	import asgl.geometries.MeshElementType;
	import asgl.geometries.MeshElementValueMappingType;
	import asgl.math.Float2;
	import asgl.renderers.BaseRenderContext;
	import asgl.system.BlendFactorsData;
	import asgl.system.Device3D;
	import asgl.utils.AlignType;
	
	use namespace asgl_protected;

	public class QuadArrayRenderable extends BaseRenderable {
		protected var _numQuads:uint;
		
		asgl_protected var _vertices:Vector.<Number>;
		asgl_protected var _texCoords:Vector.<Number>;
		
		public function QuadArrayRenderable() {
			_numQuads = 0;
			
			_meshAsset = new MeshAsset();
			
			var vertexElement:MeshElement = new MeshElement();
			vertexElement.numDataPreElement = 3;
			vertexElement.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
			_vertices = new Vector.<Number>();
			vertexElement.values = _vertices;
			_meshAsset.elements[MeshElementType.VERTEX] = vertexElement;
			
			var texCoordElement:MeshElement = new MeshElement();
			texCoordElement.numDataPreElement = 2;
			texCoordElement.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
			_texCoords = new Vector.<Number>();
			texCoordElement.values = _texCoords;
			_meshAsset.elements[MeshElementType.TEXCOORD] = texCoordElement;
			
			_blendFactors = BlendFactorsData.ALPHA_BLEND;
		}
		public function get numQuads():uint {
			return _numQuads;
		}
		public function set numQuads(value:uint):void {
			_numQuads = value;
			
			_vertices.length = value * 12;
			_texCoords.length = value * 8;
		}
		public function setQuadTexCoords(quadIndex:uint, leftTopU:Number, leftTopV:Number, rightTopU:Number, rightTopV:Number,
										 rightBottomU:Number, rightBottomV:Number, leftBottomU:Number, leftBottomV:Number):void {
			if (quadIndex < _numQuads) {
				var vertexIndex:int = quadIndex * 8;
				
				_texCoords[vertexIndex++] = leftTopU;
				_texCoords[vertexIndex++] = leftTopV;
				
				_texCoords[vertexIndex++] = rightTopU;
				_texCoords[vertexIndex++] = rightTopV;
				
				_texCoords[vertexIndex++] = rightBottomU;
				_texCoords[vertexIndex++] = rightBottomV;
				
				_texCoords[vertexIndex++] = leftBottomU;
				_texCoords[vertexIndex] = leftBottomV;
			}
		}
		public function setQuadTexCoordsFromRectangle(quadIndex:uint, rect:Rectangle):void {
			if (quadIndex < _numQuads) {
				var vertexIndex:int = quadIndex * 8;
				
				var u:Number = rect.x + rect.width;
				var v:Number = rect.y + rect.height;
				
				_texCoords[vertexIndex++] = rect.x;
				_texCoords[vertexIndex++] = rect.y;
				
				_texCoords[vertexIndex++] = u;
				_texCoords[vertexIndex++] = rect.y;
				
				_texCoords[vertexIndex++] = u;
				_texCoords[vertexIndex++] = v;
				
				_texCoords[vertexIndex++] = rect.x;
				_texCoords[vertexIndex] = v;
			}
		}
		public function setQuadVertices(quadIndex:uint, leftTopX:Number, leftTopY:Number, rightTopX:Number, rightTopY:Number,
										rightBottomX:Number, rightBottomY:Number, leftBottomX:Number, leftBottomY:Number):void {
			if (quadIndex < _numQuads) {
				var vertexIndex:int = quadIndex * 12;
				
				_vertices[vertexIndex++] = leftTopX;
				_vertices[vertexIndex] = leftTopY;
				
				vertexIndex += 2;
				
				_vertices[vertexIndex++] = rightTopX;
				_vertices[vertexIndex] = rightTopY;
				
				vertexIndex += 2;
				
				_vertices[vertexIndex++] = rightBottomX;
				_vertices[vertexIndex] = rightBottomY;
				
				vertexIndex += 2;
				
				_vertices[vertexIndex++] = leftBottomX;
				_vertices[vertexIndex] = leftBottomY;
			}
		}
		public function setQuadVerticesFromRectangle(quadIndex:uint, rect:Rectangle):void {
			if (quadIndex < _numQuads) {
				var vertexIndex:int = quadIndex * 12;
				
				var x:Number = rect.x + rect.width;
				var y:Number = rect.y + rect.height;
				
				_vertices[vertexIndex++] = rect.x;
				_vertices[vertexIndex] = rect.y;
				
				vertexIndex += 2;
				
				_vertices[vertexIndex++] = x;
				_vertices[vertexIndex] = rect.y;
				
				vertexIndex += 2;
				
				_vertices[vertexIndex++] = x;
				_vertices[vertexIndex] = y;
				
				vertexIndex += 2;
				
				_vertices[vertexIndex++] = rect.x;
				_vertices[vertexIndex] = y;
			}
		}
		public function setQuadVerticesFromWH(quadIndex:uint, w:Number, h:Number, alignX:int=AlignType.RIGHT, alignY:int=AlignType.BOTTOM):void {
			if (quadIndex < _numQuads) {
				var vertexIndex:int = quadIndex * 12;
				
				var ox:Number;
				var oy:Number;
				
				if (alignX == AlignType.LEFT) {
					ox = -w;
				} else if (alignX == AlignType.CENTER) {
					ox = -w / 2;
				} else {
					ox = 0;
				}
				
				if (alignY == AlignType.UP) {
					oy = h;
				} else if (alignY == AlignType.CENTER) {
					oy = h / 2;
				} else {
					oy = 0;
				}
				
				_vertices[vertexIndex++] = ox;
				_vertices[vertexIndex] = oy;
				
				vertexIndex += 2;
				
				_vertices[vertexIndex++] = ox + w;
				_vertices[vertexIndex] = oy;
				
				vertexIndex += 2;
				
				_vertices[vertexIndex++] = ox + w;
				_vertices[vertexIndex] = oy - h;
				
				vertexIndex += 2;
				
				_vertices[vertexIndex++] = ox;
				_vertices[vertexIndex] = oy - h;
			}
		}
		public function setQuadFromSpriteSheetAsset(quadIndex:uint, ssa:SpriteSheetAsset, vertexOffset:Float2=null):void {
			if (quadIndex < _numQuads) {
				var vertices:Vector.<Number> = ssa.vertices;
				if (vertexOffset == null) {
					setQuadVertices(quadIndex, vertices[0], vertices[1], 
						vertices[3], vertices[4], 
						vertices[6], vertices[7], 
						vertices[9], vertices[10]);
				} else {
					setQuadVertices(quadIndex, vertexOffset.x + vertices[0], vertexOffset.y + vertices[1], 
						vertexOffset.x + vertices[3], vertexOffset.y + vertices[4], 
						vertexOffset.x + vertices[6], vertexOffset.y + vertices[7], 
						vertexOffset.x + vertices[9], vertexOffset.y + vertices[10]);
				}
				setQuadTexCoordsFromRectangle(quadIndex, ssa.textureRegion);
			}
		}
		public function setTexCoord(quadIndex:uint, vertexIndex:uint, u:Number, v:Number):void {
			if (quadIndex < _numQuads && vertexIndex < 4) {
				var index:int = quadIndex * 8 + vertexIndex * 2;
				
				_texCoords[index++] = u;
				_texCoords[index] = v;
			}
		}
		public function setVertex(quadIndex:uint, vertexIndex:uint, x:Number, y:Number):void {
			if (quadIndex < _numQuads && vertexIndex < 4) {
				var index:int = quadIndex * 12 + vertexIndex * 3;
				
				_vertices[index++] = x;
				_vertices[index] = y;
			}
		}
		
		public override function collectRenderObject(device:Device3D, camera:Camera3D, context:BaseRenderContext):void {
			if (_numQuads > 0) super.collectRenderObject(device, camera, context);
		}
	}
}