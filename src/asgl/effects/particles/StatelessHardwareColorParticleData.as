package asgl.effects.particles {
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import asgl.asgl_protected;
	import asgl.geometries.MeshElement;
	import asgl.geometries.MeshElementType;
	import asgl.geometries.MeshElementValueMappingType;
	import asgl.math.Float3;
	import asgl.math.Float4;
	
	use namespace asgl_protected;
	
	public class StatelessHardwareColorParticleData extends AbstractStatelessHardwareParticleData {
		private var _color0Element:MeshElement;
		private var _color1Element:MeshElement;
		private var _color0IndexFactor:int;
		private var _color1IndexFactor:int;
		
		public function StatelessHardwareColorParticleData() {
			_color0Element = new MeshElement();
			_color0Element.numDataPreElement = 4;
			_color0Element.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
			_color0Element.values = new Vector.<Number>();
			_color0IndexFactor = _color0Element.numDataPreElement * 4;
			
			_color1Element = new MeshElement();
			_color1Element.numDataPreElement = 4;
			_color1Element.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
			_color1Element.values = new Vector.<Number>();
			_color1IndexFactor = _color1Element.numDataPreElement * 4;
			
			_meshAsset.elements[MeshElementType.COLOR0] = _color0Element;
			_meshAsset.elements[MeshElementType.COLOR1] = _color1Element;
		}
		public override function getData():ByteArray {
			var bytes:ByteArray = new ByteArray();
			bytes.endian = Endian.LITTLE_ENDIAN;
			
			bytes.writeShort(_numParticles);
			_writeAttributesToBytes(bytes);
			_writeElementToBytes(bytes, _verticesElement);
			_writeElementToBytes(bytes, _attributes0Element);
			_writeElementToBytes(bytes, _attributes1Element);
			_writeElementToBytes(bytes, _attributes2Element);
			_writeElementToBytes(bytes, _color0Element);
			_writeElementToBytes(bytes, _color1Element);
			
			return bytes;
		}
		public override function setData(value:ByteArray):void {
			var bytes:ByteArray = new ByteArray();
			bytes.endian = Endian.LITTLE_ENDIAN;
			bytes.position = 0;
			
			this.numParticles = bytes.readUnsignedShort();
			_readAttributesFromBytes(bytes);
			_readElementFromBytes(bytes, _verticesElement, _verticesIndexFactor);
			_readElementFromBytes(bytes, _attributes0Element, _attributes0IndexFactor);
			_readElementFromBytes(bytes, _attributes1Element, _attributes1IndexFactor);
			_readElementFromBytes(bytes, _attributes2Element, _attributes2IndexFactor);
			_readElementFromBytes(bytes, _color0Element, _color0IndexFactor);
			_readElementFromBytes(bytes, _color1Element, _color1IndexFactor);
		}
		public function setParticle(index:uint, pos:Float3, startSize:Number, endSize:Number, startColor:Float4, endColor:Float4, startRotationQuat:Float4, rotationRadian:Float3, lifeCycle:Number, initialVelocity:Float3, startTime:Number):void {
			_setPosAndLifeCycle(index, _verticesElement, _verticesIndexFactor, pos, lifeCycle);
			_setInitialVelocityAndStartTime(index, _attributes0Element, _attributes0IndexFactor, initialVelocity, startTime);
			_setAreaAndScale(index, _attributes1Element, _attributes1IndexFactor, startSize, endSize, startRotationQuat);
			_setRotation(index, _attributes2Element, _attributes2IndexFactor, rotationRadian);
			
			var i:int = _color0IndexFactor * index;
			
			for (var j:int = 0; j < 4; j++) {
				_color0Element.values[i++] = startColor.x;
				_color0Element.values[i++] = startColor.y;
				_color0Element.values[i++] = startColor.z;
				_color0Element.values[i++] = startColor.w;
			}
			
			i = _color1IndexFactor * index;
			
			for (j = 0; j < 4; j++) {
				_color1Element.values[i++] = endColor.x;
				_color1Element.values[i++] = endColor.y;
				_color1Element.values[i++] = endColor.z;
				_color1Element.values[i++] = endColor.w;
			}
		}
		protected override function _setNumParticles():void {
			_color0Element.values.length = _color0IndexFactor * _numParticles;
			_color1Element.values.length = _color1IndexFactor * _numParticles;
		}
	}
}

