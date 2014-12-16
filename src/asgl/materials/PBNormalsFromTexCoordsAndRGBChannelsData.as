package asgl.materials {
	import asgl.math.Float2;
	import asgl.pb.PBData;
	
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	
	public class PBNormalsFromTexCoordsAndRGBChannelsData extends PBData {
		[Embed(source="PBNormalsFromTexCoordsAndRGBChannels.pbj", mimeType="application/octet-stream")] private var PBJBytes:Class;
		public function PBNormalsFromTexCoordsAndRGBChannelsData() {
			super(new PBJBytes());
		}
		/**
		 * @param dest is ByteArray(Float) or Vector.&ltNumber&gt<br>
		 * dest = [height, 0.0, 0.0, ...]
		 * @param texCoords is ByteArray(Float) or Vector.&ltNumber&gt
		 */
		public function setData(dest:*, texCoords:*, normalMap:BitmapData, linear:Boolean, repeat:Boolean):void {
			var numData:uint;
			var f2:Float2;
			if (texCoords is ByteArray) {
				numData = texCoords.length/8;
			} else if (texCoords is Vector.<Number>) {
				numData = texCoords.length/2;
			} else {
				throw new Error();
			}
			f2 = getSize(numData, _tempFloat2);
			
			super.setInputFromVector('texCoords', texCoords, f2.x, f2.y);
			super.setInputFromBitmapData('normalMap', normalMap);
			
//			super.setParameter('linear', [1]);
			super.setParameter('repeat', [repeat ? 1 : 0]);
			super.setParameter('normalMapSize', [normalMap.width-1, normalMap.height-1]);
			
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