package asgl.pb {
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	
	public class PBExecutorData extends PBData {
		[Embed(source="PBExecutor.pbj", mimeType="application/octet-stream")] private var PBJBytes:Class;
		public function PBExecutorData() {
			super(new PBJBytes());
			
			super.setTarget(new Vector.<Number>, 1, 3, 1, 1);
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