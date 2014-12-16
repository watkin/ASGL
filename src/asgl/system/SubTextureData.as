package asgl.system {
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	import asgl.asgl_protected;
	import asgl.events.ASGLEvent;
	import asgl.materials.TextureAsset;
	
	use namespace asgl_protected;

	public class SubTextureData extends AbstractTextureData {
		public function SubTextureData(device:Device3D, format:String, optimizeForRenderToTexture:Boolean, streamingLevels:int, root:AbstractTextureData) {
			super(device, format, optimizeForRenderToTexture, streamingLevels);
			
			_root = root;
			
			_width = _root.width;
			_height = _root.height;
			
			_rootInstancID = _root._instanceID;
			_texture = _root._texture;
			
			_root.addEventListener(ASGLEvent.DISPOSE, _disposeHandler, false, 0, true);
		}
		public override function createSub(region:Rectangle=null):SubTextureData {
			var tex:SubTextureData = new SubTextureData(_device, _format, _optimizeForRenderToTexture, _streamingLevels, _root);
			tex._samplerStateData.copySamplerState(_samplerStateData);
			
			if (region == null) {
				tex._region.x = _region.x;
				tex._region.y = _region.y;
				tex._region.width = _region.width;
				tex._region.height = _region.height;
			} else {
				tex._region.x = _region.x + _region.width * region.x;
				tex._region.y = _region.y + _region.height * region.y;
				tex._region.width = _region.width * region.width;
				tex._region.height = _region.height * region.height;
			}
			
			return tex;
		}
		public override function dispose():void {
			if (_device != null) {
				removeEventListener(ASGLEvent.DISPOSE, _disposeHandler);
				
				_device = null;
				_root = null;
				_texture = null;
				
				if (hasEventListener(ASGLEvent.DISPOSE)) dispatchEvent(new ASGLEvent(ASGLEvent.DISPOSE));
			}
		}
		public override function uploadCompressedTextureFromByteArray(data:ByteArray, byteArrayOffset:uint=0, async:Boolean=false):void {
			_root.uploadCompressedTextureFromByteArray(data, byteArrayOffset, async);
		}
		public override function uploadFromBitmapData(source:BitmapData, miplevel:uint=0, side:uint=0):void {
			_root.uploadFromBitmapData(source, miplevel, side);
		}
		public override function uploadFromByteArray(data:ByteArray, byteArrayOffset:uint=0, miplevel:uint=0, side:uint=0):void {
			_root.uploadFromByteArray(data, byteArrayOffset, miplevel, side);
		}
		public override function uploadFromTextureAsset(ta:TextureAsset, async:Boolean=false):Boolean {
			return _root.uploadFromTextureAsset(ta, async);
		}
		public override function uploadMipmapFromBitmapData(source:BitmapData, side:uint=0):void {
			_root.uploadMipmapFromBitmapData(source, side);
		}
		private function _disposeHandler(e:Event):void {
			dispose();
		}
	}
}