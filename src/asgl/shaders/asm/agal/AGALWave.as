package asgl.shaders.asm.agal {
	public class AGALWave {
		public function AGALWave() {
		}
		/**
		 * <pre>
		 * offsetX = steepness ~~ A ~~ D.x ~~ cos(dot(D, pos) ~~ w + time ~~ omega)
		 * offsetY = A ~~ sin(dot(D, pos) ~~ w + time ~~ omega)
		 * offsetZ = steepness ~~ A ~~ D.z ~~ cos(dot(D, pos) ~~ w + time ~~ omega)
		 * </pre>
		 * 
		 * @param dest = v.nnn, compute offset of position(x, y, z)
		 * @param pos = v.nn, horizontal position(x, z)
		 * @param amplitude = v.n
		 * @param speed = v.n
		 * @param direction = v.nn, move direction on plane(x, z), direction is normalize.
		 * @param steepness = v.n, steepness = 0 is single wave, steepness = 1 / (w x A) is sharp crest. if steepness == null, will set the value = 1 / (w x A)
		 * @param time = v.n
		 * @param waveLength = v.n
		 * @param constants = [v.n]</br>
		 * constants = [2 x PI]
		 * @param tmp = v.nnn
		 */
		public static function gerstnerWave(dest:String, pos:String, amplitude:String, speed:String, direction:String, steepness:String, time:String, waveLength:String, constants:Vector.<String>, tmp:String):String {
			var code:String = '';
			
			var scalars:Vector.<String> = AGALHelper.splitVector(tmp);
			
			var PI2:String = constants[0];
			
			if (AGALHelper.isConstant(PI2) && AGALHelper.isConstant(waveLength)) {
				code += AGALBase.move(scalars[0], PI2);
				code += AGALBase.div(scalars[0], scalars[0], waveLength);
			} else {
				code += AGALBase.div(scalars[0], PI2, waveLength);
			}
			code += AGALBase.mul(scalars[1], scalars[0], speed);
			code += AGALBase.mul(scalars[1], scalars[1], time);
			code += gerstnerWave2(dest, pos, amplitude, speed, direction, steepness, scalars[0], scalars[1], scalars[2]);
			
			return code;
		}
		/**
		 * <pre>
		 * offsetX = steepness ~~ A ~~ D.x ~~ cos(dot(D, pos) ~~ w + time ~~ omega)
		 * offsetY = A ~~ sin(dot(D, pos) ~~ w + time ~~ omega)
		 * offsetZ = steepness ~~ A ~~ D.z ~~ cos(dot(D, pos) ~~ w + time ~~ omega)
		 * </pre>
		 * 
		 * @param dest = v.nnn, compute offset of position(x, y, z)
		 * @param pos = v.nn, horizontal position(x, z)
		 * @param amplitude = v.n
		 * @param speed = v.n
		 * @param direction = v.nn, move direction on plane(x, z), direction is normalize.
		 * @param steepness = v.n.</br>
		 * steepness = 0 is single wave.</br>
		 * steepness = 1 / (w x A) is sharp crest.</br>
		 * if steepness == null, will set the value = 1 / (w x A)
		 * @param w = v.n, 2 x PI / WaveLength
		 * @param omegaDotTime = v.n, omega = speed x 2 x PI / WaveLength; v.n = time x omega
		 * @param tmp = v.n
		 */
		public static function gerstnerWave2(dest:String, pos:String, amplitude:String, speed:String, direction:String, steepness:String, w:String, omegaDotTime:String, tmp:String):String {
			var code:String = '';
			
			var scalars:Vector.<String> = AGALHelper.splitVector(dest);
			var dest1:String = scalars[0];
			var dest2:String = scalars[1];
			var dest3:String = scalars[2];
			
			scalars = AGALHelper.splitVector(direction);
			var dir1:String = scalars[0];
			var dir2:String = scalars[1];
			
			code += AGALMath.dot2(dest1, direction, pos, tmp);
			code += AGALBase.mul(tmp, dest1, w);
			code += AGALBase.add(tmp, tmp, omegaDotTime);
			code += AGALBase.cos(dest3, tmp);
			if (steepness == null) {
				steepness = dest2;
				code += AGALBase.mul(steepness, w, amplitude);
				code += AGALBase.reciprocal(steepness, steepness);
			}
			code += AGALBase.mul(dest3, dest3, steepness);
			code += AGALBase.mul(dest3, dest3, amplitude);
			code += AGALBase.mul(dest1, dest3, dir1);
			code += AGALBase.mul(dest2, dest3, dir2);
			code += AGALBase.sin(dest3, tmp);
			code += AGALBase.mul(dest3, dest3, amplitude);
			
			return code;
		}
		/**
		 * <pre>
		 * offsetY = A ~~ sin(dot(D, pos) ~~ w + time ~~ omega)
		 * </pre>
		 * 
		 * @param dest = v.n, compute offset of position(y)
		 * @param pos = v.nn, horizontal position(x, z)
		 * @param amplitude = v.n
		 * @param speed = v.n
		 * @param direction = v.nn, move direction on plane(x, z), direction is normalize.
		 * @param time = v.n
		 * @param waveLength = v.n
		 * @param constants = [v.n]</br>
		 * constants = [2 x PI]
		 * @param tmp = v.nnn
		 */
		public static function singleWave(dest:String, pos:String, amplitude:String, speed:String, direction:String, time:String, waveLength:String, constants:Vector.<String>, tmp:String):String {
			var code:String = '';
			
			var scalars:Vector.<String> = AGALHelper.splitVector(tmp);
			
			var PI2:String = constants[0];
			
			if (AGALHelper.isConstant(PI2) && AGALHelper.isConstant(waveLength)) {
				code += AGALBase.move(scalars[0], PI2);
				code += AGALBase.div(scalars[0], scalars[0], waveLength);
			} else {
				code += AGALBase.div(scalars[0], PI2, waveLength);
			}
			code += AGALBase.mul(scalars[1], scalars[0], speed);
			code += AGALBase.mul(scalars[1], scalars[1], time);
			code += singleWave2(dest, pos, amplitude, speed, direction, scalars[0], scalars[1], scalars[2]);
			
			return code;
		}
		/**
		 * <pre>
		 * offsetY = A ~~ sin(dot(D, pos) ~~ w + time ~~ omega)
		 * </pre>
		 * 
		 * @param dest = v.n, compute offset of position(y)
		 * @param pos = v.nn, horizontal position(x, z)
		 * @param amplitude = v.n
		 * @param speed = v.n
		 * @param direction = v.nn, move direction on plane(x, z), direction is normalize.
		 * @param w = v.n, 2 x PI / WaveLength
		 * @param omegaDotTime = v.n, omega = speed x 2 x PI / WaveLength; v.n = time x omega
		 * @param tmp = v.n
		 */
		public static function singleWave2(dest:String, pos:String, amplitude:String, speed:String, direction:String, w:String, omegaDotTime:String, tmp:String):String {
			var code:String = '';
			
			code += AGALMath.dot2(dest, direction, pos, tmp);
			code += AGALBase.mul(dest, dest, w);
			code += AGALBase.add(dest, dest, omegaDotTime);
			code += AGALBase.sin(dest, dest);
			code += AGALBase.mul(dest, dest, amplitude);
			
			return code;
		}
	}
}