package asgl.math {
	public class Matrix4x4Helper {
		public function Matrix4x4Helper() {
		}
		public static function fixedAccuracy(matrices:Vector.<Matrix4x4>, accuracy:Number=0.0001):Boolean {
			var found:Boolean = false;
			
			var same:Array = [];
			
			var len:uint = matrices.length;
			for (var i:uint = 0; i < len; i++) {
				var m1:Matrix4x4 = matrices[i];
				
				same.length = 0;
				
				var sub:Array;
				var row:uint;
				var column:uint;
				var m2:Matrix4x4;
				
				for (var j:uint = i + 1; j < len; j++) {
					m2 = matrices[j];
					
					for (row = 0; row < 4; row++) {
						for (column = 0; column < 4; column++) {
							var v1:Number = m1.getElement(row, column);
							var v2:Number = m2.getElement(row, column);
							
							var a:Number = v1 - v2;
							if (a<0) a *= -1;
							
							if ((v1 != v1) || (v2 != v2)) continue;
							
							if ((a<=accuracy) && (v1 != v2)) {
								found = true;
								
								var index:uint = row * 4 + column;
								
								sub = same[index];
								if (sub == null) {
									sub = [];
									same[index] = sub;
								}
								
								sub[sub.length] = m2;
							}
						}
					}
				}
				
				for (j = 0; j < 16; j++) {
					sub = same[j];
					
					if (sub != null) {
						row = uint(j / 4);
						column = j % 4;
						
						var value:Number = m1.getElement(row, column);
						
						var num:uint = sub.length;
						for (var k:uint = 0; k < num; k++) {
							m2 = sub[k];
							
							value = (value+m2.getElement(row, column)) * 0.5;
						}
						
						m1.setElement(row, column, value);
						
						for (k = 0; k < num; k++) {
							m2 = sub[k];
							
							m2.setElement(row, column, value);
						}
					}
				}
			}
			
			if (found) fixedAccuracy(matrices, accuracy);
			
			return found;
		}
	}
}