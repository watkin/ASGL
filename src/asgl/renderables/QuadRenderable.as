package asgl.renderables {
	import flash.geom.Rectangle;
	
	import asgl.asgl_protected;
	import asgl.animators.SpriteSheetAsset;
	import asgl.geometries.MeshAsset;
	import asgl.geometries.MeshElement;
	import asgl.geometries.MeshElementType;
	import asgl.geometries.MeshElementValueMappingType;
	import asgl.math.Float2;
	import asgl.shaders.scripts.ShaderPropertyType;
	import asgl.system.AbstractTextureData;
	import asgl.system.BlendFactorsData;
	import asgl.utils.AlignType;
	
	use namespace asgl_protected;

	public class QuadRenderable extends BaseRenderable {
		asgl_protected var _vertices:Vector.<Number>;
		asgl_protected var _texCoords:Vector.<Number>;
		
		public function QuadRenderable() {
			_meshAsset = new MeshAsset();
			
			var vertexElement:MeshElement = new MeshElement();
			vertexElement.numDataPreElement = 3;
			vertexElement.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
			_vertices = new Vector.<Number>(12);
			vertexElement.values = _vertices;
			_meshAsset.elements[MeshElementType.VERTEX] = vertexElement;
			
			var texCoordElement:MeshElement = new MeshElement();
			texCoordElement.numDataPreElement = 2;
			texCoordElement.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
			_texCoords = new Vector.<Number>(8);
			texCoordElement.values = _texCoords;
			_meshAsset.elements[MeshElementType.TEXCOORD] = texCoordElement;
			
			_texCoords[2] = 1;
			
			_texCoords[4] = 1;
			_texCoords[5] = 1;
			
			_texCoords[7] = 1;
			
			_blendFactors = BlendFactorsData.ALPHA_BLEND;
		}
		public function setQuadTexCoords(leftTopU:Number, leftTopV:Number, rightTopU:Number, rightTopV:Number,
										 rightBottomU:Number, rightBottomV:Number, leftBottomU:Number, leftBottomV:Number):void {
			_texCoords[0] = leftTopU;
			_texCoords[1] = leftTopV;
			
			_texCoords[2] = rightTopU;
			_texCoords[3] = rightTopV;
			
			_texCoords[4] = rightBottomU;
			_texCoords[5] = rightBottomV;
			
			_texCoords[6] = leftBottomU;
			_texCoords[7] = leftBottomV;
		}
		public function setQuadTexCoordsFromRectangle(rect:Rectangle):void {
			var u:Number = rect.x + rect.width;
			var v:Number = rect.y + rect.height;
			
			_texCoords[0] = rect.x;
			_texCoords[1] = rect.y;
			
			_texCoords[2] = u;
			_texCoords[3] = rect.y;
			
			_texCoords[4] = u;
			_texCoords[5] = v;
			
			_texCoords[6] = rect.x;
			_texCoords[7] = v;
		}
		public function setQuadVertices(leftTopX:Number, leftTopY:Number, rightTopX:Number, rightTopY:Number,
										rightBottomX:Number, rightBottomY:Number, leftBottomX:Number, leftBottomY:Number):void {
			_vertices[0] = leftTopX;
			_vertices[1] = leftTopY;
			
			_vertices[3] = rightTopX;
			_vertices[4] = rightTopY;
			
			_vertices[6] = rightBottomX;
			_vertices[7] = rightBottomY;
			
			_vertices[9] = leftBottomX;
			_vertices[10] = leftBottomY;
		}
		public function setQuadVerticesFromRectangle(rect:Rectangle):void {
			var x:Number = rect.x + rect.width;
			var y:Number = rect.y + rect.height;
			
			_vertices[0] = rect.x;
			_vertices[1] = rect.y;
			
			_vertices[3] = x;
			_vertices[4] = rect.y;
			
			_vertices[6] = x;
			_vertices[7] = y;
			
			_vertices[9] = rect.x;
			_vertices[10] = y;
		}
		public function setQuadVerticesFromTextureRegion(alignX:int=AlignType.RIGHT, alignY:int=AlignType.BOTTOM):void {
			var tex:AbstractTextureData;
			
			if (_material != null) tex = _material._textures[ShaderPropertyType.DIFFUSE_TEX];
			
			if (tex == null) {
				setQuadVerticesFromWH(0, 0);
			} else {
				setQuadVerticesFromWH(tex.regionWidth, tex.regionHeight, alignX, alignY);
			}
		}
		public function setQuadVerticesFromWH(w:Number, h:Number, alignX:int=AlignType.RIGHT, alignY:int=AlignType.BOTTOM):void {
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
			
			_vertices[0] = ox;
			_vertices[1] = oy;
			
			_vertices[3] = ox + w;
			_vertices[4] = oy;
			
			_vertices[6] = ox + w;
			_vertices[7] = oy - h;
			
			_vertices[9] = ox;
			_vertices[10] = oy - h;
		}
		public function setQuadFromSpriteSheetAsset(ssa:SpriteSheetAsset, vertexOffset:Float2=null):void {
			var vertices:Vector.<Number> = ssa.vertices;
			if (vertexOffset == null) {
				setQuadVertices( vertices[0], vertices[1], 
					vertices[3], vertices[4], 
					vertices[6], vertices[7], 
					vertices[9], vertices[10]);
			} else {
				setQuadVertices( vertexOffset.x + vertices[0], vertexOffset.y + vertices[1], 
					vertexOffset.x + vertices[3], vertexOffset.y + vertices[4], 
					vertexOffset.x + vertices[6], vertexOffset.y + vertices[7], 
					vertexOffset.x + vertices[9], vertexOffset.y + vertices[10]);
			}
			setQuadTexCoordsFromRectangle(ssa.textureRegion);
		}
		public function setTexCoord(vertexIndex:uint, u:Number, v:Number):void {
			var index:int = vertexIndex * 2;
			
			_texCoords[index++] = u;
			_texCoords[index] = v;
		}
		public function setVertex(vertexIndex:uint, x:Number, y:Number):void {
			var index:int = vertexIndex * 3;
			
			_vertices[index++] = x;
			_vertices[index] = y;
		}
	}
}