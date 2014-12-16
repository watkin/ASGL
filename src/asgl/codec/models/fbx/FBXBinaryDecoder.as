package asgl.codec.models.fbx {
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import asgl.animators.SkeletonAnimationAsset;
	import asgl.animators.SkeletonData;
	import asgl.animators.SkinnedMeshAsset;
	import asgl.animators.SkinnedVertex;
	import asgl.entities.EntityAsset;
	import asgl.entities.Object3D;
	import asgl.geometries.MeshAsset;
	import asgl.geometries.MeshElementType;
	import asgl.math.Float3;
	import asgl.math.Float4;
	import asgl.math.Matrix4x4;
	import asgl.renderables.MeshRenderable;
	import asgl.utils.NumberLong;

	public class FBXBinaryDecoder {
		private static const DEGREES_TO_RADIAN:Number = Math.PI / 180;
		
		public var rootNode:FBXNode;
		
		public var skeletonAnimationAsset:SkeletonAnimationAsset;
		public var entityAsset:EntityAsset;
		public var skinnedMeshAssets:Object;
		public var meshAssets:Vector.<MeshAsset>;
		
		private var _idMap:Object;
		private var _animFrames:Vector.<FBXAnimationFrame>;
		private var _globalSettings:FBXGlobalSettings;
		private var _boneNames:Vector.<String>;
		private var _meshNameIndex:uint;
		private var _meshNames:Object;
		
		public function FBXBinaryDecoder(bytes:ByteArray=null, transformLHorRH:Boolean=false) {
			if (bytes == null) {
				clear();
			} else {
				decode(bytes, transformLHorRH);
			}
		}
		public function clear():void {
			rootNode = null;
			_idMap = null;
			_meshNameIndex = 0;
			_animFrames = null;
			_globalSettings = null;
			_meshNames = {};
		}
		public function decode(bytes:ByteArray, transformLRH:Boolean=false):void {
			clear();
			
			bytes.endian = Endian.LITTLE_ENDIAN;
			bytes.position = 27;
			
			rootNode = new FBXNode();
			_idMap = {};
			_meshNames = {};
			
			while (bytes.bytesAvailable > 4) {
				if (bytes.readUnsignedInt() < bytes.length) {
					bytes.position -= 4;
					
					_decodeNode(bytes, rootNode);
				} else {
					break;
				}
			}
			var s:String = rootNode.toString();
			_globalSettings = rootNode.getNode(FBXNodeName.GLOBAL_SETTINGS) as FBXGlobalSettings;
			
			var len:uint = rootNode.children.length;
			for (var i:uint = 0; i < len; i++) {
				var node:FBXNode = rootNode.children[i];
				var name:String = node.name;
				if (name == FBXNodeName.OBJECTS) {
					_parseObjects(node, transformLRH);
				} else if (name == FBXNodeName.CONNECTIONS) {
					_parseConnections(node, transformLRH);
				}
			}
		}
		private function _parseObjects(node:FBXNode, transformLRH:Boolean):void {
			var len:uint = node.children.length;
			for (var i:uint = 0; i < len; i++) {
				var child:FBXNode = node.children[i];
				
				if (child is FBXDeformer) {
					_idMap[(child as FBXDeformer).id] = child;
				} else if (child is FBXAnimationCurve) {
					_idMap[(child as FBXAnimationCurve).id] = child;
				} else if (child is FBXAnimationCurveNode) {
					_idMap[(child as FBXAnimationCurveNode).id] = child;
				} else if (child is FBXAnimationLayer) {
					_idMap[(child as FBXAnimationLayer).id] = child;
				} else if (child is FBXAnimationStack) {
					_idMap[(child as FBXAnimationStack).id] = child;
				} else if (child is FBXGeometry) {
					var geomerty:FBXGeometry = child as FBXGeometry;
					
					if(meshAssets == null) meshAssets = new Vector.<MeshAsset>();
					var ma:MeshAsset = geomerty.createMeshAsset(transformLRH);
					meshAssets[meshAssets.length] = ma;
					
					_idMap[geomerty.id] = ma;
				} else if (child is FBXModel) {
					var model:FBXModel = child as FBXModel;
					
					var obj:Object3D = model.createObject3D(transformLRH);
					
					if (model.type == FBXNodePropertyValue.LIMB_NODE || model.type == FBXNodePropertyValue.ROOT) {
						if (_boneNames == null) _boneNames = new Vector.<String>();
						_boneNames[_boneNames.length] = obj.name;
						trace(obj.name);
					}
					
					_idMap[model.id] = obj;
				} else {
					var name:String = child.name;
					if (name == FBXNodeName.POSE) {
						_parsePose(child);
					}
				}
			}
		}
		private var _poses:Vector.<FBXNode>;
		private function _parsePose(node:FBXNode):void {
			if (_poses == null) _poses = new Vector.<FBXNode>();
			_poses[_poses.length] = node;
			
			/*
			if (node.properties.length > 0) {
				_idMap[node.properties[0].numberValue] = node;
			}
			
			var len:uint = node.children.length;
			for (var i:uint = 0; i < len; i++) {
				var child:FBXNode = node.children[i];
				var name:String = child.name;
				if (name == FBXNodeName.POSE_NODE) {
					_parsePoseNode(child);
				}
			}
			*/
		}
		/*
		private function _parsePoseNode(node:FBXNode):void {
			var len:uint = node.children.length;
			for (var i:uint = 0; i < len; i++) {
				var child:FBXNode = node.children[i];
				var name:String = child.name;
				if (name == FBXNodeName.NODE) {
					if (child.properties.length > 0) {
						_idMap[child.properties[0].numberValue] = node;
					}
				}
			}
		}
		*/
		private function _parseConnections(node:FBXNode, transformLRH:Boolean):void {
			entityAsset = new EntityAsset();
			entityAsset.rootEntities = new Vector.<Object3D>();
			entityAsset.entities = new Vector.<Object3D>();
			
			var numRootEntities:uint = 0;
			var numEntities:uint = 0;
			
			var mapping:Object = {};
			var values:Vector.<FBXSubConnection>;
			
			var numDeformers:uint = 0;
			var deformers:Array = [];
			
			var boneByDeformerMapping:Object = {};
			var poseByBoneMapping:Object = {};
			
			var len:uint = node.children.length;
			for (var i:uint = 0; i < len; i++) {
				var child:FBXSubConnection = node.children[i] as FBXSubConnection;
				if (child != null) {
					values = mapping[child.currentID];
					if (values == null) {
						values = new Vector.<FBXSubConnection>();
						mapping[child.currentID] = values;
					}
					values[values.length] = child;
				}
			}
			
			for (var curID:Number in mapping) {
				var cur:* = _idMap[curID];
				
				values = mapping[curID];
				len = values.length;
				for (i = 0; i < len; i++) {
					var mappingNode:FBXSubConnection = values[i];
					
					var parent:* = _idMap[mappingNode.parentID];
					
					if (cur is Object3D) {
						if (mappingNode.parentID == 0) {
							entityAsset.rootEntities[numRootEntities++] = cur;
							entityAsset.entities[numEntities++] = cur;
						} else if (parent is Object3D) {
							(parent as Object3D).addChild(cur);
							entityAsset.entities[numEntities++] = cur;
						} else if (parent is FBXNode) {
							if (parent is FBXDeformer && (parent as FBXDeformer).indices != null) {
								boneByDeformerMapping[(parent as FBXDeformer).id] = cur;
							} else {
								_trace(mappingNode, cur, parent);
							}
						} else {
							_trace(mappingNode, cur, parent);
						}
					} else if (cur is MeshAsset) {
						if (parent is Object3D) {
							cur.name = parent.name;
							if (cur.name in _meshNames) cur.name += '_' + (++_meshNameIndex);
							_meshNames[cur.name] = true;
							
							var mesh:MeshRenderable = new MeshRenderable();
							mesh.meshAsset = cur;
							//var m:Matrix4x4 = (parent as Object3D).getLocalMatrix();
							//(cur as MeshAsset).getElement(MeshElementType.VERTEX).values = m.transform3x4Vector3((cur as MeshAsset).getElement(MeshElementType.VERTEX).values);
							(parent as Object3D).renderable  = mesh;
						} else {
							_trace(mappingNode, cur, parent);
						}
					} else if (cur is FBXNode) {
						if (cur is FBXDeformer) {
							if ((cur as FBXDeformer).indices == null) {
								_trace(mappingNode, cur, parent);
							} else {
								parent = _searchParent(mapping, MeshAsset, mappingNode);
								
								if (parent != null) {
									deformers[numDeformers++] = cur;
									deformers[numDeformers++] = parent;
								}
							}
						} else if (cur is FBXAnimationCurve) {
							_setAnimation(cur, mapping, mappingNode);
						} else {
							_trace(mappingNode, cur, parent);
						}
					} else {
						_trace(mappingNode, cur, parent);
					}
				}
			}
			
			_setPose(poseByBoneMapping);
			
			for (i = 0; i < numDeformers; i += 2) {
				_setSkinnnedMeshAsset(deformers[i], deformers[int(i + 1)], boneByDeformerMapping, poseByBoneMapping, transformLRH);
			}
			
			_setSkeletonAnimationAsset(transformLRH);
		}
		private function _searchParent(mapping:Object, type:*, mappingNode:FBXSubConnection, returnMappingNode:Boolean=false):* {
			var parent:* = _idMap[mappingNode.parentID];
			
			if (parent is type) {
				if (returnMappingNode) return mappingNode;
				return parent;
			} else {
				var values:Vector.<FBXSubConnection> = mapping[mappingNode.parentID];
				if (values == null) {
					return null;
				} else {
					var len:uint = values.length;
					for (var i:uint = 0; i < len; i++) {
						mappingNode = values[i];
						parent = _searchParent(mapping, type, mappingNode);
						if (parent is type) {
							if (returnMappingNode) return mappingNode;
							return parent;
						}
					}
					
					return null;
				}
			}
		}
		private function _setAnimation(curve:FBXAnimationCurve, mapping:Object, mappingNode:FBXSubConnection):void {
			if (_animFrames == null) _animFrames = new Vector.<FBXAnimationFrame>();
			
			var curveNodeMappingNode:FBXSubConnection = _searchParent(mapping, FBXAnimationCurveNode, mappingNode, true);
			var stack:FBXAnimationStack = _searchParent(mapping, FBXAnimationStack, curveNodeMappingNode);
			var bone:Object3D = _searchParent(mapping, Object3D, curveNodeMappingNode);
			var boneMappingNode:FBXSubConnection = _searchParent(mapping, Object3D, curveNodeMappingNode, true);
			
			var len:uint = curve.keyTime.length;
			for (var i:uint = 0; i < len; i++) {
				var time:Number = curve.keyTime[i] / FBXTime.SECOND;
				
				var curFrame:FBXAnimationFrame = null;
				
				var len2:uint = _animFrames.length;
				for (var j:uint = 0; j < len2; j++) {
					var frame:FBXAnimationFrame = _animFrames[j];
					if (time < frame.time) {
						curFrame = new FBXAnimationFrame();
						curFrame.time = time;
						_animFrames.splice(j, 0, curFrame);
						
						break;
					} else if (time == frame.time) {
						curFrame = frame;
						
						break;
					}
				}
				
				if (curFrame == null) {
					curFrame = new FBXAnimationFrame();
					curFrame.time = time;
					_animFrames[len2] = curFrame;
				}
				
				var frameData:FBXAnimationFrameData = curFrame.bones[bone.name];
				if (frameData == null) {
					frameData = new FBXAnimationFrameData();
					curFrame.bones[bone.name] = frameData;
				}
				
				var f3:Float3 = null;
				switch (boneMappingNode.param) {
					case FBXNodePropertyValue.LCL_TRANSLATION :
						f3 = frameData.position;
						if (f3 == null) {
							f3 = new Float3();
							frameData.position = f3;
						}
						break;
					case FBXNodePropertyValue.LCL_ROTATION :
						f3 = frameData.rotationXYZ;
						if (f3 == null) {
							f3 = new Float3();
							frameData.rotationXYZ = f3;
						}
						break;
					case FBXNodePropertyValue.LCL_SCALING :
						f3 = frameData.scale;
						if (f3 == null) {
							f3 = new Float3(1, 1, 1);
							frameData.scale = f3;
						}
						break;
				}
				
				if (f3 != null) {
					switch (curveNodeMappingNode.param) {
						case FBXNodePropertyValue.DX :
							f3.x = curve.keyValueFloat[i];
							if (boneMappingNode.param == FBXNodePropertyValue.LCL_ROTATION) f3.x *= DEGREES_TO_RADIAN;
							break;
						case FBXNodePropertyValue.DY :
							f3.y = curve.keyValueFloat[i];
							if (boneMappingNode.param == FBXNodePropertyValue.LCL_ROTATION) f3.y *= DEGREES_TO_RADIAN;
							break;
						case FBXNodePropertyValue.DZ :
							f3.z = curve.keyValueFloat[i];
							if (boneMappingNode.param == FBXNodePropertyValue.LCL_ROTATION) f3.z *= DEGREES_TO_RADIAN;
							break;
					}
				}
			}
			
			//trace(curve.keyTime, curveNodeMappingNode.param, boneMappingNode.param);
		}
		private function _setSkeletonAnimationAsset(transformLRH:Boolean):void {
			if (_animFrames != null) {
				if (skeletonAnimationAsset == null) {
					skeletonAnimationAsset = new SkeletonAnimationAsset();
					skeletonAnimationAsset.animationDataByNameMap = {};
				}
				
				var lerpPosition:Float3 = new Float3();
				var lerpRotation:Float4 = new Float4();
				var lerpScale:Float3 = new Float3();
				
				var timeStart:Number = _globalSettings.timeSpanStart;
				var timeStop:Number = _globalSettings.timeSpanStop;
				var numBones:uint = _boneNames.length;
				var numFrames:uint = _animFrames.length;
				var fps:Number = FBXTimeMode.getFramesPreSecond(_globalSettings.timeMode);
				var tpf:Number = 1 / fps;
				var totalFrames:uint = (timeStop - timeStart) * fps;
				
				for (var i:uint = 0; i < numBones; i++) {
					var boneName:String = _boneNames[i];
					
					var position:Float3 = null;
					var rotation:Float3 = null;
					var scale:Float3 = null;
					
					var frame:FBXAnimationFrame;
					var data:FBXAnimationFrameData;
					
					for (var j:uint = 0; j < numFrames; j++) {
						frame = _animFrames[j];
						data = frame.bones[boneName];
						if (data == null) {
							data = new FBXAnimationFrameData();
							frame.bones[boneName] = data;
						}
						
						if (data.position == null) {
							if (position == null) {
								data.position = new Float3();
							} else {
								data.position = position.clone();
							}
						}
						position = data.position;
						
						if (data.rotationXYZ == null) {
							if (rotation == null) {
								data.rotationXYZ = new Float3();
							} else {
								data.rotationXYZ = rotation.clone();
							}
						}
						data.rotationQuat = Float4.createEulerXYZQuaternion(data.rotationXYZ.x, data.rotationXYZ.y, data.rotationXYZ.z);
						rotation = data.rotationXYZ;
						
						if (data.scale == null) {
							if (scale == null) {
								data.scale = new Float3(1, 1, 1);
							} else {
								data.scale = scale.clone();
							}
						}
						scale = data.scale;
					}
					
					var prevFrame:FBXAnimationFrame = null;
					var nextFrame:FBXAnimationFrame = null;
					var prevData:FBXAnimationFrameData;
					var nextData:FBXAnimationFrameData;
					var nextFrameIndex:uint = 0;
					
					var animData:Vector.<SkeletonData> = new Vector.<SkeletonData>(totalFrames);
					skeletonAnimationAsset.animationDataByNameMap[boneName] = animData;
					skeletonAnimationAsset.totalFrames = totalFrames;
					
					for (j = 0; j < totalFrames; j++) {
						var time:Number = tpf * j + timeStart;
						
						if (nextFrame == null || nextFrame.time < time) {
							for (; nextFrameIndex < numFrames; nextFrameIndex++) {
								frame = _animFrames[nextFrameIndex];
								
								if (frame.time <= time) {
									prevFrame = frame;
									prevData = prevFrame.bones[boneName];
								}
								
								if (frame.time >= time) {
									nextFrame = frame;
									nextData = nextFrame.bones[boneName];
									break;
								}
							}
						}
						
						var ratio:Number = prevFrame == nextFrame ? 1 : (time - prevFrame.time) / (nextFrame.time - prevFrame.time);
						
						lerpPosition = Float3.lerp(prevData.position, nextData.position, ratio, lerpPosition);
						lerpRotation = Float4.slerpQuaternion(prevData.rotationQuat, nextData.rotationQuat, ratio, lerpRotation);
						lerpScale = Float3.lerp(prevData.scale, nextData.scale, ratio, lerpScale);
						
						var sd:SkeletonData = new SkeletonData();
						if (transformLRH) {
							lerpPosition.transformLRH();
							lerpRotation.transformLRHQuaternion();
							lerpScale.transformLRH();
						}
						sd.local.matrix.setLocationFromFloat3(lerpPosition);
						sd.local.rotation.copyDataFromFloat4(lerpRotation);
						sd.local.scale.copyDataFromFloat3(lerpScale);
						sd.local.updateMatrix();
						
						animData[j] = sd;
					}
				}
			}
		}
		private function _setSkinnnedMeshAsset(deformer:FBXDeformer, ma:MeshAsset, boneByDeformerMapping:Object, poseByBoneMapping:Object, transformLRH:Boolean):void {
			var index:int = meshAssets.indexOf(ma);
			if (index != -1) {
				if (skinnedMeshAssets == null) skinnedMeshAssets = {};
				var sma:SkinnedMeshAsset = skinnedMeshAssets[index];
				if (sma == null) {
					sma = new SkinnedMeshAsset();
					skinnedMeshAssets[ma.name] = sma;
					sma.boneNames = new Vector.<String>();
					sma.preOffsetMatrices = {};
					sma.postOffsetMatrices = {};
					sma.skinnedVertices = new Vector.<SkinnedVertex>(ma.getElement(MeshElementType.VERTEX).values.length / 3);
				}
				
				var bone:Object3D = boneByDeformerMapping[deformer.properties[0].numberValue];
				var boneIndex:int = sma.boneNames.indexOf(bone.name);
				if (boneIndex == -1) {
					boneIndex = sma.boneNames.length;
					sma.boneNames[boneIndex] = bone.name;
					
					var om1:Matrix4x4 = Matrix4x4.invert(deformer.transformMatrix);
					var om:Matrix4x4 = Matrix4x4.invert(deformer.transformLinkMatrix);
					om.append4x4(deformer.transformMatrix);
					if (transformLRH) {
						om.transformLRH();
						om1.transformLRH();
					}
					sma.preOffsetMatrices[bone.name] = om1;
					sma.postOffsetMatrices[bone.name] = om;
					
					/*
					var pose:FBXNode = poseByBoneMapping[bone.name];
					var matrixNode:FBXNode = pose.getNode(FBXNodeName.MATRIX);
					var om:Matrix4x4 = new Matrix4x4();
					om.copyDataFromVector(matrixNode.properties[0].arrayNumberValue);
					if (transformLRH) om.transformLRH();
					sma.offsetMatrices[boneIndex] = om;
					*/
				}
				
				var length:uint = deformer.indices.length;
				for (var i:uint = 0; i < length; i++) {
					index = deformer.indices[i];
					
					var svd:SkinnedVertex = sma.skinnedVertices[index];
					if (svd == null) {
						svd = new SkinnedVertex();
						svd.boneNameIndices = new Vector.<uint>();
						svd.weights = new Vector.<Number>();
						sma.skinnedVertices[index] = svd;
					}
					
					index = svd.boneNameIndices.length;
					
					svd.boneNameIndices[index] = boneIndex;
					svd.weights[index] = deformer.weights[i];
				}
			}
		}
		private function _setPose(poseByBoneMapping:Object):void {
			if (_poses != null) {
				var len:uint = _poses.length;
				for (var i:uint = 0; i < len; i++) {
					var node:FBXNode = _poses[i];
					var len1:uint = node.children.length;
					for (var j:uint = 0; j < len1; j++) {
						var child:FBXNode = node.children[j];
						var name:String = child.name;
						if (name == FBXNodeName.POSE_NODE) {
							if (child.hasNode(FBXNodeName.NODE)) {
								var grandson:FBXNode = child.getNode(FBXNodeName.NODE);
								if (grandson.properties.length > 0) {
									var target:* = _idMap[grandson.properties[0].numberValue];
									if (target is Object3D) {
										poseByBoneMapping[(target as Object3D).name] = child;
									}
								}
							}
						}
					}
				}
			}
		}
		private function _trace(mappingNode:FBXSubConnection, cur:*, parent:*):void {
			//trace(mappingNode.currentID, mappingNode.parentID, _traceElement(cur), _traceElement(parent), mappingNode.param);
		}
		private function _traceElement(target:*):String {
			if (target is FBXNode) {
				target = (target as FBXNode).name;
			} else if (target is Object3D) {
				target = 'Object3D[' + (target as Object3D).name + ']';
			}
			
			return target;
		}
		private function _decodeNode(bytes:ByteArray, parentNode:FBXNode):void {
			var endOffset:uint = bytes.readUnsignedInt();
			var numProperties:uint = bytes.readUnsignedInt();
			var propertyListLen:uint = bytes.readUnsignedInt();
			var nameLen:uint = bytes.readUnsignedByte();
			var name:String = bytes.readUTFBytes(nameLen);;
			
			var node:FBXNode;
			switch (name) {
				case FBXNodeName.GLOBAL_SETTINGS :
					node = new FBXGlobalSettings();
					break;
				case FBXNodeName.GEOMETRY :
					node = new FBXGeometry();
					break;
				case FBXNodeName.MODEL :
					node = new FBXModel();
					break;
				case FBXNodeName.DEFORMER :
					node = new FBXDeformer();
					break;
				case FBXNodeName.C :
					node = new FBXSubConnection();
					break;
				case FBXNodeName.ANIMATION_CURVE :
					node = new FBXAnimationCurve();
					break;
				case FBXNodeName.ANIMATION_CURVE_NODE :
					node = new FBXAnimationCurveNode();
					break;
				case FBXNodeName.ANIMATION_LAYER :
					node = new FBXAnimationLayer();
					break;
				case FBXNodeName.ANIMATION_STACK :
					node = new FBXAnimationStack();
					break;
				default :
					node = new FBXNode();
					node.name = name;
					break;
			}
			
			parentNode.children[parentNode.children.length] = node;
			
			var startPos:uint = bytes.position;
			
			for (var i:uint = 0; i < numProperties; i++) {
				var nodeProperty:FBXNodeProperty = new FBXNodeProperty();
				
				var propertyType:uint = bytes.readUnsignedByte();
				node.properties[i] = nodeProperty;
				
				if (propertyType == 0x59) {//Y
					nodeProperty.type = FBXNodePropertyValueType.INT_PROPERTY;
					nodeProperty.intValue = bytes.readShort();
				} else if (propertyType == 0x43) {//C (0 or 1)
					nodeProperty.type = FBXNodePropertyValueType.INT_PROPERTY;
					nodeProperty.intValue = bytes.readUnsignedByte();
				} else if (propertyType == 0x49) {//I
					nodeProperty.type = FBXNodePropertyValueType.INT_PROPERTY;
					nodeProperty.intValue = bytes.readInt();
				} else if (propertyType == 0x46) {//F
					nodeProperty.type = FBXNodePropertyValueType.NUMBER_PROPERTY;
					nodeProperty.numberValue = bytes.readFloat();
				} else if (propertyType == 0x44) {//D
					nodeProperty.type = FBXNodePropertyValueType.NUMBER_PROPERTY;
					nodeProperty.numberValue = bytes.readDouble();
				} else if (propertyType == 0x4C) {//L long
					nodeProperty.type = FBXNodePropertyValueType.NUMBER_PROPERTY;
					
					var low:uint = bytes.readUnsignedInt();
					var high:uint = bytes.readUnsignedInt();
					
					nodeProperty.numberValue = NumberLong.getValue(high, low);
				} else if (propertyType == 0x53) {//S
					var strLen:uint = bytes.readUnsignedInt();
					
					nodeProperty.type = FBXNodePropertyValueType.STRING_PROPERTY;
					nodeProperty.stringValue = bytes.readUTFBytes(strLen);
				} else if (propertyType == 0x66 || propertyType == 0x64  || propertyType == 0x6C || propertyType == 0x69  || propertyType == 0x62) {//f d l i b
					var arrLen:uint = bytes.readUnsignedInt();
					var encoding:uint = bytes.readUnsignedInt();
					var compressedLength:uint = bytes.readUnsignedInt();
					
					var uncompressedData:ByteArray;
					
					if (encoding == 0) {
						uncompressedData = bytes;
					} else if (encoding == 1) {
						var temp:ByteArray = new ByteArray();
						temp.endian = Endian.LITTLE_ENDIAN;
						bytes.readBytes(temp, 0, compressedLength);
						temp.uncompress();
						uncompressedData = temp;
					} else {
						throw new Error();
					}
					
					if (propertyType == 0x66 || propertyType == 0x64) {
						nodeProperty.type = FBXNodePropertyValueType.ARRAY_NUMBER_PROPERTY;
						nodeProperty.arrayNumberValue = new Vector.<Number>(arrLen);
					} else if (propertyType == 0x6C) {//long
						nodeProperty.type = FBXNodePropertyValueType.ARRAY_NUMBER_PROPERTY;
						nodeProperty.arrayNumberValue = new Vector.<Number>(arrLen);
					} else {//(0 or 1)
						nodeProperty.type = FBXNodePropertyValueType.ARRAY_INT_PROPERTY;
						nodeProperty.arrayIntValue = new Vector.<int>(arrLen);
					}
					
					for (var j:uint = 0; j < arrLen; j++) {
						if (propertyType == 0x66) {
							nodeProperty.arrayNumberValue[j] = uncompressedData.readFloat();
						} else if (propertyType == 0x64) {
							nodeProperty.arrayNumberValue[j] = uncompressedData.readDouble();
						} else if (propertyType == 0x6C) {//long
							var arrLow:uint = uncompressedData.readUnsignedInt();
							var arrHigh:uint = uncompressedData.readUnsignedInt();
							
							nodeProperty.arrayNumberValue[j] = NumberLong.getValue(arrHigh, arrLow);
						} else if (propertyType == 0x69) {
							nodeProperty.arrayIntValue[j] = uncompressedData.readInt();
						} else {//(0 or 1)
							nodeProperty.arrayIntValue[j] = uncompressedData.readUnsignedByte();
						}
					}
				}
				
				nodeProperty.update();
			}
			
			bytes.position = startPos + propertyListLen;
			
			while (true) {
				if (bytes.position < endOffset) {
					_decodeNode(bytes, node);
				} else {
					break;
				}
			}
			
			node.update();
		}
	}
}