package asgl.shaders.asm.agal.compiler {
	import flash.display3D.Context3DProgramType;
	import flash.utils.ByteArray;
	
	/**
	 * The header is immediately followed by any number of tokens. Every token is 192 bits (24 bytes) in size and always has the format:</br>
	 * token = [opcode(32 bits)][destination(32 bits)][source1(64 bits)][source2 or sampler(64 bits)]
	 */

	public class AGALAssembler {
		public function AGALAssembler() {
		}
		public function writeHeader(bytes:ByteArray, programType:String, version:uint=1):void {
			var isFrag:Boolean = false;
			
			if (programType == Context3DProgramType.FRAGMENT) {
				isFrag = true;
			} else if (programType != Context3DProgramType.VERTEX) {
				throw new ArgumentError();
			}
			
			bytes.writeByte(0xA0);//magic, must be 0xa0
			bytes.writeUnsignedInt(version);//version, must be 1
			bytes.writeByte(0xA1);//shader type ID, must be 0xa1
			bytes.writeByte(isFrag ? 1 : 0);//shader type, 0 for a vertex program; 1 for a fragment program
		}
		/**
		 * 31.............................0</br>
		 * ----TTTT----MMMMNNNNNNNNNNNNNNNN</br></br>
		 * 
		 * T = Register type (4 bits)</br>
		 * M = Write mask (4 bits)</br>
		 * N = Register number (16 bits)</br>
		 * - = undefined, must be 0
		 * 
		 * @param mask 0001(binary) = x, 0010(binary) = y, 0100(binary) = z, 1000(binary) = w. xyzw must order.</br>
		 *  if mask is singe component, xyzw all ok.</br>
		 *  if mask are multi components, first component must be x.
		 */
		public function writeDestination(bytes:ByteArray, type:uint, index:uint, mask:uint):void {
			bytes.writeShort(index);
			bytes.writeByte(mask);
			bytes.writeByte(type);
		}
		/**
		 * if opcode == OpcodeType.KILL, dest use the method
		 */
		public function writeEmptyDestination(bytes:ByteArray):void {
			bytes.writeUnsignedInt(0);
		}
		public function writeEmptySource(bytes:ByteArray):void {
			bytes.writeUnsignedInt(0);
			bytes.writeUnsignedInt(0);
		}
		public function writeOperationCode(bytes:ByteArray, opcode:uint):void {
			bytes.writeUnsignedInt(opcode);
		}
		/**
		 * 63.............................................................0</br>
		 * FFFFMMMMWWWWSSSSDDDDIIII----TTTT--------BBBBBBBBNNNNNNNNNNNNNNNN</br></br>
		 * 
		 * F = Filter (0=nearest,1=linear) (4 bits)</br>
		 * M = Mipmap (0=none,1=nearest, 2=linear)</br>
		 * W = Wrapping (0=clamp,1=repeat)</br>
		 * S = Special flag bits (must be 0)</br>
		 * D = Dimension (0=2D, 1=Cube)</br>
		 * I = Image format (0=rgba, 1=dxt, pvrtc, etc, 2=dxt(alpha), pvrtc(alpha), etc(alpha), 3=video)</br>
		 * T = Register type, must be 5, Sampler (4 bits)</br>
		 * B = Texture level-of-detail (LOD) bias, signed integer, scale by 8. The floating point value used is b/8.0 (8 bits)</br>
		 * N = Sampler register number (16 bits)
		 */
		public function writeSampler(bytes:ByteArray, index:uint, filter:uint, mipmap:uint, wrap:uint, special:uint, dimension:uint, format:uint, bias:int=0):void {
			bytes.writeShort(index);
			bytes.writeByte(int(bias * 8));
			bytes.writeByte(0);
			bytes.writeUnsignedInt(getSampleState(filter, mipmap, wrap, special, dimension, format));
		}
		public static function getSampleState(filter:uint, mipmap:uint, wrap:uint, special:uint, dimension:uint, format:uint):uint {
			return uint((filter << 28) | (mipmap << 24) | (wrap << 20) | (special << 16) | (dimension << 12) | (format << 8) | 5);
		}
		/**
		 * 63.............................................................0</br>
		 * D-------------QQ----IIII----TTTTSSSSSSSSOOOOOOOONNNNNNNNNNNNNNNN</br></br>
		 * 
		 * D = Direct=0/Indirect=1 for direct Q and I are ignored, 1bit</br>
		 * Q = Index register component select (2 bits)</br>
		 * I = Index register type (4 bits)</br>
		 * T = Register type (4 bits)</br>
		 * S = Swizzle (8 bits, 2 bits per component)</br>
		 * O = Indirect offset (8 bits)</br>
		 * N = Register number (16 bits)</br>
		 * - = undefined, must be 0</br></br>
		 * 
		 * <b>example:</b></br>
		 * direct:</br>
		 * vc1</br>
		 * indirectType = 0</br>
		 * index = 1</br>
		 * indirectMask = 0</br>
		 * indirectOffset = 0</br></br>
		 * 
		 * indirect:</br>
		 * vc[va1.x+2]</br>
		 * indirectType = va</br>
		 * index = 1</br>
		 * indirectMask = x</br>
		 * indirectOffset = 2
		 * 
		 * @param index if indirect index = indirect index else index = direct index
		 * @parm mask 00(binary) = x, 01(binary) = y, 10(binary) = z, 11(binary) = w. xyzw = 11(w)10(z)01(y)00(x). xyzw can out of order
		 * @param indirectMask 00(binary) = x, 01(binary) = y, 10(binary) = z, 11(binary) = w
		 */
		public function writeSource(bytes:ByteArray, type:uint, index:uint, mask:uint, indirect:Boolean=false, indirectType:uint=0, indirectMask:uint=0, indirectOffset:uint=0):void {
			bytes.writeShort(index);
			bytes.writeByte(indirectOffset);
			bytes.writeByte(mask);
			bytes.writeByte(type);
			if (indirect) {
				bytes.writeByte(indirectType);
				bytes.writeByte(indirectMask);
				bytes.writeByte(0x80);
			} else {
				bytes.writeByte(0);
				bytes.writeByte(0);
				bytes.writeByte(0);
			}
		}
	}
}