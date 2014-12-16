package asgl.effects.particles {
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import asgl.asgl_protected;
	import asgl.animators.TextureAnimationType;
	import asgl.geometries.MeshElement;
	import asgl.geometries.MeshElementType;
	import asgl.geometries.MeshElementValueMappingType;
	import asgl.math.Float3;
	import asgl.math.Float4;
	
	use namespace asgl_protected;
	
	public class StatelessHardwareTextureParticleData extends AbstractStatelessHardwareParticleData {
		private var _attributes3Element:MeshElement;
		private var _attributes4Element:MeshElement;
		private var _attributes3IndexFactor:int;
		private var _attributes4IndexFactor:int;
		
		private var _textureAnimationType:int;
		
		public function StatelessHardwareTextureParticleData() {
			_attributes3Element = new MeshElement();
			_attributes3Element.numDataPreElement = 4;
			_attributes3Element.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
			_attributes3Element.values = new Vector.<Number>();
			_attributes3IndexFactor = _attributes3Element.numDataPreElement * 4;
			
			_attributes4Element = new MeshElement();
			_attributes4Element.numDataPreElement = 4;
			_attributes4Element.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
			_attributes4Element.values = new Vector.<Number>();
			_attributes4IndexFactor = _attributes4Element.numDataPreElement * 4;
			
			_meshAsset.elements[MeshElementType.ATTRIBUTE3] = _attributes3Element;
			
			_textureAnimationType = TextureAnimationType.NONE;
		}
		public function get textureAnimationType():int {
			return _textureAnimationType;
		}
		public function set textureAnimationType(value:int):void {
			if (value == TextureAnimationType.NONE || value == TextureAnimationType.TILE) {
				_textureAnimationType = value;
				
				if (_textureAnimationType == TextureAnimationType.NONE) {
					delete _meshAsset.elements[MeshElementType.ATTRIBUTE4];
				} else {
					_meshAsset.elements[MeshElementType.ATTRIBUTE4] = _attributes4Element;
				}
			}
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
			_writeElementToBytes(bytes, _attributes3Element);
			_writeElementToBytes(bytes, _attributes4Element);
			
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
			_readElementFromBytes(bytes, _attributes3Element, _attributes3IndexFactor);
			_readElementFromBytes(bytes, _attributes4Element, _attributes4IndexFactor);
		}
		public override function disposeAsset():void {
			super.disposeAsset();
			
			_attributes3Element = null;
			_attributes4Element = null;
			
			delete _meshAsset.elements[MeshElementType.ATTRIBUTE3];
			delete _meshAsset.elements[MeshElementType.ATTRIBUTE4];
		}
		public function setParticle(index:uint, pos:Float3, startSize:Number, endSize:Number, startAlpha:Number, endAlpha:Number, startRotationQuat:Float4, rotationRadian:Float3, startTexCoord:Rectangle, endTexCoord:Rectangle, texCoordCycle:Number, numSplitTexCoord:uint, lifeCycle:Number, initialVelocity:Float3, startTime:Number):void {
			if (numSplitTexCoord < 2) numSplitTexCoord = 2;
			var segT:Number = 1 / numSplitTexCoord;
			
			var num:int = numSplitTexCoord - 1;
			var u2:Number = startTexCoord.x + startTexCoord.width;
			var v2:Number = startTexCoord.y + startTexCoord.height;
			var lenU:Number = endTexCoord.x - startTexCoord.x;
			var lenU2:Number = endTexCoord.x + endTexCoord.width - u2;
			var lenV:Number = endTexCoord.y - startTexCoord.y;
			var lenV2:Number = endTexCoord.y + endTexCoord.height - v2;
			var segU:Number = lenU / num;
			var segU2:Number = lenU2 / num;
			var segV:Number = lenV / num;
			var segV2:Number = lenV2 / num;
			
			_setPosAndLifeCycle(index, _verticesElement, _verticesIndexFactor, pos, lifeCycle);
			_setInitialVelocityAndStartTime(index, _attributes0Element, _attributes0IndexFactor, initialVelocity, startTime);
			_setAreaAndScale(index, _attributes1Element, _attributes1IndexFactor, startSize, endSize, startRotationQuat);
			_setRotation(index, _attributes2Element, _attributes2IndexFactor, rotationRadian);
			
			var i:int = _attributes3IndexFactor * index;
			
			_attributes3Element.values[i++] = startTexCoord.x;
			_attributes3Element.values[i++] = startTexCoord.y;
			_attributes3Element.values[i++] = startAlpha;
			_attributes3Element.values[i++] = endAlpha;
			
			_attributes3Element.values[i++] = u2;
			_attributes3Element.values[i++] = startTexCoord.y;
			_attributes3Element.values[i++] = startAlpha;
			_attributes3Element.values[i++] = endAlpha;
			
			_attributes3Element.values[i++] = u2;
			_attributes3Element.values[i++] = v2;
			_attributes3Element.values[i++] = startAlpha;
			_attributes3Element.values[i++] = endAlpha;
			
			_attributes3Element.values[i++] = startTexCoord.x;
			_attributes3Element.values[i++] = v2;
			_attributes3Element.values[i++] = startAlpha;
			_attributes3Element.values[i] = endAlpha;
			
			i = _attributes4IndexFactor * index;
			
			_attributes4Element.values[i++] = segT;
			_attributes4Element.values[i++] = texCoordCycle;
			_attributes4Element.values[i++] = segU;
			_attributes4Element.values[i++] = segV;
			
			_attributes4Element.values[i++] = segT;
			_attributes4Element.values[i++] = texCoordCycle;
			_attributes4Element.values[i++] = segU2;
			_attributes4Element.values[i++] = segV;
			
			_attributes4Element.values[i++] = segT;
			_attributes4Element.values[i++] = texCoordCycle;
			_attributes4Element.values[i++] = segU2;
			_attributes4Element.values[i++] = segV2;
			
			_attributes4Element.values[i++] = segT;
			_attributes4Element.values[i++] = texCoordCycle;
			_attributes4Element.values[i++] = segU;
			_attributes4Element.values[i++] = segV2;
		}
		protected override function _setNumParticles():void {
			_attributes2Element.values.length = _attributes2IndexFactor * _numParticles;
			_attributes3Element.values.length = _attributes3IndexFactor * _numParticles;
			_attributes4Element.values.length = _attributes4IndexFactor * _numParticles;
		}
	}
}

