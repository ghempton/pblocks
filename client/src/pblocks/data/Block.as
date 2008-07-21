package pblocks.data
{
	import mx.containers.Grid;
	
	public class Block
	{
		private var _source:BlockGrid;
		
		public function Block(source:BlockGrid)
		{
			_source = source;	
		}
		
		public function get source():BlockGrid
		{
			return _source;
		}
	}
}