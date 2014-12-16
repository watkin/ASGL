package asgl.codec.models.directx {
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
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
	import asgl.geometries.MeshHelper;
	import asgl.materials.MaterialAsset;
	import asgl.materials.TextureAsset;
	import asgl.math.Matrix4x4;

	public class DirectXBinaryDecoder {
		private static var _tempMatrix:Matrix4x4 = new Matrix4x4();
		
		public var skeletonAnimationAsset:SkeletonAnimationAsset;
		public var entityAsset:EntityAsset;
		public var skinnedMeshAssets:Object;
		public var meshAssets:Vector.<MeshAsset>;
		public var materialAssets:Object;
		
		private var _transformLRH:Boolean;
		private var _floatSize:uint;
		private var _nameIndex:uint;
		private var _names:Object;
		
		public function DirectXBinaryDecoder(bytes:ByteArray=null, transformLRH:Boolean=false) {
			if (bytes == null) {
				clear();
			} else {
				decode(bytes, transformLRH);
			}
		}
		public function clear():void {
			skeletonAnimationAsset = null;
			entityAsset = null;
			skinnedMeshAssets = null;
			meshAssets = null;
			_nameIndex = 0;
			_names = {};
		}
		public function decode(bytes:ByteArray, transformLRH:Boolean=false):void {
			clear();
			
			_names = {};
			_transformLRH = transformLRH;
			
			bytes.endian = Endian.LITTLE_ENDIAN;
			bytes.position = 8;
			var format:String = bytes.readUTFBytes(4);
			if (format == DirectXFormatType.BINARY) {
				_floatSize = (bytes[12] - 48) * 1000 + (bytes[13] - 48) * 100 + (bytes[14] - 48) * 10 + (bytes[15] - 48);
				
				while (bytes.bytesAvailable > 1) {
					var token:DirectXToken = _getNextToken(bytes);
					switch (token.value) {
						case DirectXTokenNameType.TEMPLATE :
							_parseTemplate(bytes);
							break;
						case DirectXTokenNameType.FRAME :
							if (entityAsset == null) {
								entityAsset = new EntityAsset();
								entityAsset.rootEntities = new Vector.<Object3D>();
								entityAsset.entities = new Vector.<Object3D>();
							}
							
							_parseFrame(bytes, null);
							break;
						case DirectXTokenNameType.MATERIAL :
							_parseMaterial(bytes);
							break;
						case DirectXTokenNameType.ANIMATION_SET :
							_parseAnimationSet(bytes);
							break;
						case DirectXTokenNameType.ANIM_TICKS_PRE_SECOND :
							_parseAnimTicksPerSecond(bytes);
							break;
						default :
							trace('root', token.type, token.value);
							_parseUnknownData(bytes);
							break;
					}
				}
			}
		}
		private function _parseMaterial(bytes:ByteArray):void {
			var name:String = _readHead(bytes);
			
			if (materialAssets == null) materialAssets = {};
			
			var ma:MaterialAsset = new MaterialAsset();
			ma.name = name;
			ma.textureAssets = new Vector.<TextureAsset>();
			materialAssets[name] = ma;
			
			var valueToken:DirectXToken = _getNextToken(bytes);//diffuse rgba, specularExponent, specular rgb, emissive rgb
			
			var running:Boolean = true;
			while (running) {
				var token:DirectXToken = _getNextToken(bytes);
				switch (token.value) {
					case DirectXTokenNameType.CBRACE :
						running = false;
						break;
					case DirectXTokenNameType.TEXTURE_FILE_NAME :
						_parseTextureFileName(bytes, ma);
						break;
					default :
						trace('material', token.type, token.value);
						_parseUnknownData(bytes);
						break;
				}
			}
		}
		private function _parseTextureFileName(bytes:ByteArray, ma:MaterialAsset):void {
			var name:String = _readHead(bytes);
			
			var nameToken:DirectXToken = _getNextToken(bytes);
			
			var ta:TextureAsset = new TextureAsset();
			ta.name = nameToken.value;
			ma.textureAssets[ma.textureAssets.length] = ta;
			
			_checkForClosingBrace(bytes);
		}
		private function _parseFrame(bytes:ByteArray, parent:Object3D):void {
			var name:String = _readHead(bytes);
			
			var obj:Object3D;
			obj = new Object3D();
			obj.name = name;
			if (parent != null) parent.addChild(obj);
			
			if (parent == null) entityAsset.rootEntities[entityAsset.rootEntities.length] = obj;
			entityAsset.entities[entityAsset.entities.length] = obj;
			
			var running:Boolean = true;
			while (running) {
				var token:DirectXToken = _getNextToken(bytes);
				switch (token.value) {
					case DirectXTokenNameType.CBRACE :
						running = false;
						break;
					case DirectXTokenNameType.FRAME :
						_parseFrame(bytes, obj);
						break;
					case DirectXTokenNameType.FRAME_TRANSFORM_MATRIX :
						_parseFrameTransformMatrix(bytes, obj);
						break;
					case DirectXTokenNameType.MESH :
						_parseMesh(bytes, obj);
						break;
					default :
						trace('frame', token.type, token.value);
						_parseUnknownData(bytes);
						break;
				}
			}
		}
		private function _parseAnimation(bytes:ByteArray):void {
			var name:String = _readHead(bytes);
			
			var boneName:String;
			
			var running:Boolean = true;
			while (running) {
				var token:DirectXToken = _getNextToken(bytes);
				switch (token.value) {
					case DirectXTokenNameType.OBRACE :
						var boneNameToken:DirectXToken = _getNextToken(bytes);
						
						boneName = boneNameToken.value;
						
						_checkForClosingBrace(bytes);
						break;
					case DirectXTokenNameType.CBRACE :
						running = false;
						break;
					case DirectXTokenNameType.ANIMATION_KEY :
						_parseAnimationKey(bytes, boneName);
						break;
					default :
						trace('animation', token.type, token.value);
						_parseUnknownData(bytes);
						break;
				}
			}
		}
		private function _parseAnimationKey(bytes:ByteArray, boneName:String):void {
			var name:String = _readHead(bytes);
			
			var keyToken:DirectXToken = _getNextToken(bytes);
			
			var numKeys:uint = keyToken.value[1];
			
			keyToken.value = keyToken.value.slice(2, 4);
			
			var anims:Vector.<SkeletonData> = new Vector.<SkeletonData>(numKeys);
			var times:Vector.<Number> = new Vector.<Number>();
			
			skeletonAnimationAsset.animationDataByNameMap[boneName] = anims;
			skeletonAnimationAsset.animationTimesByNameMap[boneName] = times;
			if (skeletonAnimationAsset.totalFrames < numKeys) skeletonAnimationAsset.totalFrames = numKeys;
			
			for (var i:uint = 0; i < numKeys;) {
				var time:uint = keyToken.value[0];
				
				var animValueToken:DirectXToken = _getNextToken(bytes);
				
				var sd:SkeletonData = new SkeletonData();
				sd.local.matrix.copyDataFromVector(animValueToken.value);
				
				if (_transformLRH) sd.local.matrix.transformLRH();
				
				sd.local.updateTRS();
				
				anims[i] = sd;
				times[i] = time;
				
				i++;
				if (i < numKeys) {
					keyToken = _getNextToken(bytes);
				}
			}
			
			_checkForClosingBrace(bytes);
		}
		private function _parseAnimationSet(bytes:ByteArray):void {
			var name:String = _readHead(bytes);
			
			if (skeletonAnimationAsset == null) {
				skeletonAnimationAsset = new SkeletonAnimationAsset();
				skeletonAnimationAsset.name = name;
				skeletonAnimationAsset.animationDataByNameMap = {};
				skeletonAnimationAsset.animationTimesByNameMap = {};
			}
			
			var running:Boolean = true;
			while (running) {
				var token:DirectXToken = _getNextToken(bytes);
				switch (token.value) {
					case DirectXTokenNameType.CBRACE :
						running = false;
						break;
					case DirectXTokenNameType.ANIMATION :
						_parseAnimation(bytes);
						break;
					default :
						trace('animationSet', token.type, token.value);
						_parseUnknownData(bytes);
						break;
				}
			}
		}
		private function _parseAnimTicksPerSecond(bytes:ByteArray):void {
			var name:String = _readHead(bytes);
			
			var tk:DirectXToken = _getNextToken(bytes);
			
			_checkForClosingBrace(bytes);
		}
		private function _parseMesh(bytes:ByteArray, obj:Object3D):void {
			var name:String = _readHead(bytes);
			
			var ma:MeshAsset = new MeshAsset();
			if (meshAssets == null) meshAssets = new Vector.<MeshAsset>();
			meshAssets[meshAssets.length] = ma;
			
			if (obj != null) ma.name = obj.name;
			if (ma.name in _names) ma.name += '_' + (++_nameIndex);
			_names[ma.name] = true;
			
			var numToken:DirectXToken = _getNextToken(bytes);
			var valuesToken:DirectXToken = _getNextToken(bytes);
			var indicesToken:DirectXToken = _getNextToken(bytes);
			
			var numVertices:uint;
			if (numToken.type == DirectXTokenType.INTEGER_LIST) {
				numVertices = numToken.value[0]
			}
			
			var vertexElement:MeshElement = new MeshElement();
			vertexElement.numDataPreElement = 3;
			vertexElement.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
			vertexElement.values = valuesToken.value;
			ma.elements[MeshElementType.VERTEX] = vertexElement;
			
			vertexElement.values = valuesToken.value;
			
			var indices:Vector.<uint> = indicesToken.value;
			var numTriangleIndex:uint = indices[0];
			ma.triangleIndices = new Vector.<uint>(numTriangleIndex * 3);
			var index0:uint = 0;
			var index1:uint = 2;
			for (var i:uint = 0; i < numTriangleIndex; i++) {
				ma.triangleIndices[index0++] = indices[index1++];
				ma.triangleIndices[index0++] = indices[index1++];
				ma.triangleIndices[index0++] = indices[index1];
				index1 += 2;
			}
			
			if (_transformLRH) {
				vertexElement.transformLRH();
				MeshHelper.triangleIndicesTransformLRH(ma.triangleIndices);
			}
			
			var running:Boolean = true;
			while (running) {
				var token:DirectXToken = _getNextToken(bytes);
				switch (token.value) {
					case DirectXTokenNameType.CBRACE :
						running = false;
						break;
					case DirectXTokenNameType.MESH_TEXTURE_COORDS :
						_parseMeshTextureCoords(bytes, ma);
						break;
					case DirectXTokenNameType.XSKIN_MESH_HEADER :
						_parseSkinMeshHeader(bytes);
						break;
					case DirectXTokenNameType.SKIN_WEIGHTS :
						_parseSkinWeights(bytes, ma);
						break;
					case DirectXTokenNameType.MESH_MATERIAL_LIST :
						_parseMeshMaterialList(bytes, ma);
						break;
					default :
						trace('mesh', token.type, token.value);
						_parseUnknownData(bytes);
						break;
				}
			}
		}
		private function _parseMeshMaterialList(bytes:ByteArray, ma:MeshAsset):void {
			var name:String = _readHead(bytes);
			
			var indexToken:DirectXToken = _getNextToken(bytes);
			var index:Vector.<uint> = indexToken.value;
			var numUseMaterial:uint = index[0];
			var numFaces:uint = index[1];
			index = index.slice(2);
			
			var running:Boolean = true;
			while (running) {
				var token:DirectXToken = _getNextToken(bytes);
				switch (token.value) {
					case DirectXTokenNameType.OBRACE :
						var nameToken:DirectXToken = _getNextToken(bytes);
						
						if (ma.materialIndicesMap == null) ma.materialIndicesMap = {};
						ma.materialIndicesMap[nameToken.value] = index;
						
						_checkForClosingBrace(bytes);
						break;
					case DirectXTokenNameType.CBRACE :
						running = false;
						break;
					case DirectXTokenNameType.MATERIAL :
						_parseMaterial(bytes);
						break;
					default :
						trace('meshMaterialList', token.type, token.value);
						_parseUnknownData(bytes);
						break;
				}
			}
		}
		private function _parseSkinWeights(bytes:ByteArray, ma:MeshAsset):void {
			var name:String = _readHead(bytes);
			
			if (skinnedMeshAssets == null) skinnedMeshAssets = {};
			var sma:SkinnedMeshAsset = skinnedMeshAssets[ma.name];
			if (sma == null) {
				sma = new SkinnedMeshAsset();
				skinnedMeshAssets[ma.name] = sma;
				sma.boneNames = new Vector.<String>();
				sma.preOffsetMatrices = {};
				sma.skinnedVertices = new Vector.<SkinnedVertex>(ma.getElement(MeshElementType.VERTEX).values.length / 3);
			}
			
			var boneNameToken:DirectXToken = _getNextToken(bytes);
			var indicesToken:DirectXToken = _getNextToken(bytes);
			var weightsToken:DirectXToken = _getNextToken(bytes);
			
			var indices:Vector.<uint> = indicesToken.value;
			var num:uint = indices.shift();
			
			var weights:Vector.<Number> = weightsToken.value;
			
			var boneIndex:uint = sma.boneNames.length;
			sma.boneNames[boneIndex] = boneNameToken.value;
			var m:Matrix4x4 = new Matrix4x4();
			m.copyDataFromVector(weights.slice(weights.length - 16));
			
			if (_transformLRH) m.transformLRH();
			
			sma.preOffsetMatrices[boneNameToken.value] = m;
			
			for (var i:uint = 0; i < num; i++) {
				var index:uint = indices[i];
				var sv:SkinnedVertex = sma.skinnedVertices[index];
				if (sv == null) {
					sv = new SkinnedVertex();
					sv.boneNameIndices = new Vector.<uint>();
					sv.weights = new Vector.<Number>();
					sma.skinnedVertices[index] = sv;
				}
				
				index = sv.boneNameIndices.length;
				
				sv.boneNameIndices[index] = boneIndex;
				sv.weights[index] = weights[i];
			}
			
			_checkForClosingBrace(bytes);
		}
		private function _parseSkinMeshHeader(bytes:ByteArray):void {
			var name:String = _readHead(bytes);
			
			var headToken:DirectXToken = _getNextToken(bytes);
			
			_checkForClosingBrace(bytes);
		}
		private function _parseMeshTextureCoords(bytes:ByteArray, ma:MeshAsset):void {
			var name:String = _readHead(bytes);
			
			var numToken:DirectXToken = _getNextToken(bytes);
			var valuesToken:DirectXToken = _getNextToken(bytes);
			
			var numTexCoords:uint;
			if (numToken.type == DirectXTokenType.INTEGER_LIST) {
				numTexCoords = numToken.value[0]
			}
			
			var texCoordElement:MeshElement = new MeshElement();
			texCoordElement.numDataPreElement = 2;
			texCoordElement.valueMappingType = MeshElementValueMappingType.TRIANGLE_INDEX;
			texCoordElement.values = valuesToken.value;
			ma.elements[MeshElementType.TEXCOORD] = texCoordElement;
			
			texCoordElement.values = valuesToken.value;
			
			_checkForClosingBrace(bytes);
		}
		private function _parseFrameTransformMatrix(bytes:ByteArray, obj:Object3D):void {
			_readHead(bytes);
			
			var token:DirectXToken = _getNextToken(bytes);
			
			if (token.type == DirectXTokenType.FLOAT_LIST) {
				if (obj != null) {
					_tempMatrix.copyDataFromVector(token.value);
					if (_transformLRH) _tempMatrix.transformLRH();
					obj.setLocalMatrix(_tempMatrix);
				}
			}
			
			_checkForClosingBrace(bytes);
		}
		private function _parseTemplate(bytes:ByteArray):void {
			while (_getNextToken(bytes).type != DirectXTokenType.CBRACE) {
			}
		}
		private function _parseUnknownData(bytes:ByteArray):void {
			while (_getNextToken(bytes).type != DirectXTokenType.OBRACE) {
			}
			
			var count:uint = 1;
			
			while (count > 0) {
				var token:DirectXToken = _getNextToken(bytes);
				//trace(token);
				if (token.type == DirectXTokenType.OBRACE) {
					count++;
				} else if (token.type == DirectXTokenType.CBRACE) {
					count--;
				}
			}
		}
		private function _getNextToken(bytes:ByteArray):DirectXToken {
			var token:DirectXToken = new DirectXToken();
			
			var value:uint = bytes.readUnsignedShort();
			
			token.type = value;
			
			var i:uint;
			var len:uint;
			//trace(value);
			switch (value) {
				case DirectXTokenType.NAME :
					len = bytes.readUnsignedInt();
					token.value = bytes.readUTFBytes(len);
					break;
				case DirectXTokenType.STRING :
					len = bytes.readUnsignedInt();
					token.value = bytes.readUTFBytes(len);
					bytes.position += 2;
					break;
				case DirectXTokenType.INTEGER :
					token.value = bytes.readInt();
					break;
				case DirectXTokenType.GUID :
					token.value = bytes.readUTFBytes(16);
					break;
				case DirectXTokenType.INTEGER_LIST :
					len = bytes.readUnsignedInt();
					var uintValues:Vector.<uint> = new Vector.<uint>();
					token.value = uintValues;
					for (i = 0; i < len; i++) {
						uintValues[i] = bytes.readUnsignedInt();
					}
					break;
				case DirectXTokenType.FLOAT_LIST :
					len = bytes.readUnsignedInt();
					var floatValues:Vector.<Number> = new Vector.<Number>();
					token.value = floatValues;
					for (i = 0; i < len; i++) {
						floatValues[i] = _readFloat(bytes);
					}
					break;
				case DirectXTokenType.OBRACE :
					token.value = DirectXTokenNameType.OBRACE;
					break;
				case DirectXTokenType.CBRACE :
					token.value = DirectXTokenNameType.CBRACE;
					break;
				case DirectXTokenType.TEMPLATE :
					token.value = DirectXTokenNameType.TEMPLATE;
					break;
			}
			
			return token;
		}
		private function _checkForClosingBrace(bytes:ByteArray):void {
			if (_getNextToken(bytes).type != DirectXTokenType.CBRACE) {
				trace();
			}
		}
		private function _readFloat(bytes:ByteArray):Number {
			if (_floatSize == 32) {
				return bytes.readFloat();
			} else if (_floatSize == 64) {
				return bytes.readDouble();
			} else {
				bytes.position += _floatSize / 8;
				return NaN;
			}
		}
		private function _readHead(bytes:ByteArray):String {
			var name:String;
			
			var token:DirectXToken = _getNextToken(bytes);
			if (token.type != DirectXTokenType.OBRACE) {
				name = token.value;
				token = _getNextToken(bytes);
				if (token.type != DirectXTokenType.OBRACE) {
					trace();
				}
			}
			
			return name;
		}
	}
}