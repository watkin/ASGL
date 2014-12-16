package asgl.shaders.asm.agal {
	public class AGALBase {
		public static const NEWLINE:String = '\n';
		
		public function AGALBase() {
		}
		/**
		 * absolute.</br>
		 * destination = abs(source1)</br>
		 * equal to 1 simple opcode
		 */
		public static function abs(dest:String, src:String):String {
			return OpcodeType.ABSOLUTE + ' ' + dest + ', ' + src + NEWLINE;
		}
		/**
		 * add.</br>
		 * destination = source1 + source2</br>
		 * equal to 1 simple opcode
		 */
		public static function add(dest:String, src1:String, src2:String):String {
			return OpcodeType.ADD + ' ' + dest + ', ' + src1 + ', ' + src2 + NEWLINE;
		}
		/**
		 * cross product.</br>
		 * produces only a 3 component result, destination must be masked to .xyz or less</br>
		 * equal to 3 simple opcode
		 * 
		 * <pre>
		 * destination.x = source1.y ~~ source2.z - source1.z ~~ source2.y
		 * destination.y = source1.z ~~ source2.x - source1.x ~~ source2.z
		 * destination.z = source1.x ~~ source2.y - source1.y ~~ source2.x
		 * </pre>
		 */
		public static function cross(dest:String, src1:String, src2:String):String {
			return OpcodeType.CROSS_PRODUCT + ' ' + dest + ', ' + src1 + ', ' + src2 + NEWLINE;
		}
		/**
		 * cosine.</br>
		 * destination = cos(source1)</br>
		 * equal to 40 simple opcode
		 */
		public static function cos(dest:String, src:String):String {
			return OpcodeType.COSINE + ' ' + dest + ', ' + src + NEWLINE;
		}
		public static function ddx(dest:String, src:String):String {
			return OpcodeType.DDX + ' ' + dest + ', ' + src + NEWLINE;
		}
		public static function ddy(dest:String, src:String):String {
			return OpcodeType.DDY + ' ' + dest + ', ' + src + NEWLINE;
		}
		/**
		 * divide.</br>
		 * destination = source1 / source2</br>
		 * equal to 5 simple opcode
		 */
		public static function div(dest:String, src1:String, src2:String):String {
			return OpcodeType.DIVIDE + ' ' + dest + ', ' + src1 + ', ' + src2 + NEWLINE;
		}
		/**
		 * dot product.</br>
		 * destination = source1.x ~~ source2.x + source1.y ~~ source2.y + source1.z ~~ source2.z</br>
		 * equal to 1 simple opcode
		 */
		public static function dot3(dest:String, src1:String, src2:String):String {
			return OpcodeType.DOT_PRODUCT_3 + ' ' + dest + ', ' + src1 + ', ' + src2 + NEWLINE;
		}
		/**
		 * dot product.</br>
		 * destination = source1.x ~~ source2.x + source1.y ~~ source2.y + source1.z ~~ source2.z + source1.w ~~ source2.w</br>
		 * equal to 1 simple opcode
		 */
		public static function dot4(dest:String, src1:String, src2:String):String {
			return OpcodeType.DOT_PRODUCT_4 + ' ' + dest + ', ' + src1 + ', ' + src2 + NEWLINE;
		}
		public static function els():String {
			return OpcodeType.ELSE + NEWLINE;
		}
		public static function endif():String {
			return OpcodeType.END_IF + NEWLINE;
		}
		/**
		 * exponential.</br>
		 * destination = 2^source1</br>
		 * equal to 4 simple opcode
		 */
		public static function exp2(dest:String, src:String):String {
			return OpcodeType.EXPONENTIAL_2 + ' ' + dest + ', ' + src + NEWLINE;
		}
		/**
		 * fractional.</br>
		 * destination = source1 - (float)floor(source1)</br>
		 * equal to 1 simple opcode
		 */
		public static function frac(dest:String, src:String):String {
			return OpcodeType.FRACTIONAL + ' ' + dest + ', ' + src + NEWLINE;
		}
		public static function ifEqual(src1:String, src2:String):String {
			return OpcodeType.IF_EQUAL + ' ' + src1 + ', ' + src2 + NEWLINE;
		}
		public static function ifGreater(src1:String, src2:String):String {
			return OpcodeType.IF_GREATER + ' ' + src1 + ', ' + src2 + NEWLINE;
		}
		public static function ifLess(src1:String, src2:String):String {
			return OpcodeType.IF_LESSL + ' ' + src1 + ', ' + src2 + NEWLINE;
		}
		public static function ifNotEqual(src1:String, src2:String):String {
			return OpcodeType.IF_NOT_EQUAL + ' ' + src1 + ', ' + src2 + NEWLINE;
		}
		/**
		 * set-if-equal.</br>
		 * destination = source1 == source2 ? 1 : 0</br>
		 * equal to 5 simple opcode
		 */
		public static function isEqual(dest:String, src1:String, src2:String):String {
			return OpcodeType.IS_EQUAL + ' ' + dest + ', ' + src1 + ', ' + src2 + NEWLINE;
		}
		/**
		 * set-if-greater-equal.</br>
		 * destination = source1 >= source2 ? 1 : 0</br>
		 * equal to 1 simple opcode
		 */
		public static function isGreaterEqual(dest:String, src1:String, src2:String):String {
			return OpcodeType.IS_GREATER_EQUAL + ' ' + dest + ', ' + src1 + ', ' + src2 + NEWLINE;
		}
		/**
		 * set-if-less-than.</br>
		 * destination = source1 < source2 ? 1 : 0</br>
		 * equal to 1 simple opcode
		 */
		public static function isLessThan(dest:String, src1:String, src2:String):String {
			return OpcodeType.IS_LESS_THAN + ' ' + dest + ', ' + src1 + ', ' + src2 + NEWLINE;
		}
		/**
		 * set-if-not-equal.</br>
		 * destination = source1 != source2 ? 1 : 0</br>
		 * equal to 5 simple opcode
		 */
		public static function isNotEqual(dest:String, src1:String, src2:String):String {
			return OpcodeType.IS_NOT_EQUAL + ' ' + dest + ', ' + src1 + ', ' + src2 + NEWLINE;
		}
		/**
		 * kill / discard (fragment shader only).</br>
		 * If single scalar source component is less than zero, fragment is discarded and not drawn to the frame buffer.</br>
		 * The destination register must be all 0. 
		 */
		public static function kill(src:String):String {
			return OpcodeType.KILL + ' ' + src + NEWLINE;
		}
		/**
		 * logarithm.</br>
		 * destination = log_2(source1)</br>
		 * equal to 4 simple opcode
		 */
		public static function log2(dest:String, src:String):String {
			return OpcodeType.LOGARITHM_2 + ' ' + dest + ', ' + src + NEWLINE;
		}
		/**
		 * multiply matrix 3x3.</br>
		 * produces only a 3 component result, destination must be masked to .xyz or less</br>
		 * equal to 4 simple opcode
		 * 
		 * <pre>
		 * destination.x = (source1.x ~~ source2[0].x) + (source1.y ~~ source2[0].y) + (source1.z ~~ source2[0].z)
		 * destination.y = (source1.x ~~ source2[1].x) + (source1.y ~~ source2[1].y) + (source1.z ~~ source2[1].z)
		 * destination.z = (source1.x ~~ source2[2].x) + (source1.y ~~ source2[2].y) + (source1.z ~~ source2[2].z)
		 * </pre>
		 */
		public static function m33(dest:String, src1:String, src2:String):String {
			return OpcodeType.MULTIPLY_MATRIX_3X3 + ' ' + dest + ', ' + src1 + ', ' + src2 + NEWLINE;
		}
		/**
		 * multiply matrix 3x4.</br>
		 * produces only a 3 component result, destination must be masked to .xyz or less</br>
		 * equal to 4 simple opcode
		 * 
		 * <pre>
		 * destination.x = (source1.x ~~ source2[0].x) + (source1.y ~~ source2[0].y) + (source1.z ~~ source2[0].z) + (source1.w ~~ source2[0].w)
		 * destination.y = (source1.x ~~ source2[1].x) + (source1.y ~~ source2[1].y) + (source1.z ~~ source2[1].z) + (source1.w ~~ source2[1].w)
		 * destination.z = (source1.x ~~ source2[2].x) + (source1.y ~~ source2[2].y) + (source1.z ~~ source2[2].z) + (source1.w ~~ source2[2].w)
		 * </pre>
		 */
		public static function m34(dest:String, src1:String, src2:String):String {
			return OpcodeType.MULTIPLY_MATRIX_3X4 + ' ' + dest + ', ' + src1 + ', ' + src2 + NEWLINE;
		}
		/**
		 * multiply matrix 4x4.</br>
		 * equal to 5 simple opcode
		 * 
		 * <pre>
		 * destination.x = (source1.x ~~ source2[0].x) + (source1.y ~~ source2[0].y) + (source1.z ~~ source2[0].z) + (source1.w ~~ source2[0].w)
		 * destination.y = (source1.x ~~ source2[1].x) + (source1.y ~~ source2[1].y) + (source1.z ~~ source2[1].z) + (source1.w ~~ source2[1].w)
		 * destination.z = (source1.x ~~ source2[2].x) + (source1.y ~~ source2[2].y) + (source1.z ~~ source2[2].z) + (source1.w ~~ source2[2].w)
		 * destination.w = (source1.x ~~ source2[3].x) + (source1.y ~~ source2[3].y) + (source1.z ~~ source2[3].z) + (source1.w ~~ source2[3].w)
		 * </pre>
		 */
		public static function m44(dest:String, src1:String, src2:String):String {
			return OpcodeType.MULTIPLY_MATRIX_4X4 + ' ' + dest + ', ' + src1 + ', ' + src2 + NEWLINE;
		}
		/**
		 * maximum.</br>
		 * destination = maximum(source1,source2)</br>
		 * equal to 1 simple opcode
		 */
		public static function max(dest:String, src1:String, src2:String):String {
			return OpcodeType.MAXIMUM + ' ' + dest + ', ' + src1 + ', ' + src2 + NEWLINE;
		}
		/**
		 * minimum.</br>
		 * destination = minimum(source1,source2)</br>
		 * equal to 1 simple opcode
		 */
		public static function min(dest:String, src1:String, src2:String):String {
			return OpcodeType.MINIMUM + ' ' + dest + ', ' + src1 + ', ' + src2 + NEWLINE;
		}
		/**
		 * move.</br>
		 * move data from source1 to destination</br>
		 * equal to 1 simple opcode
		 */
		public static function move(dest:String, src:String):String {
			return OpcodeType.MOVE + ' ' + dest + ', ' + src + NEWLINE;
		}
		/**
		 * multiply.</br>
		 * destination = source1 * source2</br>
		 * equal to 1 simple opcode
		 */
		public static function mul(dest:String, src1:String, src2:String):String {
			return OpcodeType.MULTIPLY + ' ' + dest + ', ' + src1 + ', ' + src2 + NEWLINE;
		}
		/**
		 * negate.</br>
		 * destination = -source1</br>
		 * equal to 1 simple opcode
		 */
		public static function negate(dest:String, src:String):String {
			return OpcodeType.NEGATE + ' ' + dest + ', ' + src + NEWLINE;
		}
		/**
		 * normalize.</br>
		 * destination = normalize(source1)</br>
		 * produces only a 3 component result, destination must be masked to .xyz or less</br>
		 * equal to 4 simple opcode
		 */
		public static function normalize(dest:String, src:String):String {
			return OpcodeType.NORMALIZE + ' ' + dest + ', ' + src + NEWLINE;
		}
		/**
		 * power.</br>
		 * destination = pow(source1, source2)</br>
		 * equal to 16 simple opcode
		 */
		public static function pow(dest:String, src1:String, src2:String):String {
			return OpcodeType.POWER + ' ' + dest + ', ' + src1 + ', ' + src2 + NEWLINE;
		}
		/**
		 * reciprocal.</br>
		 * destination = 1/source1</br>
		 * equal to 4 simple opcode
		 */
		public static function reciprocal(dest:String, src:String):String {
			return OpcodeType.RECIPROCAL + ' ' + dest + ', ' + src + NEWLINE;
		}
		/**
		 * reciprocal root.</br>
		 * destination = 1/sqrt(source1)</br>
		 * equal to 4 simple opcode
		 */
		public static function rsqrt(dest:String, src:String):String {
			return OpcodeType.RECIPROCAL_ROOT + ' ' + dest + ', ' + src + NEWLINE;
		}
		/**
		 * saturate.</br>
		 * destination = maximum(minimum(source1,1),0)</br>
		 * equal to 3 simple opcode
		 */
		public static function saturate(dest:String, src:String):String {
			return OpcodeType.SATURATE + ' ' + dest + ', ' + src + NEWLINE;
		}
		/**
		 * sine.</br>
		 * destination = sin(source1)</br>
		 * equal to 40 simple opcode
		 */
		public static function sin(dest:String, src:String):String {
			return OpcodeType.SINE + ' ' + dest + ', ' + src + NEWLINE;
		}
		/**
		 * square root.</br>
		 * destination = sqrt(source1)</br>
		 * equal to 8 simple opcode
		 */
		public static function sqrt(dest:String, src:String):String {
			return OpcodeType.SQUARE_ROOT + ' ' + dest + ', ' + src + NEWLINE;
		}
		/**
		 * subtract.</br>
		 * destination = source1 - source2</br>
		 * equal to 1 simple opcode
		 */
		public static function sub(dest:String, src1:String, src2:String):String {
			return OpcodeType.SUBTRACT + ' ' + dest + ', ' + src1 + ', ' + src2 + NEWLINE;
		}
		/**
		 * texture sample (fragment shader only).</br>
		 * destination = load from texture fs at coordinates coord. In this fs must be in sampler format
		 */
		public static function tex(dest:String, coord:String, fs:String, ...flags):String {
			var code:String = OpcodeType.TEXTURE_SAMPLE + ' ' + dest + ', ' + coord + ', ' + fs;
			
			var length:uint = flags.length;
			if (length>0) {
				code += ', <';
				
				for (var i:uint = 0; i<length; i++) {
					if (i != 0) code += ', ';
					code += flags[i];
				}
				
				code += '>';
			}
			
			code += NEWLINE;
			
			return code;
		}
	}
}