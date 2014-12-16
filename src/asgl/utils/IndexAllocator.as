package asgl.utils {
	import asgl.asgl_protected;
	
	use namespace asgl_protected;

	public class IndexAllocator {
		asgl_protected var _max:int;
		
		private var _emptySegment:Array;
		private var _allocatedMap:Array;
		
		public function IndexAllocator(maxNum:int=-1) {
			if (maxNum<=-1) maxNum = int.MAX_VALUE;
			_max = maxNum;
			_emptySegment = [];
			if (_max>0) {
				_emptySegment[0] = 0;
				_emptySegment[1] = _max - 1;
			}
			_allocatedMap = [];
		}
		public function get maxNum():uint {
			return _max;
		}
		public function get usableAmount():uint {
			var amount:int = 0;
			var length:int = _emptySegment.length;
			for (var i:int = 0; i < length; i += 2) {
				amount += _emptySegment[int(i + 1)] - _emptySegment[i] + 1;
			}
			return amount;
		}
		public function allocate(index:int=-1, mark:Boolean=true):int {
			var op:int = -1;
			var length:int = _emptySegment.length;
			if (length == 0) return op;
			var start:int;
			var end:int;
			if (index < 0) {
				if (mark) {
					start = _emptySegment[0];
					end = _emptySegment[1];
					if (start == end) {
						_emptySegment.splice(0, 2);
					} else {
						_emptySegment[0] = start + 1;
					}
					_allocatedMap[start] = true;
				}
				op = start;
			} else {
				if (_allocatedMap[index] == null) {
					if (index <= _max) {
						if (mark) {
							for (var i:int = 0; i < length; i += 2) {
								end = _emptySegment[int(i + 1)];
								if (index <= end) {
									start = _emptySegment[i];
									if (start == end) {
										_emptySegment.splice(i, 2);
									} else if (index == start) {
										_emptySegment[i] = start + 1;
									} else if (index == end) {
										_emptySegment[int(i + 1)] = end - 1;
									} else {
										_emptySegment.splice(i + 1, 0, index - 1, index + 1);
									}
									break;
								}
							}
							_allocatedMap[index] = true;
						}
						op = index;
					}
				}
			}
			return op;
		}
		public function allocateContinuous(firstIndex:int=-1, num:uint=1, mark:Boolean=true, failMark:Boolean=false):int {
			var op:int = -1;
			var length:int = _emptySegment.length;
			if (length == 0 || num == 0) return op;
			var start:int;
			var end:int;
			var i:int;
			if (firstIndex < 0) {
				for (i = 0; i < length; i += 2) {
					start = _emptySegment[0];
					end = _emptySegment[1];
					if (end - start + 1 >= num) {
						if (mark) {
							if (end - start + 1 == num) {
								_emptySegment.splice(i, 2);
							} else {
								_emptySegment[i] = start + num;
							}
							num += start;
							for (i = start; i < num; i++) {
								_allocatedMap[i] = true;
							}
						}
						op = start;
					}
				}
			} else {
				if (_allocatedMap[firstIndex] == null) {
					if (firstIndex <= _max) {
						for (i = 0; i < length; i += 2) {
							end = _emptySegment[int(i + 1)];
							if (firstIndex <= end) {
								if (firstIndex + num <= end) {
									if (mark) {
										start = _emptySegment[i];
										if (end - start + 1 == num) {
											_emptySegment.splice(i, 2);
										} else if (firstIndex == start) {
											_emptySegment[i] = start + num;
										} else if (firstIndex + num == end) {
											_emptySegment[i + 1] = end - num;
										} else {
											_emptySegment.splice(i + 1, 0, firstIndex - 1, firstIndex + num);
										}
										num += firstIndex;
										for (i = firstIndex; i < num; i++) {
											_allocatedMap[i] = true;
										}
									}
									op = firstIndex;
								}
								break;
							}
						}
					}
				} else if (mark && failMark) {
					length = firstIndex + num;
					for (i = firstIndex + 1; i < length; i++) {
						this.allocate(i);
					}
				}
			}
			return op;
		}
		public function free(index:int):Boolean {
			if (_allocatedMap[index] == null) {
				return false;
			} else {
				delete _allocatedMap[index];
				var length:int = _emptySegment.length;
				if (length == 0) {
					_emptySegment[0] = index;
					_emptySegment[1] = index;
				} else {
					var end:int = _emptySegment[int(length - 1)];
					if (index > end) {
						if (index == end + 1) {
							_emptySegment[int(length - 1)]++;
						} else {
							_emptySegment[length] = index;
							_emptySegment[int(length + 1)] = index;
						}
					} else {
						for (var i:int = 0; i < length; i += 2) {
							var start:int = _emptySegment[i];
							if (index < start) {
								if (index + 1 == start) {
									if (i > 0 && _emptySegment[int(i - 1)] + 2 == start) {
										_emptySegment.splice(i - 1, 2);
									} else {
										_emptySegment[i] = index;
									}
									break;
								} else {
									if (i > 0 && index - 1 == _emptySegment[int(i - 1)]) {
										_emptySegment[int(i - 1)] = index;
									} else {
										_emptySegment.splice(i, 0, index, index);
									}
									break;
								}
							}
						}
					}
				}
				return true;
			}
		}
		public function freeContinuous(index:int, num:int=1):void {
			if (num >= 0) {
				if (index < 0) index = 0;
				
				var end:uint = num < 0 ? _max : index+num;
				
				for (var i:uint = index; i < end; i++) {
					delete _allocatedMap[index];
				}
			}
		}
		public function freeAll():void {
			if (_allocatedMap.length > 0) {
				_emptySegment.length = 0;
				if (_max > 0) {
					_emptySegment[0] = 0;
					_emptySegment[1] = _max - 1;
				}
				_allocatedMap.length = 0;
			}
		}
		public function getAllocated(op:Vector.<uint>=null):Vector.<uint> {
			if (op == null) {
				op = new Vector.<uint>();
			} else if (!op.fixed) {
				op.length = 0;
			}
			
			var idx:uint = 0;
			
			for (var index:* in _allocatedMap) {
				op[idx++] = index;
			}
			return op;
		}
		public function isAllocated(index:uint):Boolean {
			return _allocatedMap[index] != null;
		}
	}
}