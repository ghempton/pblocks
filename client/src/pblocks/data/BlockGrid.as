package pblocks.data
{
	import flash.geom.Point;
	
	import org.papervision3d.core.proto.MaterialObject3D;
	
	/**
	 * This class is represents the underlying grid structure of the blocks
	 * and the game.
	 */
	public final class BlockGrid
	{
		private var _width:int;
		private var _height:int;
		private var _depth:int;
		
		// DO NOT ACCESS DIRECTLY, USE getter/setter methods
		private var _blocks:Array;
		
		// contains a count of the number of block on each y-slice
		private var _xLayerCount:Array;
		private var _yLayerCount:Array;
		private var _zLayerCount:Array;
		
		// contains the total number of blocks
		private var _blockCount:uint;
		public function get blockCount():uint
		{
			return _blockCount;
		}
		
		private var _mat:MaterialObject3D;
		
		/**
		 * The logical block grid class. All calculations and members of this class refer
		 * to block space, NOT 3d scene space.
		 */
		public function BlockGrid(width:int, height:int, depth:int, material:MaterialObject3D=null)
		{
			_width = width;
			_height = height;
			_depth = depth;
			_mat = material;
			_blocks = new Array(_width * _height * _depth);
			
			_xLayerCount = new Array(_width);
			for(var i:int = 0; i < _width; i++)
			{
				_xLayerCount[i] = 0;
			}
			_yLayerCount = new Array(_height);
			for(var j:int = 0; j < _height; j++)
			{
				_yLayerCount[j] = 0;
			}
			_zLayerCount = new Array(_depth);
			for(var k:int = 0; k < _depth; k++)
			{
				_zLayerCount[k] = 0;
			}
		}
		
		public function get width():int
		{
			return _width;
		}
		
		public function get height():int
		{
			return _height;
		}
		
		public function get depth():int
		{
			return _depth;
		}
		
		/**
		 * Returns the nearest point to the given block location that is a valid pivot.
		 * In order to maintain alignment with the grid, the pivot must
		 * be either on a block center or a block corner,
		 */
		private function getNearestPivot(p:Point):Point
		{
			var adjustedPoint:Point = new Point(p.x + 0.5, p.y + 0.5);
			var pivotCenter:Point = new Point();
			pivotCenter.x = Math.floor(adjustedPoint.x) + 0.5;
			pivotCenter.y = Math.floor(adjustedPoint.y) + 0.5;
			var pivotCorner:Point = new Point();
			pivotCorner.x = Math.round(adjustedPoint.x);
			pivotCorner.y = Math.round(adjustedPoint.y);
			return Point.distance(pivotCenter, adjustedPoint) < Point.distance(pivotCorner, adjustedPoint) ? pivotCenter : pivotCorner;
		}
		
		/**
		 * The block pivot on the yz plane.
		 */
		public function get pivotX():Point
		{
			var pivot:Point = new Point(_averageJ, _averageK);
			return getNearestPivot(pivot);
		}
		
		/**
		 * The block pivot on the xz plane.
		 */
		public function get pivotY():Point
		{
			var pivot:Point = new Point(_averageI, _averageK);
			return getNearestPivot(pivot);
		}
		
		/**
		 * The block pivot on the xy plane.
		 */
		public function get pivotZ():Point
		{
			var pivot:Point = new Point(_averageI, _averageJ);
			return getNearestPivot(pivot);
		}
		
		public function get centerX():Number
		{
			return width / 2.0;
		}
		
		public function get centerY():Number
		{
			return height / 2.0;
		}
		
		public function get centerZ():Number
		{
			return depth / 2.0;
		}
		
		/**
		 * Rotate the given point 90 degrees in the specified dir
		 * around the given pivot.
		 * Also translates the coordinate to fit within the rotated coordinate system and its bounds.
		 */
		/*
		private function rotateAroundPivot(p:Point, pivot:Point, bounds:Point, dir:int):Point
		{
			var sub:Point = p.subtract(pivot);
			var reciprocal:Point = new Point(sub.y, sub.x);
			if(dir > 0)
			{
				reciprocal.x = -reciprocal.x;
				reciprocal.y += bounds.x - pivot.x;
			}
			else
			{
				reciprocal.y = -reciprocal.y;
				reciprocal.x += bounds.y - pivot.y;
			}
			var pivotReciprocal:Point = new Point(pivot.y, pivot.x);
			var rotated:Point = pivotReciprocal.add(reciprocal);
			return rotated;
		}
		*/
		
		public function get mat():MaterialObject3D
		{
			return _mat;
		}
		
		public function set mat(m:MaterialObject3D):void
		{
			_mat = m;
		}
		
		public function getBlockAt(i:int, j:int, k:int):Block
		{
			if(i < 0 || i > width - 1 || j < 0 || j > height - 1 || k < 0 || k > depth - 1)
			{
				return null;
			}
			return _blocks[i + _width * j + _width * _height * k] as Block;
		}
		
		// private variables to store the averages
		private var _averageI:Number = 0.0;
		private var _averageJ:Number = 0.0;
		private var _averageK:Number = 0.0;
		
		public function setBlockAt(i:int, j:int, k:int, b:Block):void
		{
			if(i < 0 || i > width - 1 || j < 0 || j > height - 1 || k < 0 || k > depth - 1)
			{
				return;
			}
			var curr:Block = getBlockAt(i, j, k);
			if(b != null && curr == null)
			{
				_blockCount++;
				_yLayerCount[j]++;
				// update the weighted centers
				_averageI = _averageI * ((_blockCount - 1) / _blockCount) + i / _blockCount;
				_averageJ = _averageJ * ((_blockCount - 1) / _blockCount) + j / _blockCount;
				_averageK = _averageK * ((_blockCount - 1) / _blockCount) + k / _blockCount;
			}
			else if(curr != null)
			{
				_blockCount--;
				_yLayerCount[j]--;
				// update the weighted centers
				if(_blockCount == 0)
				{
					_averageI = _averageJ = _averageK = 0;
				}
				_averageI = _averageI * ((_blockCount + 1) / _blockCount) - i / _blockCount;
				_averageJ = _averageJ * ((_blockCount + 1) / _blockCount) - j / _blockCount;
				_averageK = _averageK * ((_blockCount + 1) / _blockCount) - k / _blockCount;
			}
			_blocks[i + _width * j + _width * _height * k] = b;
		}
		
		public function createBlockAt(i:int, j:int, k:int):void
		{
			setBlockAt(i, j, k, new Block(this));
		}
		
		/**
		 * Flips the grid on the x axis by 90 degrees in the direction specified by dir and returns a new BlockGrid.
		 */
		public function rotateX(dir:int):BlockGrid
		{
			var rotatedGrid:BlockGrid = new BlockGrid(width, depth, height);
			rotatedGrid.mat = mat;
			// perform the rotation by swapping the quadrants around the pivot point on each x-layer
			for(var i:int = 0; i < _width; i++)
			{
				for(var j:int = 0; j < _height; j++)
				{
					for(var k:int = 0; k < _depth; k++)
					{
						if(getBlockAt(i, j, k) != null)
						{
							// rotate the block center around the pivot
							var diffJ:Number = j + 0.5 - centerY;
							var diffK:Number = k + 0.5 - centerZ;
							var newJ:int = Math.floor(centerZ + (dir > 0 ? diffK : -diffK));
							var newK:int = Math.floor(centerY + (dir > 0 ? -diffJ : diffJ));
							rotatedGrid.createBlockAt(i, newJ, newK);
						}
					}
				}
			}
			return rotatedGrid;
		}
		
		/**
		 * Flips the grid on the y axis by 90 degrees in the direction specified by dir and returns a new BlockGrid.
		 */
		public function rotateY(dir:int):BlockGrid
		{
			var rotatedGrid:BlockGrid = new BlockGrid(depth, height, width);
			rotatedGrid.mat = mat;
			// perform the rotation by swapping the quadrants around the pivot point on each y-layer
			for(var j:int = 0; j < _height; j++)
			{
				for(var i:int = 0; i < _width; i++)
				{
					for(var k:int = 0; k < _depth; k++)
					{
						if(getBlockAt(i, j, k) != null)
						{
							var diffI:Number = i + 0.5 - centerX;
							var diffK:Number = k + 0.5 - centerZ;
							var newI:int = Math.floor(centerZ + (dir > 0 ? diffK : -diffK));
							var newK:int = Math.floor(centerX + (dir > 0 ? -diffI : diffI));
							rotatedGrid.createBlockAt(newI, j, newK);
						}
					}
				}
			}
			return rotatedGrid;
		}
		
		/**
		 * Flips the grid on the z axis by 90 degrees in the direction specified by dir and returns a new BlockGrid.
		 */
		public function rotateZ(dir:int):BlockGrid
		{
			var rotatedGrid:BlockGrid = new BlockGrid(height, width, depth);
			rotatedGrid.mat = mat;
			// perform the rotation by swapping the quadrants around the pivot point on each y-layer
			for(var k:int = 0; k < _depth; k++)
			{
				for(var i:int = 0; i < _width; i++)
				{
					for(var j:int = 0; j < _height; j++)
					{
						if(getBlockAt(i, j, k) != null)
						{
							var diffI:Number = i + 0.5 - centerX;
							var diffJ:Number = j + 0.5 - centerY;
							var newI:int = Math.floor(centerY + (dir > 0 ? -diffJ : diffJ));
							var newJ:int = Math.floor(centerX + (dir > 0 ? diffI : -diffI));
							rotatedGrid.createBlockAt(newI, newJ, k);
						}
					}
				}
			}
			return rotatedGrid;
		}
		
		/**
		 * Copies over the attributes from the target BlockGrid.
		 */
		public function copyAttributes(target:BlockGrid):void
		{
			_mat = target.mat;
		}
		
		public function clone():BlockGrid
		{
			var clone:BlockGrid = new BlockGrid(width, height, depth);
			for(var i:int = 0; i < _width; i++)
			{
				for(var j:int = 0; j < _height; j++)
				{
					for(var k:int = 0; k < _depth; k++)
					{
						if(null == getBlockAt(i, j, k))
						{
							continue;
						}
						clone.createBlockAt(i, j, k);
					}
				}
			}
			return clone;
		}
		
		/**
		 * Adds the blocks from the target BlockGrid to this BlockGrid
		 * starting at the offset specified by (i,j,k)
		 */
		public function union(target:BlockGrid, i:int = 0, j:int = 0, k:int = 0, changeSource:Boolean=false):void
		{
			for(var i2:int = Math.max(0, i); i2 < Math.min(_width, target._width + i); i2++)
			{
				for(var j2:int = Math.max(0, j); j2 < Math.min(_height, target._height + j); j2++)
				{
					for(var k2:int = Math.max(0, k); k2 < Math.min(_depth, target._depth + k); k2++)
					{
						var targetI:int = i2 - i;
						var targetJ:int = j2 - j;
						var targetK:int = k2 - k;
						var b:Block = target.getBlockAt(targetI, targetJ, targetK);
						if(null != b)
						{
							if(changeSource)
							{
								createBlockAt(i2, j2, k2);
							}
							else
							{
								setBlockAt(i2, j2, k2, b);
							}
						}
					}
				}
			}
		}
		
		/**
		 * Returns whether or not the two BlockGrids intersect starting from
		 * the given offset (i, j, k)
		 */
		public function intersects(target:BlockGrid, i:int = 0, j:int = 0, k:int = 0):Boolean
		{
			for(var i2:int = Math.max(0, i); i2 < Math.min(_width, target._width + i); i2++)
			{
				for(var j2:int = Math.max(0, j); j2 < Math.min(_height, target._height + j); j2++)
				{
					for(var k2:int = Math.max(0, k); k2 < Math.min(_depth, target._depth + k); k2++)
					{
						var targetI:int = i2 - i;
						var targetJ:int = j2 - j;
						var targetK:int = k2 - k;
						if(target.getBlockAt(targetI, targetJ, targetK) != null
							&& getBlockAt(i2, j2, k2) != null)
						{
							return true;
						}
					}
				}
			}
			return false;
		}
		
		public function get completedLayers():Array
		{
			var completedLayers:Array = new Array();
			// put them in reverse order
			for(var j:int = _height - 1; j >= 0; j--)
			{
				if(_yLayerCount[j] == _width * _depth)
				{
					completedLayers.push(j);
				}
			}
			return completedLayers;
		}
		
		/**
		 * Removes the bottom layer orthogonal to the y axis and shifts the other blocks down.
		 */
		public function removeLayer(j:int):void
		{
			var i:int,k:int;
			// explicitly set the layer to null
			for(i = 0; i < _width; i++)
			{
				for(k = 0; k < _depth; k++)
				{
					setBlockAt(i, j, k, null);
				}
			}
			
			// just decrease the j value of all the blocks by 1
			for(var j2:int = j; j2 < _height; j2++)
			{
				for(i = 0; i < _width; i++)
				{
					for(k = 0; k < _depth; k++)
					{
						var b:Block = j2 == _height - 1 ? null : getBlockAt(i, j2+1, k);
						setBlockAt(i,j2,k, b);
					}
				}
			}
			
		}
		
		/**
		 * Used to hash the BlockGrid
		 */
		public function toString():String
		{
			var s:String = "";
			for(var i:int = 0; i < _width; i++)
			{
				for(var j:int = 0; j < _height; j++)
				{
					for(var k:int = 0; k < _depth; k++)
					{
						if(getBlockAt(i, j, k) != null)
						{
							s += "("+i+","+j+","+k+")";
						}
					}
				}
			}
			return s;
		}
	}
}