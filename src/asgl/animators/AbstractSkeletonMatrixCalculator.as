package asgl.animators {
	import asgl.asgl_protected;
	import asgl.entities.Object3D;
	
	use namespace asgl_protected;

	public class AbstractSkeletonMatrixCalculator {
		asgl_protected var _animationMatrices:Object;
		
		public function AbstractSkeletonMatrixCalculator() {
			_animationMatrices = {};
		}
		public function get animationMatrices():Object {
			return _animationMatrices;
		}
		public function getSkinnedMeshBoneMatrices(boneNames:Vector.<String>, op:Vector.<Number>=null):Vector.<Number> {
			return null;
		}
		public function calculate(animationLabel:String, skinnedMeshLabel:String, cacheInterval:Number, frame:Number, 
								  bonesName:Vector.<String>, rootBones:Vector.<Object3D>, animationDataByNameMap:Object, skinnedMeshAsset:SkinnedMeshAsset, 
								  cacheKey:String=null, cacheIntervalAmount:int=0):Boolean {
			return false;
		}
		public function calculateBlend(animationLabel:String, skinnedMeshLabel:String, cacheInterval:Number, frame:Number, 
									   bonesName:Vector.<String>, rootBones:Vector.<Object3D>, animationDataByNameMap:Object, skinnedMeshAsset:SkinnedMeshAsset, 
									   prevAnimationLabel:String, prevFrame:Number, prevAnimationDataByNameMap:Object, weight:Number):Boolean {
			return false;
		}
	}
}