package asgl.effects.particles {
	import flash.utils.ByteArray;
	
	import asgl.asgl_protected;
	import asgl.geometries.MeshAsset;
	import asgl.geometries.MeshElement;
	import asgl.geometries.MeshElementType;
	import asgl.geometries.MeshElementValueMappingType;
	import asgl.math.Float3;
	import asgl.math.Float4;
	import asgl.shaders.scripts.ShaderConstants;
	
	use namespace asgl_protected;
	
	public class AbstractStatelessHardwareParticleData {
		public static const MAX_PARTICLES:int = int(65535 / 4);
		
		protected static var _tempFloat3:Float3 = new Float3();
		
		asgl_protected var _meshAsset:MeshAsset;
		asgl_protected var _particleAttribute:ShaderConstants;
		
		asgl_protected var _numParticles:uint;
		
		protected var _verticesElement:MeshElement;
		protected var _attributes0Element:MeshElement;
		protected var _attributes1Element:MeshElement;
		protected var _attributes2Element:MeshElement;
		protected var _verticesIndexFactor:int;
		protected var _attributes0IndexFactor:int;
		protected var _attributes1IndexFactor:int;
		protected var _attributes2IndexFactor:int;
		
		private var _time:Number;
		private var _acceleration:Float3;
		private var _isLoop:Boolean;
		private var _hasRotation:Boolean;
		
		public function AbstractStatelessHardwareParticleData() {
			_time = 0;
			_acceleration = new Float3();
			
			_meshAsset = new MeshAsset();
			
			_verticesElement = new MeshElement();
			_verticesElement.numDataPreElement = 4;
			_verticesElement.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
			_verticesElement.values = new Vector.<Number>();
			_verticesIndexFactor = _verticesElement.numDataPreElement * 4;
			
			_attributes0Element = new MeshElement();
			_attributes0Element.numDataPreElement = 4;
			_attributes0Element.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
			_attributes0Element.values = new Vector.<Number>();
			_attributes0IndexFactor = _attributes0Element.numDataPreElement * 4;
			
			_attributes1Element = new MeshElement();
			_attributes1Element.numDataPreElement = 4;
			_attributes1Element.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
			_attributes1Element.values = new Vector.<Number>();
			_attributes1IndexFactor = _attributes1Element.numDataPreElement * 4;
			
			_attributes2Element = new MeshElement();
			_attributes2Element.numDataPreElement = 3;
			_attributes2Element.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
			_attributes2Element.values = new Vector.<Number>();
			_attributes2IndexFactor = _attributes2Element.numDataPreElement * 4;
			
			_meshAsset.triangleIndices = new Vector.<uint>();
			
			_meshAsset.elements[MeshElementType.VERTEX] = _verticesElement;
			_meshAsset.elements[MeshElementType.ATTRIBUTE0] = _attributes0Element;
			_meshAsset.elements[MeshElementType.ATTRIBUTE1] = _attributes1Element;
			
			_particleAttribute = new ShaderConstants(2);
			_particleAttribute.values = new Vector.<Number>(_particleAttribute._length * 4);
		}
		public function get isLoop():Boolean {
			return _isLoop;
		}
		public function set isLoop(value:Boolean):void {
			_isLoop = value;
			
			_particleAttribute.values[1] = _isLoop ? 1 : 0;
		}
		public function get hasRotation():Boolean {
			return _hasRotation;
		}
		public function set hasRotation(value:Boolean):void {
			_hasRotation = value;
			
			if (_hasRotation) {
				_meshAsset.elements[MeshElementType.ATTRIBUTE2] = _attributes2Element;
			} else {
				delete _meshAsset.elements[MeshElementType.ATTRIBUTE2];
			}
		}
		public function get meshAsset():MeshAsset {
			return _meshAsset;
		}
		public function get numParticles():uint {
			return _numParticles;
		}
		public function set numParticles(value:uint):void {
			if (_numParticles != value) {
				var old:uint = _numParticles;
				_numParticles = value;
				
				_verticesElement.values.length = _verticesIndexFactor * _numParticles;
				_attributes0Element.values.length = _attributes0IndexFactor * _numParticles;
				_attributes1Element.values.length = _attributes1IndexFactor * _numParticles;
				
				_setNumParticles();
				
				_meshAsset.triangleIndices.length = _numParticles * 6;
				
				if (_numParticles > old) {
					for (var i:int = old; i < _numParticles; i++) {
						var index:int = i * 6;
						var index2:int = i * 4;
						
						_meshAsset.triangleIndices[index++] = index2;
						_meshAsset.triangleIndices[index++] = index2 + 1;
						_meshAsset.triangleIndices[index++] = index2 + 2;
						_meshAsset.triangleIndices[index++] = index2;
						_meshAsset.triangleIndices[index++] = index2 + 2;
						_meshAsset.triangleIndices[index] = index2 + 3;
					}
				}
			}
		}
		public function get time():Number {
			return _time;
		}
		public function set time(value:Number):void {
			_time = value;
			
			_particleAttribute.values[0] = _time;
		}
		public function getAcceleration(op:Float3=null):Float3 {
			if (op == null) {
				return _acceleration.clone();
			} else {
				op.x = _acceleration.x;
				op.y = _acceleration.y;
				op.z = _acceleration.z;
				
				return op;
			}
		}
		public function setAcceleration(x:Number, y:Number, z:Number):void {
			_acceleration.x = x;
			_acceleration.y = y;
			_acceleration.z = z;
			
			_particleAttribute.values[4] = _acceleration.x / 2;
			_particleAttribute.values[5] = _acceleration.y / 2;
			_particleAttribute.values[6] = _acceleration.z / 2;
		}
		public function getData():ByteArray {
			return null;
		}
		public function setData(value:ByteArray):void {
		}
		public function disposeAsset():void {
			_verticesElement = null;
			_attributes0Element = null;
			_attributes1Element = null;
			_attributes2Element = null;
			
			delete _meshAsset.elements[MeshElementType.VERTEX];
			delete _meshAsset.elements[MeshElementType.ATTRIBUTE0];
			delete _meshAsset.elements[MeshElementType.ATTRIBUTE1];
			delete _meshAsset.elements[MeshElementType.ATTRIBUTE2];
		}
		protected function _setNumParticles():void {
		}
		protected function _setPosAndLifeCycle(index:uint, element:MeshElement, indexFactor, pos:Float3, lifeCycle:Number):void {
			var i:int = indexFactor * index;
			
			for (var j:int = 0; j < 4; j++) {
				element.values[i++] = pos.x;
				element.values[i++] = pos.y;
				element.values[i++] = pos.z;
				element.values[i++] = lifeCycle;
			}
		}
		protected function _setInitialVelocityAndStartTime(index:uint, element:MeshElement, indexFactor, initialVelocity:Float3, startTime:Number):void {
			var i:int = indexFactor * index;
			
			for (var j:int = 0; j < 4; j++) {
				element.values[i++] = initialVelocity.x;
				element.values[i++] = initialVelocity.y;
				element.values[i++] = initialVelocity.z;
				element.values[i++] = startTime;
			}
		}
		protected function _setAreaAndScale(index:uint, element:MeshElement, indexFactor, startSize:Number, endSize:Number, startRotationQuat:Float4):void {
			var sizeScale:Number = endSize / startSize;
			var halfSize:Number = startSize * 0.5;
			
			var i:int = indexFactor * index;
			
			if (startRotationQuat == null) {
				element.values[i++] = -halfSize;
				element.values[i++] = halfSize;
				element.values[i++] = 0;
				element.values[i++] = sizeScale;
				
				element.values[i++] = halfSize;
				element.values[i++] = halfSize;
				element.values[i++] = 0;
				element.values[i++] = sizeScale;
				
				element.values[i++] = halfSize;
				element.values[i++] = -halfSize;
				element.values[i++] = 0;
				element.values[i++] = sizeScale;
				
				element.values[i++] = -halfSize;
				element.values[i++] = -halfSize;
				element.values[i++] = 0;
				element.values[i++] = sizeScale;
			} else {
				var x:Number = -halfSize;
				var y:Number = halfSize;
				var w1:Number = -startRotationQuat.x * x - startRotationQuat.y * y;
				var x1:Number = startRotationQuat.w * x - startRotationQuat.z * y;
				var y1:Number = startRotationQuat.w * y + startRotationQuat.z * x;
				var z1:Number = startRotationQuat.x * y - startRotationQuat.y * x;
				element.values[i++] = -w1 * startRotationQuat.x + x1 * startRotationQuat.w - y1 * startRotationQuat.z + z1 * startRotationQuat.y;
				element.values[i++] = -w1 * startRotationQuat.y + x1 * startRotationQuat.z + y1 * startRotationQuat.w - z1 * startRotationQuat.x;
				element.values[i++] = -w1 * startRotationQuat.z - x1 * startRotationQuat.y + y1 * startRotationQuat.x + z1 * startRotationQuat.w;
				element.values[i++] = sizeScale;
				
				x = halfSize;
				y = halfSize;
				w1 = -startRotationQuat.x * x - startRotationQuat.y * y;
				x1 = startRotationQuat.w * x - startRotationQuat.z * y;
				y1 = startRotationQuat.w * y + startRotationQuat.z * x;
				z1 = startRotationQuat.x * y - startRotationQuat.y * x;
				element.values[i++] = -w1 * startRotationQuat.x + x1 * startRotationQuat.w - y1 * startRotationQuat.z + z1 * startRotationQuat.y;
				element.values[i++] = -w1 * startRotationQuat.y + x1 * startRotationQuat.z + y1 * startRotationQuat.w - z1 * startRotationQuat.x;
				element.values[i++] = -w1 * startRotationQuat.z - x1 * startRotationQuat.y + y1 * startRotationQuat.x + z1 * startRotationQuat.w;
				element.values[i++] = sizeScale;
				
				x = halfSize;
				y = -halfSize;
				w1 = -startRotationQuat.x * x - startRotationQuat.y * y;
				x1 = startRotationQuat.w * x - startRotationQuat.z * y;
				y1 = startRotationQuat.w * y + startRotationQuat.z * x;
				z1 = startRotationQuat.x * y - startRotationQuat.y * x;
				element.values[i++] = -w1 * startRotationQuat.x + x1 * startRotationQuat.w - y1 * startRotationQuat.z + z1 * startRotationQuat.y;
				element.values[i++] = -w1 * startRotationQuat.y + x1 * startRotationQuat.z + y1 * startRotationQuat.w - z1 * startRotationQuat.x;
				element.values[i++] = -w1 * startRotationQuat.z - x1 * startRotationQuat.y + y1 * startRotationQuat.x + z1 * startRotationQuat.w;
				element.values[i++] = sizeScale;
				
				x = -halfSize;
				y = -halfSize;
				w1 = -startRotationQuat.x * x - startRotationQuat.y * y;
				x1 = startRotationQuat.w * x - startRotationQuat.z * y;
				y1 = startRotationQuat.w * y + startRotationQuat.z * x;
				z1 = startRotationQuat.x * y - startRotationQuat.y * x;
				element.values[i++] = -w1 * startRotationQuat.x + x1 * startRotationQuat.w - y1 * startRotationQuat.z + z1 * startRotationQuat.y;
				element.values[i++] = -w1 * startRotationQuat.y + x1 * startRotationQuat.z + y1 * startRotationQuat.w - z1 * startRotationQuat.x;
				element.values[i++] = -w1 * startRotationQuat.z - x1 * startRotationQuat.y + y1 * startRotationQuat.x + z1 * startRotationQuat.w;
				element.values[i++] = sizeScale;
			}
		}
		protected function _setRotation(index:uint, element:MeshElement, indexFactor, rotationRadian:Float3):void {
			var i:int = indexFactor * index;
			var j:int;
			
			if (rotationRadian == null) {
				for (j = 0; j < 4; j++) {
					element.values[i++] = 0;
					element.values[i++] = 0;
					element.values[i++] = 0;
				}
			} else {
				for (j = 0; j < 4; j++) {
					element.values[i++] = rotationRadian.x * 0.5;
					element.values[i++] = rotationRadian.y * 0.5;
					element.values[i++] = rotationRadian.z * 0.5;
				}
			}
		}
		protected function _writeElementToBytes(bytes:ByteArray, element:MeshElement):void {
			var values:Vector.<Number> = element.values;
			var len:int = values.length;
			for (var i:int = 0; i < len; i++) {
				bytes.writeFloat(values[i]);
			}
		}
		protected function _readElementFromBytes(bytes:ByteArray, element:MeshElement, indexFactor:uint):void {
			var values:Vector.<Number> = element.values;
			var len:int = indexFactor * _numParticles;
			for (var i:int = 0; i < len; i++) {
				values[i] = bytes.readFloat();
			}
		}
		protected function _writeAttributesToBytes(bytes:ByteArray):void {
			bytes.writeBoolean(_isLoop);
			bytes.writeFloat(_acceleration.x);
			bytes.writeFloat(_acceleration.y);
			bytes.writeFloat(_acceleration.z);
		}
		protected function _readAttributesFromBytes(bytes:ByteArray):void {
			isLoop = bytes.readBoolean();
			setAcceleration(bytes.readFloat(), bytes.readFloat(), bytes.readFloat());
		}
	}
}