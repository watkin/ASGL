package asgl.shaders.asm.agal {
	
	public class AGALCodec {
		public function AGALCodec() {
		}
		/**
		 * @param dest, the value is -1 to 1
		 * @param float, the value can set dest
		 * @param constants = v.nn, v.nn = [0.5, 2]
		 * 
		 * @see AGALCodec.encodeFloatToFloat
		 */
		public static function decodeFloatFromFloat(dest:String, float:String, constants:Vector.<String>):String {
			var code:String = '';
			
			code += AGALBase.sub(dest, float, constants[0]);
			code += AGALBase.mul(dest, dest, constants[1]);
			
			return code;
		}
		/**
		 * @param dest = v.n
		 * @param f2 = v.nn
		 * @param constants = v.nn, v.nn = [1/256, 1]
		 * @param tmp = v.n
		 * 
		 * @see AGALCodec.encodeFloatToFloat2
		 */
		public static function decodeFloatFromFloat2(dest:String, f2:String, constants:String, tmp:String):String {
			var code:String = '';
			
			code += AGALMath.dot2(dest, f2, constants, tmp);
			
			return code;
		}
		/**
		 * @param dest = v.n
		 * @param f3 = v.nnn
		 * @param constants = v.nnn, v.nnn = [1/(256*256), 1/256, 1]
		 * 
		 * @see AGALCodec.encodeFloatToFloat3
		 */
		public static function decodeFloatFromFloat3(dest:String, f3:String, constants:String):String {
			var code:String = '';
			
			code += AGALBase.dot3(dest, f3, constants);
			
			return code;
		}
		/**
		 * @param dest = v.n
		 * @param f4 = v
		 * @param constants = v, v.xyzw = [1/(255*255*255), 1/(255*255), 1/255, 1]
		 * 
		 * @see AGALCodec.encodeFloatToFloat4
		 */
		public static function decodeFloatFromFloat4(dest:String, f4:String, constants:String):String {
			var code:String = '';
			
			code += AGALBase.dot4(dest, f4, constants);
			
			return code;
		}
		/**
		 * @param dest = v, not use v.w
		 * @param number = v.n
		 * @param constants = [v.n, v.n, v.n]</br>
		 * constants = [0.001, 1, 10]
		 * @param tmp = v, will use v.xy
		 * 
		 * @see AGALCodec.encodeFloat3ToFloat
		 */
		public static function decodeFloat3FromFloat(dest:String, number:String, constants:Vector.<String>, tmp:String):String {
			var const0_001:String = constants[0];
			var const1:String = constants[1];
			var const10:String = constants[2];
			
			var mergeConst:String = AGALHelper.mergeVector(const10, const0_001);
			
			var code:String = '';
			
			code += AGALBase.frac(dest+'.x', number);
			code += AGALBase.sub(dest+'.y', number, dest+'.x');
			if (mergeConst == null) {
				code += AGALBase.mul(dest+'.x', dest+'.x', const10);
				
				code += AGALBase.mul(dest+'.z', dest+'.y', const0_001);
			} else {
				code += AGALBase.mul(dest+'.xz', dest+'.xy', mergeConst);
			}
			code += AGALBase.frac(dest+'.y', dest+'.z');
			code += AGALBase.sub(dest+'.z', dest+'.z', dest+'.y');
			code += AGALBase.sub(dest+'.z', const1, dest+'.z');
			code += AGALBase.mul(dest+'.y', dest+'.y', const10);
			
			code += AGALBase.sub(dest+'.xy', const1, dest+'.xy');
			
			code += AGALBase.mul(tmp+'.xy', dest+'.xy', dest+'.xy');
			code += AGALBase.add(tmp+'.x', tmp+'.x', tmp+'.y');
			code += AGALBase.sub(tmp+'.x', const1, tmp+'.x');
			code += AGALBase.sqrt(tmp+'.x', tmp+'.x');
			code += AGALBase.mul(dest+'.z', dest+'.z', tmp+'.x');
			
			return code;
		}
		/**
		 * @param constants = [v.n, v.n, v.n, v.n]</br>
		 * constants = [0, 1, 2]
		 * @param tmp = v.nn
		 * 
		 * @see AGALCodec.encodeFloat3ToFloat2
		 */
		public static function decodeFloat3FromFloat2(dest:String, float2:String, constants:Vector.<String>, tmp:String):String {
			var code:String = '';
			
			var scalars:Vector.<String> = AGALHelper.splitVector(dest, false);
			var destReg:String = AGALHelper.getRegister(dest)+'.';
			var destxy:String = destReg+scalars[0]+scalars[1];
			var destx:String = destReg+scalars[0];
			var desty:String = destReg+scalars[1];
			var destz:String = destReg+scalars[2];
			
			var float2x:String = AGALHelper.splitVector(float2)[0];
			
			scalars = AGALHelper.splitVector(tmp);
			var tmpx:String = scalars[0];
			var tmpy:String = scalars[1];
			
			code += AGALBase.abs(destxy, float2);
			code += AGALBase.mul(destxy, destxy, constants[2]);
			code += AGALBase.sub(destxy, destxy, constants[1]);
			
			code += AGALBase.mul(tmp, destxy, destxy);
			code += AGALBase.sub(destz, constants[1], tmpx);
			code += AGALBase.sub(destz, destz, tmpy);
			code += AGALBase.abs(destz, destz);
			code += AGALBase.sqrt(destz, destz);
			
			code += AGALBase.isGreaterEqual(tmpx, float2x, constants[0]);
			code += AGALBase.mul(tmpx, tmpx, constants[2]);
			code += AGALBase.sub(tmpx, tmpx, constants[1]);
			
			code += AGALBase.mul(destz, destz, tmpx);
			
			return code;
		}
		/**
		 * @param dest = v.nnn, the value is 0 to 1
		 * @param maxRange = v.n, the value is unsigned integer
		 * 
		 * @see AGALCodec.encodeFloat3ToFloat4
		 */
		public static function decodeFloat3FromFloat4(dest:String, float4:String, maxRange:String):String {
			var code:String = '';
			
			var scalars:Vector.<String> = AGALHelper.splitVector(dest);
			
			code += AGALBase.mul(scalars[0], float4+'.w', maxRange);
			code += AGALBase.mul(dest, float4+'.xyz', scalars[0]);
			
			return code;
		}
		/**
		 * @param dest the value is 0 to 1
		 * @param float the value is -1 to 1, the value can set dest
		 * @param constant = 0.5
		 * 
		 * @see AGALCodec.decodeFloatFromFloat
		 */
		public static function encodeFloatToFloat(dest:String, float:String, constant:String):String {
			var code:String = '';
			
			code += AGALBase.mul(dest, float, constant);
			code += AGALBase.add(dest, dest, constant);
			
			return code;
		}
		/**
		 * @param dest = v.nn, the components in 0-0.99999.....
		 * @param float = 0-0.99999....., the value can set dest or tmp
		 * @param constants1 = v.nn, v.nn = [256, 1]
		 * @param constants2 = v.n, v.n = 1/256
		 * @param tmp = v.nn
		 * 
		 * @see AGALCodec.decodeFloatFromFloat2
		 */
		public static function encodeFloatToFloat2(dest:String, float:String, constants1:String, constants2:String, tmp:String):String {
			var code:String = '';
			
			code += AGALBase.mul(dest, constants1, float);
			code += AGALBase.frac(dest, dest);
			code += AGALBase.mul(tmp, dest, constants2);
			code += AGALBase.sub(dest, dest, tmp);
			
			return code;
		}
		/**
		 * @param dest = v.nnn, the components in 0-0.99999.....
		 * @param float = 0-0.99999....., the value can set dest or tmp
		 * @param constants1 = v.nnn, v.nnn = [256*256, 256, 1]
		 * @param constants2 = v.n, v.n = 1/256
		 * @param tmp = v.nnn
		 * 
		 * @see AGALCodec.decodeFloatFromFloat3
		 */
		public static function encodeFloatToFloat3(dest:String, float:String, constants1:String, constants2:String, tmp:String):String {
			var code:String = '';
			
			code += AGALBase.mul(dest, constants1, float);
			code += AGALBase.frac(dest, dest);
			code += AGALBase.mul(tmp, dest, constants2);
			code += AGALBase.sub(dest, dest, tmp);
			
			return code;
		}
		/**
		 * @param dest = v, the components in 0-0.99999.....
		 * @param float = 0-0.99999....., the value can set dest or tmp
		 * @param constants1 = v, v.xyzw = [255*255*255, 255*255, 255, 1]
		 * @param constants2 = v, v.xyzw = [0, 1/255, 1/255, 1/255]
		 * @param tmp = v, will use all components.
		 * 
		 * @see AGALCodec.decodeFloatFromFloat4
		 */
		public static function encodeFloatToFloat4(dest:String, float:String, constants1:String, constants2:String, tmp:String):String {
			var code:String = '';
			
			code += AGALBase.mul(dest, constants1, float);
			code += AGALBase.frac(dest, dest);
			code += AGALBase.mul(tmp, dest+'.xxyz', constants2);
			code += AGALBase.sub(dest, dest, tmp);
			
			return code;
		}
		/**
		 * x,y,z is normalize
		 * 
		 * @see AGALCodec.decodeFloat3FromFloat
		 */
		public static function encodeFloat3ToFloat(x:Number, y:Number, z:Number):Number {
			x = 1 - x;
			y = 1 - y;
			
			var lx:uint = x;
			var ly:uint = y;
			
			var rx:uint = (x - lx) * 100;
			var ry:uint = (y - ly) * 100;
			
			if (rx == 99) {
				rx = 98;
			} else if (rx == 9) {
				rx = 8;
			} else if (rx == 0) {
				rx = 1;
			}
			if (ry == 99) {
				ry = 98;
			} else if (ry == 9) {
				ry = 8;
			} else if (ry == 0) {
				ry = 1;
			}
			
			var value:Number = (ly * 100 + ry) * 1000+lx * 100 + rx;
			if (z < 0) value += 2000000;
			
			return value * 0.001;
		}
		/**
		 * @param dest dest.x is -1 to 1, dest.y is 0 to 1
		 * @param float3 = v or v.nnn, is normalize
		 * @param constants = [v.n, v.n, v.n, v.n]</br>
		 * constants = [0, 1, 2]
		 * @param tmp = v.n
		 * 
		 * @see AGALCodec.decodeFloat3FromFloat2
		 */
		public static function encodeFloat3ToFloat2(dest:String, float3:String, constants:Vector.<String>, tmp:String):String {
			var code:String = '';
			
			var scalars:Vector.<String> = AGALHelper.splitVector(float3, false);
			var float3Reg:String = AGALHelper.getRegister(float3)+'.';
			float3 = float3Reg+scalars[0]+scalars[1];
			var float3z:String = float3Reg+scalars[2];
			
			scalars = AGALHelper.splitVector(dest, false);
			var destReg:String = AGALHelper.getRegister(dest)+'.';
			var destx:String = destReg+scalars[0];
			dest = destx+scalars[1];
			
			code += AGALBase.add(dest, float3, constants[1]);
			code += AGALBase.div(dest, dest, constants[2]);
			
			code += AGALBase.isGreaterEqual(tmp, float3z, constants[0]);
			code += AGALBase.mul(tmp, tmp, constants[2]);
			code += AGALBase.sub(tmp, tmp, constants[1]);
			code += AGALBase.mul(destx, destx, tmp);
			
			return code;
		}
		/**
		 * @param dest the value is 0 to 1
		 * @param float3 = v.nnn
		 * @param maxRange = v.n, the value is unsigned integer
		 * @param constants = [v.n, v.n]</br>
		 * constants = [0.000001, 1]
		 * 
		 * @see AGALCodec.decodeFloat3FromFloat4
		 */
		public static function encodeFloat3ToFloat4(dest:String, float3:String, maxRange:String, constants:Vector.<String>):String {
			var code:String = '';
			
			var scalars:Vector.<String> = AGALHelper.splitVector(float3);
			
			code += AGALBase.max(dest+'.x', scalars[0], scalars[1]);
			code += AGALBase.max(dest+'.y', scalars[2], constants[0]);
			code += AGALBase.max(dest+'.w', dest+'.x', dest+'.y');
			code += AGALBase.div(dest+'.w', dest+'.w', maxRange);
			code += AGALBase.min(dest+'.w', dest+'.w', constants[1]);
			code += AGALBase.mul(dest+'.x', dest+'.w', maxRange);
			code += AGALBase.div(dest+'.xyz', float3, dest+'.xxx');
			code += AGALBase.min(dest+'.xyz', dest+'.xyz', constants[1]);
			
			return code;
		}
	}
}