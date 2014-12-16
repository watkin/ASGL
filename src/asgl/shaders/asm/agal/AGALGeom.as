package asgl.shaders.asm.agal {
	public class AGALGeom {
		public function AGALGeom() {
		}
		/**
		 * @param dest v.nnn</br>
		 * set dest.nnn
		 * @param normal v.nnn normal is normalize.
		 * @param tangent v.nnn tangent is normalize.
		 */
		public static function binormal(dest:String, normal:String, tangent:String):String {
			var code:String = '';
			
			code += AGALBase.cross(dest, normal, tangent);
			
			return code;
		}
		/**
		 * @param dest = v.n
		 * @param src1 = v.nnn, the value can set tmp
		 * @param src2 = v.nnn, the value can set tmp
		 * @param tmp = v.nnn
		 */
		public static function distance(dest:String, src1:String, src2:String, tmp:String):String {
			var code:String = '';
			
			code += AGALBase.sub(tmp, src2, src1);
			code += AGALBase.dot3(dest, tmp, tmp);
			code += AGALBase.sqrt(dest, dest);
			
			return code;
		}
		/**
		 * <pre>
		 * incidenceDir - 2 ~~ normalize(incidenceDir) ~~ normal
		 * </pre>
		 * 
		 * @param dest v.nnn</br>
		 * set dest.nnn
		 * @param incidenceDir = v.nnn(pixelPos-lightingPos), incidenceDir is normalize
		 * @param normal = v.nnn, the value can set dest, normal is normalize
		 * @param tmp = v.n
		 */
		public static function reflect(dest:String, incidenceDir:String, normal:String, tmp:String):String {
			var code:String = '';
			
			code += AGALBase.dot3(tmp, normal, incidenceDir);
			code += AGALBase.add(tmp, tmp, tmp);
			code += AGALBase.mul(dest, tmp, normal);
			code += AGALBase.sub(dest, incidenceDir, dest);
			
			return code;
		}
		/**
		 * <pre>
		 * k = 1 - eta ~~ eta ~~ (1 - normalize(-incidenceDir)) ~~ normalize(-incidenceDir)
		 * if (k < 0) dest = (0, 0, 0)
		 * else dest = eta ~~ incidenceDir + (eta ~~ normalize(-incidenceDir) - sqrt(abs(k))) ~~ normal
		 * </pre>
		 * 
		 * @param dest v.nnn</br>
		 * set dest.nnn
		 * @param incidenceDir = v.nnn(pixelPos-lightingPos), the value can set dest, incidenceDir is normalize
		 * @param normal = v.nnn, the value can set dest, normal is normalize
		 * @param eta = v.n, the value is ratio of indices of refraction
		 * @param constants = [v.n, v.n]</br>
		 * constants = [0, 1]
		 * @param tmp = v
		 */
		public static function refract(dest:String, incidenceDir:String, normal:String, eta:String, constants:Vector.<String>, tmp:String):String {
			var code:String = '';
			
			code += AGALBase.negate(tmp+'.xyz', incidenceDir);
			code += AGALBase.dot3(tmp+'.x', normal, tmp+'.xyz');
			code += AGALBase.mul(tmp+'.w', tmp+'.x', tmp+'.x');
			code += AGALBase.sub(tmp+'.w', constants[1], tmp+'.w');
			if (AGALHelper.isConstant(eta)) {
				code += AGALBase.move(tmp+'.z', eta);
				code += AGALBase.mul(tmp+'.z', tmp+'.z', tmp+'.z');
			} else {
				code += AGALBase.mul(tmp+'.z', eta, eta);
			}
			code += AGALBase.mul(tmp+'.w', tmp+'.w', tmp+'.z');
			code += AGALBase.sub(tmp+'.w', constants[1], tmp+'.w');//k
			
			code += AGALBase.mul(tmp+'.x', eta, tmp+'.x');
			code += AGALBase.abs(tmp+'.z', tmp+'.w');
			code += AGALBase.sqrt(tmp+'.z', tmp+'.z');
			code += AGALBase.sub(tmp+'.x', tmp+'.x', tmp+'.z');
			code += AGALBase.mul(tmp+'.xyz', normal, tmp+'.xxx');
			code += AGALBase.mul(dest, eta, incidenceDir);
			code += AGALBase.add(dest, dest, tmp+'.xyz');
			
			code += AGALBase.isLessThan(tmp+'.w', constants[0], tmp+'.w');
			code += AGALBase.mul(dest, dest, tmp+'.w');
			
			return code;
		}
		/**
		 * @param dest = v.nn
		 * @param vertexCoord = v.nn, v.nn = vertexCoord.xy, the value can set dest
		 * @param constants = [v.n, v.n]</br>
		 * constants = [0.5, 1]
		 * @param w = v.n
		 */
		public static function vertexCoordToTex2DCoord(dest:String, vertexCoord:String, constants:Vector.<String>, w:String=null):String {
			var code:String = '';
			
			if (w == null) {
				code += AGALBase.add(dest, vertexCoord, constants[1]);
			} else {
				code += AGALBase.div(dest, vertexCoord, w);
				code += AGALBase.add(dest, dest, constants[1]);
			}
			
			var scalars:Vector.<String> = AGALHelper.splitVector(dest);
			var y:String = scalars[1];
			
			code += AGALBase.mul(dest, dest, constants[0]);
			code += AGALBase.sub(y, constants[1], y);
			
			return code;
		}
		/**
		 * @param dest = v.n, the value can set src
		 * @param projSpaceDepth = v.n, is proj space depth, the value is 0 to 1, can set dest
		 * @param constants = [v.n, v.n]</br>
		 * constants = [zFar/(zFar-zNear) (the value is proj matrix m22), zNear*zFar/(zNear-zFar) (the value is proj matrix m32)]
		 */
		public static function viewSpaceDepth(dest:String, projSpaceDepth:String, constants:Vector.<String>):String {
			var code:String = '';
			
			code += AGALBase.sub(dest, projSpaceDepth, constants[0]);
			code += AGALBase.div(dest, constants[1], dest);
			
			return code;
		}
		/**
		 * @param dest = v.nn, the value can set projSpaceXY
		 * @param projSpaceXY = v.nn, is proj space xy, the value is 0 to 1, can set dest
		 * @param constants = [v.n, v.n]</br>
		 * constants = [width/(2*zNear) (the value is proj matrix 1/m00), height/(2*zNear) (the value is proj matrix 1/m11)]
		 */
		public static function viewSpaceXY(dest:String, projSpaceXY:String, viewSpaceDepth:String, constants:Vector.<String>):String {
			var code:String = '';
			
			var mergeConst:String = AGALHelper.mergeVector(constants[0], constants[1]);
			
			code += AGALBase.mul(dest, projSpaceXY, viewSpaceDepth);
			
			if (mergeConst == null) {
				var scalars:Vector.<String> = AGALHelper.splitVector(dest);
				
				code += AGALBase.mul(scalars[0], scalars[0], constants[0]);
				code += AGALBase.mul(scalars[1], scalars[1], constants[1]);
			} else {
				code += AGALBase.mul(dest, dest, mergeConst);
			}
			
			return code;
		}
	}
}