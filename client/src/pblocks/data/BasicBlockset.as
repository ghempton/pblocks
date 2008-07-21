package pblocks.data
{
	/**
	 * The Basic blocket consists of the seven polycubes present in a soma cube.
	 */
	public class BasicBlockset extends Blockset
	{
		public static const NAME:String = "Basic";
		
		public override function get name():String
		{
			return NAME;
		}
		
		public function BasicBlockset()
		{
			super();
			var blockGrid:BlockGrid;
			
			// "L" Tricube
			blockGrid = new BlockGrid(2, 2, 1);
			blockGrid.createBlockAt(0,0,0);
			blockGrid.createBlockAt(0,1,0);
			blockGrid.createBlockAt(1,1,0);
			_blocks.push(blockGrid);
			
			// "T" Tetracube
			blockGrid = new BlockGrid(3, 2, 1);
			blockGrid.createBlockAt(0,1,0);
			blockGrid.createBlockAt(1,0,0);
			blockGrid.createBlockAt(1,1,0);
			blockGrid.createBlockAt(2,1,0);
			_blocks.push(blockGrid);
			
			// "L" Tetracube
			blockGrid = new BlockGrid(3, 2, 1);
			blockGrid.createBlockAt(0,0,0);
			blockGrid.createBlockAt(0,1,0);
			blockGrid.createBlockAt(1,1,0);
			blockGrid.createBlockAt(2,1,0);
			_blocks.push(blockGrid);
			
			// "S" Tetracube
			blockGrid = new BlockGrid(3, 2, 1);
			blockGrid.createBlockAt(0,0,0);
			blockGrid.createBlockAt(1,0,0);
			blockGrid.createBlockAt(1,1,0);
			blockGrid.createBlockAt(2,1,0);
			_blocks.push(blockGrid);
			
			// Left Screw Tetracube
			blockGrid = new BlockGrid(2, 2, 2);
			blockGrid.createBlockAt(0,0,0);
			blockGrid.createBlockAt(0,1,0);
			blockGrid.createBlockAt(1,1,0);
			blockGrid.createBlockAt(1,1,1);
			_blocks.push(blockGrid);
			
			// Right Screw Tetracube
			blockGrid = new BlockGrid(2, 2, 2);
			blockGrid.createBlockAt(0,0,0);
			blockGrid.createBlockAt(0,1,0);
			blockGrid.createBlockAt(1,1,0);
			blockGrid.createBlockAt(0,0,1);
			_blocks.push(blockGrid);
			
			// Branch Tetracube
			blockGrid = new BlockGrid(2, 2, 2);
			blockGrid.createBlockAt(0,0,0);
			blockGrid.createBlockAt(0,1,0);
			blockGrid.createBlockAt(1,1,0);
			blockGrid.createBlockAt(0,1,1);
			_blocks.push(blockGrid);
			
		}
	}
}