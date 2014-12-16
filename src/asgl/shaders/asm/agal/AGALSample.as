package asgl.shaders.asm.agal {
	import asgl.shaders.asm.IShaderCoder;

	public class AGALSample {
		public function AGALSample() {
		}
		/**
		 * @param destUV destUV = v or v.nn
		 * @param handler handler(offsetRow:int, offsetColumn:int):void
		 */
		public static function getRectRangeTexCoords(destUV:String, shaderCoder:IShaderCoder, rangeUpRows:uint, rangeDownRows:uint, rangeLeftColumns:uint, rangeRightColumns:uint, centerUV:String, unitU:String, unitV:String, handler:Function):void {
			var scalars:Vector.<String> = AGALHelper.splitVector(centerUV);
			var u:String = scalars[0];
			var v:String = scalars[1];
			
			scalars = AGALHelper.splitVector(destUV);
			var destU:String = scalars[0];
			var destV:String = scalars[1];
			
			var offsetColumn:int;
			
			for (var offsetRow:int = -1; offsetRow >= -rangeUpRows; offsetRow--) {
				if (offsetRow == -1) {
					shaderCoder.appendCode(AGALBase.sub(destV, v, unitV));
				} else {
					shaderCoder.appendCode(AGALBase.sub(destV, destV, unitV));
				}
				shaderCoder.appendCode(AGALBase.move(destU, u));
				
				//tex(0, -v)
				handler(offsetRow, 0);
				
				for (offsetColumn = -1; offsetColumn >= -rangeLeftColumns; offsetColumn--) {
					shaderCoder.appendCode(AGALBase.sub(destU, destU, unitU));
					
					//tex(-u, -v)
					handler(offsetRow, offsetColumn);
				}
				
				for (offsetColumn = 1; offsetColumn <= rangeRightColumns; offsetColumn++) {
					if (offsetColumn == 1) {
						shaderCoder.appendCode(AGALBase.add(destU, u, unitU));
					} else {
						shaderCoder.appendCode(AGALBase.add(destU, destU, unitU));
					}
					
					//tex(u, -v)
					handler(offsetRow, offsetColumn);
				}
			}
			
			for (offsetRow = 1; offsetRow <= rangeDownRows; offsetRow++) {
				if (offsetRow == 1) {
					shaderCoder.appendCode(AGALBase.add(destV, v, unitV));
				} else {
					shaderCoder.appendCode(AGALBase.add(destV, destV, unitV));
				}
				shaderCoder.appendCode(AGALBase.move(destU, u));
				
				//tex(0, v)
				handler(offsetRow, 0);
				
				for (offsetColumn = -1; offsetColumn >= -rangeLeftColumns; offsetColumn--) {
					shaderCoder.appendCode(AGALBase.sub(destU, destU, unitU));
					
					//tex(-u, v)
					handler(offsetRow, offsetColumn);
				}
				
				for (offsetColumn = 1; offsetColumn <= rangeRightColumns; offsetColumn++) {
					if (offsetColumn == 1) {
						shaderCoder.appendCode(AGALBase.add(destU, u, unitU));
					} else {
						shaderCoder.appendCode(AGALBase.add(destU, destU, unitU));
					}
					
					//tex(u, v)
					handler(offsetRow, offsetColumn);
				}
			}
			
			shaderCoder.appendCode(AGALBase.move(destUV, centerUV));
			
			//tex(0, 0)
			handler(0, 0);
			
			for (offsetColumn = -1; offsetColumn >= -rangeLeftColumns; offsetColumn--) {
				shaderCoder.appendCode(AGALBase.sub(destU, destU, unitU));
				
				//tex(-u, 0)
				handler(0, offsetColumn);
			}
			
			for (offsetColumn = 1; offsetColumn <= rangeRightColumns; offsetColumn++) {
				if (offsetColumn == 1) {
					shaderCoder.appendCode(AGALBase.add(destU, u, unitU));
				} else {
					shaderCoder.appendCode(AGALBase.add(destU, destU, unitU));
				}
				
				//tex(u, 0)
				handler(0, offsetColumn);
			}
		}
	}
}