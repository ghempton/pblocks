package pblocks.geom
{
	import org.papervision3d.core.geom.renderables.Triangle3D;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.core.math.NumberUV;
	import org.papervision3d.core.proto.MaterialObject3D;
	
	import pblocks.data.BlockGrid;
	import pblocks.mat.BlockMaterial;
	import pblocks.mat.GameBorderMaterial;

	public class GameBorderMesh extends BlocksMesh3D
	{
		private var _generateWalls:Boolean = true;
		private var _mat:BlockMaterial;
		
		public function get generateWalls():Boolean
		{
			return _generateWalls;
		}
		
		public function set generateWalls(b:Boolean):void
		{
			if(_generateWalls == b)
			{
				return;
			}
			_generateWalls = b;
			generateMesh();
		}
		
		public function GameBorderMesh(grid:BlockGrid)
		{
			_mat = new GameBorderMaterial();
			super(grid);
		}
		
		public function set color(c:uint):void
		{
			_mat.color = c;
		}
		
		/**
		 * This method should be called when the underlying block grid changes.
		 * It will prevent the walls from being drawn when they are invisible
		 * becaues of block accumulation.
		 */
		public function updateGameBorder():void
		{
			generateMesh();
		}
		
		/**
		 * Adds the bottom and walls to the mesh.
		 */
		protected override function generateMesh():void
		{
			super.generateMesh();
			var v1:Vertex3D;
			var v2:Vertex3D;
			var v3:Vertex3D;
			var v4:Vertex3D;
			var uv1:NumberUV = new NumberUV(0,0);
			var uv2:NumberUV = new NumberUV(1,0);
			var uv3:NumberUV = new NumberUV(0,1);
			var uv4:NumberUV = new NumberUV(1,1);
			// TODO: Figure out final material assignment
			var mat:MaterialObject3D = _mat;
			var i:int, j:int, k:int;
			// draw the bottom grid
			for(i = 0; i < _grid.width; i++)
			{
				for(k = 0; k < _grid.depth; k++)
				{
					if(null != _grid.getBlockAt(i, 0, k))
					{
						continue;
					}
					
					// face with normal (0, -1, 0)
					v1 = getVertex(i, 0, k);
					v2 = getVertex(i + 1, 0, k);
					v3 = getVertex(i, 0, k + 1);
					v4 = getVertex(i + 1, 0, k + 1); 
					
					_mesh.geometry.faces.push(new Triangle3D(this, [v1, v2, v3], mat, [uv1, uv2, uv3]));
					_mesh.geometry.faces.push(new Triangle3D(this, [v4, v3, v2], mat, [uv4, uv3, uv2]));
				}
			}
			
			if(!_generateWalls)
			{
				return;
			}
			
			// draw the walls
			for(i = 0; i < _grid.width; i++)
			{
				for(j = 0; j < _grid.height; j++)
				{
					if(null == _grid.getBlockAt(i, j, 0))
					{
						// face with normal (0, 0, 1)
						v1 = getVertex(i, j, 0);
						v2 = getVertex(i + 1, j, 0);
						v3 = getVertex(i, j + 1, 0);
						v4 = getVertex(i + 1, j + 1, 0); 
						
						_mesh.geometry.faces.push(new Triangle3D(this, [v1, v3, v2], mat, [uv1, uv3, uv2]));
						_mesh.geometry.faces.push(new Triangle3D(this, [v4, v2, v3], mat, [uv4, uv2, uv3]));
					}
					
					if(null == _grid.getBlockAt(i, j, _grid.depth - 1))
					{
						// face with normal (0, 0, -1)
						v1 = getVertex(i, j, _grid.depth);
						v2 = getVertex(i + 1, j, _grid.depth);
						v3 = getVertex(i, j + 1, _grid.depth);
						v4 = getVertex(i + 1, j + 1, _grid.depth); 
					
						_mesh.geometry.faces.push(new Triangle3D(this, [v1, v2, v3], mat, [uv1, uv2, uv3]));
						_mesh.geometry.faces.push(new Triangle3D(this, [v4, v3, v2], mat, [uv4, uv3, uv2]));
					}
				}
			}
			
			for(k = 0; k < _grid.depth; k++)
			{
				for(j = 0; j < _grid.height; j++)
				{
					if(null == _grid.getBlockAt(0, j, k))
					{
						// face with normal (1, 0, 0)
						v1 = getVertex(0, j, k);
						v2 = getVertex(0, j + 1, k);
						v3 = getVertex(0, j, k + 1);
						v4 = getVertex(0, j + 1, k + 1); 
						
						_mesh.geometry.faces.push(new Triangle3D(this, [v1, v3, v2], mat, [uv1, uv3, uv2]));
						_mesh.geometry.faces.push(new Triangle3D(this, [v4, v2, v3], mat, [uv4, uv2, uv3]));
					}
					
					if(null == _grid.getBlockAt(_grid.width - 1, j, k))
					{
						// face with normal (-1, 0, 0)
						v1 = getVertex(_grid.width , j, k);
						v2 = getVertex(_grid.width, j + 1, k);
						v3 = getVertex(_grid.width, j, k + 1);
						v4 = getVertex(_grid.width, j + 1, k + 1); 
						
						_mesh.geometry.faces.push(new Triangle3D(this, [v1, v2, v3], mat, [uv1, uv2, uv3]));
						_mesh.geometry.faces.push(new Triangle3D(this, [v4, v3, v2], mat, [uv4, uv3, uv2]));
					}
				}
			}
		}
		
	}
}