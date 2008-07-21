package pblocks.geom
{
	import flash.utils.Dictionary;
	
	import org.papervision3d.core.proto.MaterialObject3D;
	
	import pblocks.data.Block;
	import pblocks.data.BlockGrid;
	import pblocks.mat.BlockMaterialFast;
	import pblocks.util.Color;
	
	/**
	 * This class serves as the accumulated geometry of all the blocks.
	 * Also contains the game border geometry.
	 */
	public class BlockAccumulationMesh extends BlocksMesh3D
	{
		private var _depthMaterials:Dictionary;
		
		public function BlockAccumulationMesh(grid:BlockGrid)
		{
			super(grid);
			_depthMaterials = new Dictionary();
		}
		
		private var _colorByDepth:Boolean = true;
		public function get colorByDepth():Boolean
		{
			return _colorByDepth;
		}
		public function set colorByDepth(b:Boolean):void
		{
			if(colorByDepth == b)
			{
				return;
			}
			_colorByDepth = b;
			generateMesh();
		}
		
		public function get completedLayers():Array
		{
			return _grid.completedLayers;
		}
		
		public function removeLayer(j:int):void
		{
			_grid.removeLayer(j);
			generateMesh();
		}
		
		protected override function getBlockMaterial(b:Block, i:int, j:int, k:int):MaterialObject3D
		{
			if(!_colorByDepth)
			{
				return super.getBlockMaterial(b, i, j, k);
			}
			return getDepthMaterial(j);
		}
		
		private function getDepthMaterial(j:int):MaterialObject3D
		{
			if(_depthMaterials[j] != null)
			{
				return _depthMaterials[j];
			}
			var mat:BlockMaterialFast = new BlockMaterialFast(Color.randomColor());
			_depthMaterials[j] = mat;
			return mat;
		}
	}
}