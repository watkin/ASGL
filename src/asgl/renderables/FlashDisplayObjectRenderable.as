package asgl.renderables {
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display3D.Context3DMipFilter;
	import flash.display3D.Context3DTextureFilter;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DWrapMode;
	
	import asgl.asgl_protected;
	import asgl.entities.Camera3D;
	import asgl.geometries.MeshAsset;
	import asgl.geometries.MeshElement;
	import asgl.geometries.MeshElementType;
	import asgl.geometries.MeshElementValueMappingType;
	import asgl.materials.Material;
	import asgl.materials.TextureHelper;
	import asgl.math.Float2;
	import asgl.renderers.BaseRenderContext;
	import asgl.shaders.scripts.ShaderPropertyType;
	import asgl.system.AbstractTextureData;
	import asgl.system.BlendFactorsData;
	import asgl.system.Device3D;
	import asgl.system.SamplerStateData;
	import asgl.utils.AlignType;
	
	use namespace asgl_protected;

	public class FlashDisplayObjectRenderable extends BaseRenderable {
		private static var _float2:Float2 = new Float2();
		
		asgl_protected var _height:uint;
		asgl_protected var _width:uint;
		
		asgl_protected var _vertices:Vector.<Number>;
		asgl_protected var _texCoords:Vector.<Number>;
		
		protected var _tex:AbstractTextureData;
		protected var _device:Device3D;
		
		protected var _samplerStateData:SamplerStateData;
		
		public function FlashDisplayObjectRenderable(device:Device3D) {
			_device = device;
			
			_samplerStateData = new SamplerStateData(Context3DWrapMode.CLAMP, Context3DTextureFilter.LINEAR, Context3DMipFilter.MIPNONE);
			
			_blendFactors = BlendFactorsData.ALPHA_BLEND;
			
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
		}
		public function get height():uint {
			return _height;
		}
		public override function set material(value:Material):void {
			if (_material != value) {
				if (_material != null && _tex != null) {
					if (_tex == _material._textures[ShaderPropertyType.DIFFUSE_TEX]) _material.setTexture(ShaderPropertyType.DIFFUSE_TEX, null);
				}
				
				super.material = value;
				
				if (_material != null && _tex != null) _material.setTexture(ShaderPropertyType.DIFFUSE_TEX, _tex);
			}
		}
		public function get samplerStateData():SamplerStateData {
			return _samplerStateData;
		}
		public function get width():uint {
			return _width;
		}
		public function dispose():void {
			if (_device != null) {
				this.material = null;
				
				_device = null;
				
				if (_tex != null) {
					_tex.dispose();
					_tex = null;
				}
			}
		}
		public function setAlign(alignX:int=AlignType.RIGHT, alignY:int=AlignType.BOTTOM):void {
			var ox:Number;
			var oy:Number;
			
			if (alignX == AlignType.LEFT) {
				ox = -_width;
			} else if (alignX == AlignType.CENTER) {
				ox = -_width / 2;
			} else {
				ox = 0;
			}
			
			if (alignY == AlignType.UP) {
				oy = _height;
			} else if (alignY == AlignType.CENTER) {
				oy = _height / 2;
			} else {
				oy = 0;
			}
			
			_vertices[0] = ox;
			_vertices[1] = oy;
			
			_vertices[3] = ox + _width;
			_vertices[4] = oy;
			
			_vertices[6] = ox + _width;
			_vertices[7] = oy - _height;
			
			_vertices[9] = ox;
			_vertices[10] = oy - _height;
		}
		public function updateSamplerData():void {
			if (_tex != null) _tex._samplerStateData.copySamplerState(_samplerStateData);
		}
		public function upload(dis:DisplayObject, textureFormat:String=Context3DTextureFormat.BGRA, powerOfTow:Boolean=true, alignX:int=AlignType.RIGHT, alignY:int=AlignType.BOTTOM):void {
			_width = dis.width;
			_height = dis.height;
			
			var bmd:BitmapData;
			
			if (powerOfTow) {
				var size:Float2 = TextureHelper.convertToPowerOfTow(_width, _height, true, _float2);
				bmd = new BitmapData(size.x, size.y, true, 0x0);
				bmd.draw(dis);
				
				var u:Number = _width / size.x;
				
				_texCoords[2] = u;
				
				_texCoords[4] = u;
				_texCoords[5] = _height / size.y;
				
				if (_tex == null) {
					_tex = _device._textureManager.createTextureData(bmd.width, bmd.height, textureFormat, false);
				} else if (_tex._width != size.x || _tex._height != size.y || _tex._format != textureFormat) {
					_tex.dispose();
					_tex = _device._textureManager.createTextureData(bmd.width, bmd.height, textureFormat, false);
				}
			} else {
				bmd = new BitmapData(_width, _height, true, 0x0);
				bmd.draw(dis);
				
				if (_tex == null) {
					_tex = _device._textureManager.createRectangleTextureData(bmd.width, bmd.height, textureFormat, false);
				} else if (_tex._width != _width || _tex._height != _height || _tex._format != textureFormat) {
					_tex.dispose();
					_tex = _device._textureManager.createRectangleTextureData(bmd.width, bmd.height, textureFormat, false);
				}
			}
			
			_tex.uploadFromBitmapData(bmd);
			_tex._samplerStateData.copySamplerState(_samplerStateData);
			
			if (!_device._cacheTextures) bmd.dispose();
			
			setAlign(alignX, alignY);
			
			if (_material != null) _material.setTexture(ShaderPropertyType.DIFFUSE_TEX, _tex);
		}
		
		public override function collectRenderObject(device:Device3D, camera:Camera3D, context:BaseRenderContext):void {
			if (_width > 0 && _height > 0) super.collectRenderObject(device, camera, context);
		}
	}
}