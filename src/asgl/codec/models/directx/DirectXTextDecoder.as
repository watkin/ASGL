package asgl.codec.models.directx {
	import asgl.animators.SkeletonAnimationAsset;
	import asgl.animators.SkeletonData;
	import asgl.animators.SkinnedMeshAsset;
	import asgl.animators.SkinnedVertex;
	import asgl.entities.EntityAsset;
	import asgl.entities.Object3D;
	import asgl.geometries.MeshAsset;
	import asgl.geometries.MeshElement;
	import asgl.geometries.MeshElementType;
	import asgl.geometries.MeshElementValueMappingType;
	import asgl.math.Matrix4x4;
	
	public class DirectXTextDecoder {
		public var skeletonAnimationAsset:SkeletonAnimationAsset;
		public var entityAsset:EntityAsset;
		public var skinnedMeshAssets:Object;
		public var meshAssets:Vector.<MeshAsset>;
		
		private var _transformLRH:Boolean;
		private var _meshNameIndex:uint;
		private var _meshNames:Object;
		
		public function DirectXTextDecoder(data:String=null, transformLHorRH:Boolean=false, decodeBones:Boolean=true) {
			if (data == null) {
				clear();
			} else {
				decode(data, transformLHorRH, decodeBones);
			}
		}
		public function clear():void {
			skeletonAnimationAsset = null;
			entityAsset = null;
			skinnedMeshAssets = null;
			meshAssets = null;
			_meshNameIndex = 0;
			_meshNames = null;
		}
		public function decode(data:String, transformLRH:Boolean=false, decodeMeshes:Boolean=true, decodeEntities:Boolean=true, decodeAnimation:Boolean=true):void {
			clear();
			
			_meshNames = {};
			
			_transformLRH = transformLRH;
			var list:Array = data.replace(/\r/g, '').split('\n');
			
			var root:DataSegment = new DataSegment();
			_parse(list, 0, root, 0);
			
			_decode(root.children, decodeMeshes, decodeEntities, decodeAnimation);
		}
		private function _decode(dss:Vector.<DataSegment>, decodeMeshes:Boolean, decodeEntities:Boolean, decodeAnimation:Boolean):void {
			var len:uint = dss.length;
			
			for (var i:uint = 0; i < len; i++) {
				var ds:DataSegment = dss[i];
				
				if (ds.head == DirectXTokenNameType.FRAME) {
					if (decodeMeshes) _decodeChildrenMesh(ds, null);
					
					if (decodeEntities) {
						var bone:Object3D = new Object3D();
						if (entityAsset == null) {
							entityAsset = new EntityAsset();
							entityAsset.rootEntities = new Vector.<Object3D>();
							entityAsset.entities = new Vector.<Object3D>();
						}
						entityAsset.rootEntities.push(bone);
						entityAsset.entities.push(bone);
						
						_decodeBones(ds, bone);
					}
				} else if (ds.head == DirectXTokenNameType.ANIMATION_SET) {
					if (decodeAnimation) _decodeAnimation(ds);
				}
			}
		}
		private function _decodeAnimation(ds:DataSegment):void {
			var len:uint = ds.children.length;
			for (var i:uint = 0; i < len; i++) {
				var anim:DataSegment = ds.children[i];
				
				var boneName:String = anim.children[0].body;
				
				if (skeletonAnimationAsset == null) {
					skeletonAnimationAsset = new SkeletonAnimationAsset();
					skeletonAnimationAsset.animationDataByNameMap = {};
					skeletonAnimationAsset.animationTimesByNameMap = {};
				}
				var animationTimesByNameMap:Object = skeletonAnimationAsset.animationTimesByNameMap;
				var animationMatricesByNameMap:Object = skeletonAnimationAsset.animationDataByNameMap;
				
				var timeList:Vector.<Number> = null;
				var matrices:Vector.<SkeletonData> = animationMatricesByNameMap[boneName];
				if (matrices == null) {
					matrices = new Vector.<SkeletonData>();
					timeList = new Vector.<Number>();
					skeletonAnimationAsset.animationDataByNameMap[boneName] = matrices;
					skeletonAnimationAsset.animationTimesByNameMap[boneName] = timeList;
				} else {
					timeList = skeletonAnimationAsset.animationTimesByNameMap[boneName];
				}
				
				var animKey:DataSegment = anim.getChildFromHead(DirectXTokenNameType.ANIMATION_KEY);
				
				var lines:Array = animKey.body.split('\n');
				var numLines:uint = 1;
				var num:uint = uint(lines[numLines++].split(';')[0]);
				
				for (var j:uint = 0; j < num; j++) {
					var temparr:Array = lines[numLines++].split(';');
					var bmarr:Array = temparr[2].split(',');
					var sd:SkeletonData = new SkeletonData();
					sd.local.matrix.m00 = Number(bmarr[0]);
					sd.local.matrix.m01 = Number(bmarr[1]);
					sd.local.matrix.m02 = Number(bmarr[2]);
					sd.local.matrix.m10 = Number(bmarr[4]);
					sd.local.matrix.m11 = Number(bmarr[5]);
					sd.local.matrix.m12 = Number(bmarr[6]);
					sd.local.matrix.m20 = Number(bmarr[8]);
					sd.local.matrix.m21 = Number(bmarr[9]);
					sd.local.matrix.m22 = Number(bmarr[10]);
					sd.local.matrix.m30 = Number(bmarr[12]);
					sd.local.matrix.m31 = Number(bmarr[13]);
					sd.local.matrix.m32 = Number(bmarr[14]);
					
					if (_transformLRH) sd.local.matrix.transformLRH();
					
					sd.local.updateTRS();
					
					matrices[j] = sd;
					timeList[j] = int(temparr[0]);
				}
				
				if (skeletonAnimationAsset.totalFrames < num) skeletonAnimationAsset.totalFrames = num;
			}
		}
		private function _decodeBones(ds:DataSegment, bone:Object3D):void {
			bone.name = ds.name;
			var matrix:DataSegment = ds.getChildFromHead(DirectXTokenNameType.FRAME_TRANSFORM_MATRIX);
			if (matrix != null) {
				var marr:Array = matrix.body.split(' ');
				marr = marr[marr.length-1].split(',');
				var m:Matrix4x4 = new Matrix4x4(Number(marr[0]), Number(marr[1]), Number(marr[2]), 0, 
					Number(marr[4]), Number(marr[5]), Number(marr[6]), 0, 
					Number(marr[8]), Number(marr[9]), Number(marr[10]), 0, 
					Number(marr[12]), Number(marr[13]), Number(marr[14]));
				if (_transformLRH) m.transformLRH();
				bone.setLocalMatrix(m);
			}
			
			var len:uint = ds.children.length;
			for (var i:uint = 0; i < len; i++) {
				var child:DataSegment = ds.children[i];
				if (child.head == DirectXTokenNameType.FRAME && child.name != null) {
					var childBone:Object3D = new Object3D();
					bone.addChild(childBone);
					
					entityAsset.entities.push(childBone);
					
					_decodeBones(child, childBone);
				}
			}
		}
		private function _decodeChildrenMesh(ds:DataSegment, name:String):void {
			if (ds.name != null) name = ds.name;
			
			if (ds.getChildFromHead(DirectXTokenNameType.MESH) != null) {
				if (meshAssets == null) meshAssets = new Vector.<MeshAsset>();
				
				var mo:MeshAsset = new MeshAsset();
				meshAssets[meshAssets.length] = mo;
				
				mo.name = name;
				if (mo.name in _meshNames) mo.name += '_' + (++_meshNameIndex);
				_meshNames[mo.name] = true;
				
				_decodeMesh(ds, mo);
			}
			
			var len:uint = ds.children.length;
			for (var i:uint = 0; i < len; i++) {
				var child:DataSegment = ds.children[i];
				if (child.head == DirectXTokenNameType.FRAME) {
					_decodeChildrenMesh(child, name);
				}
			}
		}
		private function _decodeMesh(ds:DataSegment, mo:MeshAsset):void {
			var mesh:DataSegment = ds.getChildFromHead(DirectXTokenNameType.MESH);
			
			var numLines:uint = 0;
			
			var lines:Array = mesh.body.split('\n');
			var line:String = lines[numLines++];
			
			var numVertices:uint = uint(line.substr(0, line.lastIndexOf(';')));
			var vertices:MeshElement = new MeshElement();
			vertices.numDataPreElement = 3;
			vertices.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
			vertices.values = new Vector.<Number>(numVertices * 3);
			mo.elements[MeshElementType.VERTEX] = vertices;
			
			var index:uint = 0;
			for (var i:uint = 0; i < numVertices; i++) {
				line = lines[numLines++];
				var varr:Array = line.split(';');
				vertices.values[index++] = Number(varr[0]);
				if (_transformLRH) {
					vertices.values[index++] = Number(varr[2]);
					vertices.values[index++] = Number(varr[1]);
				} else {
					vertices.values[index++] = Number(varr[1]);
					vertices.values[index++] = Number(varr[2]);
				}
			}
			
			line = lines[numLines++];
			var num:uint = uint(line.substr(0, line.lastIndexOf(';')));
			var vertexIndices:Vector.<uint> = new Vector.<uint>(num * 3);
			mo.triangleIndices = vertexIndices;
			index = 0;
			for (i = 0; i < num; i++) {
				var farr:Array = lines[numLines++].split(';')[1].split(',');
				if (_transformLRH) {
					vertexIndices[index++] = uint(farr[1]);
					vertexIndices[index++] = uint(farr[0]);
				} else {
					vertexIndices[index++] = uint(farr[0]);
					vertexIndices[index++] = uint(farr[1]);
				}
				vertexIndices[index++] = uint(farr[2]);
			}
			
			var meshTexCoords:DataSegment = mesh.getChildFromHead(DirectXTokenNameType.MESH_TEXTURE_COORDS);
			if (meshTexCoords != null) {
				lines = meshTexCoords.body.split('\n');
				numLines = 0;
				line = lines[numLines++];
				num = uint(line.substr(0, line.lastIndexOf(';')));
				var texCoords:MeshElement = new MeshElement();
				texCoords.numDataPreElement = 2;
				texCoords.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
				texCoords.values = new Vector.<Number>(num * 2);
				mo.elements[MeshElementType.TEXCOORD] = texCoords;
				index = 0;
				
				for (i = 0; i < num; i++) {
					line = lines[numLines++];
					var uvarr:Array = line.split(';');
					texCoords.values[index++] = Number(uvarr[0]);
					texCoords.values[index++] = Number(uvarr[1]);
				}
			}
			
			if (skinnedMeshAssets == null) skinnedMeshAssets = {};
			var skinnedMeshAsset:SkinnedMeshAsset = new SkinnedMeshAsset();
			skinnedMeshAssets[mo.name] = skinnedMeshAsset;
			
			var sws:Vector.<DataSegment> = mesh.getChildrenFromHead(DirectXTokenNameType.SKIN_WEIGHTS);
			var len:uint = sws.length;

			var offsetMatrices:Object = {};
			var boneNames:Vector.<String> = new Vector.<String>();
			var skinnedVertices:Vector.<SkinnedVertex> = new Vector.<SkinnedVertex>(numVertices);
			skinnedMeshAsset.preOffsetMatrices = offsetMatrices;
			skinnedMeshAsset.boneNames = boneNames;
			skinnedMeshAsset.skinnedVertices = skinnedVertices;
			
			for (i = 0; i < len; i++) {
				var meshSkinWights:DataSegment = sws[i];
				
				lines = meshSkinWights.body.split('\n');
				numLines = 0;
				line = lines[numLines++];
				
				var boneName:String = line.substring(line.indexOf('"') + 1, line.lastIndexOf('"'));
				
				num = uint(lines[numLines++].split(';')[0]);
				
				var blmarr:Array = lines[int(numLines + num * 2)].split(';')[0].split(' ');
				blmarr = blmarr[int(blmarr.length - 1)].split(',');
				var m:Matrix4x4 = new Matrix4x4(Number(blmarr[0]), Number(blmarr[1]), Number(blmarr[2]), 0, 
					Number(blmarr[4]), Number(blmarr[5]), Number(blmarr[6]), 0, 
					Number(blmarr[8]), Number(blmarr[9]), Number(blmarr[10]), 0, 
					Number(blmarr[12]), Number(blmarr[13]), Number(blmarr[14]));
				if (_transformLRH) m.transformLRH();
				
				boneNames[i] = boneName;
				offsetMatrices[boneName] = m;
				
				for (var j:uint = 0; j < num; j++) {
					var l1:String = lines[numLines];
					var l2:String = lines[int(numLines + num)];
					numLines++;
					
					index = uint(l1.substr(0, l1.length - 1));
					
					var svd:SkinnedVertex = skinnedVertices[index];
					if (svd == null) {
						svd = new SkinnedVertex();
						svd.boneNameIndices = new Vector.<uint>();
						svd.weights = new Vector.<Number>();
						skinnedVertices[index] = svd;
					}
					
					index = svd.boneNameIndices.length;
					
					svd.boneNameIndices[index] = i;
					svd.weights[index] = Number(l2.substr(0, l2.length - 1));
				}
			}
		}
		private function _deleteHeadSpace(str:String):String {
			var len:uint = str.length;
			var num:uint = 0;
			while (true) {
				if (num == len) {
					break;
				} else if (str.charAt(num) == ' ') {
					num++;
				} else {
					break;
				}
			}
			
			return str.substring(num);
		}
		private function _deleteTrailSpace(str:String):String {
			var len:uint = str.length;
			if (len > 0) len--;
			var num:uint = 0;
			
			while (true) {
				if (len == 0) {
					break;
				} else if (str.charAt(len) == ' ') {
					num++;
					len--;
				} else {
					break;
				}
			}
			
			return str.substr(0, str.length - num);
		}
		private function _parse(list:Array, index:uint, parent:DataSegment, depth:uint):uint {
			var ds:DataSegment;
			
			var count:int = 0;
			
			var len:uint = list.length;
			for (var i:uint = index; i < len; i++) {
				var line:String = list[i];
				
				var start:int = line.indexOf('{');
				
				if (start != -1) {
					var end:int = line.lastIndexOf('}');
					if (end != -1) {
						var ds1:DataSegment = new DataSegment();
						ds1.head = '';
						ds1.body = line.substring(start + 2, end - 1);
						
						ds.children.push(ds1);
						
						continue;
					}
					
					count++;
					
					if (count == 1) {
						ds = new DataSegment();
						
						var head:String = line.substring(depth, start - 1);
						if (head.charAt(head.length-1) == ' ') {
							head = head.substr(0, head.length - 1);
						}
						
						start = head.indexOf(DirectXTokenNameType.FRAME + ' ');
						if (start != -1) {
							ds.head = head.substr(0, DirectXTokenNameType.FRAME.length);
							ds.name = head.substr(DirectXTokenNameType.FRAME.length + 1);
						} else {
							start = head.indexOf(DirectXTokenNameType.ANIMATION_SET + ' ');
							if (start != -1) {
								ds.head = head.substr(0, DirectXTokenNameType.ANIMATION_SET.length);
								ds.name = head.substr(DirectXTokenNameType.ANIMATION_SET.length + 1);
							} else {
								start = head.indexOf(DirectXTokenNameType.ANIMATION + ' ');
								if (start != -1) {
									ds.head = head.substr(0, DirectXTokenNameType.ANIMATION.length);
									ds.name = head.substr(DirectXTokenNameType.ANIMATION.length + 1);
								} else {
									ds.head = _deleteTrailSpace(head);
								}
							}
						}
					} else {
						i = _parse(list, i, ds, depth + 1);
						
						count = 1;
					}
				} else if (line.indexOf('}') != -1) {
					count--;
					
					if (count == 0) {
						parent.children.push(ds);
					} else if (count < 0) {
						i--;
						break;
					}
				} else {
					if (count == 1) {
						ds.body += line + '\n';
					}
				}
			}
			
			return i;
		}
	}
}

class DataSegment {
	public var head:String = '';
	public var name:String;
	public var body:String = '';
	public var children:Vector.<DataSegment> = new Vector.<DataSegment>();
	
	public function getChildFromHead(head:String):DataSegment {
		var len:uint = children.length;
		for (var i:uint = 0; i < len; i ++) {
			if (children[i].head == head) {
				return children[i];
			}
		}
		
		return null;
	}
	
	public function getChildrenFromHead(head:String):Vector.<DataSegment> {
		var op:Vector.<DataSegment> = new Vector.<DataSegment>();
		var index:uint = 0;
		
		var len:uint = children.length;
		for (var i:uint = 0; i < len; i ++) {
			if (children[i].head == head) {
				op[index++] = children[i];
			}
		}
		
		return op;
	}
}