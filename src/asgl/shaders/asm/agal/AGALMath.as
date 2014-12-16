package asgl.shaders.asm.agal {
	import asgl.shaders.asm.Register;

	public class AGALMath {
		public function AGALMath() {
		}
		/**
		 * @param dest = v.n
		 * @param x = v.n, the value can set dest
		 * @param constants = [v.n, v.n ... v.n]</br>
		 * constants = [0, 1, -0.0187293, 0.0742610, -0.2121144, 1.5707288, 3.14159265358979]
		 * @param tmp = v or v.nn, will use two components.
		 */
		public static function acos(dest:String, x:String, constants:Vector.<String>, tmp:String):String {
			var code:String = '';
			
			var scalars:Vector.<String> = AGALHelper.splitVector(tmp);
			var scalar1:String = scalars[0];
			var scalar2:String = scalars[1];
			
			code += AGALBase.isLessThan(scalar1, x, constants[0]);
			
			code += AGALBase.abs(scalar2, x);
			code += AGALBase.mul(dest, scalar2, constants[2]);
			code += AGALBase.add(dest, dest, constants[3]);
			code += AGALBase.mul(dest, dest, scalar2);
			code += AGALBase.add(dest, dest, constants[4]);
			code += AGALBase.mul(dest, dest, scalar2);
			code += AGALBase.add(dest, dest, constants[5]);
			code += AGALBase.sub(scalar2, constants[1], scalar2);
			code += AGALBase.sqrt(scalar2, scalar2);
			code += AGALBase.mul(dest, dest, scalar2);
			code += AGALBase.add(scalar2, scalar1, scalar1);
			code += AGALBase.mul(scalar2, scalar2, dest);
			code += AGALBase.sub(dest, dest, scalar2);
			code += AGALBase.mul(scalar1, scalar1, constants[6]);
			code += AGALBase.sub(dest, scalar1, dest);
			
			return code;
		}
		/**
		 * @param dest = v.n
		 * @param x = v.n
		 * @param constants = [v.n, v.n ... v.n]</br>
		 * constants = [0, 1, -0.0187293, 0.0742610, -0.2121144, 1.5707288, 3.14159265358979*0.5]
		 * @param tmp = v.n
		 */
		public static function asin(dest:String, x:String, constants:Vector.<String>, tmp:String):String {
			var code:String = '';
			
			code += AGALBase.abs(tmp, x);
			code += AGALBase.mul(dest, tmp, constants[2]);
			code += AGALBase.add(dest, dest, constants[3]);
			code += AGALBase.mul(dest, dest, tmp);
			code += AGALBase.add(dest, dest, constants[4]);
			code += AGALBase.mul(dest, dest, tmp);
			code += AGALBase.add(dest, dest, constants[5]);
			code += AGALBase.sub(tmp, constants[1], tmp);
			code += AGALBase.sqrt(tmp, tmp);
			code += AGALBase.mul(dest, dest, tmp);
			code += AGALBase.sub(dest, constants[6], dest);
			code += AGALBase.isLessThan(tmp, x, constants[0]);
			code += AGALBase.add(tmp, tmp, tmp);
			code += AGALBase.mul(tmp, tmp, dest);
			code += AGALBase.sub(dest, dest, tmp);
			
			return code;
		}
		/**
		 * @param dest = v.n
		 * @param x = v.n
		 * @param constants = [v.n, v.n ... v.n]</br>
		 * constants = [0, 1, -0.013480470, 0.057477314, -0.121239071, 0.195635925, -0.332994597, 0.999995630, 1.570796327, 3.141592654]
		 * @param tmp = v, will use four components.
		 */
		public static function atan(dest:String, x:String, constants:Vector.<String>, tmp:String):String {
			var code:String = '';
			
			code += atan2(dest, x, constants[1], constants, tmp);
			
			return code;
		}
		/**
		 * @param dest = v.n
		 * @param y = v.n
		 * @param x = v.n
		 * @param constants = [v.n, v.n ... v.n]</br>
		 * constants = [0, 1, -0.013480470, 0.057477314, -0.121239071, 0.195635925, -0.332994597, 0.999995630, 1.570796327, 3.141592654]
		 * @param tmp = v, will use four components.
		 */
		public static function atan2(dest:String, y:String, x:String, constants:Vector.<String>, tmp:String):String {
			var const1:String = constants[1];
			
			var code:String = '';
			
			code += AGALBase.abs(tmp+'.z', x);
			code += AGALBase.abs(tmp+'.w', y);
			code += AGALBase.max(tmp+'.x', tmp+'.z', tmp+'.w');
			code += AGALBase.min(tmp+'.y', tmp+'.z', tmp+'.w');
			code += AGALBase.reciprocal(dest, tmp+'.x');
			code += AGALBase.mul(dest, dest, tmp+'.y');
			
			code += AGALBase.mul(tmp+'.x', dest, dest);
			code += AGALBase.mul(tmp+'.y', tmp+'.x', constants[2]);//-0.013480470
			code += AGALBase.add(tmp+'.y', tmp+'.y', constants[3]);//0.057477314
			code += AGALBase.mul(tmp+'.y', tmp+'.y', tmp+'.x');
			code += AGALBase.add(tmp+'.y', tmp+'.y', constants[4]);//-0.121239071
			code += AGALBase.mul(tmp+'.y', tmp+'.y', tmp+'.x');
			code += AGALBase.add(tmp+'.y', tmp+'.y', constants[5]);//0.195635925
			code += AGALBase.mul(tmp+'.y', tmp+'.y', tmp+'.x');
			code += AGALBase.add(tmp+'.y', tmp+'.y', constants[6]);//-0.332994597
			code += AGALBase.mul(tmp+'.y', tmp+'.y', tmp+'.x');
			code += AGALBase.add(tmp+'.y', tmp+'.y', constants[7]);//0.999995630
			code += AGALBase.mul(dest, dest, tmp+'.y');
			
			code += AGALBase.sub(tmp+'.x', constants[8], dest);//1.570796327
			code += AGALComparison.ifLessThan(tmp+'.w', tmp+'.z', tmp+'.w', tmp+'.x', dest, const1, tmp+'.y');
			code += AGALBase.sub(tmp+'.z', constants[9], tmp+'.w');//3.141592654
			code += AGALComparison.ifLessThan(tmp+'.x', x, constants[0], tmp+'.z', tmp+'.w', const1, tmp+'.y');
			code += AGALBase.negate(tmp+'.y', dest);
			code += AGALComparison.ifLessThan(dest, y, constants[0], tmp+'.y', tmp+'.x', const1, tmp+'.z');
			
			code += '';
			
			return code;
		}
		/**
		 * ceil.</br>
		 * destination = ceil(source)</br>
		 * </br>
		 * <b>example:</b>
		 * <pre>
		 * ceil('vt0', 'vt1', 'vt2')
		 * ceil('vt0.x', 'vt1.x', 'vt2.x')
		 * </pre>
		 */
		public static function ceil(dest:String, src:String, tmp:String):String {
			var code:String = '';
			
			code += AGALBase.negate(tmp, src);
			code += AGALMath.floor(dest, tmp);
			code += AGALBase.negate(dest, dest);
			
			return code;
		}
		/**
		 * max(min, min(max, x))
		 * 
		 * <pre>
		 * if (x > max) dest = max
		 * else if (x < min) dest = min
		 * else dest = x
		 * </pre>
		 * 
		 * <b>example:</b>
		 * <pre>
		 * clamp('vt0', 'vt1', 'vt2', 'vt3')
		 * clamp('vt0.x', 'vt1.x', 'vt2.x', 'vt3.x')
		 * </pre>
		 * 
		 * @param x the value can set dest
		 * @param max the value can set dest
		 */
		public static function clamp(dest:String, x:String, max:String, min:String):String {
			var code:String = '';
			
			code += AGALBase.min(dest, x, max);
			code += AGALBase.max(dest, dest, min);
			
			return code;
		}
		/**
		 * hyperbolic cosine.</br>
		 * 
		 * @param dest = v.n
		 * @param x = v.n, the value can set dest
		 * @param constants = [v.n, v.n]</br>
		 * constants = [0.5, 2.71828182845904523536]
		 * @param tmp = v or v.nn, will use two components.
		 */
		public static function cosh(dest:String, x:String, constants:Vector.<String>, tmp:String):String {
			var code:String = '';
			
			var scalars:Vector.<String> = AGALHelper.splitVector(tmp);
			var scalar1:String = scalars[0];
			var scalar2:String = scalars[1];
			
			code += AGALBase.pow(scalar1, constants[1], x);
			code += AGALBase.negate(scalar2, x);
			code += AGALBase.pow(scalar2, constants[1], scalar2);
			code += AGALBase.add(scalar1, scalar1, scalar2);
			code += AGALBase.mul(dest, scalar1, constants[0]);
			
			return code;
		}
		/**
		 * converted from radians to degrees
		 * 
		 * @param src the value can set dest
		 * @param constants = v.n, v.n = 57.29577951
		 */
		public static function degrees(dest:String, src:String, constants:String):String {
			var code:String = '';
			
			code += AGALBase.mul(dest, src, constants);
			
			return code;
		}
		/**
		 * @param dest = v.n
		 * @param src1 = v.nn
		 * @param src2 = v.nn
		 * @param tmp = v.n
		 */
		public static function dot2(dest:String, src1:String, src2:String, tmp:String):String {
			var code:String = '';
			
			var scalars1:Vector.<String> = AGALHelper.splitVector(src1);
			var scalars2:Vector.<String> = AGALHelper.splitVector(src2);
			
			code += AGALBase.mul(dest, scalars1[0], scalars2[0]);
			code += AGALBase.mul(tmp, scalars1[1], scalars2[1]);
			code += AGALBase.add(dest, dest, tmp);
			
			return code;
		}
		/**
		 * <pre>
		 * f + (1 - f) ~~ ((1 - normalize(eyesDir))^fresnelPower)
		 * </pre>
		 * 
		 * @param dest = v.n
		 * @param f = v.n
		 * @param eyesDir = v.nnn, eyesDir is normalize.
		 * @param normal = v.nnn, normal is normalize.
		 * @param fresnelPower = v.n
		 * @param constants = [v.n]</br>
		 * constants = [1]
		 * @param tmp = v.n
		 */
		public static function fastFresnel(dest:String, f:String, eyesDir:String, normal:String, fresnelPower:String, constants:Vector.<String>, tmp:String):String {
			var code:String = '';
			
			code += AGALBase.dot3(dest, eyesDir, normal);
			code += AGALBase.sub(dest, constants[0], dest);
			code += AGALBase.pow(dest, dest, fresnelPower);
			code += AGALBase.sub(tmp, constants[0], f);
			code += AGALBase.mul(dest, tmp, dest);
			code += AGALBase.add(dest, dest, f);
			
			return code;
		}
		/**
		 * floor.</br>
		 * destination = floor(source)</br>
		 * </br>
		 * <b>example:</b>
		 * <pre>
		 * floor('vt0', 'vt1', 'vt2')
		 * floor('vt0.x', 'vt1.x', 'vt2.x')
		 * </pre>
		 */
		public static function floor(dest:String, src:String):String {
			var code:String = '';
			
			code += AGALBase.frac(dest, src);
			code += AGALBase.sub(dest, src, dest);
			
			return code;
		}
		/**
		 * compute the remainder of x/y with the same sign as x
		 * 
		 * @param constants = [0, 1, 2]</br>
		 */
		public static function fmod(dest:String, x:String, y:String, constants:Vector.<String>, tmp:String):String {
			var code:String = '';
			
			code += AGALBase.div(dest, x, y);
			code += AGALBase.abs(dest, dest);
			code += AGALBase.frac(dest, dest);
			code += AGALBase.abs(tmp, y);
			code += AGALBase.mul(dest, dest, tmp);
			code += AGALBase.isGreaterEqual(tmp, x, constants[0]);
			code += AGALBase.mul(tmp, constants[2], tmp);
			code += AGALBase.sub(tmp, tmp, constants[1]);
			code += AGALBase.mul(dest, tmp, dest);
			
			return code;
		}
		/**
		 * @param src2, the value can set dest
		 */
		public static function lerp(dest:String, src1:String, src2:String, f:String):String {
			var code:String = '';
			
			code += AGALBase.sub(dest, src2, src1);
			code += AGALBase.mul(dest, dest, f);
			code += AGALBase.add(dest, dest, src1);
			
			return code;
		}
		/**
		 * multiply matrix 3x3.</br>
		 * 
		 * <pre>
		 * destination.x = (source1.x ~~ source2.x) + (source1.y ~~ source2.y) + (source1.z ~~ source2.z)
		 * destination.y = (source1.x ~~ source3.x) + (source1.y ~~ source3.y) + (source1.z ~~ source3.z)
		 * destination.z = (source1.x ~~ source4.x) + (source1.y ~~ source4.y) + (source1.z ~~ source4.z)
		 * </pre>
		 */
		public static function m33Components(dest:String, src1:String, src2:String, src3:String, src4:String):String {
			var code:String = '';
			
			if (AGALHelper.getScalars(src2).length != 3) src2 = AGALHelper.getRegister(src2)+'.xyz';
			if (AGALHelper.getScalars(src3).length != 3) src3 = AGALHelper.getRegister(src3)+'.xyz';
			if (AGALHelper.getScalars(src4).length != 3) src4 = AGALHelper.getRegister(src4)+'.xyz';
			
			code += AGALBase.dot3(dest+'.x', src1+'.xyz', src2);
			code += AGALBase.dot3(dest+'.y', src1+'.xyz', src3);
			code += AGALBase.dot3(dest+'.z', src1+'.xyz', src4);
			
			return code;
		}
		/**
		 * multiply matrix 3x3.</br>
		 * equal to 3 simple opcode. less 1 simple opcode to AGALBase.m33
		 * 
		 * <pre>
		 * destination.x = (source1.x ~~ source2[0].x) + (source1.y ~~ source2[0].y) + (source1.z ~~ source2[0].z)
		 * destination.y = (source1.x ~~ source2[1].x) + (source1.y ~~ source2[1].y) + (source1.z ~~ source2[1].z)
		 * destination.z = (source1.x ~~ source2[2].x) + (source1.y ~~ source2[2].y) + (source1.z ~~ source2[2].z)
		 * </pre>
		 */
		public static function m33Continuation(dest:String, src1:String, src2:String):String {
			var code:String = '';
			
			var reg:Register = new Register();
			reg.setFromString(src2);
			var type:String = reg.type;
			var index:int = reg.index;
			
			code += AGALBase.dot3(dest+'.x', src1+'.xyz', src2+'.xyz');
			code += AGALBase.dot3(dest+'.y', src1+'.xyz', type+(index+1)+'.xyz');
			code += AGALBase.dot3(dest+'.z', src1+'.xyz', type+(index+2)+'.xyz');
			
			return code;
		}
		public static function m33Transpose(dest1:String, dest2:String, dest3:String, src1:String, src2:String, src3:String):String {
			var code:String = '';
			
			var reg:Register;
			
			if (dest3 == null) {
				if (dest2 == null) {
					if (reg == null) reg = new Register();
					reg.setFromString(dest1);
					dest2 = reg.type+(reg.index+1);
					dest3 = reg.type+(reg.index+2);
				} else {
					if (reg == null) reg = new Register();
					reg.setFromString(dest2);
					dest3 = reg.type+(reg.index+1);
				}
			}
			
			if (src3 == null) {
				if (src2 == null) {
					if (reg == null) reg = new Register();
					reg.setFromString(src1);
					src2 = reg.type+(reg.index+1);
					src3 = reg.type+(reg.index+2);
				} else {
					if (reg == null) reg = new Register();
					reg.setFromString(src2);
					src3 = reg.type+(reg.index+1);
				}
			}
			
			code += AGALBase.move(dest1+'.x', src1+'.x');
			code += AGALBase.move(dest1+'.y', src2+'.x');
			code += AGALBase.move(dest1+'.z', src3+'.x');
			
			code += AGALBase.move(dest2+'.x', src1+'.y');
			code += AGALBase.move(dest2+'.y', src2+'.y');
			code += AGALBase.move(dest2+'.z', src3+'.y');
			
			code += AGALBase.move(dest3+'.x', src1+'.z');
			code += AGALBase.move(dest3+'.y', src2+'.z');
			code += AGALBase.move(dest3+'.z', src3+'.z');
			
			return code;
		}
		/**
		 * multiply matrix 3x4.</br>
		 * equal to 3 simple opcode. less 1 simple opcode to AGALBase.m34
		 * 
		 * <pre>
		 * destination.x = (source1.x ~~ source2[0].x) + (source1.y ~~ source2[0].y) + (source1.z ~~ source2[0].z) + (source1.w ~~ source2[0].w)
		 * destination.y = (source1.x ~~ source2[1].x) + (source1.y ~~ source2[1].y) + (source1.z ~~ source2[1].z) + (source1.w ~~ source2[1].w)
		 * destination.z = (source1.x ~~ source2[2].x) + (source1.y ~~ source2[2].y) + (source1.z ~~ source2[2].z) + (source1.w ~~ source2[2].w)
		 * </pre>
		 */
		public static function m34continuation(dest:String, src1:String, src2:String):String {
			var code:String = '';
			
			var reg:Register = new Register();
			reg.setFromString(src2);
			var type:String = reg.type;
			var index:int = reg.index;
			
			code += AGALBase.dot4(dest+'.x', src1, src2);
			code += AGALBase.dot4(dest+'.y', src1, type+(index+1));
			code += AGALBase.dot4(dest+'.z', src1, type+(index+2));
			
			return code;
		}
		/**
		 * matrix 3x4 * matrix 3x4.</br>
		 * 
		 * <pre>
		 * dest_00_30.x = (m1_00_30.x ~~ m2_00_03.x) + (m1_01_31.x ~~ m2_10_13.x) + (m1_02_32.x ~~ m2_20_23.x)
		 * dest_00_30.y = (m1_00_30.y ~~ m2_00_03.y) + (m1_01_31.y ~~ m2_10_13.y) + (m1_02_32.y ~~ m2_20_23.y)
		 * dest_00_30.z = (m1_00_30.z ~~ m2_00_03.z) + (m1_01_31.z ~~ m2_10_13.z) + (m1_02_32.z ~~ m2_20_23.z)
		 * dest_00_30.w = (m1_00_30.w ~~ m2_00_03.w) + (m1_01_31.w ~~ m2_10_13.w) + (m1_02_32.w ~~ m2_20_23.w) + m2_00_30.w
		 * </br>
		 * dest_01_31.x = (m1_00_30.x ~~ m2_00_03.x) + (m1_01_31.x ~~ m2_10_13.x) + (m1_02_32.x ~~ m2_20_23.x)
		 * dest_01_31.y = (m1_00_30.y ~~ m2_00_03.y) + (m1_01_31.y ~~ m2_10_13.y) + (m1_02_32.y ~~ m2_20_23.y)
		 * dest_01_31.z = (m1_00_30.z ~~ m2_00_03.z) + (m1_01_31.z ~~ m2_10_13.z) + (m1_02_32.z ~~ m2_20_23.z)
		 * dest_01_31.w = (m1_00_30.w ~~ m2_00_03.w) + (m1_01_31.w ~~ m2_10_13.w) + (m1_02_32.w ~~ m2_20_23.w) + m2_01_31.w
		 * </br>
		 * dest_02_32.x = (m1_00_30.x ~~ m2_00_03.x) + (m1_01_31.x ~~ m2_10_13.x) + (m1_02_32.x ~~ m2_20_23.x)
		 * dest_02_32.y = (m1_00_30.y ~~ m2_00_03.y) + (m1_01_31.y ~~ m2_10_13.y) + (m1_02_32.y ~~ m2_20_23.y)
		 * dest_02_32.z = (m1_00_30.z ~~ m2_00_03.z) + (m1_01_31.z ~~ m2_10_13.z) + (m1_02_32.z ~~ m2_20_23.z)
		 * dest_02_32.w = (m1_00_30.w ~~ m2_00_03.w) + (m1_01_31.w ~~ m2_10_13.w) + (m1_02_32.w ~~ m2_20_23.w) + m2_02_32.w
		 * </pre>
		 */
		public static function m34xm34(dest_00_30:String, dest_01_31:String, dest_02_32:String,
									   m1_00_30:String, m1_01_31:String, m1_02_32:String,
									   m2_00_30:String, m2_01_31:String, m2_02_32:String,
									   tmp:String):String {
			var code:String = '';
			
			code += AGALBase.move(tmp+'.x', m1_00_30+'.x');
			code += AGALBase.move(tmp+'.y', m1_01_31+'.x');
			code += AGALBase.move(tmp+'.z', m1_02_32+'.x');
			code += AGALBase.dot3(dest_00_30+'.x', tmp, m2_00_30);
			code += AGALBase.dot3(dest_01_31+'.x', tmp, m2_01_31);
			code += AGALBase.dot3(dest_02_32+'.x', tmp, m2_02_32);
			code += AGALBase.move(tmp+'.x', m1_00_30+'.y');
			code += AGALBase.move(tmp+'.y', m1_01_31+'.y');
			code += AGALBase.move(tmp+'.z', m1_02_32+'.y');
			code += AGALBase.dot3(dest_00_30+'.y', tmp, m2_00_30);
			code += AGALBase.dot3(dest_01_31+'.y', tmp, m2_01_31);
			code += AGALBase.dot3(dest_02_32+'.y', tmp, m2_02_32);
			code += AGALBase.move(tmp+'.x', m1_00_30+'.z');
			code += AGALBase.move(tmp+'.y', m1_01_31+'.z');
			code += AGALBase.move(tmp+'.z', m1_02_32+'.z');
			code += AGALBase.dot3(dest_00_30+'.z', tmp, m2_00_30);
			code += AGALBase.dot3(dest_01_31+'.z', tmp, m2_01_31);
			code += AGALBase.dot3(dest_02_32+'.z', tmp, m2_02_32);
			code += AGALBase.move(tmp+'.x', m1_00_30+'.w');
			code += AGALBase.move(tmp+'.y', m1_01_31+'.w');
			code += AGALBase.move(tmp+'.z', m1_02_32+'.w');
			code += AGALBase.dot3(dest_00_30+'.w', tmp, m2_00_30);
			code += AGALBase.dot3(dest_01_31+'.w', tmp, m2_01_31);
			code += AGALBase.dot3(dest_02_32+'.w', tmp, m2_02_32);
			code += AGALBase.add(dest_00_30+'.w', dest_00_30+'.w', m2_00_30+'.w');
			code += AGALBase.add(dest_01_31+'.w', dest_01_31+'.w', m2_01_31+'.w');
			code += AGALBase.add(dest_02_32+'.w', dest_02_32+'.w', m2_02_32+'.w');
			
			return code;
		}
		/**
		 * matrix 4x4 * matrix 4x4.</br>
		 * 
		 * <pre>
		 * dest_00_30.x = (m1_00_30.x ~~ m2_00_30.x) + (m1_01_31.x ~~ m2_00_30.y) + (m1_02_32.x ~~ m2_00_30.z) + (m1_03_33.x ~~ m2_00_30.w)
		 * dest_00_30.y = (m1_00_30.y ~~ m2_01_31.x) + (m1_01_31.y ~~ m2_01_31.y) + (m1_02_32.y ~~ m2_01_31.z) + (m1_03_33.y ~~ m2_01_31.w)
		 * dest_00_30.z = (m1_00_30.z ~~ m2_02_32.x) + (m1_01_31.z ~~ m2_02_32.y) + (m1_02_32.z ~~ m2_02_32.z) + (m1_03_33.z ~~ m2_02_32.w)
		 * dest_00_30.w = (m1_00_30.w ~~ m2_03_33.x) + (m1_01_31.w ~~ m2_03_33.y) + (m1_02_32.w ~~ m2_03_33.z) + (m1_03_33.w ~~ m2_03_33.w)
		 * </br>
		 * dest_01_31.x = (m1_00_30.x ~~ m2_00_30.x) + (m1_01_31.x ~~ m2_00_30.y) + (m1_02_32.x ~~ m2_00_30.z) + (m1_03_33.x ~~ m2_00_30.w)
		 * dest_01_31.y = (m1_00_30.y ~~ m2_01_31.x) + (m1_01_31.y ~~ m2_01_31.y) + (m1_02_32.y ~~ m2_01_31.z) + (m1_03_33.y ~~ m2_01_31.w)
		 * dest_01_31.z = (m1_00_30.z ~~ m2_02_32.x) + (m1_01_31.z ~~ m2_02_32.y) + (m1_02_32.z ~~ m2_02_32.z) + (m1_03_33.z ~~ m2_02_32.w)
		 * dest_01_31.w = (m1_00_30.w ~~ m2_03_33.x) + (m1_01_31.w ~~ m2_03_33.y) + (m1_02_32.w ~~ m2_03_33.z) + (m1_03_33.w ~~ m2_03_33.w)
		 * </br>
		 * dest_02_32.x = (m1_00_30.x ~~ m2_00_30.x) + (m1_01_31.x ~~ m2_00_30.y) + (m1_02_32.x ~~ m2_00_30.z) + (m1_03_33.x ~~ m2_00_30.w)
		 * dest_02_32.y = (m1_00_30.y ~~ m2_01_31.x) + (m1_01_31.y ~~ m2_01_31.y) + (m1_02_32.y ~~ m2_01_31.z) + (m1_03_33.y ~~ m2_01_31.w)
		 * dest_02_32.z = (m1_00_30.z ~~ m2_02_32.x) + (m1_01_31.z ~~ m2_02_32.y) + (m1_02_32.z ~~ m2_02_32.z) + (m1_03_33.z ~~ m2_02_32.w)
		 * dest_02_32.w = (m1_00_30.w ~~ m2_03_33.x) + (m1_01_31.w ~~ m2_03_33.y) + (m1_02_32.x ~~ m2_03_33.z) + (m1_03_33.w ~~ m2_03_33.w)
		 * </br>
		 * dest_03_33.x = (m1_00_30.x ~~ m2_00_30.x) + (m1_01_31.x ~~ m2_00_30.y) + (m1_02_32.x ~~ m2_00_30.z) + (m1_03_33.x ~~ m2_00_30.w)
		 * dest_03_33.y = (m1_00_30.y ~~ m2_01_31.x) + (m1_01_31.y ~~ m2_01_31.y) + (m1_02_32.y ~~ m2_01_31.z) + (m1_03_33.y ~~ m2_01_31.w)
		 * dest_03_33.z = (m1_00_30.z ~~ m2_02_32.x) + (m1_01_31.z ~~ m2_02_32.y) + (m1_02_32.z ~~ m2_02_32.z) + (m1_03_33.z ~~ m2_02_32.w)
		 * dest_03_33.w = (m1_00_30.w ~~ m2_03_33.x) + (m1_01_31.w ~~ m2_03_33.y) + (m1_02_32.x ~~ m2_03_33.z) + (m1_03_33.w ~~ m2_03_33.w)
		 * </pre>
		 */
		public static function m44xm44_1(dest_00_30:String, dest_01_31:String, dest_02_32:String, dest_03_33:String,
										 m1_00_30:String, m1_01_31:String, m1_02_32:String, m1_03_33:String,
										 m2_00_30:String, m2_01_31:String, m2_02_32:String, m2_03_33:String,
										 tmp:String):String {
			var code:String = '';
			
			code += AGALBase.move(tmp+'.x', m1_00_30+'.x');
			code += AGALBase.move(tmp+'.y', m1_01_31+'.x');
			code += AGALBase.move(tmp+'.z', m1_02_32+'.x');
			code += AGALBase.move(tmp+'.w', m1_03_33+'.x');
			code += AGALBase.dot4(dest_00_30+'.x', tmp, m2_00_30);
			code += AGALBase.dot4(dest_01_31+'.x', tmp, m2_01_31);
			code += AGALBase.dot4(dest_02_32+'.x', tmp, m2_02_32);
			code += AGALBase.dot4(dest_03_33+'.x', tmp, m2_03_33);
			code += AGALBase.move(tmp+'.x', m1_00_30+'.y');
			code += AGALBase.move(tmp+'.y', m1_01_31+'.y');
			code += AGALBase.move(tmp+'.z', m1_02_32+'.y');
			code += AGALBase.move(tmp+'.w', m1_03_33+'.y');
			code += AGALBase.dot4(dest_00_30+'.y', tmp, m2_00_30);
			code += AGALBase.dot4(dest_01_31+'.y', tmp, m2_01_31);
			code += AGALBase.dot4(dest_02_32+'.y', tmp, m2_02_32);
			code += AGALBase.dot4(dest_03_33+'.y', tmp, m2_03_33);
			code += AGALBase.move(tmp+'.x', m1_00_30+'.z');
			code += AGALBase.move(tmp+'.y', m1_01_31+'.z');
			code += AGALBase.move(tmp+'.z', m1_02_32+'.z');
			code += AGALBase.move(tmp+'.w', m1_03_33+'.z');
			code += AGALBase.dot4(dest_00_30+'.z', tmp, m2_00_30);
			code += AGALBase.dot4(dest_01_31+'.z', tmp, m2_01_31);
			code += AGALBase.dot4(dest_02_32+'.z', tmp, m2_02_32);
			code += AGALBase.dot4(dest_03_33+'.z', tmp, m2_03_33);
			code += AGALBase.move(tmp+'.x', m1_00_30+'.w');
			code += AGALBase.move(tmp+'.y', m1_01_31+'.w');
			code += AGALBase.move(tmp+'.z', m1_02_32+'.w');
			code += AGALBase.move(tmp+'.w', m1_03_33+'.w');
			code += AGALBase.dot4(dest_00_30+'.w', tmp, m2_00_30);
			code += AGALBase.dot4(dest_01_31+'.w', tmp, m2_01_31);
			code += AGALBase.dot4(dest_02_32+'.w', tmp, m2_02_32);
			code += AGALBase.dot4(dest_03_33+'.w', tmp, m2_03_33);
			
			return code;
		}
		/**
		 * matrix 4x4 * matrix 4x4.</br>
		 * 
		 * <pre>
		 * dest_00_03.x = (m1_00_03.x ~~ m2_00_03.x) + (m1_00_03.y ~~ m2_10_13.x) + (m1_00_03.z ~~ m2_20_23.x) + (m1_00_03.w ~~ m2_30_33.x)
		 * dest_00_03.y = (m1_00_03.x ~~ m2_00_03.y) + (m1_00_03.y ~~ m2_10_13.y) + (m1_00_03.z ~~ m2_20_23.y) + (m1_00_03.w ~~ m2_30_33.y)
		 * dest_00_03.z = (m1_00_03.x ~~ m2_00_03.z) + (m1_00_03.y ~~ m2_10_13.z) + (m1_00_03.z ~~ m2_20_23.z) + (m1_00_03.w ~~ m2_30_33.z)
		 * dest_00_03.w = (m1_00_03.x ~~ m2_00_03.w) + (m1_00_03.y ~~ m2_10_13.w) + (m1_00_03.z ~~ m2_20_23.w) + (m1_00_03.w ~~ m2_30_33.w)
		 * </br>
		 * dest_10_13.x = (m1_10_13.x ~~ m2_00_03.x) + (m1_10_13.y ~~ m2_10_13.x) + (m1_10_13.z ~~ m2_20_23.x) + (m1_10_13.w ~~ m2_30_33.x)
		 * dest_10_13.y = (m1_10_13.x ~~ m2_00_03.y) + (m1_10_13.y ~~ m2_10_13.y) + (m1_10_13.z ~~ m2_20_23.y) + (m1_10_13.w ~~ m2_30_33.y)
		 * dest_10_13.z = (m1_10_13.x ~~ m2_00_03.z) + (m1_10_13.y ~~ m2_10_13.z) + (m1_10_13.z ~~ m2_20_23.z) + (m1_10_13.w ~~ m2_30_33.z)
		 * dest_10_13.w = (m1_10_13.x ~~ m2_00_03.w) + (m1_10_13.y ~~ m2_10_13.w) + (m1_10_13.z ~~ m2_20_23.w) + (m1_10_13.w ~~ m2_30_33.w)
		 * </br>
		 * dest_20_23.x = (m1_20_23.x ~~ m2_00_03.x) + (m1_20_23.y ~~ m2_10_13.x) + (m1_20_23.z ~~ m2_20_23.x) + (m1_20_23.w ~~ m2_30_33.x)
		 * dest_20_23.y = (m1_20_23.x ~~ m2_00_03.y) + (m1_20_23.y ~~ m2_10_13.y) + (m1_20_23.z ~~ m2_20_23.y) + (m1_20_23.w ~~ m2_30_33.y)
		 * dest_20_23.z = (m1_20_23.x ~~ m2_00_03.z) + (m1_20_23.y ~~ m2_10_13.z) + (m1_20_23.z ~~ m2_20_23.z) + (m1_20_23.w ~~ m2_30_33.z)
		 * dest_20_23.w = (m1_20_23.x ~~ m2_00_03.w) + (m1_20_23.y ~~ m2_10_13.w) + (m1_20_23.z ~~ m2_20_23.w) + (m1_20_23.w ~~ m2_30_33.w)
		 * </br>
		 * dest_30_33.x = (m1_30_33.x ~~ m2_00_03.x) + (m1_30_33.y ~~ m2_10_13.x) + (m1_30_33.z ~~ m2_20_23.x) + (m1_30_33.w ~~ m2_30_33.x)
		 * dest_30_33.y = (m1_30_33.x ~~ m2_00_03.y) + (m1_30_33.y ~~ m2_10_13.y) + (m1_30_33.z ~~ m2_20_23.y) + (m1_30_33.w ~~ m2_30_33.y)
		 * dest_30_33.z = (m1_30_33.x ~~ m2_00_03.z) + (m1_30_33.y ~~ m2_10_13.z) + (m1_30_33.z ~~ m2_20_23.z) + (m1_30_33.w ~~ m2_30_33.z)
		 * dest_30_33.w = (m1_30_33.x ~~ m2_00_03.w) + (m1_30_33.y ~~ m2_10_13.w) + (m1_30_33.z ~~ m2_20_23.w) + (m1_30_33.w ~~ m2_30_33.w)
		 * </pre>
		 */
		public static function m44xm44_2(dest_00_03:String, dest_10_13:String, dest_20_23:String, dest_30_33:String,
										 m1_00_03:String, m1_10_13:String, m1_20_23:String, m1_30_33:String,
										 m2_00_03:String, m2_10_13:String, m2_20_23:String, m2_30_33:String,
										 tmp:String):String {
			var code:String = '';
			
			code += AGALBase.move(tmp+'.x', m2_00_03+'.x');
			code += AGALBase.move(tmp+'.y', m2_10_13+'.x');
			code += AGALBase.move(tmp+'.z', m2_20_23+'.x');
			code += AGALBase.move(tmp+'.w', m2_30_33+'.x');
			code += AGALBase.dot4(dest_00_03+'.x', m1_00_03, tmp);
			code += AGALBase.dot4(dest_10_13+'.x', m1_10_13, tmp);
			code += AGALBase.dot4(dest_20_23+'.x', m1_20_23, tmp);
			code += AGALBase.dot4(dest_30_33+'.x', m1_30_33, tmp);
			code += AGALBase.move(tmp+'.x', m2_00_03+'.y');
			code += AGALBase.move(tmp+'.y', m2_10_13+'.y');
			code += AGALBase.move(tmp+'.z', m2_20_23+'.y');
			code += AGALBase.move(tmp+'.w', m2_30_33+'.y');
			code += AGALBase.dot4(dest_00_03+'.y', m1_00_03, tmp);
			code += AGALBase.dot4(dest_10_13+'.y', m1_10_13, tmp);
			code += AGALBase.dot4(dest_20_23+'.y', m1_20_23, tmp);
			code += AGALBase.dot4(dest_30_33+'.y', m1_30_33, tmp);
			code += AGALBase.move(tmp+'.x', m2_00_03+'.z');
			code += AGALBase.move(tmp+'.y', m2_10_13+'.z');
			code += AGALBase.move(tmp+'.z', m2_20_23+'.z');
			code += AGALBase.move(tmp+'.w', m2_30_33+'.z');
			code += AGALBase.dot4(dest_00_03+'.z', m1_00_03, tmp);
			code += AGALBase.dot4(dest_10_13+'.z', m1_10_13, tmp);
			code += AGALBase.dot4(dest_20_23+'.z', m1_20_23, tmp);
			code += AGALBase.dot4(dest_30_33+'.z', m1_30_33, tmp);
			code += AGALBase.move(tmp+'.x', m2_00_03+'.w');
			code += AGALBase.move(tmp+'.y', m2_10_13+'.w');
			code += AGALBase.move(tmp+'.z', m2_20_23+'.w');
			code += AGALBase.move(tmp+'.w', m2_30_33+'.w');
			code += AGALBase.dot4(dest_00_03+'.w', m1_00_03, tmp);
			code += AGALBase.dot4(dest_10_13+'.w', m1_10_13, tmp);
			code += AGALBase.dot4(dest_20_23+'.w', m1_20_23, tmp);
			code += AGALBase.dot4(dest_30_33+'.w', m1_30_33, tmp);
			
			return code;
		}
		/**
		 * converted from degrees to radians
		 * 
		 * @param src the value can set dest
		 * @param constants = v.n, v.n = 0.017453292
		 */
		public static function radians(dest:String, src:String, constants:String):String {
			var code:String = '';
			
			code += AGALBase.mul(dest, src, constants);
			
			return code;
		}
		/**
		 * @param constants = [v.n, v.n]</br>
		 * constants = [0, 0.5, 1]
		 */
		public static function round(dest:String, src:String, constants:String, tmp):String {
			var code:String = '';
			
			code += AGALBase.abs(dest, src);
			code += AGALBase.add(dest, dest, constants[1]);
			code += AGALMath.floor(dest, dest);
			code += AGALBase.isGreaterEqual(tmp, src, constants[0]);
			code += AGALBase.div(tmp, tmp, constants[1]);
			code += AGALBase.sub(tmp, tmp, constants[2]);
			code += AGALBase.mul(dest, tmp, dest);
			
			return code;
		}
		/**
		 * hyperbolic sine.
		 * 
		 * @param dest = v.n
		 * @param x the value can set dest or tmp
		 * @param constants = [v.n, v.n]</br>
		 * constants = [0.5, 2.71828182845904523536]
		 * @param tmp = v.n
		 */
		public static function sinh(dest:String, x:String, constants:Vector.<String>, tmp:String):String {
			var code:String = '';
			
			code += AGALBase.negate(tmp, x);
			code += AGALBase.pow(tmp, constants[1], tmp);
			code += AGALBase.pow(dest, constants[1], x);
			code += AGALBase.sub(dest, dest, tmp);
			code += AGALBase.mul(dest, dest, constants[0]);
			
			return code;
		}
		/**
		 * <pre>
		 * if (x < a < b or x > a > b) dest = 0
		 * else if (x < b < a or x > b > a) dest = 1
		 * else dest in the range [0,1] for the domain [a, b]
		 * </pre>
		 * 
		 * @param dest = v.n
		 * @param a = v.n, the value can set dest
		 * @param b = v.n, the value can set dest
		 * @param x = v.n, the value can set dest or tmp
		 * @param constants = [v.n]</br>
		 * constants = [3]
		 * @param tmp = v.n
		 */
		public static function smoothstep(dest:String, a:String, b:String, x:String, constants:Vector.<String>, tmp:String):String {
			var code:String = '';
			
			code += AGALBase.sub(tmp, x, a);
			code += AGALBase.sub(dest, b, a);
			code += AGALBase.div(tmp, tmp, dest);
			code += AGALBase.saturate(tmp, tmp);
			code += AGALBase.add(dest, tmp, tmp);
			code += AGALBase.sub(dest, constants[0], dest);
			code += AGALBase.mul(tmp, tmp, tmp);
			code += AGALBase.mul(dest, dest, tmp);
			
			return code;
		}
		/**
		 * @param x the value can set tmp
		 */
		public static function tan(dest:String, x:String, tmp:String):String {
			var code:String = '';
			
			code += AGALBase.sin(dest, x);
			code += AGALBase.cos(tmp, x);
			code += AGALBase.div(dest, dest, tmp);
			
			return code;
		}
		/**
		 * hyperbolic tangent.
		 * 
		 * @param dest = v.n
		 * @param x the value can set dest or tmp
		 * @param constants = [v.n, v.n]</br>
		 * constants = [1, 2.71828182845904523536]
		 * @param tmp = v.n
		 */
		public static function tanh(dest:String, x:String, constants:Vector.<String>, tmp:String):String {
			var code:String = '';
			
			code += AGALBase.add(tmp, x, x);
			code += AGALBase.pow(tmp, constants[1], tmp);
			code += AGALBase.sub(dest, tmp, constants[0]);
			code += AGALBase.add(tmp, tmp, constants[0]);
			code += AGALBase.div(dest, dest, tmp);
			
			return code;
		}
	}
}