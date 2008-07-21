package pblocks.data
{
	import de.polygonal.ds.LinkedQueue;
	
	import flash.utils.Dictionary;

	/**
	 * Abstract class which is used to represent a polycube blockset.
	 */
	public class PolyCubeBlockset extends Blockset
	{
		private var _maxWidth:int;
		private var _maxHeight:int;
		private var _maxDepth:int;
		private var _maxOrder:int;
		
		public function PolyCubeBlockset(maxWidth:int, maxHeight:int, maxDepth:int, maxOrder:int)
		{
			super();
			_maxWidth = maxWidth;
			_maxHeight = maxHeight;
			_maxDepth = maxDepth;
			_maxOrder = maxOrder;
			generateBlocks();
		}
		
		/**
		 * Brute force generation of all polycubes.
		 */
		private function generateBlocks():void
		{
			var q:LinkedQueue = new LinkedQueue();
			var visited:Dictionary = new Dictionary();
			
			var first:BlockGrid = new BlockGrid(1, 1, 1, null);
			first.createBlockAt(0, 0, 0);
			q.enqueue(first);
			
			var curr:BlockGrid;
			while((curr = q.dequeue()) != null)
			{
				// use the string as a key since we need by value comparison
				if(visited[curr.toString()])
				{
					continue;
				}
				
				_blocks.push(curr);
				visited[curr.toString()] = true;
				// mark all rotations of the block as visited as well so we dont have duplicates
				visited[curr.rotateX(1).toString()] = true;
				visited[curr.rotateX(-1).toString()] = true;
				visited[curr.rotateY(1).toString()] = true;
				visited[curr.rotateY(-1).toString()] = true;
				visited[curr.rotateZ(1).toString()] = true;
				visited[curr.rotateZ(-1).toString()] = true;
				
				if(curr.blockCount >= _maxOrder)
				{
					continue;
				}
				
				var newPolys:Array = getHigherOrderPolyCubes(curr);
				for each(var b:BlockGrid in newPolys)
				{
					q.enqueue(b);
				}
			}
		}
		
		/**
		 * Retuns all polycubes of order blockCount + 1 that
		 * can be generated from the specified BlockGrid by adding a block
		 * and keeping it connected
		 */
		public function getHigherOrderPolyCubes(b:BlockGrid):Array
		{
			var cubes:Array = new Array();
			for(var i:int = 0; i < Math.min(b.width + 1, _maxWidth); i++)
			{
				for(var j:int = 0; j < Math.min(b.height + 1, _maxHeight); j++)
				{
					for(var k:int = 0; k < Math.min(b.depth + 1, _maxDepth); k++)
					{
						if(b.getBlockAt(i, j, k) == null
							&& hasAdjacentBlock(b, i, j, k))
						{
							var newPolyCube:BlockGrid = new BlockGrid(Math.max(i + 1, b.width), Math.max(j + 1, b.height), Math.max(k + 1, b.depth));
							newPolyCube.copyAttributes(b);
							newPolyCube.union(b, 0, 0, 0, true);
							newPolyCube.createBlockAt(i, j, k);
							cubes.push(newPolyCube);
						}
					}
				}
			}
			return cubes;
		}
		
		/**
		 * Returns if there is a block adjacent to this location.
		 */
		private function hasAdjacentBlock(b:BlockGrid, i:int, j:int, k:int):Boolean
		{
			return b.getBlockAt(i - 1, j, k) != null
					|| b.getBlockAt(i + 1, j, k) != null
					|| b.getBlockAt(i, j - 1, k) != null
					|| b.getBlockAt(i, j + 1, k) != null
					|| b.getBlockAt(i, j, k - 1) != null
					|| b.getBlockAt(i, j, k + 1) != null
		}
	}
}