package asgl.math {
	import asgl.pb.PBData;
	
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	
	public class PBRayTraceFromLinearSpaceByMatrix4x4Data extends PBData {
		[Embed(source="PBRayTraceFromLinearSpaceByMatrix4x4.pbj", mimeType="application/octet-stream")] private var PBJBytes:Class;
		public function PBRayTraceFromLinearSpaceByMatrix4x4Data() {
			super(new PBJBytes());
		}
		/**
		 * @param dest is ByteArray(Float) or Vector.&ltNumber&gt<br>
		 * dest = [if (true) traceZ, 1, 0 (else) 0, 0, 0, ...]
		 * @param vertices is ByteArray(Float) or Vector.&ltNumber&gt
		 * @param indices is ByteArray(Float) or Vector.&ltNumber&gt
		 */
		public function setData(dest:*, vertices:*, indices:*, pos:Float3, dir:Float3, m:Matrix4x4):void {
			var numData:uint;
			var f2:Float2;
			if (vertices is ByteArray) {
				numData = vertices.length/12;
			} else if (vertices is Vector.<Number>) {
				numData = vertices.length/3;
			} else {
				throw new Error();
			}
			f2 = getSize(numData, _tempFloat2);
			super.setInputFromVector('vertices', vertices, f2.x, f2.y);
			
			super.setParameter('pos', [pos.x, pos.y, pos.z]);
			super.setParameter('dir', [dir.x, dir.y, dir.z]);
			super.setParameter('verticesWidth', [f2.x]);
			super.setParameter('matrix', [m.m00, m.m10, m.m20, m.m30, m.m01, m.m11, m.m21, m.m31, m.m02, m.m12, m.m22, m.m32, m.m03, m.m13, m.m23, m.m33]);
			
			if (indices is ByteArray) {
				numData = indices.length/12;
			} else if (indices is Vector.<Number>) {
				numData = indices.length/3;
			} else {
				throw new Error();
			}
			f2 = getSize(numData, _tempFloat2);
			super.setInputFromVector('indices', indices, f2.x, f2.y);
			
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