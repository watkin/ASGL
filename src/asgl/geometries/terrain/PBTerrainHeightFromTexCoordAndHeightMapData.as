package asgl.geometries.terrain {
	import asgl.math.Float2;
	import asgl.pb.PBData;
	
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	
	public class PBTerrainHeightFromTexCoordAndHeightMapData extends PBData {
		public static const A:uint = 0x1;
		public static const B:uint = 0x2;
		public static const G:uint = 0x4;
		public static const R:uint = 0x8;
		
		[Embed(source="PBTerrainHeightFromTexCoordAndHeightMap.pbj", mimeType="application/octet-stream")] private var PBJBytes:Class;
		public function PBTerrainHeightFromTexCoordAndHeightMapData() {
			super(new PBJBytes());
		}
		/**
		 * @param dest is ByteArray(Float) or Vector.&ltNumber&gt<br>
		 * dest = [height, 0.0, 0.0, ...]
		 * @param texCoords is ByteArray(Float) or Vector.&ltNumber&gt
		 */
		public function setData(dest:*, texCoords:*, heightMap:BitmapData, valueType:uint, minY:Number, maxY:Number, repeat:Boolean):void {
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
			super.setInputFromBitmapData('heightMap', heightMap);
			
			var length:uint;
			if (valueType == A || valueType == R || valueType == G || valueType == B) {
				length = 255;
			} else {
				length = 1;
			}
			
			super.setParameter('minY', [minY]);
			super.setParameter('unitHeight', [(maxY-minY)/length]);
			super.setParameter('valueType', [valueType]);
			super.setParameter('repeat', [repeat ? 1 : 0]);
			super.setParameter('heightMapSize', [heightMap.width-1, heightMap.height-1]);
			
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