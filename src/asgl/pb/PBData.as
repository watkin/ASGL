package asgl.pb {
	import asgl.math.Float2;
	
	import flash.display.BitmapData;
	import flash.display.Shader;
	import flash.display.ShaderData;
	import flash.display.ShaderInput;
	import flash.display.ShaderParameter;
	import flash.utils.ByteArray;

	public class PBData implements IPBData {
		private static const MAX:uint = 4096;
		private static const POW_MAX_2:uint = MAX*MAX;
		protected static var _tempFloat2:Float2 = new Float2();
		private var _offsetTargetLength:uint;
		private var _targetHeight:uint;
		private var _targetWidth:uint;
		private var _target:Object;
		private var _shader:Shader;
		private var _data:ShaderData;
		public function PBData(byteCode:ByteArray=null) {
			_constructor(byteCode);
		}
		protected function _constructor(byteCode:ByteArray):void {
			_shader = new Shader(byteCode);
			_data = _shader.data;
		}
		public function set byteCode(value:ByteArray):void {
			_shader.byteCode = value;
			_data = _shader.data;
		}
		public function get offsetTargetLength():uint {
			return _offsetTargetLength;
		}
		public function get shader():Shader {
			return _shader;
		}
		public function get target():Object {
			return _target;
		}
		public function get targetHeight():uint {
			return _targetHeight;
		}
		public function get targetWidth():uint {
			return _targetWidth;
		}
		public function clear():void {
			if (_data != null) {
				for each (var value:* in _data) {
					if (value is ShaderInput) {
						value.input = null;
					}
				}
			}
		}
		public static function getSize(numData:uint, op:Float2=null):Float2 {
			var total:uint;
			
			if (op == null) op = new Float2();
			
			if (numData>MAX) {
				if (numData>POW_MAX_2) {
					throw new Error();
				} else {
					var sqrt:Number = Math.sqrt(numData);
					var intSqrt:uint = sqrt;
					op.x = sqrt == intSqrt ? intSqrt : intSqrt+1;
					op.y = op.x;
				}
			} else {
				op.x = numData;
				op.y = 1;
			}
			
			return op;
		}
		public function setTarget(target:Object, numData:uint, channels:uint, width:uint, height:uint):void {
			_target = target;
			_targetWidth = width;
			_targetHeight = height;
			_offsetTargetLength = (_targetWidth*_targetHeight-numData)*channels;
			if (_offsetTargetLength>0 && (target is ByteArray)) _offsetTargetLength *= 4;
		}
		public function setInput(name:String, src:*, width:uint=0, height:uint=0):void {
			if (src is Vector.<Number>) {
				this.setInputFromVector(name, src, width, height);
			} else if (src is ByteArray) {
				this.setInputFromByteArray(name, src, width, height);
			} else if (src is BitmapData) {
				this.setInputFromBitmapData(name, src);
			}
		}
		public function setInputFromBitmapData(name:String, src:BitmapData):void {
			var data:ShaderInput = _data[name];
			data.width = src.width;
			data.height = src.height;
			data.input = src;
		}
		public function setInputFromByteArray(name:String, src:ByteArray, width:uint, height:uint):void {
			var data:ShaderInput = _data[name];
			data.width = width;
			data.height = height;
			
			var max:uint = width*height*data.channels*4;
			var len:uint = src.length;
			if (len<max) src.length = max;
			
			data.input = src;
			
			if (len<max) src.length = len;
		}
		public function setInputFromVector(name:String, src:Vector.<Number>, width:uint, height:uint):void {
			var data:ShaderInput = _data[name];
			data.width = width;
			data.height = height;
			
			var max:uint = width*height*data.channels;
			var len:uint = src.length;
			var changeLength:Boolean = false;
			if (len<max) {
				src = src.concat();
				src.length = max;
			}
			
			data.input = src;
			
			if (changeLength) src.length = len;
		}
		public function setParameter(name:String, value:Array):void {
			var data:ShaderParameter = _data[name];
			data.value = value;
		}
	}
}