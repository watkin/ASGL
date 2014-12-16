package asgl.system {
	import flash.display.BitmapData;
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DClearMask;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProfile;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DRenderMode;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.textures.TextureBase;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
	
	import asgl.asgl_protected;
	import asgl.effects.postprocess.PostProcessExecutor;
	import asgl.events.ASGLEvent;
	import asgl.geometries.MeshBuffer;
	import asgl.materials.Material;
	import asgl.materials.MaterialProperty;
	import asgl.shaders.scripts.Shader3D;
	import asgl.shaders.scripts.Shader3DCell;
	import asgl.shaders.scripts.ShaderBuffer;
	import asgl.shaders.scripts.ShaderConstants;
	import asgl.shaders.scripts.ShaderTexture;
	
	use namespace asgl_protected;
	
	[Event(name="create", type="asgl.events.ASGLEvent")]
	[Event(name="lost", type="asgl.events.ASGLEvent")]
	[Event(name="recovery", type="asgl.events.ASGLEvent")]

	public class Device3D extends EventDispatcher {
		public static const DISPOSED:String = 'Disposed';
		
		private static var _instanceIDAccumulator:uint = 0;
		
		asgl_protected var _instanceID:uint;
		asgl_protected var _context3D:Context3D;
		
		private var _isSoftware:Boolean;
		
		private var _culling:String;
		
		private var _backBufferHeight:uint;
		private var _backBufferWidth:uint;
		private var _backBufferAntiAlias:int;
		private var _enableDepthAndStencil:Boolean;
		private var _wantsBestResolution:Boolean;
		
		private var _depthTestMask:Boolean;
		private var _depthTestPassCompareMode:String;
		
		private var _enableErrorChecking:Boolean;
		
		private var _blendFactorsID:uint;
		private var _blendSourceFactor:String;
		private var _blendDestinationFactor:String;
		
		private var _setRect:Boolean;
		private var _rect:Rectangle;
		
		asgl_protected var _textureManager:TextureManager;
		asgl_protected var _vertexBufferManager:VertexBufferManager;
		asgl_protected var _indexBufferManager:IndexBufferManager;
		asgl_protected var _programConstantsManager:ProgramConstantsManager;
		asgl_protected var _programManager:ProgramManager;
		
		asgl_protected var _cacheIndexBuffers:Boolean;
		asgl_protected var _cacheProgramConstants:Boolean;
		asgl_protected var _cachePrograms:Boolean;
		asgl_protected var _cacheTextures:Boolean;
		asgl_protected var _cacheVertexBuffers:Boolean;
		
		private var _stage:Stage3D;
		private var _isFirstRequest:Boolean;
		private var _isShared:Boolean;
		
		private var _rtts:Object;
		private var _numRtt:int;
		private var _rttPool:Vector.<RTT>;
		private var _numRttInPool:int;
		
		asgl_protected var _debugger:DeviceDebugger;
		
		public function Device3D(stage:Stage3D) {
			_isFirstRequest = true;
			
			_culling = Context3DTriangleFace.BACK;
			
			_depthTestMask = true;
			_depthTestPassCompareMode = Context3DCompareMode.LESS;
			
			_blendSourceFactor = Context3DBlendFactor.ONE;
			_blendDestinationFactor = Context3DBlendFactor.ZERO;
			
			_rect = new Rectangle();
			
			_instanceID = ++_instanceIDAccumulator;
			
			_rtts = {};
			_rttPool = new Vector.<RTT>();
			
			_stage = stage;
			
			_debugger = new DeviceDebugger();
			
			_vertexBufferManager = new VertexBufferManager(this);
			_textureManager = new TextureManager(this);
			_indexBufferManager = new IndexBufferManager(this);
			_programConstantsManager = new ProgramConstantsManager(this);
			_programManager = new ProgramManager(this);
		}
		public function get backBufferHeight():uint {
			return _backBufferHeight;
		}
		public function get backBufferWidth():uint {
			return _backBufferWidth;
		}
		public function get cacheIndexBuffers():Boolean {
			return _cacheIndexBuffers;
		}
		public function set cacheIndexBuffers(value:Boolean):void {
			if (_cacheIndexBuffers != value) {
				_cacheIndexBuffers = value;
				
				if (!_cacheIndexBuffers) _indexBufferManager._clearCache();
			}
		}
		public function get cacheProgramConstants():Boolean {
			return _cacheProgramConstants;
		}
		public function set cacheProgramConstants(value:Boolean):void {
			_cacheProgramConstants = value;
		}
		public function get cachePrograms():Boolean {
			return _cachePrograms;
		}
		public function set cachePrograms(value:Boolean):void {
			if (_cachePrograms != value) {
				_cachePrograms = value;
				
				if (!_cachePrograms) _programManager._clearCache();
			}
		}
		public function get cacheTextures():Boolean {
			return _cacheTextures;
		}
		public function set cacheTextures(value:Boolean):void {
			if (_cacheTextures != value) {
				_cacheTextures = value;
				
				if (!_cacheTextures) _textureManager._clearCache();
			}
		}
		public function get cacheVertexBuffers():Boolean {
			return _cacheVertexBuffers;
		}
		public function set cacheVertexBuffers(value:Boolean):void {
			if (_cacheVertexBuffers != value) {
				_cacheVertexBuffers = value;
				
				if (!_cacheVertexBuffers) _vertexBufferManager._clearCache();
			}
		}
		public function get context3D():Context3D {
			return _context3D;
		}
		public function get debugger():DeviceDebugger {
			return _debugger;
		}
		public function get driverInfo():String {
			if (_context3D == null) {
				return null;
			} else {
				return _context3D.driverInfo;
			}
		}
		public function get enableErrorChecking():Boolean {
			return _enableErrorChecking;
		}
		public function set enableErrorChecking(value:Boolean):void {
			if (_enableErrorChecking != value) {
				_enableErrorChecking = value;
				
				if (_context3D != null) _context3D.enableErrorChecking = _enableErrorChecking;
			}
		}
		public function get indexBufferManager():IndexBufferManager {
			return _indexBufferManager;
		}
		public function get instanceID():uint {
			return _instanceID;
		}
		public function get isSoftware():Boolean {
			return _isSoftware;
		}
		public function get programConstantsManager():ProgramConstantsManager {
			return _programConstantsManager;
		}
		public function get programManager():ProgramManager {
			return _programManager;
		}
		public function get stage3D():Stage3D {
			return _stage;
		}
		public function get textureManager():TextureManager {
			return _textureManager;
		}
		public function get vertexBufferManager():VertexBufferManager {
			return _vertexBufferManager;
		}
		public function clear(red:Number=0.0, green:Number=0.0, blue:Number=0.0, alpha:Number=1.0, depth:Number=1.0, stencil:uint=0, mask:uint=0xFFFFFFFF):void {
			if (_context3D != null) {
				if (_context3D.driverInfo == DISPOSED) {
					_lost();
				} else {
					_context3D.clear(red, green, blue, alpha, depth, stencil, mask);
					
					_debugger._changeOtherStateCount++;
				}
			}
		}
		public function clearFromData(data:ClearData):void {
			if (data.clearMask <= Context3DClearMask.ALL) {
				if (_context3D != null) {
					if (_context3D.driverInfo == DISPOSED) {
						_lost();
					} else {
						_context3D.clear(data._backgroundColorRed, data._backgroundColorGreen, data._backgroundColorBlue, 
							data._backgroundColorAlpha, data.clearDepth, data.clearStencil, data.clearMask);
						
						_debugger._changeOtherStateCount++;
					}
				}
			}
		}
		public function configureBackBuffer(width:uint, height:uint, antiAlias:int, enableDepthAndStencil:Boolean=true, wantsBestResolution:Boolean=false):void {
			if (width < 50) width = 50;
			if (height < 50) height = 50;
			
			if (_backBufferWidth != width || _backBufferHeight != height || _backBufferAntiAlias != antiAlias ||
				_enableDepthAndStencil != enableDepthAndStencil) {
				_backBufferWidth = width;
				_backBufferHeight = height;
				_backBufferAntiAlias = antiAlias;
				_enableDepthAndStencil = enableDepthAndStencil;
				_wantsBestResolution = wantsBestResolution;
				
				if (_context3D != null) {
					if (_context3D.driverInfo == DISPOSED) {
						_lost();
					} else {
						_context3D.configureBackBuffer(_backBufferWidth, _backBufferHeight, _backBufferAntiAlias, _enableDepthAndStencil, _wantsBestResolution);
						
						_debugger._changeOtherStateCount++;
					}
				}
			}
		}
		public function createMeshBuffer(security:Boolean=false):MeshBuffer {
			return new MeshBuffer(this, security);
		}
		public function createPostProcessExector():PostProcessExecutor {
			return new PostProcessExecutor(this);
		}
		public function createShader():Shader3D {
			return new Shader3D(this);
		}
		public function dispose(recreate:Boolean=true):void {
			if (_context3D != null) {
				_stage.removeEventListener(Event.CONTEXT3D_CREATE, _context3DCreatedHandler);
				
				_vertexBufferManager.disposeVertexBuffers();
				_textureManager.disposeTextures();
				_indexBufferManager.disposeIndexBuffers();
				_programManager.disposePrograms();
				
				var c:Context3D = _context3D;
				_context3D = null;
				
				if (!_isShared) c.dispose(recreate);
			}
		}
		public function drawToBitmapData(destination:BitmapData):void {
			if (_context3D != null) {
				if (_context3D.driverInfo == DISPOSED) {
					_lost();
				} else {
					_context3D.drawToBitmapData(destination);
					
					_debugger._changeOtherStateCount++;
				}
			}
		}
		public function drawTriangles(indexBuffer:IndexBuffer3D, firstIndex:int=0, numTriangles:int=-1):int {
			if (_context3D == null) {
				return RenderResultType.DISPOSED;
			} else {
				if (_context3D.driverInfo == DISPOSED) {
					_lost();
					
					return RenderResultType.DISPOSED;
				} else {
					_context3D.drawTriangles(indexBuffer, firstIndex, numTriangles);
					
					_debugger._drawCalls++;
					
					return RenderResultType.SUCCESS;
				}
			}
		}
		public function drawTrianglesFromData(data:IndexBufferData, firstIndex:int=0, numTriangles:int=-1):int {
			if (_context3D == null) {
				return RenderResultType.DISPOSED;
			} else {
				if (_context3D.driverInfo == DISPOSED) {
					_lost();
					
					return RenderResultType.DISPOSED;
				} else if (data._root._valid) {
					var numIndices:int = numTriangles < 0 ? data._numTriangles : numTriangles;
					numIndices *= 3;
					if (firstIndex >= data._numIndices) {
						numTriangles = 0;
					} else {
						var len:int = data._numIndices - firstIndex;
						if (numIndices > len) numIndices = len;
						firstIndex += data._firstIndex;
						numTriangles = numIndices / 3;
					}
					
					if (numTriangles > 0) {
						_context3D.drawTriangles(data._buffer, firstIndex, numTriangles);
						
						_debugger._drawCalls++;
						_debugger._drawTriangles += numTriangles;
					}
					
					return RenderResultType.SUCCESS;
				} else {
					return RenderResultType.DATA_INVALID;
				}
			}
		}
		public function present():void {
			if (_context3D != null) {
				_context3D.present();
				
				_debugger._changeOtherStateCount++;
			}
		}
		public function requestCreate(context3DRenderMode:String=Context3DRenderMode.AUTO, profile:String=Context3DProfile.BASELINE):void {
			if (_stage != null && _isFirstRequest) {
				var context:Context3D = _stage.context3D;
				if (context == null) {
					_stage.addEventListener(Event.CONTEXT3D_CREATE, _context3DCreatedHandler, false, 0, true);
					_stage.requestContext3D(context3DRenderMode, profile);
				} else if (context3D.driverInfo == DISPOSED) {
					_lost();
				} else {
					_isShared = true;
					_context3DCreatedHandler(null);
				}
			}
		}
		public function setBlendFactors(sourceFactor:String, destinationFactor:String):void {
			if (_blendSourceFactor != sourceFactor || _blendDestinationFactor != destinationFactor) {
				_blendSourceFactor = sourceFactor;
				_blendDestinationFactor = destinationFactor;
				
				if (_context3D != null) {
					_context3D.setBlendFactors(_blendSourceFactor, _blendDestinationFactor);
					
					_debugger._changeOtherStateCount++;
				}
			}
		}
		public function setBlendFactorsFormData(data:BlendFactorsData):void {
			if (_blendFactorsID != data._blendFactorsID) {
				_blendFactorsID = data._blendFactorsID;
				
				_blendSourceFactor = data._sourceFactor;
				_blendDestinationFactor = data._destinationFactor;
				
				if (_context3D != null) {
					_context3D.setBlendFactors(_blendSourceFactor, _blendDestinationFactor);
					
					_debugger._changeOtherStateCount++;
				}
			}
		}
		public function setCulling(triangleFaceToCull:String):void {
			if (_culling != triangleFaceToCull) {
				_culling = triangleFaceToCull;
				
				if (_context3D != null) {
					_context3D.setCulling(_culling);
					
					_debugger._changeOtherStateCount++;
				}
			}
		}
		public function setDepthTest(depthMask:Boolean, passCompareMode:String):void {
			if (_depthTestMask != depthMask || _depthTestPassCompareMode != passCompareMode) {
				_depthTestMask = depthMask;
				_depthTestPassCompareMode = passCompareMode;
				
				if (_context3D != null) {
					_context3D.setDepthTest(_depthTestMask, _depthTestPassCompareMode);
					
					_debugger._changeOtherStateCount++;
				}
			}
		}
		public function setRenderData(shaderProgram:ProgramData, material:Material, materialProperty:MaterialProperty, vertexBuffers:Object):Boolean {
			var name:String;
			
			var shader:Shader3DCell = shaderProgram._cell;
			var textures:Object = material._textures;
			var constants:Object = material._constants;
			var constants2:Object = materialProperty == null ? null : materialProperty._constants;
			var shaderConstants:Object = shader._constants;
			
			var shaderBuffers:Object = shader._buffers;
			for (name in shaderBuffers) {
				var buffer:VertexBufferData = vertexBuffers[name];
				if (buffer == null) {
					trace('setRenderData error, no buffer : ' + name);
					return false;
				}
				var sb:ShaderBuffer = shaderBuffers[name];
				if (!_vertexBufferManager.setVertexBufferFromData(buffer, sb._index, buffer.bufferOffset, buffer.format)) {
					trace('setRenderData error, invalid vertex buffer : ' + name);
					return false;
				}
			}
			
			var shaderTextures:Object = shader._textures;
			for (name in shaderTextures) {
				var texture:AbstractTextureData = textures[name];
				if (texture == null) texture = Shader3D._globalTextures[name];
				if (texture == null) {
					trace('setRenderData error, no texture : ' + name);
					return false;
				}
				var st:ShaderTexture = shaderTextures[name];
				if (_textureManager.setTextureFromData(texture, st._index)) {
					_textureManager.setSamplerStateFromData(st._index, texture._samplerStateData);
				} else {
					trace('setRenderData error, invalid texture : ' + name);
					return false;
				}
			}
			
			var vertConstants:Object = shader._vertexConstants;
			for (name in vertConstants) {
				var vi:uint = vertConstants[name];
				var vc:ShaderConstants;
				if (constants2 == null) {
					vc = constants[name];
				} else {
					vc = constants2[name];
					if (vc == null) vc = constants[name];
				}
				if (vc == null) {
					vc = Shader3D._globalConstants[name];
					if (vc == null) vc = shaderConstants[name];
				}
				if (vc == null) {
					trace('setRenderData warning, no vertex constants : ' + name);
				} else {
					_programConstantsManager.setProgramConstantsFromVector(Context3DProgramType.VERTEX, vi, vc.values, vc._length);
				}
			}
			
			var fragConstants:Object = shader._fragmentConstants;
			for (name in fragConstants) {
				var fi:uint = fragConstants[name];
				var fc:ShaderConstants;
				if (constants2 == null) {
					fc = constants[name];
				} else {
					fc = constants2[name];
					if (fc == null) fc = constants[name];
				}
				if (fc == null) {
					fc = Shader3D._globalConstants[name];
					if (fc == null) fc = shaderConstants[name];
				}
				if (fc == null) {
					trace('setRenderData warning, no fragment constants : ' + name);
				} else {
					_programConstantsManager.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, fi, fc.values, fc._length);
				}
			}
			
			if (!_programManager.setProgramFromData(shaderProgram)) {
				trace('setRenderData error, invalid shader');
				return false;
			}
			
			return true;
		}
		public function setRenderToBackBuffer():void {
			if (_numRtt > 0) {
				var i:int = _numRttInPool;
				
				for each (var rtt:RTT in _rtts) {
					_rttPool[_numRttInPool++] = rtt;
					
//					if (_context3D != null) {
//						_context3D.setRenderToTexture(null, false, 0, 0, rtt.colorOutputIndex);
//						
//						_debugger._changeOtherStateCount++;
//					}
				}
				
				for (; i < _numRttInPool; i++) {
					delete _rtts[_rttPool[i].colorOutputIndex];
				}
				
				_numRtt = 0;
				
				_context3D.setRenderToTexture(null, false, 0, 0);
				
				_debugger._changeOtherStateCount++;
			}
			
			if (_context3D != null) {
				_context3D.setRenderToBackBuffer();
				
				_debugger._changeOtherStateCount++;
			}
		}
		public function setRenderToTextureData(texture:AbstractTextureData, enableDepthAndStencil:Boolean=false, antiAlias:int=0, surfaceSelector:int=0, colorOutputIndex:int=0):void {
			var tex:TextureBase;
			
			var rtt:RTT = _rtts[colorOutputIndex];
			if (texture == null) {
				if (rtt != null) {
					delete _rtts[colorOutputIndex];
					_rttPool[_numRttInPool++] = rtt;
					_numRtt--;
				}
			} else {
				tex = texture.texture;
				
				if (rtt == null) {
					rtt = _numRttInPool == 0 ? new RTT() : _rttPool[--_numRttInPool];
					_rtts[colorOutputIndex] = rtt;
					_numRtt++;
				}
				
				rtt.id = texture._rootInstancID;
				rtt.enableDepthAndStencil = enableDepthAndStencil;
				rtt.antiAlias = antiAlias;
				rtt.surfaceSelector = surfaceSelector;
				rtt.colorOutputIndex = colorOutputIndex;
			}
			
			if (_context3D != null) {
				_context3D.setRenderToTexture(tex, enableDepthAndStencil, antiAlias, surfaceSelector);
				
				_debugger._changeOtherStateCount++;
			}
		}
		public function setScissorRectangle(rectangle:Rectangle):void {
			if (rectangle == null) {
				if (_setRect) {
					_setRect = false;
				} else {
					return;
				}
			} else {
				if (_setRect) {
					if (_rect.x == rectangle.x && _rect.y == rectangle.y && _rect.width == rectangle.width && _rect.height == rectangle.height) {
						return;
					} else {
						_rect.x = rectangle.x;
						_rect.y = rectangle.y;
						_rect.width = rectangle.width;
						_rect.height = rectangle.height;
					}
				} else {
					_setRect = true;
					
					_rect.x = rectangle.x;
					_rect.y = rectangle.y;
					_rect.width = rectangle.width;
					_rect.height = rectangle.height;
				}
			}
			
			if (_context3D != null) {
				if (_setRect) {
					_context3D.setScissorRectangle(_rect);
				} else {
					_context3D.setScissorRectangle(null);
				}
				
				_debugger._changeOtherStateCount++;
			}
		}
		asgl_protected function _lost():void {
			_indexBufferManager._lost();
			_programManager._lost();
			_textureManager._lost();
			_vertexBufferManager._lost();
			
			_context3D = null;
			
			if (hasEventListener(ASGLEvent.LOST)) dispatchEvent(new ASGLEvent(ASGLEvent.LOST));
		}
		private function _reset(context:Context3D):void {
			if (_context3D != null) _lost();
			
			_context3D = _stage.context3D;
			
			_context3D.enableErrorChecking = _enableErrorChecking;
			_context3D.setCulling(_culling);
			_context3D.setDepthTest(_depthTestMask, _depthTestPassCompareMode);
			_context3D.setBlendFactors(_blendSourceFactor, _blendDestinationFactor);
			
			if (_setRect) {
				_context3D.setScissorRectangle(_rect);
			} else {
				_context3D.setScissorRectangle(null);
			}
			
			_isSoftware = _context3D.driverInfo.search(/software/i) != -1;
			
			if (_isFirstRequest) {
				_isFirstRequest = false;
				
				if (hasEventListener(ASGLEvent.CREATE)) dispatchEvent(new ASGLEvent(ASGLEvent.CREATE));
			} else {
				_indexBufferManager._recovery();
				_programManager._recovery();
				_textureManager._recovery();
				_vertexBufferManager._recovery();
				_programConstantsManager._recovery();
				
				if (_numRtt > 0) {
					for each (var rtt:RTT in _rtts) {
						setRenderToTextureData(_textureManager._textureMap[rtt.id], rtt.enableDepthAndStencil, rtt.antiAlias, rtt.surfaceSelector, rtt.colorOutputIndex);
					}
				}
				
				if (hasEventListener(ASGLEvent.RECOVERY)) dispatchEvent(new ASGLEvent(ASGLEvent.RECOVERY));
			}
		}
		//handlers
		private function _context3DCreatedHandler(e:Event):void {
			_reset(_stage.context3D);
		}
	}
}

class RTT {
	public var id:uint;
	public var enableDepthAndStencil:Boolean;
	public var antiAlias:int;
	public var surfaceSelector:int;
	public var colorOutputIndex:int;
}