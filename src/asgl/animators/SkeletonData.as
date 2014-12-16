package asgl.animators {
	import asgl.entities.SimpleCoordinates3D;

	public class SkeletonData {
		public var local:SimpleCoordinates3D;
		public var global:SimpleCoordinates3D;
		
		public function SkeletonData() {
			local = new SimpleCoordinates3D();
			global = new SimpleCoordinates3D();
		}
		public function copy(sd:SkeletonData):void {
			local.copy(sd.local);
			global.copy(sd.global);
		}
		public static function slerp(sd1:SkeletonData, sd2:SkeletonData, t:Number, op:SkeletonData=null):SkeletonData {
			op ||= new SkeletonData();
			
			SimpleCoordinates3D.slerp(sd1.local, sd2.local, t, op.local);
			SimpleCoordinates3D.slerp(sd1.global, sd2.global, t, op.global);
			
			return op;
		}
	}
}