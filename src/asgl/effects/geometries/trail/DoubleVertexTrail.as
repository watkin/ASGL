package asgl.effects.geometries.trail {
	import asgl.math.Float3;

	public class DoubleVertexTrail {
		private static var _tempVector:Vector.<Number> = new Vector.<Number>();
		
		private var _copyDataToUnusedSegment:Boolean;
		private var _life:Vector.<Number>;
		private var _vertices:Vector.<Number>;
		private var _totalLife:Number;
		private var _segNum:uint;
		private var _activateNum:uint;
		public function DoubleVertexTrail(totalLife:Number, segmentNum:uint=0, copyDataToUnusedSegment:Boolean=true) {
			_totalLife = totalLife;
			
			_segNum = segmentNum;
			_copyDataToUnusedSegment = copyDataToUnusedSegment;
			
			_life = new Vector.<Number>(_segNum);
			_vertices = new Vector.<Number>(_segNum*6);
		}
		public static function getIndices(segNum:uint, op:Vector.<uint>=null):Vector.<uint> {
			if (segNum<1) segNum = 1;
			segNum--;
			
			var length:uint = segNum*6;
			
			if (op == null) {
				op = new Vector.<uint>(length);
			} else if (op.length != length) {
				if (op.fixed) {
					if (op.length < length) return null;
				} else {
					op.length = length;
				}
			}
			
			var index:int;
			for (var i:int = 0; i<segNum; i++) {
				var idx:int = i*2;
				
				op[index++] = idx;
				op[index++] = idx+2;
				op[index++] = idx+3;
				op[index++] = idx;
				op[index++] = idx+3;
				op[index++] = idx+1;
			}
			
			return op;
		}
		public static function getTexCoordsFromLife(totalLife:Number, life:Vector.<Number>, op:Vector.<Number>=null):Vector.<Number> {
			var length:int = life.length*4;
			
			if (op == null) {
				op = new Vector.<Number>(length);
			} else if (op.length != length) {
				if (op.fixed) {
					if (op.length < length) return null;
				} else {
					op.length = length;
				}
			}
			
			if (length>0) {
				length *= 0.25;
				
				var i:int;
				
				var total:Number = life[0];
				
				if (total == 0) {
					for (i = 0; i<length; i++) {
						op[index++] = 0;
						op[index++] = 0;
						op[index++] = 0;
						op[index++] = 1;
					}
				} else {
					var index:int = 0;
					
					for (i = 0; i<length; i++) {
						var x:Number = (total-life[i])/total;
						
						op[index++] = x;
						op[index++] = 0;
						op[index++] = x;
						op[index++] = 1;
					}
				}
			}
			
			return op;
		}
		public static function getTexCoordsFromDistance(vertices:Vector.<Number>, activateNum:uint=0, op:Vector.<Number>=null):Vector.<Number> {
			var length:int = vertices.length*4/6;
			
			if (op == null) {
				op = new Vector.<Number>(length);
			} else if (op.length != length) {
				if (op.fixed) {
					if (op.length < length) return null;
				} else {
					op.length = length;
				}
			}
			
			length *= 0.25;
			
			if (activateNum == 0) activateNum = length;
			
			if (activateNum>1) {
				var length2:int = (activateNum-1) * 2;
				
				var len1:Number = 0;
				var len2:Number = 0;
				
				var x1:Number = vertices[0];
				var y1:Number = vertices[1];
				var z1:Number = vertices[2];
				var x2:Number = vertices[3];
				var y2:Number = vertices[4];
				var z2:Number = vertices[5];
				
				var index:int = 0;
				
				for (var i:int = 1; i<activateNum; i++) {
					var i6:int = i*6;
					
					var x3:Number = vertices[i6++];
					var y3:Number = vertices[i6++];
					var z3:Number = vertices[i6++];
					var x4:Number = vertices[i6++];
					var y4:Number = vertices[i6++];
					var z4:Number = vertices[i6];
					
					var x:Number = x1-x3;
					var y:Number = y1-y3;
					var z:Number = z1-z3;
					
					var len:Number = x*x+y*y+z*z;
					
					len1 += len;
					
					_tempVector[index++] = len;
					
					x = x2-x4;
					y = y2-y4;
					z = z2-z4;
					
					len = x*x+y*y+z*z;
					
					len2 += len;
					
					_tempVector[index++] = len;
					
					x1 = x3;
					y1 = y3;
					z1 = z3;
					x2 = x4;
					y2 = y4;
					z2 = z4;
				}
				
				op[0] = 0;
				op[1] = 0;
				op[2] = 0;
				op[3] = 1;
				
				var u1:Number = 0;
				var u2:Number = 0;
				
				index = 4;
				
				for (i = 0; i<length2; i++) {
					u1 += _tempVector[i++]/len1;
					u2 += _tempVector[i]/len2;
					
					op[index++] = u1;
					op[index++] = 0;
					op[index++] = u2;
					op[index++] = 1;
				}
				
				length -= activateNum;
				
				for (i = 0; i<length; i++) {
					op[index++] = 1;
					op[index++] = 0;
					op[index++] = 1;
					op[index++] = 1;
				}
			}
			
			return op;
		}
		public function get life():Vector.<Number> {
			return _life;
		}
		public function get vertices():Vector.<Number> {
			return _vertices;
		}
		public function update(pos1:Float3, pos2:Float3, progress:Number=NaN):uint {
			var i:int;
			var length:int;
			var life:Number;
			
			var isPosNull:Boolean = pos1 == null || pos2 == null;
			
			if (_segNum == 0) {
				if (progress == progress) {
					if (isPosNull) {
						i = 0;
					} else {
						i = 1;
						
						if (_life.length == 0) this.update(pos1, pos2);
						
						_vertices.unshift(pos1.x, pos1.y, pos1.z, pos2.x, pos2.y, pos2.z);
						_life.unshift(_totalLife);
					}
					
					length = _life.length;
					
					for (; i<length; i++) {
						life = _life[i]-progress;
						if (life<=0) {
							if (isPosNull && i == 0) {
								_life.length = 0;
								_vertices.length = 0;
							} else {
								_life[i] = 0;
								_life.length = i+1;
								_vertices.length = (i+1)*6;
							}
							
							break;
						} else {
							_life[i] = life;
						}
					}
				} else {
					_vertices.length = 6;
					_life.length = 1;
					
					_life[0] = 0;
					_vertices[0] = pos1.x;
					_vertices[1] = pos1.y;
					_vertices[2] = pos1.z;
					_vertices[3] = pos2.x;
					_vertices[4] = pos2.y;
					_vertices[5] = pos2.z;
				}
				
				return _life.length;
			} else {
				var i6:int;
				var max:int;
				var prev1X:Number;
				var prev1Y:Number;
				var prev1Z:Number;
				var prev2X:Number;
				var prev2Y:Number;
				var prev2Z:Number;
				
				length = _life.length;
				
				if (progress == progress) {
					if (isPosNull) {
						for (i = 0; i<length; i++) {
							life = _life[i]-progress;
							if (life<=0) {
								_activateNum = i;
								
								_life[i] = 0;
								
								if (_copyDataToUnusedSegment) {
									i6 = i*6;
									
									prev1X = _vertices[i6++];
									prev1Y = _vertices[i6++];
									prev1Z = _vertices[i6++];
									prev2X = _vertices[i6++];
									prev2Y = _vertices[i6++];
									prev2Z = _vertices[i6];
									
									for (++i; i<length; i++) {
										i6 = i*6;
										
										_life[i] = 0;
										
										_vertices[i6++] = prev1X;
										_vertices[i6++] = prev1Y;
										_vertices[i6++] = prev1Z;
										_vertices[i6++] = prev2X;
										_vertices[i6++] = prev2Y;
										_vertices[i6] = prev2Z;
									}
								}
								
								break;
							} else {
								_life[i] = life;
							}
						}
					} else {
						if (_activateNum == 0) this.update(pos1, pos2);
						
						if (length>1) {
							var prevlife:Number = _life[0];
							prev1X = _vertices[0];
							prev1Y = _vertices[1];
							prev1Z = _vertices[2];
							prev2X = _vertices[3];
							prev2Y = _vertices[4];
							prev2Z = _vertices[5];
							
							for (i = 1; i<length; i++) {
								life = prevlife-progress;
								if (life<=0) {
									_activateNum = i;
									
									if (_copyDataToUnusedSegment) {
										max = length;
									} else {
										max = i + 1;
									}
									
									for (; i<max; i++) {
										i6 = i*6;
										
										_life[i] = 0;
										
										_vertices[i6++] = prev1X;
										_vertices[i6++] = prev1Y;
										_vertices[i6++] = prev1Z;
										_vertices[i6++] = prev2X;
										_vertices[i6++] = prev2Y;
										_vertices[i6] = prev2Z;
									}
									
									break;
								} else {
									i6 = i*6;
									
									var curLife:Number = _life[i];
									var cur1X:Number = _vertices[i6];
									var cur1Y:Number = _vertices[int(i6+1)];
									var cur1Z:Number = _vertices[int(i6+2)];
									var cur2X:Number = _vertices[int(i6+3)];
									var cur2Y:Number = _vertices[int(i6+4)];
									var cur2Z:Number = _vertices[int(i6+5)];
									
									_life[i] = life;
									_vertices[i6++] = prev1X;
									_vertices[i6++] = prev1Y;
									_vertices[i6++] = prev1Z;
									_vertices[i6++] = prev2X;
									_vertices[i6++] = prev2Y;
									_vertices[i6] = prev2Z;
									
									prevlife = curLife;
									prev1X = cur1X;
									prev1Y = cur1Y;
									prev1Z = cur1Z;
									prev2X = cur2X;
									prev2Y = cur2Y;
									prev2Z = cur2Z;
								}
							}
						}
						
						_life[0] = _totalLife;
						_vertices[0] = pos1.x;
						_vertices[1] = pos1.y;
						_vertices[2] = pos1.z;
						_vertices[3] = pos2.x;
						_vertices[4] = pos2.y;
						_vertices[5] = pos2.z;
						
						if (_activateNum<_segNum) _activateNum++;
					}
				} else {
					_activateNum = 1;
					
					if (_copyDataToUnusedSegment) {
						max = length;
					} else {
						max = 1;
					}
					
					for (i = 0; i<max; i++) {
						i6 = i*6;
						
						_life[i] = 0;
						_vertices[i6++] = pos1.x;
						_vertices[i6++] = pos1.y;
						_vertices[i6++] = pos1.z;
						_vertices[i6++] = pos2.x;
						_vertices[i6++] = pos2.y;
						_vertices[i6] = pos2.z;
					}
				}
				
				return _activateNum;
			}
		}
	}
}