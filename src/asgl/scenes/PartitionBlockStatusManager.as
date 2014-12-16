package asgl.scenes {
	public class PartitionBlockStatusManager {
		private var _isFirst:Boolean;
		private var _addedHandler:Function;
		private var _removedHandler:Function;
		private var _maxLimitRangeX:int;
		private var _maxLimitRangeY:int;
		private var _maxLimitRangeZ:int;
		private var _minLimitRangeX:int;
		private var _minLimitRangeY:int;
		private var _minLimitRangeZ:int;
		private var _oldMinX:int;
		private var _oldMaxX:int;
		private var _oldMinY:int;
		private var _oldMaxY:int;
		private var _oldMinZ:int;
		private var _oldMaxZ:int;
		private var _blockLength:Number;
		private var _blockWidth:Number;
		private var _blockHeight:Number;
		private var _halfLength:Number;
		private var _halfWidth:Number;
		private var _halfHeight:Number;
		private var _originX:Number;
		private var _originY:Number;
		private var _originZ:Number;
		private var _maxVisibleRangeX:uint;
		private var _maxVisibleRangeY:uint;
		private var _maxVisibleRangeZ:uint;
		private var _minVisibleRangeX:uint;
		private var _minVisibleRangeY:uint;
		private var _minVisibleRangeZ:uint;
		
		private var _addMap:Array;
		private var _segs:Vector.<Seg>;
		
		public function PartitionBlockStatusManager(originX:Number, originY:Number, originZ:Number, blockLength:Number, blockWidth:Number, blockHeight:Number) {
			_isFirst = true;
			_addMap = [];
			_segs = new Vector.<Seg>();
			
			_addedHandler = _defaultHandler;
			_removedHandler = _defaultHandler;
			
			this.reset(originX, originY, originZ, blockLength, blockWidth, blockHeight);
			
			this.setLimitRange();
			this.setVisibleRange();
		}
		public function get blockHeight():Number {
			return _blockHeight;
		}
		public function get blockLength():Number {
			return _blockLength;
		}
		public function get blockWidth():Number {
			return _blockWidth;
		}
		/**
		 * @param addedHandler function(segX:int, segY:int, segZ:int)
		 * @param removedHandler function(segX:int, segY:int, segZ:int)
		 */
		public function addListeners(addedHandler:Function, removedHandler:Function):void {
			_addedHandler = addedHandler == null ? _defaultHandler : addedHandler;
			_removedHandler = removedHandler == null ? _defaultHandler : removedHandler;
		}
		public function clear():void {
			if (!_isFirst) {
				for (var ix:int = _oldMinX; ix <= _oldMaxX; ix++) {
					for (var iy:int = _oldMinY; iy <= _oldMaxY; iy++) {
						for (var iz:int = _oldMinZ; iz <= _oldMaxZ; iz++) {
							_removedHandler(ix, iy, iz);
						}
					}
				}
				
				_isFirst = true;
			}
		}
		public function reset(originX:Number, originY:Number, originZ:Number, blockLength:Number, blockWidth:Number, blockHeight:Number):void {
			this.clear();
			
			_blockLength = blockLength;
			_blockWidth = blockWidth;
			_blockHeight = blockHeight;
			
			_halfLength = _blockLength * 0.5;
			_halfWidth = _blockWidth * 0.5;
			_halfHeight = _blockHeight * 0.5;
			
			_originX = originX - _halfLength;
			_originY = originY - _halfHeight;
			_originZ = originZ - _halfWidth;
		}
		public function setLimitRange(minX:int=int.MIN_VALUE, maxX:int=int.MAX_VALUE, minY:int=int.MIN_VALUE, maxY:int=int.MAX_VALUE, minZ:int=int.MIN_VALUE, maxZ:int=int.MAX_VALUE):void {
			if (maxX<minX) maxX = minX;
			if (maxY<minY) maxY = minY;
			if (maxZ<minZ) maxZ = minZ;
			
			_minLimitRangeX = minX;
			_maxLimitRangeX = maxX;
			_minLimitRangeY = minY;
			_maxLimitRangeY = maxY;
			_minLimitRangeZ = minZ;
			_maxLimitRangeZ = maxZ;
		}
		public function setVisibleRange(minX:uint=1, maxX:uint=1, minY:uint=1, maxY:uint=1, minZ:uint=1, maxZ:uint=1):void {
			_minVisibleRangeX = minX;
			_maxVisibleRangeX = maxX;
			_minVisibleRangeY = minY;
			_maxVisibleRangeY = maxY;
			_minVisibleRangeZ = minZ;
			_maxVisibleRangeZ = maxZ;
			
			var oldLen:uint = _segs.length;
			var newLen:uint = (minX + maxX + 1) * (minY + maxY + 1) * (minZ + maxZ + 1);
			_segs.length = newLen;
			for (var i:uint = oldLen; i < newLen; i++) {
				_segs[i] = new Seg();
			}
		}
		public function removeListeners():void {
			_addedHandler = _defaultHandler;
			_removedHandler = _defaultHandler;
		}
		public function update(x:Number, y:Number, z:Number):void {
			x -= _originX;
			y -= _originY;
			z -= _originZ;
			
			x /= _blockLength;
			y /= _blockHeight;
			z /= _blockWidth;
			
			var sx:int = x;
			var sy:int = y;
			var sz:int = z;
			
			if (x < 0 && sx != x) sx--;
			if (y < 0 && sy != y) sy--;
			if (z < 0 && sz != z) sz--;
			
			var minX:int = sx - _minVisibleRangeX;
			var maxX:int = sx + _maxVisibleRangeX;
			var minY:int = sy - _minVisibleRangeY;
			var maxY:int = sy + _maxVisibleRangeY;
			var minZ:int = sz - _minVisibleRangeZ;
			var maxZ:int = sz + _maxVisibleRangeZ;
			
			if (minX < _minLimitRangeX) minX = _minLimitRangeX;
			if (maxX > _maxLimitRangeX) maxX = _maxLimitRangeX;
			if (minY < _minLimitRangeY) minY = _minLimitRangeY;
			if (maxY > _maxLimitRangeY) maxY = _maxLimitRangeY;
			if (minZ < _minLimitRangeZ) minZ = _minLimitRangeZ;
			if (maxZ > _maxLimitRangeZ) maxZ = _maxLimitRangeZ;
			
			var newMinX:int = minX;
			var newMaxX:int = maxX;
			var newMinY:int = minY;
			var newMaxY:int = maxY;
			var newMinZ:int = minZ;
			var newMaxZ:int = maxZ;
			
			var ix:int;
			var iy:int;
			var iz:int;
			
			var seg:Seg;
			
			if (_isFirst) {
				_isFirst = false;
				
				for (ix = minX; ix <= maxX; ix++) {
					for (iy = minY; iy <= maxY; iy++) {
						for (iz = minZ; iz <= maxZ; iz++) {
							include 'PartitionBlockStatusManager_addSeg.define';
						}
					}
				}
			} else {
				var addIndex:uint;
				var useSegNum:uint;
				var absX:int;
				var absY:int;
				var absZ:int;
				var num:int;
				
				if (maxX < _oldMaxX) {
					if ( maxX < _oldMinX) {
						num = _oldMinX;
					} else {
						num = maxX + 1;
					}
					for (ix = num; ix <= _oldMaxX; ix++) {
						for (iy = _oldMinY; iy<=_oldMaxY; iy++) {
							for (iz = _oldMinZ; iz <= _oldMaxZ; iz++) {
								_removedHandler(ix, iy, iz);
							}
						}
					}
					
					_oldMaxX = num - 1;
				} else if (maxX > _oldMaxX) {
					if (_oldMaxX < minX) {
						num = minX;
					} else {
						num = _oldMaxX + 1;
					}
					for (ix = num; ix <= maxX; ix++) {
						for (iy = minY; iy <= maxY; iy++) {
							for (iz = minZ; iz <= maxZ; iz++) {
								include 'PartitionBlockStatusManager_addSeg.define';
//								_addedHandler(ix, iy, iz);
							}
						}
					}
					
					maxX = num - 1;
				}
				
				if (minX > _oldMinX) {
					if (minX > _oldMaxX) {
						num = _oldMaxX;
					} else {
						num = minX - 1;
					}
					for (ix = _oldMinX; ix <= num; ix++) {
						for (iy = _oldMinY; iy <= _oldMaxY; iy++) {
							for (iz = _oldMinZ; iz <= _oldMaxZ; iz++) {
								_removedHandler(ix, iy, iz);
							}
						}
					}
					
					_oldMinX = num + 1;
				} else if (minX < _oldMinX) {
					if (_oldMinX > maxX) {
						num = maxX;
					} else {
						num = _oldMinX - 1;
					}
					for (ix = minX; ix <= num; ix++) {
						for (iy = minY; iy <= maxY; iy++) {
							for (iz = minZ; iz <= maxZ; iz++) {
								include 'PartitionBlockStatusManager_addSeg.define';
							}
						}
					}
					
					minX = num + 1;
				}
				
				if (maxY < _oldMaxY) {
					if (maxY < _oldMinY) {
						num = _oldMinY;
					} else {
						num = maxY + 1;
					}
					for (ix = _oldMinX; ix <= _oldMaxX; ix++) {
						for (iy = num; iy <= _oldMaxY; iy++) {
							for (iz = _oldMinZ; iz <= _oldMaxZ; iz++) {
								_removedHandler(ix, iy, iz);
							}
						}
					}
					
					_oldMaxY = num - 1;
				} else if (maxY > _oldMaxY) {
					if (_oldMaxY < minY) {
						num = minY;
					} else {
						num = _oldMaxY + 1;
					}
					for (ix = minX; ix <= maxX; ix++) {
						for (iy = num; iy <= maxY; iy++) {
							for (iz = minZ; iz <= maxZ; iz++) {
								include 'PartitionBlockStatusManager_addSeg.define';
							}
						}
					}
					
					maxY = num - 1;
				}
				
				if (minY > _oldMinY) {
					if (minY > _oldMaxY) {
						num = _oldMaxY;
					} else {
						num = minY - 1;
					}
					for (ix = _oldMinX; ix <= _oldMaxX; ix++) {
						for (iy = _oldMinY; iy <= num; iy++) {
							for (iz = _oldMinZ; iz <= _oldMaxZ; iz++) {
								_removedHandler(ix, iy, iz);
							}
						}
					}
					
					_oldMinY = num + 1;
				} else if (minY < _oldMinY) {
					if (_oldMinY > maxY) {
						num = maxY;
					} else {
						num = _oldMinY - 1;
					}
					for (ix = minX; ix <= maxX; ix++) {
						for (iy = minY; iy <= num; iy++) {
							for (iz = minZ; iz <= maxZ; iz++) {
								include 'PartitionBlockStatusManager_addSeg.define';
							}
						}
					}
					
					minY = num + 1;
				}
				
				if (maxZ < _oldMaxZ) {
					if (maxZ < _oldMinZ) {
						num = _oldMinZ;
					} else {
						num = maxZ + 1;
					}
					for (ix = _oldMinX; ix <= _oldMaxX; ix++) {
						for (iy = _oldMinY; iy <= _oldMaxY; iy++) {
							for (iz = num; iz <= _oldMaxZ; iz++) {
								_removedHandler(ix, iy, iz);
							}
						}
					}
				} else if (maxZ > _oldMaxZ) {
					if (_oldMaxZ<minZ) {
						num = minZ;
					} else {
						num = _oldMaxZ + 1;
					}
					for (ix = minX; ix <= maxX; ix++) {
						for (iy = minY; iy <= maxY; iy++) {
							for (iz = num; iz <= maxZ; iz++) {
								include 'PartitionBlockStatusManager_addSeg.define';
							}
						}
					}
				}
				
				if (minZ > _oldMinZ) {
					if (minZ > _oldMaxZ) {
						num = _oldMaxZ;
					} else {
						num = minZ - 1;
					}
					for (ix = _oldMinX; ix <= _oldMaxX; ix++) {
						for (iy = _oldMinY; iy <= _oldMaxY; iy++) {
							for (iz = _oldMinZ; iz <= num; iz++) {
								_removedHandler(ix, iy, iz);
							}
						}
					}
				} else if (minZ < _oldMinZ) {
					if (_oldMinZ > maxZ) {
						num = maxZ;
					} else {
						num = _oldMinZ - 1;
					}
					for (ix = minX; ix <= maxX; ix++) {
						for (iy = minY; iy <= maxY; iy++) {
							for (iz = minZ; iz <= num; iz++) {
								include 'PartitionBlockStatusManager_addSeg.define';
							}
						}
					}
				}
			}
			
			if (addIndex>0) {
				_addMap.sortOn('sortValue');
				
				for (var i:uint = 0; i < addIndex; i++) {
					seg = _addMap[i];
					_addedHandler(seg.x, seg.y, seg.z);
				}
				
				_addMap.length = 0;
			}
			
			
			_oldMinX = newMinX;
			_oldMaxX = newMaxX;
			_oldMinY = newMinY;
			_oldMaxY = newMaxY;
			_oldMinZ = newMinZ;
			_oldMaxZ = newMaxZ;
		}
		private function _defaultHandler(x:int, y:int, z:int):void {
		}
	}
}
class Seg {
	public var sortValue:uint;
	public var x:int;
	public var y:int;
	public var z:int;
}