package asgl.animators {
	import asgl.math.Float2;
	
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	import asgl.pb.PBData;
	
	public class PBSkinnedMeshVerticesCalculateData extends PBData {
		[Embed(source="PBSkinnedMeshVerticesCalculate.pbj", mimeType="application/octet-stream")] private var PBJBytes:Class;
		public function PBSkinnedMeshVerticesCalculateData() {
			super(new PBJBytes());
		}
		public function setBindData(dest:Vector.<Number>, vertices3AndWeight1:Vector.<Number>, vertices3AndWeight2:Vector.<Number>, vertices3AndWeight3:Vector.<Number>, vertices3AndWeight4:Vector.<Number>,
									boneIndices:Vector.<Number>):void {
			var numData:uint = vertices3AndWeight1.length/4;
			var f2:Float2 = getSize(numData, _tempFloat2);
			super.setInputFromVector('verticesAndWeight1', vertices3AndWeight1, f2.x, f2.y);
			super.setInputFromVector('verticesAndWeight2', vertices3AndWeight2, f2.x, f2.y);
			super.setInputFromVector('verticesAndWeight3', vertices3AndWeight3, f2.x, f2.y);
			super.setInputFromVector('verticesAndWeight4', vertices3AndWeight4, f2.x, f2.y);
			
			super.setInputFromVector('boneIndices', boneIndices, f2.x, f2.y);
			
			super.setTarget(dest, numData, 3, f2.x, f2.y);
		}
		public function setBoneData(boneMatrix_m00_m03:Vector.<Number>, boneMatrix_m10_m13:Vector.<Number>, boneMatrix_m20_m23:Vector.<Number>):void {
			var numData:uint = boneMatrix_m00_m03.length/4;
			var f2:Float2 = getSize(numData, _tempFloat2);
			super.setInputFromVector('boneMatrix_m00_m03', boneMatrix_m00_m03, f2.x, f2.y);
			super.setInputFromVector('boneMatrix_m10_m13', boneMatrix_m10_m13, f2.x, f2.y);
			super.setInputFromVector('boneMatrix_m20_m23', boneMatrix_m20_m23, f2.x, f2.y);
			
			super.setParameter('boneMatrixWidth', [f2.x]);
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