package asgl.pb {
	import asgl.asgl_protected;
	
	import flash.display.ShaderJob;
	
	use namespace asgl_protected;

	public class PBExecuteDataInfo {
		public var prev:PBExecuteDataInfo;
		public var next:PBExecuteDataInfo;
		
		public var id:uint;
		public var executor:PBExecutor;
		public var completeHandler:Function;
		public var data:IPBData;
		public var shaderJob:ShaderJob;
		public function clear(cancel:Boolean):void {
			clearShaderJob(cancel);
			
			executor = null;
			completeHandler = null;
			data = null;
		}
		public function clearShaderJob(cancel:Boolean):void {
			if (shaderJob != null) {
				if (cancel) shaderJob.cancel();
				executor._clearJob(shaderJob);
				shaderJob = null;
			}
		}
		public function run():void {
			executor._runJob(this);
		}
	}
}