package asgl.math {
	
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	import asgl.pb.PBData;

	public class PBMatrix3x4TransformFloat3Data extends PBData {
		[Embed(source="PBMatrix3x4TransformFloat3.pbj", mimeType="application/octet-stream")] private var PBJBytes:Class;
		public function PBMatrix3x4TransformFloat3Data() {
			super(new PBJBytes());
		}
		/**
		 * @param dest is ByteArray(Float) or Vector.&ltNumber&gt<br>
		 * dest = [x, y, z, ...]
		 * @param src is ByteArray(Float) or Vector.&ltNumber&gt
		 */
		public function setData(dest:*, src:*, m:Matrix4x4):void {
			var numData:uint;
			var f2:Float2;
			if (src is ByteArray) {
				numData = src.length/12;
			} else if (src is Vector.<Number>) {
				numData = src.length/3;
			} else {
				throw new Error();
			}
			
			f2 = getSize(numData, _tempFloat2);
			super.setInputFromVector('src', src, f2.x, f2.y);
			
			super.setParameter('matrix', [m.m00, m.m01, m.m02, 0, m.m10, m.m11, m.m12, 0, m.m20, m.m21, m.m22, 0, m.m30, m.m31, m.m32, 1]);
			
			super.setTarget(dest, numData, 3, f2.x, f2.y);
		}
		public override function set byteCode(value:ByteArray):void {
			//empty
		}
		public override function setTarget(target:Object, numData:uint, channels:uint, width:uint, height:uint):void {
			//empty
		}
		public override function setInput(name:String, src:*, width:uint=0, height:uint=0):void {
			//empty
		}
		public override function setInputFromBitmapData(name:String, src:BitmapData):void {
			//empty
		}
		public override function setInputFromByteArray(name:String, src:ByteArray, width:uint, height:uint):void {
			//empty
		}
		public override function setInputFromVector(name:String, src:Vector.<Number>, width:uint, height:uint):void {
			//empty
		}
		public override function setParameter(name:String, value:Array):void {
			//empty
		}
	}
}