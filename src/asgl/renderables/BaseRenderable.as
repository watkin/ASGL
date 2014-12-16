package asgl.renderables {
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DTriangleFace;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import asgl.asgl_protected;
	import asgl.entities.Camera3D;
	import asgl.entities.Object3D;
	import asgl.events.ASGLEvent;
	import asgl.geometries.MeshAsset;
	import asgl.geometries.MeshBuffer;
	import asgl.materials.Material;
	import asgl.materials.MaterialProperty;
	import asgl.renderers.BaseRenderContext;
	import asgl.renderers.BaseRenderer;
	import asgl.shaders.scripts.ShaderConstants;
	import asgl.shaders.scripts.ShaderConstantsCollection;
	import asgl.system.BlendFactorsData;
	import asgl.system.Device3D;
	import asgl.utils.NumberLong;
	
	use namespace asgl_protected;

	public class BaseRenderable {
		public static const MAX_PRIORITY:int = 65535;//16bits
		public static const MAX_QUEUE:int = 31;//5bits
		public static const MAX_SHADER_ID:int = 1023;//10bits
		
		public var culling:String = Context3DTriangleFace.NONE;
		public var depthWrite:Boolean = true;
		public var depthTest:String = Context3DCompareMode.LESS_EQUAL;
		
		public var scissorRectangle:Rectangle;
		
		public var receiveShadows:Boolean;
		
		asgl_protected var _renderer:BaseRenderer;
		
		asgl_protected var _textureRegions:Object;
		
		asgl_protected var _blendFactors:BlendFactorsData;
		asgl_protected var _transparentBlendFactors:BlendFactorsData;
		
		asgl_protected var _meshBuffer:MeshBuffer;
		asgl_protected var _meshAsset:MeshAsset;
		asgl_protected var _material:Material;
		asgl_protected var _materialProperty:MaterialProperty;
		asgl_protected var _shaderID:uint;
		
		/**
		 * 53bits
		 */
		asgl_protected var _renderSortValue:Number;
		asgl_protected var _highRenderSortValue:uint;
		asgl_protected var _lowRenderSortValue:uint;
		
		asgl_protected var _object3D:Object3D;
		
		asgl_protected var _priority:uint;
		asgl_protected var _queue:uint;
		
		/**
		 * hide
		 */
		asgl_protected var _staticKey:String;
		
		public function BaseRenderable() {
			_renderSortValue = 0;
			_blendFactors = BlendFactorsData.NO_BLEND;
			_textureRegions = {};
			receiveShadows = true;
		}
		public function get blendFactors():BlendFactorsData {
			return _blendFactors;
		}
		public function set blendFactors(value:BlendFactorsData):void {
			if (value == null) {
				_blendFactors = BlendFactorsData.NO_BLEND;
			} else {
				_blendFactors = value;
			}
		}
		public function get material():Material {
			return _material;
		}
		public function set material(value:Material):void {
			if (_material != value) {
				if (_material != null) {
					_material.removeEventListener(ASGLEvent.UPDATE_SHADER_PROGRAM, _updateShaderProgramHandler);
				}
				
				_material = value;
				
				if (_material != null && _materialProperty == null) {
					_material.addEventListener(ASGLEvent.UPDATE_SHADER_PROGRAM, _updateShaderProgramHandler, false, 0, true);
					_updateShaderProgramHandler(null);
				} else {
					_shaderID = 0;
					
					_lowRenderSortValue = (_lowRenderSortValue & 0xFFFFFC00) | _shaderID;
					_renderSortValue = _highRenderSortValue * NumberLong.HIGH_CONST + _lowRenderSortValue;
				}
			}
		}
		public function get materialProperty():MaterialProperty {
			return _materialProperty;
		}
		public function set materialProperty(value:MaterialProperty):void {
			if (_materialProperty != value) {
				_materialProperty = value;
				
				if (_materialProperty == null) {
					if (_material != null) {
						_material.addEventListener(ASGLEvent.UPDATE_SHADER_PROGRAM, _updateShaderProgramHandler, false, 0, true);
						
						_updateShaderProgramHandler(null);
					}
				} else if (_material != null) {
					_material.removeEventListener(ASGLEvent.UPDATE_SHADER_PROGRAM, _updateShaderProgramHandler);
				}
			}
		}
		public function get meshAsset():MeshAsset {
			return _meshAsset;
		}
		public function get meshBuffer():MeshBuffer {
			return _meshBuffer;
		}
		public function set meshBuffer(value:MeshBuffer):void {
			if (_meshBuffer != null) _meshBuffer.removeEventListener(ASGLEvent.DISPOSE, _disposeMeshBufferHandler);
			
			_meshBuffer = value;
			
			if (_meshBuffer != null) _meshBuffer.addEventListener(ASGLEvent.DISPOSE, _disposeMeshBufferHandler, false, 0, true);
		}
		public function get object3D():Object3D {
			return _object3D;
		}
		public function get priority():uint {
			return _priority;
		}
		public function set priority(value:uint):void {
			_priority = value;
			if (_priority > MAX_PRIORITY) throw new Error();
			
			_highRenderSortValue = (_highRenderSortValue & 0x1F0000) | value;
			_renderSortValue = _highRenderSortValue * NumberLong.HIGH_CONST + _lowRenderSortValue;
		}
		public function get queue():uint {
			return _queue;
		}
		public function set queue(value:uint):void {
			_queue = value;
			if (_queue > MAX_QUEUE) throw new Error();
			
			_highRenderSortValue = (_queue << 16) | (_highRenderSortValue & 0xFFFF);
			_renderSortValue = _highRenderSortValue * NumberLong.HIGH_CONST + _lowRenderSortValue;
		}
		public function get renderer():BaseRenderer {
			return _renderer;
		}
		public function set renderer(value:BaseRenderer):void {
			_renderer = value;
		}
		public function get transparentBlendFactors():BlendFactorsData {
			return _transparentBlendFactors;
		}
		public function set transparentBlendFactors(value:BlendFactorsData):void {
			_transparentBlendFactors = value;
		}
		public function setConstants(name:String, value:ShaderConstants):void {
			if (_materialProperty == null) {
				if (_material != null) _material.setConstants(name, value);
			} else {
				_materialProperty.setConstants(name, value);
			}
		}
		public function setConstantsCollection(c:ShaderConstantsCollection, clearOld:Boolean=true):void {
			if (_materialProperty == null) {
				if (_material != null) _material.setConstantsCollection(c, clearOld);
			} else {
				_materialProperty.setConstantsCollection(c, clearOld);
			}
		}
		public function setDefine(name:String, value:*):void {
			if (_materialProperty == null) {
				if (_material != null) _material.setDefine(name, value);
			} else {
				_materialProperty.setDefine(name, value);
			}
		}
		public function setTextureRegion(name:String, region:Rectangle):void {
			if (region == null) {
				delete _textureRegions[name];
			} else {
				_textureRegions[name] = region;
			}
		}
		public function updateShaderProgram():void {
			if (_material != null) {
				_material.updateShaderProgram(_materialProperty);
				
				if (_materialProperty != null) {
					if (_shaderID != _materialProperty._shaderProgramID) {
						_shaderID = _materialProperty._shaderProgramID;
						
						if (_shaderID > MAX_SHADER_ID) throw new Error();
						
						_lowRenderSortValue = (_lowRenderSortValue & 0xFFFFFC00) | _shaderID;
						_renderSortValue = _highRenderSortValue * NumberLong.HIGH_CONST + _lowRenderSortValue;
					}
				}
			}
		}
		
		public function collectRenderObject(device:Device3D, camera:Camera3D, context:BaseRenderContext):void {
			context.pushRenderable(this);
		}
		public function preRender(device:Device3D, camera:Camera3D):void {
		}
		public function postRender(device:Device3D, camera:Camera3D):void {
		}
		
		protected function _disposeShaderProgramHandler(e:Event):void {
			
		}
		protected function _updateShaderProgramHandler(e:Event):void {
			if (_material == null || _material._shaderProgram == null) {
				_shaderID = 0;
			} else {
				_shaderID = _material._shaderProgram.id;
			}
			
			if (_shaderID > MAX_SHADER_ID) throw new Error();
			
			_lowRenderSortValue = (_lowRenderSortValue & 0xFFFFFC00) | _shaderID;
			_renderSortValue = _highRenderSortValue * NumberLong.HIGH_CONST + _lowRenderSortValue;
		}
		private function _disposeMeshBufferHandler(e:Event):void {
			meshBuffer = null;
		}
	}
}