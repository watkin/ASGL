package asgl.scenes.culling {
	public interface ICullingObject {
		/**
		 * asgl_protected::_instanceID
		 */
		function get instanceID():uint;
		
		/**
		 * asgl_protected::_frustumCullingVisible
		 */
		function get frustumCullingVisible():Boolean;
		function set frustumCullingVisible(value:Boolean):void;
		function frustumCullingPass():void;
	}
}