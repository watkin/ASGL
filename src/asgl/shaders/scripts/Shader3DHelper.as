package asgl.shaders.scripts {
	import flash.geom.Rectangle;
	
	import asgl.asgl_protected;
	import asgl.effects.BillboardType;
	import asgl.entities.Camera3D;
	import asgl.entities.Coordinates3D;
	import asgl.entities.Coordinates3DHelper;
	import asgl.math.Float4;
	import asgl.math.Matrix4x4;
	
	use namespace asgl_protected;

	public class Shader3DHelper {
		private static var _tempFloat4_1:Float4 = new Float4();
		private static var _tempFloat4_2:Float4 = new Float4();
		private static var _tempFloat4_3:Float4 = new Float4();
		private static var _tempMatrix:Matrix4x4 = new Matrix4x4();
		
		private static var _billboardMatConstants:ShaderConstants = _createShaderConstants(3);
		private static var _localToProjMatConstants:ShaderConstants = _createShaderConstants(4);
		private static var _localToViewMatConstants:ShaderConstants = _createShaderConstants(3);
		private static var _localToWorldMatConstants:ShaderConstants = _createShaderConstants(3);
		private static var _projToViewMatConstants:ShaderConstants = _createShaderConstants(4);
		private static var _projToWorldMatConstants:ShaderConstants = _createShaderConstants(4);
		private static var _diffTexRegionMatConstants:ShaderConstants = _createShaderConstants(1);
		private static var _viewWorldPosConstants:ShaderConstants = _createShaderConstants(1);
		private static var _viewToProjMatConstants:ShaderConstants = _createShaderConstants(4);
		private static var _worldToProjMatConstants:ShaderConstants = _createShaderConstants(4);
		
		public function Shader3DHelper() {
		}
		private static function _createShaderConstants(length:uint):ShaderConstants {
			var sc:ShaderConstants = new ShaderConstants(length);
			sc.values = new Vector.<Number>(length * 4);
			
			return sc;
		}
		public static function setGlobalBillboardMatrix(obj:Coordinates3D, camera:Camera3D, billboardType:int):void {
			if (billboardType == BillboardType.PARALLEL_VIEW_PLANE) {
				var rot:Float4 = Coordinates3DHelper.getBillboardWorldRotationOfParallelToViewPlane(obj, camera, false, _tempFloat4_1);
				var rot2:Float4 = obj.getLocalRotation(_tempFloat4_2);
				rot2.conjugateQuaternion();
				var rot3:Float4 = obj.calculateLocalRotationFromWorldRotation(rot, _tempFloat4_3);
				rot2.multiplyQuaternion(rot3);
				var m:Matrix4x4 = rot2.getMatrixFromQuaternion(_tempMatrix);
				m.toVector3x4(true, _billboardMatConstants.values);
				
				Shader3D.setGlobalConstants(ShaderPropertyType.BILLBOARD_MATRIX, _billboardMatConstants);
			}
		}
		public static function setGlobalLocalToProjMatrix(obj:Coordinates3D, camera:Camera3D):void {
			Coordinates3DHelper.getLocalToProjectionMatrix(obj, camera, _tempMatrix).toVector4x4(true, _localToProjMatConstants.values);
			Shader3D.setGlobalConstants(ShaderPropertyType.LOCAL_TO_PROJ_MATRIX, _localToProjMatConstants);
		}
		public static function setGlobalLocalToViewMatrix(obj:Coordinates3D, camera:Camera3D):void {
			Coordinates3DHelper.getLocalToLocalMatrix(obj, camera, null, null, null, _tempMatrix).toVector3x4(true, _localToViewMatConstants.values);
			Shader3D.setGlobalConstants(ShaderPropertyType.LOCAL_TO_WORLD_MATRIX, _localToViewMatConstants);
		}
		public static function setGlobalLocalToWorldMatrix(obj:Coordinates3D):void {
			obj.updateWorldMatrix();
			obj._worldMatrix.toVector3x4(true, _localToWorldMatConstants.values);
			Shader3D.setGlobalConstants(ShaderPropertyType.LOCAL_TO_WORLD_MATRIX, _localToWorldMatConstants);
		}
		public static function setGlobalProjToViewMatrix(camera:Camera3D):void {
			Matrix4x4.invert(camera._projectionMatrix, _tempMatrix).toVector4x4(true, _projToViewMatConstants.values);
			Shader3D.setGlobalConstants(ShaderPropertyType.PROJ_TO_VIEW_MATRIX, _projToViewMatConstants);
		}
		public static function setGlobalProjToWorldMatrix(camera:Camera3D):void {
			camera.getWorldToProjectionMatrix(_tempMatrix);
			_tempMatrix.invert();
			_tempMatrix.toVector4x4(true, _projToWorldMatConstants.values);
			Shader3D.setGlobalConstants(ShaderPropertyType.PROJ_TO_WORLD_MATRIX, _projToWorldMatConstants);
		}
		public static function setGlobalViewWorldPostion(camera:Coordinates3D):void {
			camera.updateWorldMatrix();
			
			_viewWorldPosConstants.values[0] = camera._worldMatrix.m30;
			_viewWorldPosConstants.values[1] = camera._worldMatrix.m31;
			_viewWorldPosConstants.values[2] = camera._worldMatrix.m32;
			_viewWorldPosConstants.values[3] = camera._worldMatrix.m33;
			Shader3D.setGlobalConstants(ShaderPropertyType.VIEW_WORLD_POSITION, _viewWorldPosConstants);
		}
		public static function setGlobalViewToProjMatrix(camera:Camera3D):void {
			camera._projectionMatrix.toVector4x4(true, _viewToProjMatConstants.values);
			Shader3D.setGlobalConstants(ShaderPropertyType.VIEW_TO_PROJ_MATRIX, _viewToProjMatConstants);
		}
		public static function setGlobalWorldToProjMatrix(camera:Camera3D):void {
			camera.getWorldToProjectionMatrix(_tempMatrix).toVector4x4(true, _worldToProjMatConstants.values);
			Shader3D.setGlobalConstants(ShaderPropertyType.WORLD_TO_PROJ_MATRIX, _worldToProjMatConstants);
		}
		public static function setGlobalForRenderContext(camera:Camera3D):void {
			camera.getWorldToProjectionMatrix(_tempMatrix).toVector4x4(true, _worldToProjMatConstants.values);
			Shader3D.setGlobalConstants(ShaderPropertyType.WORLD_TO_PROJ_MATRIX, _worldToProjMatConstants);
			
			_tempMatrix.invert();
			_tempMatrix.toVector4x4(true, _projToWorldMatConstants.values);
			Shader3D.setGlobalConstants(ShaderPropertyType.PROJ_TO_WORLD_MATRIX, _projToWorldMatConstants);
			
			Matrix4x4.invert(camera._projectionMatrix, _tempMatrix).toVector4x4(true, _projToViewMatConstants.values);
			Shader3D.setGlobalConstants(ShaderPropertyType.PROJ_TO_VIEW_MATRIX, _projToViewMatConstants);
			
			camera._projectionMatrix.toVector4x4(true, _viewToProjMatConstants.values);
			Shader3D.setGlobalConstants(ShaderPropertyType.VIEW_TO_PROJ_MATRIX, _viewToProjMatConstants);
			
			_viewWorldPosConstants.values[0] = camera._worldMatrix.m30;
			_viewWorldPosConstants.values[1] = camera._worldMatrix.m31;
			_viewWorldPosConstants.values[2] = camera._worldMatrix.m32;
			_viewWorldPosConstants.values[3] = camera._worldMatrix.m33;
			Shader3D.setGlobalConstants(ShaderPropertyType.VIEW_WORLD_POSITION, _viewWorldPosConstants);
		}
		public static function clearGlobalForRenderContext():void {
			Shader3D.setGlobalConstants(ShaderPropertyType.PROJ_TO_VIEW_MATRIX, null);
			Shader3D.setGlobalConstants(ShaderPropertyType.PROJ_TO_WORLD_MATRIX, null);
			Shader3D.setGlobalConstants(ShaderPropertyType.VIEW_WORLD_POSITION, null);
			Shader3D.setGlobalConstants(ShaderPropertyType.VIEW_TO_PROJ_MATRIX, null);
			Shader3D.setGlobalConstants(ShaderPropertyType.WORLD_TO_PROJ_MATRIX, null);
		}
		
		public static function setGlobalDiffuseTexRegion(texRegion:Rectangle, renderableRegion:Rectangle):void {
			var regionX:Number = texRegion.x;
			var regionY:Number = texRegion.y;
			var regionWidth:Number = texRegion.width;
			var regionHeight:Number = texRegion.height;
			if (renderableRegion != null) {
				regionX += texRegion.width * renderableRegion.x;
				regionY += texRegion.height * renderableRegion.y;
				regionWidth *= renderableRegion.width;
				regionHeight *= renderableRegion.height;
			}
			
			_diffTexRegionMatConstants.values[0] = regionX;
			_diffTexRegionMatConstants.values[1] = regionY;
			_diffTexRegionMatConstants.values[2] = regionWidth;
			_diffTexRegionMatConstants.values[3] = regionHeight;
			
			Shader3D.setGlobalConstants(ShaderPropertyType.DIFFUSE_TEX_REGION, _diffTexRegionMatConstants);
		}
	}
}