package pblocks.data
{
	import flash.utils.Dictionary;
	
	import org.papervision3d.core.proto.MaterialObject3D;
	
	import pblocks.mat.BlockMaterialFast;
	import pblocks.util.Color;
	
	// Abstract class to represent a set of blocks to play with
	public class Blockset
	{
		public static const NAME:String = "Abstract";
		
		protected var _blocks:Array;
		
		public function Blockset()
		{
			_blocks = new Array();
			_materials = new Dictionary();
		}
		
		/**
		 * Returns a block in this blockset.
		 */
		public function getBlock():BlockGrid
		{
			var index:int = Math.round(Math.random() * (_blocks.length - 1));
			var b:BlockGrid = BlockGrid(_blocks[index]).clone();
			b.mat = getBlockMaterial(index);
			return b;
		}
		
		private var _materials:Dictionary;
		
		/**
		 * Returns a new MaterialObject3D for the gien index.
		 */
		protected function getBlockMaterial(index:int):MaterialObject3D
		{
			var mat:MaterialObject3D = _materials[index];
			if(mat == null)
			{
				mat = new BlockMaterialFast(Color.randomColor());
				_materials[index] = mat;
			}
			return new BlockMaterialFast(mat.fillColor);
		}
		
		public function get name():String
		{
			return NAME;
		}
	}
}