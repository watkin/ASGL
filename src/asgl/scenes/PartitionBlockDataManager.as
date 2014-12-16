package asgl.scenes {
	public class PartitionBlockDataManager {
		protected var _blockLength:Number;
		protected var _blockWidth:Number;
		protected var _blockHeight:Number;
		protected var _halfLength:Number;
		protected var _halfWidth:Number;
		protected var _halfHeight:Number;
		protected var _originX:Number;
		protected var _originY:Number;
		protected var _originZ:Number;
		protected var _map:Object;
		protected var _currentCacheAmount:uint;
		protected var _maxCacheAmount:uint;
		protected var _pool:Vector.<Object>;
		private var _originLTX:Number;
		private var _originLTY:Number;
		private var _originLTZ:Number;
		
		public function PartitionBlockDataManager(originX:Number, originY:Number, originZ:Number, blockLength:Number, blockWidth:Number, blockHeight:Number, maxCacheAmount:uint) {
			_map = {};
			_currentCacheAmount = 0;
			_maxCacheAmount = maxCacheAmount;
			_pool = new Vector.<Object>(_maxCacheAmount);
			
			this.reset(originX, originY, originZ, blockLength, blockWidth, blockHeight, maxCacheAmount);
		}
		public function get maxCacheAmount():uint {
			return _maxCacheAmount;
		}
		public function set maxCacheAmount(value:uint):void {
			if (_maxCacheAmount != value) {
				_maxCacheAmount = value;
				
				_pool.length = _maxCacheAmount;
				if (_currentCacheAmount>_maxCacheAmount) _currentCacheAmount = _maxCacheAmount;
			}
		}
		public function createData(segX:int, segY:int, segZ:int):* {
			var usegX:uint = int.MAX_VALUE+segX;
			var usegY:uint = int.MAX_VALUE+segY;
			var usegZ:uint = int.MAX_VALUE+segZ;
			
			var mapY:Object = _map[usegX];
			if (mapY == null) {
				mapY = {};
				_map[usegX] = mapY;
			}
			var mapZ:Object = mapY[usegY];
			if (mapZ == null) {
				mapZ = {};
				mapY[usegY] = mapZ;
			}
			var oldData:* = mapZ[usegZ];
			if (oldData != null) {
				var put:Boolean = _currentCacheAmount<_maxCacheAmount;
				if (_removeData(oldData, segX, segY, segZ, put)) {
					_pool[_currentCacheAmount++] = oldData;
					if (!put) _maxCacheAmount++;
				}
			}
			
			var originX:Number = segX*_blockLength+_originX;
			var originY:Number = segY*_blockHeight+_originY;
			var originZ:Number = segZ*_blockWidth+_originZ;
			
			var newData:*;
			if (_currentCacheAmount>0) {
				newData = _pool[--_currentCacheAmount];
				_createData(newData, segX, segY, segZ, originX, originY, originZ);
			} else {
				newData = _createData(null, segX, segY, segZ, originX, originY, originZ);
			}
			mapZ[usegZ] = newData;
			
			return newData;
		}
		public function removeAll():void {
			for (var segX:* in _map) {
				var mapY:Object = _map[segX];
				for (var segY:* in mapY) {
					var mapZ:Object = mapY[segY];
					for (var segZ:* in mapZ) {
						removeData(segX, segY, segZ);
					}
				}
			}
		}
		public function removeData(segX:int, segY:int, segZ:int):void {
			var usegX:uint = int.MAX_VALUE+segX;
			var usegY:uint = int.MAX_VALUE+segY;
			var usegZ:uint = int.MAX_VALUE+segZ;
			
			var data:*;
			
			var mapY:Object = _map[usegX];
			if (mapY != null) {
				var mapZ:Object = mapY[usegY];
				if (mapZ != null) {
					data = mapZ[usegZ];
					if (data != null) {
						delete mapZ[usegZ];
						
						var isEmpty:Boolean = true;
						for (var key:* in mapZ) {
							isEmpty = false;
							break;
						}
						
						if (isEmpty) {
							delete mapY[usegY];
							
							isEmpty = true;
							for (key in _map) {
								isEmpty = false;
								break;
							}
							
							if (isEmpty) delete _map[usegX];
						}
						
						var put:Boolean = _currentCacheAmount<_maxCacheAmount;
						if (_removeData(data, segX, segY, segZ, put)) {
							_pool[_currentCacheAmount++] = data;
							if (!put) _maxCacheAmount++;
						}
					}
				}
			}
		}
		public function reset(originX:Number, originY:Number, originZ:Number, blockLength:Number, blockWidth:Number, blockHeight:Number, maxCacheAmount:uint):void {
			this.removeAll();
			
			_blockLength = blockLength;
			_blockWidth = blockWidth;
			_blockHeight = blockHeight;
			
			_halfLength = _blockLength * 0.5;
			_halfWidth = _blockWidth * 0.5;
			_halfHeight = _blockHeight * 0.5;
			
			_originX = originX;
			_originY = originY;
			_originZ = originZ;
			
			_originLTX = _originX - _halfLength;
			_originLTY = _originY - _halfHeight;
			_originLTZ = _originZ - _halfWidth;
			
			if (_maxCacheAmount != maxCacheAmount) {
				_maxCacheAmount = maxCacheAmount;
				_pool.length = _maxCacheAmount;
				
				if (_currentCacheAmount>_maxCacheAmount) _currentCacheAmount = _maxCacheAmount;
			}
		}
		public function update(x:Number, y:Number, z:Number):* {
			var tx:Number = x - _originLTX;
			var ty:Number = y - _originLTY;
			var tz:Number = z - _originLTZ;
			
			tx /= _blockLength;
			ty /= _blockHeight;
			tz /= _blockWidth;
			
			var segX:int = tx;
			var segY:int = ty;
			var segZ:int = tz;
			
			if (tx < 0 && segX != tx) segX--;
			if (ty < 0 && segY != ty) segY--;
			if (tz < 0 && segZ != tz) segZ--;
			
			var usegX:uint = int.MAX_VALUE + segX;
			var usegY:uint = int.MAX_VALUE + segY;
			var usegZ:uint = int.MAX_VALUE + segZ;
			
			var mapY:Object = _map[usegX];
			if (mapY == null) {
				return _dataUpdate(null, segX, segY, segZ, x, y, z);
			} else {
				var mapZ:Object = mapY[usegY];
				if (mapZ == null) {
					return _dataUpdate(null, segX, segY, segZ, x, y, z);
				} else {
					var data:* = mapZ[usegZ];
					if (data == null) {
						return _dataUpdate(null, segX, segY, segZ, x, y, z);
					} else {
						return _dataUpdate(data, segX, segY, segZ, x, y, z);
					}
				}
			}
		}
		/**
		 * if data is null<br>
		 *  new data<br>
		 * else<br>
		 *  reset data<br>
		 */
		protected function _createData(data:*, segX:int, segY:int, segZ:int, originX:Number, originY:Number, originZ:Number):* {
			return data;
		}
		/**
		 * if data is null<br>
		 * 	data not found<br>
		 * else<br>
		 *  update<br>
		 */
		protected function _dataUpdate(data:*, segX:int, segY:int, segZ:int, x:Number, y:Number, z:Number):* {
			return null;
		}
		protected function _removeData(data:*, segX:int, segY:int, segZ:int, putToPool:Boolean):Boolean {
			return putToPool;
		}
	}
}