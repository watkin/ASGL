package asgl.effects.geometries.trail {
	import asgl.math.Float3;

	public class SingleVertexTrail {
		private var _copyDataToUnusedSegment:Boolean;
		private var _life:Vector.<Number>;
		private var _vertices:Vector.<Number>;
		private var _totalLife:Number;
		private var _segNum:uint;
		private var _activateNum:uint;
		public function SingleVertexTrail(totalLife:Number, segNum:uint=0, copyDataToUnusedSegment:Boolean=true) {
			_totalLife = totalLife;
			
			_segNum = segNum;
			_copyDataToUnusedSegment = copyDataToUnusedSegment;
			
			_life = new Vector.<Number>(_segNum);
			_vertices = new Vector.<Number>(_segNum*3);
		}
		public function get vertices():Vector.<Number> {
			return _vertices;
		}
		public function update(pos:Float3, progress:Number=NaN):uint {
			var i:int;
			var length:int;
			var life:Number;
			
			var isPosNull:Boolean = pos == null;
			
			if (_segNum == 0) {
				if (progress == progress) {
					if (isPosNull) {
						i = 0;
					} else {
						i = 1;
						
						if (_life.length == 0) this.update(pos);
						
						_vertices.unshift(pos.x, pos.y, pos.z);
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
								_vertices.length = (i+1)*3;
							}
							
							break;
						} else {
							_life[i] = life;
						}
					}
				} else {
					_vertices.length = 3;
					_life.length = 1;
					
					_life[0] = 0;
					_vertices[0] = pos.x;
					_vertices[1] = pos.y;
					_vertices[2] = pos.z;
				}
				
				return _life.length;
			} else {
				var i3:int;
				var max:int;
				var prevX:Number;
				var prevY:Number;
				var prevZ:Number;
				
				length = _life.length;
				
				if (progress == progress) {
					if (isPosNull) {
						for (i = 0; i<length; i++) {
							life = _life[i]-progress;
							if (life<=0) {
								_activateNum = i;
								
								_life[i] = 0;
								
								if (_copyDataToUnusedSegment) {
									i3 = i*3;
									
									prevX = _vertices[i3++];
									prevY = _vertices[i3++];
									prevZ = _vertices[i3];
									
									for (++i; i<length; i++) {
										i3 = i*3;
										
										_life[i] = 0;
										
										_vertices[i3++] = prevX;
										_vertices[i3++] = prevY;
										_vertices[i3] = prevZ;
									}
								}
								
								break;
							} else {
								_life[i] = life;
							}
						}
					} else {
						if (_activateNum == 0) this.update(pos);
						
						if (length>1) {
							var prevlife:Number = _life[0];
							prevX = _vertices[0];
							prevY = _vertices[1];
							prevZ = _vertices[2];
							
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
										i3 = i*3;
										
										_life[i] = 0;
										
										_vertices[i3++] = prevX;
										_vertices[i3++] = prevY;
										_vertices[i3] = prevZ;
									}
									
									break;
								} else {
									i3 = i*3;
									
									var curLife:Number = _life[i];
									var curX:Number = _vertices[i3];
									var curY:Number = _vertices[int(i3+1)];
									var curZ:Number = _vertices[int(i3+2)];
									
									_life[i] = life;
									_vertices[i3++] = prevX;
									_vertices[i3++] = prevY;
									_vertices[i3] = prevZ;
									
									prevlife = curLife;
									prevX = curX;
									prevY = curY;
									prevZ = curZ;
								}
							}
						}
						
						_life[0] = _totalLife;
						_vertices[0] = pos.x;
						_vertices[1] = pos.y;
						_vertices[2] = pos.z;
						
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
						i3 = i*3;
						
						_life[i] = 0;
						_vertices[i3++] = pos.x;
						_vertices[i3++] = pos.y;
						_vertices[i3] = pos.z;
					}
				}
				
				return _activateNum;
			}
		}
	}
}