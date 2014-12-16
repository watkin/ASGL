package asgl.animators {
	
	public class SpriteSheetAtlas {
		private var _map:Object;
		private var _amount:uint;
		
		public function SpriteSheetAtlas() {
			_map = {};
		}
		public function get numAssets():uint {
			return _amount;
		}
		public function setAsset(name:String, asset:SpriteSheetAsset):void {
			var hasOld:Boolean = name in _map;
			
			if (asset == null) {
				if (hasOld) {
					_amount--;
					delete _map[name];
				}
			} else {
				_map[name] = asset;
				if (!hasOld) _amount++;
			}
		}
		public function getAsset(name:String):SpriteSheetAsset {
			return _map[name];
		}
		public function getAssets(prefix:String='', op:Vector.<SpriteSheetAsset>=null):Vector.<SpriteSheetAsset> {
			op ||= new Vector.<SpriteSheetAsset>();
			
			var names:Vector.<String> = new Vector.<String>();
			var num:int;
			
			for (var name:String in _map) {
				if (name.indexOf(prefix) == 0) names[num++] = name;
			}
			
			names.sort(Array.CASEINSENSITIVE);
			
			var index:int = op.length;
			
			for (var i:int = 0; i < num; i++) {
				op[index++] = _map[names[i]];
			}
			
			return op;
		}
		public function removeAssets():void {
			if (_amount > 0) {
				_map = {};
				_amount = 0;
			}
		}
	}
}