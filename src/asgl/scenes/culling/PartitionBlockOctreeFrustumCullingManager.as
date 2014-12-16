package asgl.scenes.culling {
	import asgl.asgl_protected;
	import asgl.bounds.BoundingAxisAlignedBox;
	import asgl.math.Matrix4x4;
	import asgl.scenes.PartitionBlockDataManager;
	
	use namespace asgl_protected;
	
	public class PartitionBlockOctreeFrustumCullingManager extends PartitionBlockDataManager {
		private static var _outsideData:Vector.<SegmentData>;
		private static var _outsideDataNum:uint = 0;
		
		private static var _managerData:Vector.<ManagerData>;
		private static var _managerDataNum:uint = 0;
		
		private var _removeObjects:Vector.<ICullingObject>;
		
		private var _managerMap:Object;
		private var _outsideObjectMap:Object;
		private var _outsideSegMap:Object;
		
		private var _depthLevel:uint;
		private var _looseMultiple:Number;
		
		private var _type:uint;
		
		private var _tempBoundingBox:BoundingAxisAlignedBox;
		private var _tempCullingObject:*;//ICullingObject
		
		public function PartitionBlockOctreeFrustumCullingManager(type:uint, depthLevel:uint, looseMultiple:Number, originX:Number, originY:Number, originZ:Number, blockLength:Number, blockWidth:Number, blockHeight:Number, maxCacheAmount:uint) {
			super(originX, originY, originZ, blockLength, blockWidth, blockHeight, maxCacheAmount);
			
			_type = type;
			
			if (_outsideData == null) {
				_outsideData = new Vector.<SegmentData>(100);
				_managerData = new Vector.<ManagerData>(100);
			}
			
			_managerMap = {};
			_outsideObjectMap = {};
			_outsideSegMap = {};
			
			_depthLevel = depthLevel;
			_looseMultiple = looseMultiple;
			
			_removeObjects = new Vector.<ICullingObject>();
		}
		public function culling(matrix:Matrix4x4):void {
			for each (var mapY:Object in _map) {
				for each (var mapZ:Object in mapY) {
					for each (var manager:OctreeFrustumCullingManager in mapZ) {
						manager.culling(matrix);
					}
				}
			}
		}
		public function cullingFrom(cameraWorldMatrix:Matrix4x4, projectionMatrix:Matrix4x4, computeOffset:Boolean=true):void {
			for each (var mapY:Object in _map) {
				for each (var mapZ:Object in mapY) {
					for each (var manager:OctreeFrustumCullingManager in mapZ) {
						manager.cullingFrom(cameraWorldMatrix, projectionMatrix, computeOffset);
					}
				}
			}
		}
		public function query(obj:ICullingObject):Boolean {
			var co:* = obj;
			var id:uint = co._instanceID;
			var md:ManagerData = _managerMap[id];
			
			if (md == null) {
				return false;
			} else {
				return md.manager.queryFromInstanceID(id);
			}
		}
		public override function update(x:Number, y:Number, z:Number):* {
			throw new Error('can not call the method');
		}
		public function removeObject(obj:ICullingObject):void {
			var co:* = obj;
			
			var id:uint = co._internalID;
			
			var md:ManagerData = _managerData[id];
			
			if (md == null) {
				var sd:SegmentData = _outsideObjectMap[id];
				if (sd != null) {
					var outsideMap:Object = _outsideSegMap[sd.key];
					if (outsideMap != null) {
						delete outsideMap[id];
						
						var isEmpty:Boolean = true;
						for (var key:* in outsideMap) {
							isEmpty = false;
							break;
						}
						
						if (isEmpty) delete _outsideSegMap[sd.key];
					}
					
					delete _outsideObjectMap[id];
					
					sd.obj = null;
					_outsideData[_outsideDataNum++] = sd;
					
					if (co._frustumCullingVisible) obj.frustumCullingVisible = false;
				}
			} else {
				md.manager.removeObject(obj);
				delete _managerMap[id];
				
				md.manager = null;
				md.obj = null;
				
				_managerData[_managerDataNum++] = md;
			}
		}
		public function updateObject(obj:ICullingObject, bound:BoundingAxisAlignedBox, x:Number, y:Number, z:Number):Number {
			_tempCullingObject = obj;
			_tempBoundingBox = bound;
			
			var op:* = super.update(x, y, z);
			
			_tempCullingObject = null;
			_tempBoundingBox = null;
			
			return op;
		}
		protected override function _createData(data:*, segX:int, segY:int, segZ:int, originX:Number, originY:Number, originZ:Number):* {
			var manager:OctreeFrustumCullingManager;
			
			if (data == null) {
				manager = new OctreeFrustumCullingManager(_type, new BoundingAxisAlignedBox(-_halfLength, _halfLength, -_halfHeight, _halfHeight, -_halfWidth, _halfWidth), _depthLevel, _looseMultiple, originX, originY, originZ);
			} else {
				manager = data;
				manager.setOffset(originX, originY, originZ);
			}
			
			var key:String = segX + '_' + segY + '_' + segZ;
			var outsideMap:Object = _outsideSegMap[key];
			if (outsideMap != null) {
				delete _outsideSegMap[key];
				
				for (var id:* in outsideMap) {
					delete _outsideObjectMap[id];
					
					var sd:SegmentData = outsideMap[id];
					
					var md:ManagerData;
					if (_managerDataNum == 0) {
						md = new ManagerData();
					} else {
						md = _managerData[--_managerDataNum];
						_managerData[_managerDataNum] = null;
					}
					
					md.manager = manager;
					md.obj = sd.obj;
					md.bounding.copy(sd.bounding);
					md.segX = sd.segX;
					md.segY = sd.segY;
					md.segZ = sd.segZ;
					md.x = sd.x;
					md.y = sd.y;
					md.z = sd.z;
					
					_managerMap[id] = md;
					
					manager.updateObject(sd.obj, sd.bounding, sd.x, sd.y, sd.z);
					
					sd.obj = null;
					_outsideData[_outsideDataNum++] = sd;
				}
			}
			
			return manager;
		}
		protected override function _dataUpdate(data:*, segX:int, segY:int, segZ:int, x:Number, y:Number, z:Number):* {
			var id:uint = _tempCullingObject._instanceID;
			var md:ManagerData = _managerMap[id];
			
			var sd:SegmentData;
			var outsideMap:Object;
			var isEmpty:Boolean;
			
			if (data == null) {
				if (md == null) {
					sd = _outsideObjectMap[id];
					if (sd == null) {
						if (_outsideDataNum == 0) {
							sd = new SegmentData();
						} else {
							sd = _outsideData[--_outsideDataNum];
							_outsideData[_outsideDataNum] = null;
						}
						
						sd.obj = _tempCullingObject;
						sd.bounding.copy(_tempBoundingBox);
						sd.segX = segX;
						sd.segY = segY;
						sd.segZ = segZ;
						sd.key = segX + '_' + segY + '_' + segZ;
						sd.x = x;
						sd.y = y;
						sd.z = z;
						
						outsideMap = _outsideSegMap[sd.key];
						if (outsideMap == null) {
							outsideMap = {};
							_outsideSegMap[sd.key] = outsideMap;
						}
						
						outsideMap[id] = sd;
						_outsideObjectMap[id] = sd;
						
						if (_tempCullingObject._frustumCullingVisible) _tempCullingObject.setFrustumCullingVisible(false);
					} else {
						var key:String = segX + '_' + segY + '_' + segZ;
						if (sd.key != key) {
							outsideMap = _outsideSegMap[sd.key];
							if (outsideMap != null) {
								delete outsideMap[sd.key];
								
								isEmpty = true;
								for (var key2:* in outsideMap) {
									isEmpty = false;
									break;
								}
								
								if (isEmpty) delete _outsideSegMap[sd.key];
							}
							
							outsideMap = _outsideSegMap[key];
							if (outsideMap == null) {
								outsideMap = {};
								_outsideSegMap[key] = outsideMap;
							}
							
							outsideMap[id] = sd;
							
							sd.segX = segX;
							sd.segY = segY;
							sd.segZ = segZ;
							sd.key = key;
						}
						
						sd.x = x;
						sd.y = y;
						sd.z = z;
					}
				} else {
					md.manager.removeObject(_tempCullingObject);
					delete _managerMap[id];
					
					md.manager = null;
					md.obj = null;
					
					_managerData[_managerDataNum++] = md;
					
					if (_outsideDataNum == 0) {
						sd = new SegmentData();
					} else {
						sd = _outsideData[--_outsideDataNum];
						_outsideData[_outsideDataNum] = null;
					}
					
					sd.obj = _tempCullingObject;
					sd.bounding.copy(_tempBoundingBox);
					sd.segX = segX;
					sd.segY = segY;
					sd.segZ = segZ;
					sd.key = segX + '_' + segY + '_' + segZ;
					sd.x = x;
					sd.y = y;
					sd.z = z;
					
					outsideMap = _outsideSegMap[sd.key];
					if (outsideMap == null) {
						outsideMap = {};
						_outsideSegMap[sd.key] = outsideMap;
					}
					
					outsideMap[id] = sd;
					_outsideObjectMap[id] = sd;
				}
			} else {
				var manager:OctreeFrustumCullingManager = data;
				if (md == null || md.manager != manager) {
					if (md == null) {
						sd = _outsideObjectMap[id];
						if (sd != null) {
							outsideMap = _outsideSegMap[sd.key];
							if (outsideMap != null) {
								delete outsideMap[id];
								
								isEmpty = true;
								for (var key3:* in outsideMap) {
									isEmpty = false;
									break;
								}
								
								if (isEmpty) delete _outsideSegMap[sd.key];
							}
							
							delete _outsideObjectMap[id];
							
							sd.obj = null;
							_outsideData[_outsideDataNum++] = sd;
						}
						
						if (_managerDataNum == 0) {
							md = new ManagerData();
						} else {
							md = _managerData[--_managerDataNum];
							_managerData[_managerDataNum] = null;
						}
						
						md.obj = _tempCullingObject;
					} else {
						md.manager.removeObject(_tempCullingObject);
					}
					
					md.manager = manager;
					
					_managerMap[id] = md;
				}
				
				md.bounding.copy(_tempBoundingBox);
				md.x = x;
				md.y = y;
				md.z = z;
				
				manager.updateObject(_tempCullingObject, _tempBoundingBox, x, y, z);
			}
			
			return null;
		}
		protected override function _removeData(data:*, segX:int, segY:int, segZ:int, putToPool:Boolean):Boolean {
			var manager:OctreeFrustumCullingManager = data;
			
			manager.removeAllObjects(_removeObjects);
			
			var key:String = segX + '_' + segY + '_' + segZ;
			
			var outsideMap:Object = _outsideSegMap[key];
			if (outsideMap == null) {
				outsideMap = {};
				_outsideSegMap[key] = outsideMap;
			}
			
			for each (var obj:* in _removeObjects) {//ICullingObject
				var id:uint = obj._instanceID;
				
				var md:ManagerData = _managerMap[id];
				
				delete _managerMap[id];
				
				var sd:SegmentData;
				if (_outsideDataNum == 0) {
					sd = new SegmentData();
				} else {
					sd = _outsideData[--_outsideDataNum];
					_outsideData[_outsideDataNum] = null;
				}
				
				sd.obj = obj;
				sd.bounding.copy(md.bounding);
				sd.segX = segX;
				sd.segY = segY;
				sd.segZ = segZ;
				sd.key = key;
				sd.x = md.x;
				sd.y = md.y;
				sd.z = md.z;
				
				md.obj = null;
				md.manager = null;
				
				_managerData[_managerDataNum++] = md;
				
				_outsideObjectMap[id] = sd;
				outsideMap[id] = sd;
			}
			
			_removeObjects.length = 0;
			
			return putToPool;
		}
	}
}
import asgl.bounds.BoundingAxisAlignedBox;
import asgl.scenes.culling.ICullingObject;
import asgl.scenes.culling.OctreeFrustumCullingManager;

class SegmentData {
	public var obj:ICullingObject;
	public var bounding:BoundingAxisAlignedBox = new BoundingAxisAlignedBox();
	public var segX:int;
	public var segY:int;
	public var segZ:int;
	public var key:String;
	public var x:Number;
	public var y:Number;
	public var z:Number;
}
class ManagerData {
	public var manager:OctreeFrustumCullingManager;
	
	public var obj:ICullingObject;
	public var bounding:BoundingAxisAlignedBox = new BoundingAxisAlignedBox();
	public var segX:int;
	public var segY:int;
	public var segZ:int;
	public var x:Number;
	public var y:Number;
	public var z:Number;
	
}