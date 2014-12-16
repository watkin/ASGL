package asgl.renderers {
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import asgl.asgl_protected;
	import asgl.entities.Camera3D;
	import asgl.entities.Object3D;
	import asgl.events.ASGLEvent;
	import asgl.geometries.MeshElement;
	import asgl.geometries.MeshElementType;
	import asgl.geometries.MeshHelper;
	import asgl.materials.Material;
	import asgl.materials.MaterialProperty;
	import asgl.math.Matrix4x4;
	import asgl.renderables.BaseRenderable;
	import asgl.shaders.scripts.Shader3D;
	import asgl.shaders.scripts.ShaderConstants;
	import asgl.shaders.scripts.ShaderPropertyType;
	import asgl.shaders.scripts.builtin.priorityfill.ConstantBatchShaderAsset;
	import asgl.shaders.scripts.builtin.priorityfill.VertexBatchShaderAsset;
	import asgl.system.AbstractTextureData;
	import asgl.system.BlendFactorsData;
	import asgl.system.Device3D;
	import asgl.system.IndexBufferData;
	import asgl.system.ProgramData;
	import asgl.system.VertexBufferData;
	
	use namespace asgl_protected;
	
	public class QuadBatchRenderer extends BaseRenderer {
		private static const CONSTANT_BATCH_MAX_QUAD:int = 15;
		
		public static const BATCH_DATA_BUFFER0:String = 'dataBuffer0';
		public static const BATCH_DATA_BUFFER1:String = 'dataBuffer1';
		public static const BATCH_DATA_CONSTANTS:String = 'batchData';
		
		private var _vertexBatchData1Vector:Vector.<Number>;
		private var _vertexBatchData2Vector:Vector.<Number>;
		private var _vertexBatchIndexVector:Vector.<uint>;
		private var _vertexBatchData1Buffer:VertexBufferData;
		private var _vertexBatchData2Buffer:VertexBufferData;
		private var _vertexBatchIndexBuffer:IndexBufferData;
		private var _vertexBatchMaterial:Material;
		private var _vertexBatchTexFormat:String;
		private var _vertexBatchVertexBuffers:Object;
		private var _vertexBatchQuadNum:int;
		
		private var _constantBatchConstVector:Vector.<Number>;
		private var _constantBatchShaderConstants:ShaderConstants;
		private var _constantBatchVertexBuffer:VertexBufferData;
		private var _constantBatchIndexBuffer:IndexBufferData;
		private var _constantBatchMaterial:Material;
		private var _constantBatchTexFormat:String;
		private var _constantBatchVertexBuffers:Object;
		
		private var _device:Device3D;
		
		private var _renderables:Vector.<BaseRenderable>;
		private var _numRenderables:int;
		
		private var _texID:uint;
		private var _texSampleState:uint;
		private var _numQuads:int;
		private var _blendFactors:BlendFactorsData;
		private var _scissorRectangle:Rectangle;
		private var _shaderID:uint;
		private var _material:Material;
		private var _materialProperty:MaterialProperty;
		
		private var _staticMap:Object;
		
		public function QuadBatchRenderer(device:Device3D) {
			_device = device;
			
			_staticMap = {};
			
			_renderables = new Vector.<BaseRenderable>(512);
			//================================
			_vertexBatchQuadNum = 32;
			_vertexBatchVertexBuffers = {};
			
			_vertexBatchMaterial = new Material();
			//==================
			_constantBatchVertexBuffers = {};
			
			var numVertices:int = CONSTANT_BATCH_MAX_QUAD * 4;
			
			_constantBatchConstVector = new Vector.<Number>(numVertices * 8);
			var len:int = _constantBatchConstVector.length;
			for (var i:int = 3; i < len; i += 8) {
				_constantBatchConstVector[i] = 1;
			}
			_constantBatchShaderConstants = new ShaderConstants(-1);
			_constantBatchShaderConstants.values = _constantBatchConstVector;
			
			_constantBatchMaterial = new Material();
			_constantBatchMaterial._constants[BATCH_DATA_CONSTANTS] = _constantBatchShaderConstants;
			
			_device.addEventListener(ASGLEvent.RECOVERY, _deviceRecoveryHandler, false, 0, true);
			
			_deviceRecoveryHandler(null);
		}
		public override function dispose():void {
			if (_device != null) {
				_device.removeEventListener(ASGLEvent.RECOVERY, _deviceRecoveryHandler);
				_device = null;
				
				_vertexBatchMaterial.shader.dispose();
				_vertexBatchMaterial = null;
				
				_vertexBatchData2Buffer.dispose();
				_vertexBatchData2Buffer = null;
				_vertexBatchData2Vector = null;
				_vertexBatchData1Buffer.dispose();
				_vertexBatchData1Buffer = null;
				_vertexBatchData1Vector = null;
				_vertexBatchIndexBuffer.dispose();
				_vertexBatchIndexBuffer = null;
				_vertexBatchIndexVector = null;
				_vertexBatchVertexBuffers = null;
				
				_constantBatchMaterial.shader.dispose();
				_constantBatchMaterial = null;
				
				_constantBatchConstVector = null;
				_constantBatchIndexBuffer.dispose();
				_constantBatchIndexBuffer = null;
				_constantBatchVertexBuffer.dispose();
				_constantBatchVertexBuffer = null;
				_constantBatchVertexBuffers = null;
			}
			
			var keys:Vector.<uint> = new Vector.<uint>();
			var num:int = 0;
			for (var key:uint in _staticMap) {
				keys[num++] = key;
			}
			
			for (var i:int = 0; i < num; i++) {
				destroyStatic(keys[i]);
			}
		}
		public override function postRender(device:Device3D, camera:Camera3D, context:BaseRenderContext):void {
			_numQuads = 0;
			_scissorRectangle = null;
			_material = null;
			_materialProperty = null;
			
			delete _vertexBatchMaterial._textures[ShaderPropertyType.DIFFUSE_TEX];
			delete _constantBatchMaterial._textures[ShaderPropertyType.DIFFUSE_TEX];
		}
		public override function pushCheck(renderable:BaseRenderable, material:Material):Boolean {
			if (renderable._material == null) {
				return false;
			} else {
				renderable.updateShaderProgram();
				
				return renderable._meshAsset != null;
			}
		}
		public override function pushRenderable(renderable:BaseRenderable, device:Device3D, camera:Camera3D, material:Material, staticRenderData:Vector.<AbstractStaticRenderData>):void {
			var mat:Material = renderable._material;
			
			var tex:AbstractTextureData = mat._textures[ShaderPropertyType.DIFFUSE_TEX];
			if (tex != null) {
				var blendFactors:BlendFactorsData;
				if (renderable._object3D._multipliedAlpha < 1) {
					blendFactors = renderable._transparentBlendFactors == null ? renderable._blendFactors : renderable._transparentBlendFactors;
				} else {
					blendFactors = renderable._blendFactors;
				}
				
				if (mat._shader != null) renderable.updateShaderProgram();
				
				var isBreak:Boolean = true;
				
				var vertices:MeshElement = renderable._meshAsset.elements[MeshElementType.VERTEX];
				var numQuads:int = vertices.values.length / 12;
				
				if (renderable._shaderID == 0) {
					if (_shaderID != 0) {
						_renderCustom(device, staticRenderData);
						
						_shaderID = 0;
						
						isBreak = false;
						_blendFactors = blendFactors;
						_texID = tex._rootInstancID;
						_texSampleState = tex._samplerStateData._samplerStateValue;
						_scissorRectangle = renderable.scissorRectangle;
						
						_numQuads = numQuads;
						
						_numRenderables = 0;
					} else if (_blendFactors == null) {
						isBreak = false;
						_blendFactors = blendFactors;
						_texID = tex._rootInstancID;
						_texSampleState = tex._samplerStateData._samplerStateValue;
						_scissorRectangle = renderable.scissorRectangle;
						
						_numQuads = numQuads;
					} else if (_texID == tex._rootInstancID && 
						_blendFactors._blendFactorsID == blendFactors._blendFactorsID && 
						_scissorRectangle == renderable.scissorRectangle &&
						_texSampleState == tex._samplerStateData._samplerStateValue) {
						isBreak = false;
						
						_numQuads += numQuads;
					}
					
					if (isBreak) {
						if (_numRenderables > 0) {
							if (_numQuads > CONSTANT_BATCH_MAX_QUAD) {
								_renderVertexBatch(device, staticRenderData);
							} else {
								_renderConstantBatch(device, staticRenderData);
							}
							
							_numRenderables = 0;
						}
						
						_blendFactors = blendFactors;
						_texID = tex._rootInstancID;
						_texSampleState = tex._samplerStateData._samplerStateValue;
						_numQuads = numQuads;
						_scissorRectangle = renderable.scissorRectangle;
					}
					
					_renderables[_numRenderables++] = renderable;
				} else {
					if (_shaderID == 0) {
						isBreak = false;
						
						if (_numRenderables > 0) {
							if (_numQuads > CONSTANT_BATCH_MAX_QUAD) {
								_renderVertexBatch(device, staticRenderData);
							} else {
								_renderConstantBatch(device, staticRenderData);
							}
							
							_numRenderables = 0;
						}
						
						_shaderID = renderable._shaderID;
						_material = renderable._material;
						_materialProperty = renderable._materialProperty;
						
						_blendFactors = blendFactors;
						_texID = tex._rootInstancID;
						_texSampleState = tex._samplerStateData._samplerStateValue;
						_scissorRectangle = renderable.scissorRectangle;
						
						_numQuads = numQuads;
					} else if (_shaderID == renderable._shaderID && _material == renderable._material && _materialProperty == renderable._materialProperty && 
						_texID == tex._rootInstancID && _blendFactors._blendFactorsID == blendFactors._blendFactorsID && 
						_scissorRectangle == renderable.scissorRectangle &&
						_texSampleState == tex._samplerStateData._samplerStateValue) {
						isBreak = false;
						
						_numQuads += numQuads;
					}
					
					if (isBreak) {
						_renderCustom(device, staticRenderData);
						
						_numRenderables = 0;
						
						_shaderID = renderable._shaderID;
						_material = renderable._material
						_materialProperty = renderable._materialProperty;
						
						_blendFactors = blendFactors;
						_texID = tex._rootInstancID;
						_texSampleState = tex._samplerStateData._samplerStateValue;
						_scissorRectangle = renderable.scissorRectangle;
						
						_numQuads = numQuads;
					}
					
					_renderables[_numRenderables++] = renderable;
				}
			}
		}
		public override function render(device:Device3D, staticRenderData:Vector.<AbstractStaticRenderData>):void {
			if (_numRenderables > 0) {
				if (_shaderID == 0) {
					if (_numQuads > CONSTANT_BATCH_MAX_QUAD) {
						_renderVertexBatch(device, staticRenderData);
					} else {
						_renderConstantBatch(device, staticRenderData);
					}
				} else {
					_renderCustom(device, staticRenderData);
					
					_shaderID = 0;
				}
				
				_blendFactors = null;
				_numRenderables = 0;
			}
		}
		public override function renderStatic(device:Device3D, renderID:uint):void {
			var sd:StaticData = _staticMap[renderID];
			if (sd != null) {
				var pd:ProgramData;
				
				if (sd.shaderID == -1) {
					_vertexBatchMaterial._textures[ShaderPropertyType.DIFFUSE_TEX] = sd.texture;
					if (_vertexBatchTexFormat != sd.texture._format) {
						_vertexBatchTexFormat = sd.texture._format;
						_vertexBatchMaterial._shaderProgram = _vertexBatchMaterial._shaderCell.getShaderProgram(_vertexBatchMaterial._textures);
					}
					pd = _vertexBatchMaterial._shaderProgram;
				} else {
					pd = Shader3D._shaderPrograms[_shaderID];
				}
				
				device.setBlendFactorsFormData(sd.blendFactors);
				device.setScissorRectangle(sd.scissorRectangle);
				
				device._vertexBufferManager.resetOccupiedState();
				device._textureManager.resetOccupiedState();
				device.setRenderData(pd, sd.material, sd.materialProperty, sd.buffers);
				device._vertexBufferManager.deactiveOccupiedVertexBuffers();
				device._textureManager.deactiveOccupiedTextures();
				
				sd.indexBuffer.draw();
			}
		}
		public override function destroyStatic(renderID:uint):void {
			var sd:StaticData = _staticMap[renderID];
			if (sd != null) {
				sd.dispose();
				delete _staticMap[renderID];
			}
		}
		private function _renderCustom(device:Device3D, staticRenderData:Vector.<AbstractStaticRenderData>):void {
			if (staticRenderData == null) {
				if (_vertexBatchQuadNum < _numQuads) _dilatationVertexBatch(device, _numQuads);
				
				var index1:int = 0;
				var index2:int = 0;
				var renderable:BaseRenderable;
				var tex:AbstractTextureData;
				
				for (var i:int = 0; i < _numRenderables; i++) {
					renderable = _renderables[i];
					_renderables[i] = null;
					
					tex = renderable._material._textures[ShaderPropertyType.DIFFUSE_TEX];
					var region0:Rectangle = tex._region;
					
					var region1:Rectangle = renderable._textureRegions[ShaderPropertyType.DIFFUSE_TEX];
					
					var regionX:Number = region0.x;
					var regionY:Number = region0.y;
					var regionWidth:Number = region0.width;
					var regionHeight:Number = region0.height;
					if (region1 != null) {
						regionX += region0.width * region1.x;
						regionY += region0.height * region1.y;
						regionWidth *= region1.width;
						regionHeight *= region1.height;
					}
					
					var obj:Object3D = renderable._object3D;
					obj.updateWorldMatrix();
					var l2w:Matrix4x4 = obj._worldMatrix;
					
					var elements:Object = renderable._meshAsset.elements;
					var vertices:MeshElement = elements[MeshElementType.VERTEX];
					var texCoords:MeshElement = elements[MeshElementType.TEXCOORD];
					var len:int = vertices.values.length / 3;
					
					for (var j:int = 0; j < len; j++) {
						var k:int = j * 3;
						
						var x:Number = vertices.values[k++];
						var y:Number = vertices.values[k++];
						var z:Number = vertices.values[k];
						
						_vertexBatchData1Vector[index1++] = x * l2w.m00 + y * l2w.m10 + z * l2w.m20 + l2w.m30;
						_vertexBatchData1Vector[index1++] = x * l2w.m01 + y * l2w.m11 + z * l2w.m21 + l2w.m31;
						_vertexBatchData1Vector[index1++] = x * l2w.m02 + y * l2w.m12 + z * l2w.m22 + l2w.m32;
						
						k = j + j;
						
						_vertexBatchData2Vector[index2++] = regionX + regionWidth * texCoords.values[k++];
						_vertexBatchData2Vector[index2++] = regionY + regionHeight * texCoords.values[k];
						_vertexBatchData2Vector[index2++] = obj._multipliedAlpha;
					}
				}
				
				_vertexBatchData1Buffer.uploadFromVector(_vertexBatchData1Vector);
				_vertexBatchData2Buffer.uploadFromVector(_vertexBatchData2Vector);
				
				device.setBlendFactorsFormData(_blendFactors);
				device.setScissorRectangle(_scissorRectangle);
				
				device._vertexBufferManager.resetOccupiedState();
				device._textureManager.resetOccupiedState();
				device.setRenderData(Shader3D._shaderPrograms[_shaderID], _material, _materialProperty, _vertexBatchVertexBuffers);
				device._vertexBufferManager.deactiveOccupiedVertexBuffers();
				device._textureManager.deactiveOccupiedTextures();
				
				_vertexBatchIndexBuffer.draw(0, _numQuads + _numQuads);
			} else {
				var sd:StaticData = _createStaticBatch(device);
				sd.material = _material;
				sd.materialProperty = _materialProperty;
				sd.shaderID = _shaderID;
				
				_staticMap[sd.renderID] = sd;
				staticRenderData[staticRenderData.length] = sd;
			}
		}
		private function _renderVertexBatch(device:Device3D, staticRenderData:Vector.<AbstractStaticRenderData>):void {
			if (staticRenderData == null) {
				if (_vertexBatchQuadNum < _numQuads) _dilatationVertexBatch(device, _numQuads);
				
				var index1:int = 0;
				var index2:int = 0;
				var renderable:BaseRenderable;
				var tex:AbstractTextureData;
				
				for (var i:int = 0; i < _numRenderables; i++) {
					renderable = _renderables[i];
					_renderables[i] = null;
					
					tex = renderable._material._textures[ShaderPropertyType.DIFFUSE_TEX];
					var region0:Rectangle = tex._region;
					
					var region1:Rectangle = renderable._textureRegions[ShaderPropertyType.DIFFUSE_TEX];
					
					var regionX:Number = region0.x;
					var regionY:Number = region0.y;
					var regionWidth:Number = region0.width;
					var regionHeight:Number = region0.height;
					if (region1 != null) {
						regionX += region0.width * region1.x;
						regionY += region0.height * region1.y;
						regionWidth *= region1.width;
						regionHeight *= region1.height;
					}
					
					var obj:Object3D = renderable._object3D;
					obj.updateWorldMatrix();
					var l2w:Matrix4x4 = obj._worldMatrix;
					
					var elements:Object = renderable._meshAsset.elements;
					var vertices:MeshElement = elements[MeshElementType.VERTEX];
					var texCoords:MeshElement = elements[MeshElementType.TEXCOORD];
					var len:int = vertices.values.length / 3;
					
					for (var j:int = 0; j < len; j++) {
						var k:int = j * 3;
						
						var x:Number = vertices.values[k++];
						var y:Number = vertices.values[k++];
						var z:Number = vertices.values[k];
						
						_vertexBatchData1Vector[index1++] = x * l2w.m00 + y * l2w.m10 + z * l2w.m20 + l2w.m30;
						_vertexBatchData1Vector[index1++] = x * l2w.m01 + y * l2w.m11 + z * l2w.m21 + l2w.m31;
						_vertexBatchData1Vector[index1++] = x * l2w.m02 + y * l2w.m12 + z * l2w.m22 + l2w.m32;
						
						k = j + j;
						
						_vertexBatchData2Vector[index2++] = regionX + regionWidth * texCoords.values[k++];
						_vertexBatchData2Vector[index2++] = regionY + regionHeight * texCoords.values[k];
						_vertexBatchData2Vector[index2++] = obj._multipliedAlpha;
					}
				}
				
				_vertexBatchData1Buffer.uploadFromVector(_vertexBatchData1Vector);
				_vertexBatchData2Buffer.uploadFromVector(_vertexBatchData2Vector);
				
				_vertexBatchMaterial._textures[ShaderPropertyType.DIFFUSE_TEX] = tex;
				if (_vertexBatchTexFormat != tex._format) {
					_vertexBatchTexFormat = tex._format;
					_vertexBatchMaterial._shaderProgram = _vertexBatchMaterial._shaderCell.getShaderProgram(_vertexBatchMaterial._textures);
				}
				
				device.setBlendFactorsFormData(_blendFactors);
				device.setScissorRectangle(_scissorRectangle);
				
				device._vertexBufferManager.resetOccupiedState();
				device._textureManager.resetOccupiedState();
				device.setRenderData(_vertexBatchMaterial._shaderProgram, _vertexBatchMaterial, null, _vertexBatchVertexBuffers);
				device._vertexBufferManager.deactiveOccupiedVertexBuffers();
				device._textureManager.deactiveOccupiedTextures();
				
				_vertexBatchIndexBuffer.draw(0, _numQuads + _numQuads);
			} else {
				var sd:StaticData = _createStaticBatch(device);
				sd.material = _vertexBatchMaterial;
				sd.shaderID = -1;
				
				_staticMap[sd.renderID] = sd;
				staticRenderData[staticRenderData.length] = sd;
			}
		}
		private function _createStaticBatch(device:Device3D):StaticData {
			var index1:int = 0;
			var index2:int = 0;
			var renderable:BaseRenderable;
			var tex:AbstractTextureData;
			
			var vertexBatchData0:Vector.<Number> = new Vector.<Number>(_numQuads * 12);
			var vertexBatchData1:Vector.<Number> = new Vector.<Number>(_numQuads * 12);
			
			for (var i:int = 0; i < _numRenderables; i++) {
				renderable = _renderables[i];
				_renderables[i] = null;
				
				tex = renderable._material._textures[ShaderPropertyType.DIFFUSE_TEX];
				var region0:Rectangle = tex._region;
				
				var region1:Rectangle = renderable._textureRegions[ShaderPropertyType.DIFFUSE_TEX];
				
				var regionX:Number = region0.x;
				var regionY:Number = region0.y;
				var regionWidth:Number = region0.width;
				var regionHeight:Number = region0.height;
				if (region1 != null) {
					regionX += region0.width * region1.x;
					regionY += region0.height * region1.y;
					regionWidth *= region1.width;
					regionHeight *= region1.height;
				}
				
				var obj:Object3D = renderable._object3D;
				obj.updateWorldMatrix();
				var l2w:Matrix4x4 = obj._worldMatrix;
				
				var elements:Object = renderable._meshAsset.elements;
				var vertices:MeshElement = elements[MeshElementType.VERTEX];
				var texCoords:MeshElement = elements[MeshElementType.TEXCOORD];
				var len:int = vertices.values.length / 3;
				
				for (var j:int = 0; j < len; j++) {
					var k:int = j * 3;
					
					var x:Number = vertices.values[k++];
					var y:Number = vertices.values[k++];
					var z:Number = vertices.values[k];
					
					vertexBatchData0[index1++] = x * l2w.m00 + y * l2w.m10 + z * l2w.m20 + l2w.m30;
					vertexBatchData0[index1++] = x * l2w.m01 + y * l2w.m11 + z * l2w.m21 + l2w.m31;
					vertexBatchData0[index1++] = x * l2w.m02 + y * l2w.m12 + z * l2w.m22 + l2w.m32;
					
					k = j + j;
					
					vertexBatchData1[index2++] = regionX + regionWidth * texCoords.values[k++];
					vertexBatchData1[index2++] = regionY + regionHeight * texCoords.values[k];
					vertexBatchData1[index2++] = obj._multipliedAlpha;
				}
			}
			
			var sd:StaticData = new StaticData();
			
			sd.buffers = {};
			var numVertices:int = _numQuads * 4;
			var vertexBatchDataBuffer0:VertexBufferData = device._vertexBufferManager.createVertexBufferData(numVertices, 3);
			vertexBatchDataBuffer0.format = Context3DVertexBufferFormat.FLOAT_3;
			var vertexBatchDataBuffer1:VertexBufferData = device._vertexBufferManager.createVertexBufferData(numVertices, 3);
			vertexBatchDataBuffer1.format = Context3DVertexBufferFormat.FLOAT_3;
			var indexData:Vector.<uint> = MeshHelper.createQuadTriangleIndices(_numQuads);
			sd.indexBuffer = device._indexBufferManager.createIndexBufferData(indexData.length);
			vertexBatchDataBuffer0.uploadFromVector(vertexBatchData0);
			vertexBatchDataBuffer1.uploadFromVector(vertexBatchData1);
			
			sd.batchData0 = vertexBatchData0;
			sd.batchData1 = vertexBatchData1;
			sd.buffers[BATCH_DATA_BUFFER0] = vertexBatchDataBuffer0;
			sd.buffers[BATCH_DATA_BUFFER1] = vertexBatchDataBuffer1;
			sd.indexBuffer.uploadFromVector(indexData);
			sd.texture = tex;
			sd.blendFactors = _blendFactors;
			sd.scissorRectangle = _scissorRectangle;
			sd.renderer = this;
			
			return sd;
		}
		private function _renderConstantBatch(device:Device3D, staticRenderData:Vector.<AbstractStaticRenderData>):void {
			if (staticRenderData == null) {
				var index:int = 0;
				var renderable:BaseRenderable;
				var tex:AbstractTextureData;
				
				for (var i:int = 0; i < _numRenderables; i++) {
					renderable = _renderables[i];
					_renderables[i] = null;
					
					tex = renderable._material._textures[ShaderPropertyType.DIFFUSE_TEX];
					var region0:Rectangle = tex._region;
					
					var region1:Rectangle = renderable._textureRegions[ShaderPropertyType.DIFFUSE_TEX];
					
					var regionX:Number = region0.x;
					var regionY:Number = region0.y;
					var regionWidth:Number = region0.width;
					var regionHeight:Number = region0.height;
					if (region1 != null) {
						regionX += region0.width * region1.x;
						regionY += region0.height * region1.y;
						regionWidth *= region1.width;
						regionHeight *= region1.height;
					}
					
					var obj:Object3D = renderable._object3D;
					obj.updateWorldMatrix();
					var l2w:Matrix4x4 = obj._worldMatrix;
					
					var elements:Object = renderable._meshAsset.elements;
					var vertices:MeshElement = elements[MeshElementType.VERTEX];
					var texCoords:MeshElement = elements[MeshElementType.TEXCOORD];
					var len:int = vertices.values.length / 3;
					
					for (var j:int = 0; j < len; j++) {
						var k:int = j * 3;
						
						var x:Number = vertices.values[k++];
						var y:Number = vertices.values[k++];
						var z:Number = vertices.values[k];
						
						_constantBatchConstVector[index++] = x * l2w.m00 + y * l2w.m10 + z * l2w.m20 + l2w.m30;
						_constantBatchConstVector[index++] = x * l2w.m01 + y * l2w.m11 + z * l2w.m21 + l2w.m31;
						_constantBatchConstVector[index] = x * l2w.m02 + y * l2w.m12  + z * l2w.m22+ l2w.m32;
						
						index += 2;
						
						k = j + j;
						
						_constantBatchConstVector[index++] = regionX + regionWidth * texCoords.values[k++];
						_constantBatchConstVector[index++] = regionY + regionHeight * texCoords.values[k];
						_constantBatchConstVector[index] = obj._multipliedAlpha;
						
						index += 2;
					}
				}
				
				_constantBatchShaderConstants._length = index / 4;
				
				_constantBatchMaterial._textures[ShaderPropertyType.DIFFUSE_TEX] = tex;
				if (_constantBatchTexFormat != tex._format) {
					_constantBatchTexFormat = tex._format;
					_constantBatchMaterial._shaderProgram = _constantBatchMaterial._shaderCell.getShaderProgram(_constantBatchMaterial._textures);
				}
				
				device.setBlendFactorsFormData(_blendFactors);
				device.setScissorRectangle(_scissorRectangle);
				
				device._vertexBufferManager.resetOccupiedState();
				device._textureManager.resetOccupiedState();
				device.setRenderData(_constantBatchMaterial._shaderProgram, _constantBatchMaterial, null, _constantBatchVertexBuffers);
				device._vertexBufferManager.deactiveOccupiedVertexBuffers();
				device._textureManager.deactiveOccupiedTextures();
				
				_constantBatchIndexBuffer.draw(0, _numQuads + _numQuads);
			} else {
				var sd:StaticData = _createStaticBatch(device);
				sd.material = _vertexBatchMaterial;
				sd.shaderID = -1;
				
				_staticMap[sd.renderID] = sd;
				staticRenderData[staticRenderData.length] = sd;
			}
		}
		private function _dilatationVertexBatch(device:Device3D, numQuads:int):void {
			var newNumQuads:int = _vertexBatchQuadNum;
			
			while (newNumQuads < numQuads) {
				newNumQuads *= 2;
			}
			
			var len:int = newNumQuads * 6;
			var start:int;
			
			if (_vertexBatchIndexVector == null) {
				start = 0;
				_vertexBatchIndexVector = new Vector.<uint>(len);
			} else {
				start = _vertexBatchQuadNum;
				_vertexBatchIndexVector.length = len;
			}
			
			var index:int = start * 6;
			
			for (var i:int = start; i < newNumQuads; i++) {
				var index2:int = i * 4;
				
				_vertexBatchIndexVector[index++] = index2;
				_vertexBatchIndexVector[index++] = index2 + 1;
				_vertexBatchIndexVector[index++] = index2 + 2;
				_vertexBatchIndexVector[index++] = index2;
				_vertexBatchIndexVector[index++] = index2 + 2;
				_vertexBatchIndexVector[index++] = index2 + 3;
			}
			
			var numVertices:int = newNumQuads * 4;
			
			if (_vertexBatchIndexBuffer == null) {
				_vertexBatchData1Vector = new Vector.<Number>(numVertices * 3);
				_vertexBatchData2Vector = new Vector.<Number>(numVertices * 3);
			} else {
				_vertexBatchIndexBuffer.dispose();
				_vertexBatchData1Buffer.dispose();
				_vertexBatchData2Buffer.dispose();
				
				_vertexBatchData1Vector.length = numVertices * 3;
				_vertexBatchData2Vector.length = numVertices * 3;
			}
			
			_vertexBatchData1Buffer = device._vertexBufferManager.createVertexBufferData(numVertices, 3);
			_vertexBatchData1Buffer.format = Context3DVertexBufferFormat.FLOAT_3;
			_vertexBatchData2Buffer = device._vertexBufferManager.createVertexBufferData(numVertices, 3);
			_vertexBatchData2Buffer.format = Context3DVertexBufferFormat.FLOAT_3;
			
			_vertexBatchVertexBuffers[BATCH_DATA_BUFFER0] = _vertexBatchData1Buffer;
			_vertexBatchVertexBuffers[BATCH_DATA_BUFFER1] = _vertexBatchData2Buffer;
			
			_vertexBatchIndexBuffer = device._indexBufferManager.createIndexBufferData(_vertexBatchIndexVector.length);
			_vertexBatchIndexBuffer.uploadFromVector(_vertexBatchIndexVector);
			
			_vertexBatchQuadNum = newNumQuads;
		}
		private function _deviceRecoveryHandler(e:Event):void {
			var numVertices:int = CONSTANT_BATCH_MAX_QUAD * 4;
			
			_dilatationVertexBatch(_device, _vertexBatchQuadNum);
			
			if (_vertexBatchMaterial._shader == null) _vertexBatchMaterial.shader = _device.createShader();
			_vertexBatchMaterial.shader.upload(VertexBatchShaderAsset.asset);
			_vertexBatchMaterial.updateShaderProgram();
			
			var vector:Vector.<Number> = new Vector.<Number>(numVertices);
			var len:int = vector.length;
			for (var i:int = 0; i < len; i++) {
				vector[i] = i * 2;
			}
			
			if (_constantBatchVertexBuffer == null) {
				_constantBatchVertexBuffer = _device._vertexBufferManager.createVertexBufferData(numVertices, 1);
				_constantBatchVertexBuffer.format = Context3DVertexBufferFormat.FLOAT_1;
				_constantBatchVertexBuffers[BATCH_DATA_BUFFER0] = _constantBatchVertexBuffer;
			}
			_constantBatchVertexBuffer.uploadFromVector(vector);
			
			if (_constantBatchIndexBuffer == null) _constantBatchIndexBuffer = _device._indexBufferManager.createIndexBufferData(CONSTANT_BATCH_MAX_QUAD * 6);
			_constantBatchIndexBuffer.uploadFromVector(_vertexBatchIndexVector);
			
			if (_constantBatchMaterial._shader == null) _constantBatchMaterial.shader = _device.createShader();
			_constantBatchMaterial.shader.upload(ConstantBatchShaderAsset.asset);
			_constantBatchMaterial.updateShaderProgram();
			
			for each (var sd:StaticData in _staticMap) {
				sd.recovery();
			}
		}
	}
}
import flash.geom.Rectangle;

import asgl.geometries.MeshHelper;
import asgl.materials.Material;
import asgl.materials.MaterialProperty;
import asgl.renderers.AbstractStaticRenderData;
import asgl.renderers.QuadBatchRenderer;
import asgl.system.AbstractTextureData;
import asgl.system.BlendFactorsData;
import asgl.system.IndexBufferData;
import asgl.system.VertexBufferData;

class StaticData extends AbstractStaticRenderData {
	public var batchData0:Vector.<Number>;
	public var batchData1:Vector.<Number>;
	public var buffers:Object;
	public var indexBuffer:IndexBufferData;
	public var texture:AbstractTextureData;
	public var blendFactors:BlendFactorsData;
	public var scissorRectangle:Rectangle;
	public var shaderID:int;
	public var material:Material;
	public var materialProperty:MaterialProperty;
	
	public override function dispose():void {
		if (buffers != null) {
			for each (var buffer:VertexBufferData in buffers) {
				buffer.dispose();
			}
			buffers = null;
			batchData0 = null;
			batchData1 = null;
			
			indexBuffer.dispose();
			indexBuffer = null;
			
			texture = null;
			blendFactors = null;
			scissorRectangle = null;
			material = null;
			materialProperty = null;
			renderer = null;
		}
	}
	public override function recovery():void {
		if (buffers != null) {
			var vb:VertexBufferData = buffers[QuadBatchRenderer.BATCH_DATA_BUFFER0];
			vb.uploadFromVector(batchData0);
			vb = buffers[QuadBatchRenderer.BATCH_DATA_BUFFER1];
			vb.uploadFromVector(batchData1);
			indexBuffer.uploadFromVector(MeshHelper.createQuadTriangleIndices(indexBuffer.numIndices / 6));
		}
	}
}