package asgl.effects.geometries.decal {
	import asgl.math.Float3;
	
	public class DecalVertex extends Float3 {
		public var next:DecalVertex;
		public var prev:DecalVertex;
		public var mask:uint;
		public var valid:Boolean;
		
		public var nx:Number;
		public var ny:Number;
		public var nz:Number;
		public function DecalVertex(x:Number=0, y:Number=0, z:Number=0) {
			super(x, y, z);
		}
	}
}