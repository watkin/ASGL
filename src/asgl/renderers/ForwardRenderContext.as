package asgl.renderers {
	import asgl.asgl_protected;
	import asgl.entities.Camera3D;
	import asgl.entities.Object3D;
	import asgl.lights.AbstractLight;
	import asgl.lights.LightType;
	import asgl.materials.Material;
	import asgl.renderables.BaseRenderable;
	import asgl.shaders.scripts.Shader3D;
	import asgl.shaders.scripts.Shader3DHelper;
	import asgl.shaders.scripts.ShaderConstants;
	import asgl.shaders.scripts.ShaderDefineType;
	import asgl.shaders.scripts.ShaderDefineValue;
	import asgl.shaders.scripts.ShaderPropertyType;
	import asgl.shadows.ShadowMapData;
	import asgl.system.AbstractTextureData;
	import asgl.system.Device3D;
	
	use namespace asgl_protected;

	public class ForwardRenderContext extends BaseRenderContext {
		public static const MAX_LIGHTS:int = 2;
		private static const DEFUALT_MESH_LENGTH:int = 512;
		
		public var lights:Vector.<AbstractLight>;
		public var shadowsData:Vector.<ShadowMapData>;
		
		private var _lightingMethodMap:Object;
		
		private var _lightingVertAtts:Vector.<ShaderConstants>;
		private var _lightingFragAtts:Vector.<ShaderConstants>;
		private var _worldToLightMatrices:Vector.<ShaderConstants>;
		private var _numLights:int;
		
		private var _renderables:Vector.<BaseRenderable>;
		private var _numRenderables:int;
		
		private var _renderers:Vector.<BaseRenderer>;
		private var _numRenderers:int;
		
		private var _globalMaterial:Material;
		
		public function ForwardRenderContext() {
			_renderables = new Vector.<BaseRenderable>(DEFUALT_MESH_LENGTH);
			
			_renderers = new Vector.<BaseRenderer>(8);
			
			_lightingMethodMap = {};
			_lightingMethodMap[LightType.DIRECTIONAL] = new DirectionalLightingMethod();
			_lightingMethodMap[LightType.POINT] = new PointLightingMethod();
			_lightingMethodMap[LightType.SPOT] = new SpotLightingMethod();
			
			_lightingVertAtts = new Vector.<ShaderConstants>();
			_lightingFragAtts = new Vector.<ShaderConstants>();
			_worldToLightMatrices = new Vector.<ShaderConstants>();
		}
		public override function pushRenderable(renderable:BaseRenderable):Boolean {
			var renderer:BaseRenderer = renderable._renderer;
			if (renderer != null && (cullingMask & renderable._object3D.cullingLabel) != 0) {
				for (var i:int = 0; i < _numLights; i++) {
					var light:AbstractLight = lights[i];
					if ((light.cullingMask & renderable._object3D.cullingLabel) == 0) {
						renderable.setDefine(ShaderDefineType.LIGHTS[i], ShaderDefineValue.LIGHT_NONE);
						renderable.setDefine(ShaderDefineType.SHADOWS[i], 0);
					} else {
						renderable.setDefine(ShaderDefineType.LIGHTS[i], null);
						if (renderable.receiveShadows) {
							renderable.setDefine(ShaderDefineType.SHADOWS[i], null);
						} else {
							renderable.setDefine(ShaderDefineType.SHADOWS[i], 0);
						}
					}
				}
				
				if (renderer.pushCheck(renderable, _globalMaterial)) {
					if (!renderer._isRunning) {
						renderer._isRunning = true;
						_renderers[_numRenderers] = renderer;
					}
					
					_renderables[_numRenderables++] = renderable;
					
					return true;
				} else {
					return false;
				}
			} else {
				return false;
			}
		}
		public override function render(device:Device3D, camera:Camera3D, root:Object3D, renderTarget:AbstractTextureData=null, material:Material=null):void {
			if (material != null) {
				material.updateShaderProgram();
				if (material._shaderProgram == null) return;
				
				_globalMaterial = material;
			}
			
			var renderer:BaseRenderer = null;
			var i:int;
			
			camera.preRender(device, this);
			
			if (lights == null) {
				_numLights = 0;
			} else {
				var sc:ShaderConstants;
				var numLights:int = lights.length;
				if (numLights > MAX_LIGHTS) numLights = MAX_LIGHTS;
				if (numLights > _numLights) {
					for (i = _numLights; i < numLights; i++) {
						sc = new ShaderConstants(1);
						sc.values = new Vector.<Number>(sc._length * 4);
						_lightingVertAtts[i] = sc;
						
						sc = new ShaderConstants(2);
						sc.values = new Vector.<Number>(sc._length * 4);
						_lightingFragAtts[i] = sc;
						
						sc = new ShaderConstants(4);
						sc.values = new Vector.<Number>(sc._length * 4);
						_worldToLightMatrices[i] = sc;
					}
					
					_numLights = numLights;
				}
				
				var numShadows:int = shadowsData == null ? 0 : shadowsData.length;
				
				for (i = 0; i < _numLights; i++) {
					var light:AbstractLight = lights[i];
					var lightMethod:AbstractLightingMethod = _lightingMethodMap[light._lightType];
					if (lightMethod == null) {
						Shader3D.setGlobalDefine(ShaderDefineType.LIGHTS[i], ShaderDefineValue.LIGHT_NONE);
						Shader3D.setGlobalDefine(ShaderDefineType.SHADOWS[i], 0);
					} else {
						Shader3D.setGlobalDefine(ShaderDefineType.LIGHTS[i], lightMethod.define);
						sc = _lightingVertAtts[i];
						lightMethod.setLightingVertexAttributes(light, sc.values);
						Shader3D.setGlobalConstants(ShaderPropertyType.LIGHTING_VERT_ATTS[i], sc);
						sc = _lightingFragAtts[i];
						lightMethod.setLightingFragmentAttributes(light, sc.values);
						Shader3D.setGlobalConstants(ShaderPropertyType.LIGHTING_FRAG_ATTS[i], sc);
						
						if (numShadows == 0 || numShadows < i) {
							Shader3D.setGlobalDefine(ShaderDefineType.SHADOWS[i], 0);
						} else {
							var smd:ShadowMapData = shadowsData[i];
							if (smd == null) {
								Shader3D.setGlobalDefine(ShaderDefineType.SHADOWS[i], 0);
							} else {
								Shader3D.setGlobalDefine(ShaderDefineType.SHADOWS[i], 1);
								Shader3D.setGlobalTexture(ShaderPropertyType.SHADOW_TEXS[i], smd.depthTexture);
								sc = _worldToLightMatrices[i];
								smd.worldToLightMatrix.toVector4x4(true, sc.values);
								Shader3D.setGlobalConstants(ShaderPropertyType.WORLD_TO_LIGHT_MATRICES[i], sc);
							}
						}
					}
				}
				
				for (; i < MAX_LIGHTS; i++) {
					Shader3D.setGlobalDefine(ShaderDefineType.LIGHTS[i], ShaderDefineValue.LIGHT_NONE);
					Shader3D.setGlobalDefine(ShaderDefineType.SHADOWS[i], 0);
				}
			}
			
			if (root._enabled) {
				root.updateMultipliedAlpha();
				if (root._multipliedAlpha > 0) _traversal(device, camera, root);
			}
			
			_quickSort(_renderables, 0, _numRenderables - 1);
			
			for (i = 0; i < _numRenderers; i++) {
				_renderers[i].preRender(device, camera, this);
			}
			
			Shader3DHelper.setGlobalForRenderContext(camera);
			
			if (renderTarget == null) {
				device.setRenderToBackBuffer();
			} else {
				renderTarget.setRenderToThis();
			}
			
			device.clearFromData(camera._clearData);
			
			renderer = null;
			
			for (i = 0; i < _numRenderables; i++) {
				var renderable:BaseRenderable = _renderables[i];
				_renderables[i] = null;
				
				if (renderer != renderable._renderer) {
					if (renderer != null) renderer.render(device, null);
					renderer = renderable._renderer;
				}
				
				renderable._renderer.pushRenderable(renderable, device, camera, material, null);
			}
			
			if (renderer != null) renderer.render(device, null);
			
			Shader3DHelper.clearGlobalForRenderContext();
			
			for (i = 0; i < _numRenderers; i++) {
				renderer = _renderers[i];
				renderer.postRender(device, camera, this);
				renderer._isRunning = false;
				_renderers[i] = null;
			}
			
			for (i = 0; i < _numLights; i++) {
				Shader3D.setGlobalTexture(ShaderPropertyType.SHADOW_TEXS[i], null);
				Shader3D.setGlobalConstants(ShaderPropertyType.WORLD_TO_LIGHT_MATRICES[i], null);
			}
			
			_numRenderables = 0;
			_numRenderers = 0;
			
			_globalMaterial = null;
			
			camera.postRender(device, this);
		}
		private function _traversal(device:Device3D, camera:Camera3D, obj:Object3D):void {
			obj.collectRenderObject(device, camera, this);
			
			for (var i:int = 0; i < obj._delayNumChildren; i++) {
				var child:* = obj._delayChildren[i];
				if (child != null && child._enabled) {
					child._multipliedAlpha = obj._multipliedAlpha * child._alpha;
					if (child._multipliedAlpha > 0) _traversal(device, camera, child);
				}
			}
		}
		private function _quickSort(data:Vector.<BaseRenderable>, left:int, right:int):void {
			if (left < right) {
				var middle:Number = data[int((left + right) * 0.5)]._renderSortValue;
				
				var i:int = left - 1;
				var j:int = right + 1;
				
				while (true) {
					while (data[++i]._renderSortValue < middle);
					
					while (data[--j]._renderSortValue > middle);
					
					if (i >= j) break;
					
					var temp:BaseRenderable = data[i];
					data[i] = data[j];
					data[j] = temp;
				}
				
				_quickSort(data, left, i - 1);
				_quickSort(data, j + 1, right);
			}
		}
	}
}

import asgl.asgl_protected;
import asgl.lights.AbstractLight;
import asgl.lights.PointLight;
import asgl.lights.SpotLight;
import asgl.math.Float3;
import asgl.math.Matrix4x4;
import asgl.shaders.scripts.ShaderDefineValue;

use namespace asgl_protected;

class AbstractLightingMethod {
	public static var _tempFloat3:Float3 = new Float3();
	
	public var define:String;
	
	public function setLightingVertexAttributes(light:AbstractLight, op:Vector.<Number>):void {}
	public function setLightingFragmentAttributes(light:AbstractLight, op:Vector.<Number>):void {}
}
class DirectionalLightingMethod extends AbstractLightingMethod {
	public function DirectionalLightingMethod() {
		define = ShaderDefineValue.LIGHT_DIRECTIONAL;
	}
	public override function setLightingVertexAttributes(light:AbstractLight, op:Vector.<Number>):void {
		light.updateWorldMatrix();
		light._worldMatrix.getAxisZ(_tempFloat3);
		_tempFloat3.normalize();
		
		op[0] = -_tempFloat3.x;
		op[1] = -_tempFloat3.y;
		op[2] = -_tempFloat3.z;
	}
	public override function setLightingFragmentAttributes(light:AbstractLight, op:Vector.<Number>):void {
		//light.updateWorldMatrix();
		//light._worldMatrix.getAxisZ(_tempFloat3);
		//_tempFloat3.normalize();
		
		op[0] = light._colorRed * light._intensity;
		op[1] = light._colorGreen * light._intensity;
		op[2] = light._colorBlue * light._intensity;
		
		op[4] = -_tempFloat3.x;
		op[5] = -_tempFloat3.y;
		op[6] = -_tempFloat3.z;
	}
}
class PointLightingMethod extends AbstractLightingMethod {
	public function PointLightingMethod() {
		define = ShaderDefineValue.LIGHT_POINT;
	}
	public override function setLightingVertexAttributes(light:AbstractLight, op:Vector.<Number>):void {
		light.updateWorldMatrix();
		var m:Matrix4x4 = light._worldMatrix;
		
		op[0] = m.m30;
		op[1] = m.m31;
		op[2] = m.m32;
		op[3] = (light as PointLight)._range;
	}
	public override function setLightingFragmentAttributes(light:AbstractLight, op:Vector.<Number>):void {
		op[0] = light._colorRed * light._intensity;
		op[1] = light._colorGreen * light._intensity;
		op[2] = light._colorBlue * light._intensity;
	}
}
class SpotLightingMethod extends AbstractLightingMethod {
	public function SpotLightingMethod() {
		define = ShaderDefineValue.LIGHT_SPOT;
	}
	public override function setLightingVertexAttributes(light:AbstractLight, op:Vector.<Number>):void {
		light.updateWorldMatrix();
		var m:Matrix4x4 = light._worldMatrix;
		
		op[0] = m.m30;
		op[1] = m.m31;
		op[2] = m.m32;
		op[3] = (light as SpotLight)._range;
	}
	public override function setLightingFragmentAttributes(light:AbstractLight, op:Vector.<Number>):void {
		op[0] = light._colorRed * light._intensity;
		op[1] = light._colorGreen * light._intensity;
		op[2] = light._colorBlue * light._intensity;
		op[3] = (light as SpotLight)._spotAngle * 0.5;
		
		light.updateWorldMatrix();
		light._worldMatrix.getAxisZ(_tempFloat3);
		_tempFloat3.normalize();
		
		op[4] = -_tempFloat3.x;
		op[5] = -_tempFloat3.y;
		op[6] = -_tempFloat3.z;
	}
}