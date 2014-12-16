package asgl.animators {
	import flash.geom.Rectangle;
	
	import asgl.asgl_protected;
	
	use namespace asgl_protected;
	
	public class AnimationClip {
		asgl_protected var _wrap:int;
		asgl_protected var _startFrame:int;
		asgl_protected var _endFrame:int;
		asgl_protected var _totalFrames:int;
		asgl_protected var _data:*;
		
		public function AnimationClip() {
			_wrap = AnimationWrapMode.NONE;
			_startFrame = 0;
			_endFrame = -1;
		}
		public function get data():* {
			return _data;
		}
		public function get endFrame():Number {
			return _endFrame;
		}
		public function get startFrame():Number {
			return _startFrame;
		}
		public function get totalFrames():int {
			return _totalFrames;
		}
		public function set totalFrames(value:int):void {
			if (value < 0) value = 0;
			_totalFrames = value;
		}
		public function get wrap():int {
			return _wrap;
		}
		public function set wrap(value:int):void {
			if (_wrap != value) {
				if (value == AnimationWrapMode.NONE || value == AnimationWrapMode.CLAMP || value == AnimationWrapMode.LOOP || value == AnimationWrapMode.PINGPONG) _wrap = value;
			}
		}
		public function setLocal(startFrame:int=0, endFrame:int=-1):void {
			_startFrame = startFrame;
			_endFrame = endFrame;
		}
		public static function createMeshElementKeyFrameClip(data:Vector.<Vector.<Number>>):AnimationClip {
			var clip:AnimationClip = new AnimationClip();
			
			clip._data = data;
			clip._totalFrames = data.length;
			
			return clip;
		}
		public static function createRegionKeyFrameClip(regions:Vector.<Rectangle>):AnimationClip {
			var clip:AnimationClip = new AnimationClip();
			
			clip._data = regions;
			clip._totalFrames = regions.length;
			
			return clip;
		}
		public static function createGridRegionKeyFrameClip(rows:uint, columns:uint, totalFrames:int=-1):AnimationClip {
			var max:int = rows * columns;
			if (totalFrames < 0 || totalFrames > max) totalFrames = max;
			
			var regions:Vector.<Rectangle> = new Vector.<Rectangle>(totalFrames);
			
			var w:Number = 1 / columns;
			var h:Number = 1 / rows;
			
			for (var i:int = 0; i < totalFrames; i++) {
				var row:int = i / columns;
				var column:int = i % columns;
				
				regions[i] = new Rectangle(column * w, row * h, w, h);
			}
			
			var clip:AnimationClip = new AnimationClip();
			
			clip._data = regions;
			clip._totalFrames = regions.length;
			
			return clip;
		}
		public static function createSkinnedMeshClip(asset:SkeletonAnimationAsset):AnimationClip {
			var clip:AnimationClip = new AnimationClip();
			
			clip._data = asset;
			clip._totalFrames = asset.totalFrames;
			
			return clip;
		}
		public static function createSpriteSheetClip(asset:Vector.<SpriteSheetAsset>):AnimationClip {
			var clip:AnimationClip = new AnimationClip();
			
			clip._data = asset;
			clip._totalFrames = asset.length;
			
			return clip;
		}
	}
}