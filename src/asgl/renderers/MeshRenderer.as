package asgl.renderers {
	import asgl.asgl_protected;
	import asgl.entities.Camera3D;
	import asgl.materials.Material;
	import asgl.renderables.BaseRenderable;
	import asgl.shaders.scripts.Shader3D;
	import asgl.shaders.scripts.Shader3DHelper;
	import asgl.shaders.scripts.ShaderConstants;
	import asgl.shaders.scripts.ShaderPropertyType;
	import asgl.system.BlendFactorsData;
	import asgl.system.Device3D;
	import asgl.system.ProgramData;
	
	use namespace asgl_protected;
	
	public class MeshRenderer extends BaseRenderer {
		private var _colorAttConstants:ShaderConstants;
		
		private var _staticMap:Object;
		
		public function MeshRenderer() {
			_colorAttConstants = new ShaderConstants(1);
			_colorAttConstants.values = new Vector.<Number>(4);
			_colorAttConstants.values[0] = 1;
			_colorAttConstants.values[1] = 1;
			_colorAttConstants.values[2] = 1;
			
			_staticMap = {};
		}
		public override function pushCheck(renderable:BaseRenderable, material:Material):Boolean {
			if (material == null) {
				if (renderable._material == null) {
					return false;
				} else {
					renderable.updateShaderProgram();
					
					return renderable._meshBuffer != null && renderable._shaderID != 0 && renderable._meshBuffer._indexBuffer != null;
				}
			} else {
				return renderable._meshBuffer != null && renderable._meshBuffer._indexBuffer != null;
			}
		}
		public override function postRender(device:Device3D, camera:Camera3D, context:BaseRenderContext):void {
			Shader3D.setGlobalConstants(ShaderPropertyType.LOCAL_TO_VIEW_MATRIX, null);
			Shader3D.setGlobalConstants(ShaderPropertyType.LOCAL_TO_WORLD_MATRIX, null);
			Shader3D.setGlobalConstants(ShaderPropertyType.LOCAL_TO_PROJ_MATRIX, null);
			Shader3D.setGlobalConstants(ShaderPropertyType.DIFFUSE_TEX_REGION, null);
			Shader3D.setGlobalConstants(ShaderPropertyType.MULTIPLY_COLOR, null);
		}
		public override function pushRenderable(renderable:BaseRenderable, device:Device3D, camera:Camera3D, material:Material, staticRenderData:Vector.<AbstractStaticRenderData>):void {
			if (staticRenderData == null) {
				renderable.preRender(device, camera);
				
				var mat:Material;
				var p:ProgramData;
				
				if (material == null) {
					mat = renderable._material;
					p = Shader3D._shaderPrograms[renderable._shaderID];
				} else {
					mat = material;
					p = material._shaderProgram;
				}
				
				var constants:Object = p._cell._constants;
				
				if (ShaderPropertyType.LOCAL_TO_VIEW_MATRIX in constants) Shader3DHelper.setGlobalLocalToViewMatrix(renderable._object3D, camera);
				if (ShaderPropertyType.LOCAL_TO_WORLD_MATRIX in constants) Shader3DHelper.setGlobalLocalToWorldMatrix(renderable._object3D);
				if (ShaderPropertyType.LOCAL_TO_PROJ_MATRIX in constants) Shader3DHelper.setGlobalLocalToProjMatrix(renderable._object3D, camera);
				if (ShaderPropertyType.DIFFUSE_TEX_REGION in constants) Shader3DHelper.setGlobalDiffuseTexRegion(mat._textures[ShaderPropertyType.DIFFUSE_TEX]._region, renderable._textureRegions[ShaderPropertyType.DIFFUSE_TEX]);
				
				_colorAttConstants.values[3] = renderable._object3D._multipliedAlpha;
				Shader3D.setGlobalConstants(ShaderPropertyType.COLOR_ATTRIBUTE, _colorAttConstants);
				
				device._vertexBufferManager.resetOccupiedState();
				device._textureManager.resetOccupiedState();
				
				if (device.setRenderData(p, mat, renderable._materialProperty, renderable._meshBuffer._vertexBuffers)) {
					device._vertexBufferManager.deactiveOccupiedVertexBuffers();
					device._textureManager.deactiveOccupiedTextures();
					
					var blendFactors:BlendFactorsData;
					if (renderable._object3D._multipliedAlpha < 1) {
						blendFactors = renderable._transparentBlendFactors == null ? renderable._blendFactors : renderable._transparentBlendFactors;
					} else {
						blendFactors = renderable._blendFactors;
					}
					
					if (!lockDepthTest) device.setDepthTest(renderable.depthWrite, renderable.depthTest);
					device.setCulling(renderable.culling);
					device.setBlendFactorsFormData(blendFactors);
					device.setScissorRectangle(renderable.scissorRectangle);
					
					device.drawTrianglesFromData(renderable._meshBuffer._indexBuffer);
				}
				
				renderable.postRender(device, camera);
			} else {
				var sd:StaticData = new StaticData();
				sd.renderer = this;
				
				_staticMap[sd.renderID] = sd;
				staticRenderData[staticRenderData.length] = sd;
			}
		}
		public override function renderStatic(device:Device3D, renderID:uint):void {
			var sd:StaticData = _staticMap[renderID];
			if (sd != null) {
				pushRenderable(sd.renderable, sd.device, sd.camera, sd.material, null);
			}
		}
		public override function destroyStatic(renderID:uint):void {
			var sd:StaticData = _staticMap[renderID];
			if (sd != null) {
				sd.dispose();
				delete _staticMap[renderID];
			}
		}
	}
}
import asgl.entities.Camera3D;
import asgl.materials.Material;
import asgl.renderables.BaseRenderable;
import asgl.renderers.AbstractStaticRenderData;
import asgl.system.Device3D;

class StaticData extends AbstractStaticRenderData {
	public var renderable:BaseRenderable;
	public var device:Device3D;
	public var camera:Camera3D;
	public var material:Material;
	
	public override function dispose():void {
		renderable = null;
		device = null;
		camera = null;
		material = null;
	}
}