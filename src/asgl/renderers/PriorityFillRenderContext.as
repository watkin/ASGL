package asgl.renderers {
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DTriangleFace;
	
	import asgl.asgl_protected;
	import asgl.entities.Camera3D;
	import asgl.entities.Object3D;
	import asgl.materials.Material;
	import asgl.renderables.BaseRenderable;
	import asgl.shaders.scripts.Shader3D;
	import asgl.shaders.scripts.Shader3DHelper;
	import asgl.shaders.scripts.ShaderPropertyType;
	import asgl.system.AbstractTextureData;
	import asgl.system.Device3D;
	
	use namespace asgl_protected;
	
	public class PriorityFillRenderContext extends BaseRenderContext {
		private static const DEFUALT_RENDERABLE_LENGTH:int = 512;
		private static const DEFUALT_OBJECT_LENGTH:int = 512;
		
		private var _renderables:Vector.<BaseRenderable>;
		private var _numRenderables:int;
		
		private var _objects:Vector.<Object3D>;
		private var _numObjects:int;
		
		private var _renderers:Vector.<BaseRenderer>;
		private var _numRenderers:int;
		
		private var _globalMaterial:Material;
		
		private var _staticMap:Object;
		
		private var _staticRenderables:Vector.<BaseRenderable>;
		private var _useStaticRenderables:int;
		private var _numStaticRenderables:int;
		
		public function PriorityFillRenderContext() {
			_renderables = new Vector.<BaseRenderable>(DEFUALT_RENDERABLE_LENGTH);
			_objects = new Vector.<Object3D>(DEFUALT_OBJECT_LENGTH);
			
			_renderers = new Vector.<BaseRenderer>(8);
			
			_staticMap = {};
			_staticRenderables = new Vector.<BaseRenderable>(8);
		}
		public override function dispose():void {
			var keys:Vector.<String> = new Vector.<String>();
			var num:int = 0;
			for (var key:String in _staticMap) {
				keys[num++] = key;
			}
			
			for (var i:int = 0; i < num; i++) {
				key = keys[i];
				var sd:StaticData = _staticMap[key];
				sd.dispose();
				delete _staticMap[key];
			}
		}
		public override function pushRenderable(renderable:BaseRenderable):Boolean {
			var renderer:BaseRenderer = renderable._renderer;
			if (renderer != null) {
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
			var renderer:BaseRenderer = null;
			
			camera.preRender(device, this);
			
			if (root._enabled) {
				root.updateMultipliedAlpha();
				if (root._multipliedAlpha > 0) _traversal(device, camera, root);
			}
			
			for (var i:int = 0; i < _numRenderers; i++) {
				_renderers[i].preRender(device, camera, this);
			}
			
			if (renderTarget == null) {
				device.setRenderToBackBuffer();
			} else {
				renderTarget.setRenderToThis();
			}
			
			device.clearFromData(camera._clearData);
			
			device.setDepthTest(false, Context3DCompareMode.ALWAYS);
			device.setCulling(Context3DTriangleFace.NONE);
			
			Shader3DHelper.setGlobalWorldToProjMatrix(camera);
			
			renderer = null;
			
			for (i = 0; i < _numRenderables; i++) {
				var renderable:BaseRenderable = _renderables[i];
				_renderables[i] = null;
				
				if (renderable._staticKey == null) {
					if (renderer != renderable._renderer) {
						if (renderer != null) renderer.render(device, null);
						renderer = renderable._renderer;
					}
					
					renderable._renderer.pushRenderable(renderable, device, camera, material, null);
				} else {
					if (renderer != null) renderer.render(device, null);
					
					var sd:StaticData = _staticMap[renderable._staticKey];
					var len:int = sd.staticRenderData.length;
					for (var j:int = 0; j < len; j++) {
						var srd:AbstractStaticRenderData = sd.staticRenderData[j];
						srd.renderer.renderStatic(device, srd.renderID);
					}
					
					renderer = null;
				}
			}
			
			if (renderer != null) renderer.render(device, null);
			
			Shader3D.setGlobalConstants(ShaderPropertyType.WORLD_TO_PROJ_MATRIX, null);
			
			for (i = 0; i < _numRenderers; i++) {
				renderer = _renderers[i];
				renderer.postRender(device, camera, this);
				renderer._isRunning = false;
				_renderers[i] = null;
			}
			
			_numRenderables = 0;
			_numObjects = 0;
			_numRenderers = 0;
			_useStaticRenderables = 0;
			
			_globalMaterial = null;
			
			camera.postRender(device, this);
		}
		public function createStatic(device:Device3D, camera:Camera3D, obj:Object3D, material:Material=null):void {
			var key:String = device._instanceID + '|'  + camera._instanceID + '|' + obj._instanceID;
			
			var sd:StaticData = _staticMap[key];
			if (sd != null) sd.dispose();
			
			if (obj._enabled) {
				obj.updateMultipliedAlpha();
				if (obj._multipliedAlpha > 0) _traversal(device, camera, obj, true);
			}
			
			var srds:Vector.<AbstractStaticRenderData> = new Vector.<AbstractStaticRenderData>();
			
			var renderer:BaseRenderer = null;
			
			for (var i:int = 0; i < _numRenderables; i++) {
				var renderable:BaseRenderable = _renderables[i];
				_renderables[i] = null;
				
				if (renderer != renderable._renderer) {
					if (renderer != null) renderer.render(device, srds);
					renderer = renderable._renderer;
				}
				
				renderable._renderer.pushRenderable(renderable, device, camera, material, srds);
			}
			
			if (renderer != null) renderer.render(device, srds);
			
			sd = new StaticData();
			sd.staticRenderData = srds;
			
			_staticMap[key] = sd;
			
			_numObjects = 0;
			_numRenderables = 0;
		}
		public function destroyStatic(device:Device3D, camera:Camera3D, obj:Object3D):void {
			var key:String = device._instanceID + '|'  + camera._instanceID + '|' + obj._instanceID;
			
			var sd:StaticData = _staticMap[key];
			if (sd != null) {
				sd.dispose();
				delete _staticMap[key];
			}
		}
		private function _traversal(device:Device3D, camera:Camera3D, obj:Object3D, creating:Boolean=false):void {
			if (obj.isStatic && !creating) {
				var key:String = device._instanceID + '|'  + camera._instanceID + '|' + obj._instanceID;
				
				if (key in _staticMap) {
					var renderable:BaseRenderable;
					if (_useStaticRenderables == _numStaticRenderables) {
						renderable = new BaseRenderable();
						_staticRenderables[_numStaticRenderables++] = renderable;
					} else {
						renderable = _staticRenderables[_useStaticRenderables++];
					}
					
					renderable._staticKey = key;
					
					_renderables[_numRenderables++] = renderable;
					
					return;
				}
			}
			
			obj.collectRenderObject(device, camera, this);
			
			var i:int;
			var child:*;
			
			if (obj._dynamicSortEnabled) {
				var start:int = _numObjects;
				
				for (i = 0; i < obj._delayNumChildren; i++) {
					child = obj._delayChildren[i];
					if (child != null && child._enabled) {
						child._multipliedAlpha = obj._multipliedAlpha * child._alpha;
						if (child._multipliedAlpha > 0) _objects[_numObjects++] = child;
					}
				}
				
				var end:int = _numObjects;
				
				if (end - start > 1) _quickSort(_objects, start, end - 1);
				
				for (i = start; i < end; i++) {
					_traversal(device, camera, _objects[i]);
					_objects[i] = null;
				}
			} else {
				for (i = 0; i < obj._delayNumChildren; i++) {
					child = obj._delayChildren[i];
					if (child != null && child._enabled) {
						child._multipliedAlpha = obj._multipliedAlpha * child._alpha;
						if (child._multipliedAlpha > 0) _traversal(device, camera, child);
					}
				}
			}
		}
		private function _quickSort(data:Vector.<Object3D>, left:int, right:int):void {
			if (left < right) {
				var middle:Number = data[int((left + right) * 0.5)]._priority;
				
				var i:int = left - 1;
				var j:int = right + 1;
				
				while (true) {
					while (data[++i]._priority < middle);
					
					while (data[--j]._priority > middle);
					
					if (i >= j) break;
					
					var temp:Object3D = data[i];
					data[i] = data[j];
					data[j] = temp;
				}
				
				_quickSort(data, left, i - 1);
				_quickSort(data, j + 1, right);
			}
		}
	}
}
import asgl.renderers.AbstractStaticRenderData;

class StaticData {
	public var staticRenderData:Vector.<AbstractStaticRenderData>;
	
	public function dispose():void {
		var len:int = staticRenderData.length;
		for (var i:int = 0; i < len; i++) {
			var srd:AbstractStaticRenderData = staticRenderData[i];
			srd.renderer.destroyStatic(srd.renderID);
		}
		staticRenderData = null;
	}
}