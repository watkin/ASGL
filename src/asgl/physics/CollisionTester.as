package asgl.physics {
	import asgl.asgl_protected;
	import asgl.bounds.BoundingAxisAlignedBox;
	import asgl.bounds.BoundingOrientedBox;
	import asgl.bounds.BoundingSphere;
	import asgl.bounds.BoundingVolume;
	import asgl.bounds.BoundingVolumeType;
	import asgl.entities.Coordinates3DHelper;
	import asgl.entities.Object3D;
	import asgl.math.Float2;
	import asgl.math.Float3;
	import asgl.math.Matrix4x4;
	
	use namespace asgl_protected;

	public class CollisionTester {
		private static var _funcMap:Object = _createFuncMap();
		
		private static var _minmax1:Float2 = new Float2();
		private static var _minmax2:Float2 = new Float2();
		private static var _tempFloat3_1:Float3 = new Float3();
		private static var _tempFloat3_2:Float3 = new Float3();
		private static var _axis:Float3 = new Float3();
		private static var _tempMatrix:Matrix4x4 = new Matrix4x4();
		private static var _tempVertices:Vector.<Number> = new Vector.<Number>(24);
		
		public function CollisionTester() {
		}
		private static function _createFuncMap():Object {
			var map:Object = {};
			
			map[(BoundingVolumeType.SPHERE << 4) | BoundingVolumeType.SPHERE] = Sphere_Sphere;
			map[(BoundingVolumeType.AABB << 4) | BoundingVolumeType.AABB] = AABB_AABB;
			map[(BoundingVolumeType.AABB << 4) | BoundingVolumeType.OBB] = AABB_OBB;
			map[(BoundingVolumeType.OBB << 4) | BoundingVolumeType.AABB] = OBB_AABB;
			map[(BoundingVolumeType.OBB << 4) | BoundingVolumeType.OBB] = OBB_OBB;
			map[(BoundingVolumeType.SPHERE << 4) | BoundingVolumeType.AABB] = Sphere_AABB;
			map[(BoundingVolumeType.AABB << 4) | BoundingVolumeType.SPHERE] = AABB_Sphere;
			map[(BoundingVolumeType.SPHERE << 4) | BoundingVolumeType.OBB] = Sphere_OBB;
			map[(BoundingVolumeType.OBB << 4) | BoundingVolumeType.SPHERE] = OBB_Sphere;
			
			return map;
		}
		public static function test(volume1:BoundingVolume, obj1:Object3D, volume2:BoundingVolume, obj2:Object3D):Boolean {
			var func:Function = _funcMap[(volume1._type << 4) | volume2._type];
			
			if (func == null) {
				return false;
			} else {
				return func(volume1, obj1, volume2, obj2);
			}
			
			return false;
		}
		private static function Sphere_Sphere(sphere1:BoundingSphere, obj1:Object3D, sphere2:BoundingSphere, obj2:Object3D):Boolean {
			var o1:Float3 = sphere1.globalOrigin;
			var o2:Float3 = sphere2.globalOrigin;
			
			var dx:Number = o1.x - o2.x;
			var dy:Number = o1.y - o2.y;
			var dz:Number = o1.z - o2.z;
			
			var dis2:Number = dx * dx + dy * dy + dz * dz;
			var len2:Number = sphere1.globalRadius + sphere1.globalRadius;
			len2 *= len2;
			
			return dis2 <= len2;
		}
		private static function AABB_Sphere(box:BoundingAxisAlignedBox, obj1:Object3D, sphere:BoundingSphere, obj2:Object3D):Boolean {
			return Sphere_AABB(sphere, obj2, box, obj1);
		}
		private static function _Sphere_AABB(origin:Float3, radius:Number, minX:Number, maxX:Number, minY:Number, maxY:Number, minZ:Number, maxZ:Number):Boolean {
			var s:Number = 0;
			var d:Number = 0;
			
			if (origin.x < minX) {
				s = origin.x - minX;
				d += s * s;
			} else if (origin.x > maxX) {
				s = origin.x - maxX;
				d += s * s;
			}
			
			if (origin.y < minY) {
				s = origin.y - minY;
				d += s * s;
			} else if (origin.y > maxY) {
				s = origin.y - maxY;
				d += s * s;
			}
			
			if (origin.z < minZ) {
				s = origin.z - minZ;
				d += s * s;
			} else if (origin.z > maxZ) {
				s = origin.z - maxZ;
				d += s * s;
			}
			
			return d <= radius * radius;
		}
		private static function Sphere_AABB(sphere:BoundingSphere, obj1:Object3D, box:BoundingAxisAlignedBox, obj2:Object3D):Boolean {
			return _Sphere_AABB(sphere.globalOrigin, sphere.globalRadius, box.globalMinX, box.globalMaxX, box.globalMinY, box.globalMaxY, box.globalMinZ, box.globalMaxZ);
		}
		private static function OBB_Sphere(box:BoundingOrientedBox, obj1:Object3D, sphere:BoundingSphere, obj2:Object3D):Boolean {
			return Sphere_OBB(sphere, obj2, box, obj1);
		}
		private static function Sphere_OBB(sphere:BoundingSphere, obj1:Object3D, box:BoundingOrientedBox, obj2:Object3D):Boolean {
			var m:Matrix4x4 = Coordinates3DHelper.getLocalToLocalMatrix(obj1, obj2, _tempMatrix);
			
			var o:Float3 = m.transform3x4Float3(sphere.origin, _tempFloat3_1);
			
			var radius:Number = m.getAxisX(_tempFloat3_2).length;
			var s:Number = m.getAxisY(_tempFloat3_2).length;
			if (radius < s) radius = s;
			s = m.getAxisZ(_tempFloat3_2).length;
			if (radius < s) radius = s;
			radius *= sphere._radius;
			
			return _Sphere_AABB(o, radius, box.minX, box.maxX, box.minY, box.maxY, box.minZ, box.maxZ);
		}
		private static function AABB_AABB(box1:BoundingAxisAlignedBox, obj1:Object3D, box2:BoundingAxisAlignedBox, obj2:Object3D):Boolean {
			if (box1.globalMinX > box2.globalMaxX || box1.globalMaxX < box2.globalMinX || 
				box1.globalMinY > box2.globalMaxY || box1.globalMaxY < box2.globalMinY || 
				box1.globalMinZ > box2.globalMaxZ || box1.globalMaxZ < box2.globalMinZ) return false;
			return true;
		}
		private static function OBB_AABB(box1:BoundingOrientedBox, obj1:Object3D, box2:BoundingAxisAlignedBox, obj2:Object3D):Boolean {
			return AABB_OBB(box2, obj2, box1, obj1);
		}
		private static function AABB_OBB(box1:BoundingAxisAlignedBox, obj1:Object3D, box2:BoundingOrientedBox, obj2:Object3D):Boolean {
			_tempVertices[0] = box1.globalMinX;
			_tempVertices[1] = box1.globalMinY;
			_tempVertices[2] = box1.globalMinZ;
			_tempVertices[3] = box1.globalMaxX;
			_tempVertices[4] = box1.globalMinY;
			_tempVertices[5] = box1.globalMinZ;
			_tempVertices[6] = box1.globalMaxX;
			_tempVertices[7] = box1.globalMinY;
			_tempVertices[8] = box1.globalMaxZ;
			_tempVertices[9] = box1.globalMinX;
			_tempVertices[10] = box1.globalMinY;
			_tempVertices[11] = box1.globalMaxZ;
			_tempVertices[12] = box1.globalMinX;
			_tempVertices[13] = box1.globalMaxY;
			_tempVertices[14] = box1.globalMinZ;
			_tempVertices[15] = box1.globalMaxX;
			_tempVertices[16] = box1.globalMaxY;
			_tempVertices[17] = box1.globalMinZ;
			_tempVertices[18] = box1.globalMaxX;
			_tempVertices[19] = box1.globalMaxY;
			_tempVertices[20] = box1.globalMaxZ;
			_tempVertices[21] = box1.globalMinX;
			_tempVertices[22] = box1.globalMaxY;
			_tempVertices[23] = box1.globalMaxZ;
			
			return _OBB_OBB(_tempVertices, box2.globalVertices);
		}
		private static function _OBB_OBB(vertices1:Vector.<Number>, vertices2:Vector.<Number>):Boolean {
			for (var i:int = 0; i < 3; i++) {
				_getFaceDir(vertices1, i, _tempFloat3_1);
				_getInterval(vertices1, _tempFloat3_1, _minmax1);              
				_getInterval(vertices2, _tempFloat3_1, _minmax2);              
				if (_minmax1.y < _minmax2.x || _minmax2.y < _minmax1.x) return false;               
			}
			
			for (i = 0; i < 3; i++) {
				_getFaceDir(vertices2, i, _tempFloat3_1);
				_getInterval(vertices1, _tempFloat3_1, _minmax1);              
				_getInterval(vertices2, _tempFloat3_1, _minmax2);              
				if (_minmax1.y < _minmax2.x || _minmax2.y < _minmax1.x) return false;             
			}
			
			for (i = 0; i < 3; i++) {
				_getEdgeDir(vertices1, i, _tempFloat3_1);
				for (var j:int = 0; j < 3; j++) {
					_getEdgeDir(vertices2, j, _tempFloat3_2);
					
					_axis.x = _tempFloat3_1.y * _tempFloat3_2.z - _tempFloat3_1.z * _tempFloat3_2.y;
					_axis.y = _tempFloat3_1.z * _tempFloat3_2.x - _tempFloat3_1.x * _tempFloat3_2.z;
					_axis.z = _tempFloat3_1.x * _tempFloat3_2.y - _tempFloat3_1.y * _tempFloat3_2.x;
					
					_getInterval(vertices1, _axis, _minmax1);
					_getInterval(vertices2, _axis, _minmax2);            
					if (_minmax1.y < _minmax2.x || _minmax2.y < _minmax1.x) return false;            
				}
			}
			
			return true;
		}
		private static function OBB_OBB(box1:BoundingOrientedBox, obj1:Object3D, box2:BoundingOrientedBox, obj2:Object3D):Boolean {
			return _OBB_OBB(box1.globalVertices, box2.globalVertices);
		}
		private static function _getEdgeDir(vertices:Vector.<Number>, indexID:int, op:Float3):Float3 {
			var p1:int = 0;//vertices[1];
			var p2:int;
			
			if (indexID == 0) {//edge in parallel with x axis
				p2 = 3;//vertices[1];
			} else if (indexID == 1) {//edge in parallel with y axis
				p2 = 12;//vertices[4];
			} else {//edge in parallel with z axis
				p2 = 9;//vertices[3];
			}
			
			op.x = vertices[p2] - vertices[p1];
			op.y = vertices[int(p2 + 1)] - vertices[int(p1 + 1)];
			op.z = vertices[int(p2 + 2)]- vertices[int(p1 + 2)];
			
			op.normalize();
			
			return op;
		}
		private static function _getFaceDir(vertices:Vector.<Number>, indexID:int, op:Float3):void {
			var p1:int;
			var p2:int;
			var p3:int;
			
			if (indexID == 0) {//front and back
				p1 = 6;//vertices[2];
				p2 = 9;//vertices[3];
				p3 = 18;//vertices[6];
			} else if (indexID == 1) {//left and right
				p1 = 3;//vertices[1];
				p2 = 6;//vertices[2];
				p3 = 15;//vertices[5];
			} else {//top and bottom
				p1 = 0;//vertices[0];
				p2 = 3;//vertices[1];
				p3 = 6;//vertices[2];
			}
			
			var x:Number = vertices[p1];
			var y:Number = vertices[int(p1 + 1)];
			var z:Number = vertices[int(p1 + 2)];
			
			var abX:Number = vertices[p2] - x;
			var abY:Number = vertices[int(p2 + 1)] - y;
			var abZ:Number = vertices[int(p2 + 2)]- z;
			var acX:Number = vertices[p3] - x;
			var acY:Number = vertices[int(p3 + 1)] - y;
			var acZ:Number = vertices[int(p3 + 2)] - z;
			
			op.x = abY * acZ - abZ * acY;
			op.y = abZ * acX - abX * acZ;
			op.z = abX * acY - abY * acX;
			
			op.normalize();
		}
		private static function _getInterval(vertices:Vector.<Number>, axis:Float3, op:Float2):void {
			var p:int = 0;//vertices[0];
			
			op.x = axis.x * vertices[0] + axis.y * vertices[1] + axis.z * vertices[2];
			op.y = op.x;
			
			for (var i:int = 1; i < 8; i++) {
				p = i * 3;//vertices[i];
				var value:Number = axis.x * vertices[p] + axis.y * vertices[int(p + 1)] + axis.z * vertices[int(p + 2)];
				
				if (value < op.x) op.x = value;
				if (value > op.y) op.y = value;
			}
		}
	}
}