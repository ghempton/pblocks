package pblocks.geom
{
	
	import flash.geom.Point;
	
	import mx.effects.Tween;
	import mx.effects.easing.Circular;
	
	import org.papervision3d.core.geom.TriangleMesh3D;
	import org.papervision3d.core.geom.renderables.Triangle3D;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.core.math.NumberUV;
	import org.papervision3d.core.proto.MaterialObject3D;
	import org.papervision3d.objects.DisplayObject3D;
	
	import pblocks.PaperblocksController;
	import pblocks.data.Block;
	import pblocks.data.BlockGrid;
	import pblocks.view.PaperblocksScene;

	
	public class BlocksMesh3D extends DisplayObject3D
	{
		public static const ROTATION_DURATION:Number = 100;
		public static const TRANSLATION_DURATION:Number = 40;
		
		protected var _grid:BlockGrid;
		protected var _meshContainer:DisplayObject3D;
		protected var _mesh:TriangleMesh3D;
		
		protected var _rotTween:Tween;
		protected var _tranTween:Tween;
		// Don't need these callbacks, they are just required by the tween class
		
		private var _verts:Array;
		private var _i:int;
		private var _j:int;
		private var _k:int;
		
		public function BlocksMesh3D(grid:BlockGrid)
		{
			super();
			_grid = grid;
			_meshContainer = new DisplayObject3D();
			addChild(_meshContainer);
			_mesh = new TriangleMesh3D(null, null, null);
			_meshContainer.addChild(_mesh);
			generateMesh();
			i = 0;
			j = 0;
			k = 0;
		}
		
		/**
		 * The X coordinate in grid space.
		 */
		public function get i():int
		{
			return _i;
		}
		
		public function set i(i:int):void
		{
			_i = i;
			x = _i * PaperblocksScene.BLOCK_SIZE;
		}
		
		/**
		 * The Y coordinate in grid space.
		 */
		public function get j():int
		{
			return _j;
		}
		
		public function set j(j:int):void
		{
			_j = j;
			y = _j * PaperblocksScene.BLOCK_SIZE;
		}
		
		/**
		 * The Z coordinate in grid space.
		 */
		public function get k():int
		{
			return _k;
		}
		
		public function set k(k:int):void
		{
			_k = k;
			z = _k * PaperblocksScene.BLOCK_SIZE;
		}
		
		/**
		 * The width in 3D scene space.
		 */
		public function get width():Number
		{
			return _grid.width * PaperblocksScene.BLOCK_SIZE;
		}
		
		/**
		 * The height in 3D scene space.
		 */
		public function get height():Number
		{
			return _grid.height * PaperblocksScene.BLOCK_SIZE;
		}
		
		/**
		 * The depth in 3D scene space.
		 */
		public function get depth():Number
		{
			return _grid.depth * PaperblocksScene.BLOCK_SIZE;
		}
		
		public function get blockWidth():Number
		{
			return _grid.width;
		}
		
		public function get blockHeight():Number
		{
			return _grid.height;
		}
		
		public function get blockDepth():Number
		{
			return _grid.depth;
		}
		
		public function get blockMaterial():MaterialObject3D
		{
			return _grid.mat;
		}
		
		public function set blockMaterial(m:MaterialObject3D):void
		{
			_grid.mat = m;
		}
		
		private var _meshOffsetX:Number = 0.0;
		private var _meshOffsetY:Number = 0.0;
		private var _meshOffsetZ:Number = 0.0;
		private function set meshPivot(pivot:Number3D):void
		{
			_mesh.x = -pivot.x;
			_mesh.y = -pivot.y;
			_mesh.z = -pivot.z;
			_meshContainer.x = pivot.x + _meshOffsetX;
			_meshContainer.y = pivot.y + _meshOffsetY;
			_meshContainer.z = pivot.z + _meshOffsetZ;
		}
		
		private function updatePivots():void
		{
			_meshContainer.rotationX = 0.0;
			_meshContainer.rotationY = 0.0;
			_meshContainer.rotationZ = 0.0;
			_meshOffsetX = 0.0;
			_meshOffsetY = 0.0;
			_meshOffsetZ = 0.0;
			meshPivot = new Number3D(0.0, 0.0, 0.0);
			_pivotX = new Point(_grid.pivotX.x * PaperblocksScene.BLOCK_SIZE,
				_grid.pivotX.y * PaperblocksScene.BLOCK_SIZE);
			_pivotY = new Point(_grid.pivotY.x * PaperblocksScene.BLOCK_SIZE,
				_grid.pivotY.y * PaperblocksScene.BLOCK_SIZE);
			_pivotZ = new Point(_grid.pivotZ.x * PaperblocksScene.BLOCK_SIZE,
				_grid.pivotZ.y * PaperblocksScene.BLOCK_SIZE);
		}
		
		private function get meshPivot():Number3D
		{
			return new Number3D(-_mesh.x, -_mesh.y, -_mesh.z);
		}
		
		public function changeI(deltaI:int, animate:Boolean=false ):void
		{
			if(null != _tranTween)
			{
				_tranTween.endTween();
				_tranTween = null;
			}
			
			if(!animate)
			{
				i += deltaI;
				return;
			}
			
			_i += deltaI;
			
			_tranTween = new Tween(this, x, x + deltaI * PaperblocksScene.BLOCK_SIZE, TRANSLATION_DURATION);
			_tranTween.easingFunction = Circular.easeOut;
			_tranTween.setTweenHandlers(function(d:Number):void {x = d;},
									 function(d:Number):void {x = d;_tranTween=null;});
		}
		
		public function changeJ(deltaJ:int, animate:Boolean=false ):void
		{
			if(null != _tranTween)
			{
				_tranTween.endTween();
				_tranTween = null;
			}
			
			if(!animate)
			{
				j += deltaJ;
				return;
			}
			
			_j += deltaJ;
			
			_tranTween = new Tween(this, y, y + deltaJ * PaperblocksScene.BLOCK_SIZE, TRANSLATION_DURATION);
			_tranTween.easingFunction = Circular.easeOut;
			_tranTween.setTweenHandlers(function(d:Number):void {y = d;},
									 function(d:Number):void {y = d;_tranTween=null;});
		}
		
		public function changeK(deltaK:int, animate:Boolean=false ):void
		{
			if(null != _tranTween)
			{
				_tranTween.endTween();
				_tranTween = null;
			}
			
			if(!animate)
			{
				k+=deltaK;
				return;
			}
			
			_k += deltaK;
			
			_tranTween = new Tween(this, z, z + deltaK * PaperblocksScene.BLOCK_SIZE, TRANSLATION_DURATION);
			_tranTween.easingFunction = Circular.easeOut;
			_tranTween.setTweenHandlers(function(d:Number):void {z = d;},
									 function(d:Number):void {z = d;_tranTween=null;});
		}
		
		public function rotateX(dir:int, animate:Boolean=false):void
		{
			// we need to stop the previous tween
			if(null != _rotTween)
			{
				_rotTween.endTween();
				_rotTween = null;
			}
			
			// rotate the underlying block grid
			var blockPivot:Point = _grid.pivotX;
			_grid = _grid.rotateX(dir);
			
			// we need to compensate for the block grid coordinate system
			blockPivot = blockPivot.subtract(_grid.pivotX);
			j += blockPivot.x;
			k += blockPivot.y;
			
			if(!animate)
			{
				generateMesh();
				return;
			}
			
			_meshOffsetY -= blockPivot.x * PaperblocksScene.BLOCK_SIZE;
			_meshOffsetZ -= blockPivot.y * PaperblocksScene.BLOCK_SIZE;
			meshPivot = new Number3D(0.0, pivotX.x, pivotX.y);
			
			// tween the mesh for a visual cue, the block grid is already rotated
			_rotTween = new Tween(this, _meshContainer.rotationX, _meshContainer.rotationX + dir * Math.PI / 2, ROTATION_DURATION);
			_rotTween.easingFunction = Circular.easeOut;
			_rotTween.setTweenHandlers(function(r:Number):void {_meshContainer.rotationX = r;}, finishRotationHandler);
		}
		
		public function rotateY(dir:int, animate:Boolean=false):void
		{
			// we need to stop the previous tween
			if(null != _rotTween)
			{
				_rotTween.endTween();
				_rotTween = null;
			}
			
			// rotate the underlying block grid
			var blockPivot:Point = _grid.pivotY;
			_grid = _grid.rotateY(dir);
			
			// we need to compensate for the block grid coordinate system
			blockPivot = blockPivot.subtract(_grid.pivotY);
			i += blockPivot.x;
			k += blockPivot.y;
			
			if(!animate)
			{
				generateMesh();
				return;
			}
			

			_meshOffsetX -= blockPivot.x * PaperblocksScene.BLOCK_SIZE;
			_meshOffsetZ -= blockPivot.y * PaperblocksScene.BLOCK_SIZE;
			meshPivot = new Number3D(pivotY.x, 0.0, pivotY.y);
			
			// tween the mesh for a visual cue, the block grid is already rotated
			_rotTween = new Tween(this, _meshContainer.rotationY, _meshContainer.rotationY + dir * Math.PI / 2, ROTATION_DURATION);
			_rotTween.easingFunction = Circular.easeOut;
			_rotTween.setTweenHandlers(function(r:Number):void {_meshContainer.rotationY = r;}, finishRotationHandler);
		}
		
		public function rotateZ(dir:int, animate:Boolean=false):void
		{
			// we need to stop the previous tween
			if(null != _rotTween)
			{
				_rotTween.endTween();
				_rotTween = null;
			}
			// rotate the underlying block grid
			var blockPivot:Point = _grid.pivotZ;
			_grid = _grid.rotateZ(dir);
			
			// we need to compensate for the block grid coordinate system
			blockPivot = blockPivot.subtract(_grid.pivotZ);
			i += blockPivot.x;
			j += blockPivot.y;
			
			if(!animate)
			{
				generateMesh();
				return;
			}
			
			_meshOffsetX -= blockPivot.x * PaperblocksScene.BLOCK_SIZE;
			_meshOffsetY -= blockPivot.y * PaperblocksScene.BLOCK_SIZE;
			meshPivot = new Number3D(pivotZ.x, pivotZ.y, 0.0);
			
			// tween the mesh for a visual cue, the block grid is already rotated
			_rotTween = new Tween(this, _meshContainer.rotationZ, _meshContainer.rotationZ + dir * Math.PI / 2, ROTATION_DURATION);
			_rotTween.easingFunction = Circular.easeOut;
			_rotTween.setTweenHandlers(function(r:Number):void {_meshContainer.rotationZ = r;}, finishRotationHandler);
		}
		
		private function finishRotationHandler(r:Number):void
		{
			generateMesh();
			_rotTween = null;
		}
		
		private var _pivotX:Point;
		public function get pivotX():Point
		{
			return _pivotX;
		}
		
		private var _pivotY:Point;
		public function get pivotY():Point
		{
			return _pivotY;
		}
		
		private var _pivotZ:Point;
		public function get pivotZ():Point
		{
			return _pivotZ;
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
		
		public function intersects(target:BlocksMesh3D):Boolean
		{
			var di:int = target.i - i;
			var dj:int = target.j - j;
			var dk:int = target.k - k;
			return _grid.intersects(target._grid, di, dj, dk);
		}
		
		public function union(target:BlocksMesh3D):void
		{
			var di:int = target.i - i;
			var dj:int = target.j - j;
			var dk:int = target.k - k;
			_grid.union(target._grid, di, dj, dk);
			generateMesh();
		}
		
		public override function clone():DisplayObject3D
		{
			return new BlocksMesh3D(_grid);
		}
		
		protected function get gameController():PaperblocksController
		{
			return PaperblocksScene(scene).gameController;
		}
		
		protected function getVertex(i:int, j:int, k:int):Vertex3D
		{
			var numI:int = _grid.width + 1;
			var numJ:int = _grid.height + 1;
			var numK:int = _grid.depth + 1;
			var index:int = i + j * numI + k * numI * numJ;
			var vert:Vertex3D = _verts[index] as Vertex3D;
			if(null != vert)
			{
				return vert;
			}
			
			vert = new Vertex3D(i * PaperblocksScene.BLOCK_SIZE,
								j * PaperblocksScene.BLOCK_SIZE,
								k * PaperblocksScene.BLOCK_SIZE);
			_verts[index] = vert;
			_mesh.geometry.vertices.push(vert);
			return vert;
		}
		
		protected function generateMesh():void
		{
			// update the pivots
			updatePivots();
			
			// generate the geometry
			_mesh.geometry.vertices = new Array();
			_mesh.geometry.faces = new Array();
			_verts = new Array((_grid.width + 1) * (_grid.height + 1) * (_grid.depth + 1));
			
			for(var i:int = 0; i < _grid.width; i++)
			{
				for(var j:int = 0; j < _grid.height; j++)
				{
					for(var k:int = 0; k < _grid.depth; k++)
					{
						var b:Block = _grid.getBlockAt(i, j, k);
						if(null != b)
						{
							generateBlockMesh(b, i, j, k);
						}
					}
				}
			}
		}
		
		protected function getBlockMaterial(b:Block,  i:int, j:int, k:int):MaterialObject3D
		{
			return b.source.mat;
		}
		
		protected function generateBlockMesh(b:Block, i:int, j:int, k:int):void
		{
			var v1:Vertex3D;
			var v2:Vertex3D;
			var v3:Vertex3D;
			var v4:Vertex3D;
			var uv1:NumberUV = new NumberUV(0,0);
			var uv2:NumberUV = new NumberUV(1,0);
			var uv3:NumberUV = new NumberUV(0,1);
			var uv4:NumberUV = new NumberUV(1,1);
			var mat:MaterialObject3D = getBlockMaterial(b, i, j, k);
			// check which faces we need to add to the geometry
			
			// face with normal (1, 0, 0)
			if(i == 0 || _grid.getBlockAt(i - 1, j, k) == null)
			{
				v1 = getVertex(i, j, k);
				v2 = getVertex(i, j + 1, k);
				v3 = getVertex(i, j, k + 1);
				v4 = getVertex(i, j + 1, k + 1); 
				
				_mesh.geometry.faces.push(new Triangle3D(this, [v1, v2, v3], mat, [uv1, uv2, uv3]));
				_mesh.geometry.faces.push(new Triangle3D(this, [v4, v3, v2], mat, [uv4, uv3, uv2]));
			}
			
			// face with normal (-1, 0, 0)
			if(i == _grid.width - 1 || _grid.getBlockAt(i + 1, j, k) == null)
			{
				v1 = getVertex(i + 1, j, k);
				v2 = getVertex(i + 1, j + 1, k);
				v3 = getVertex(i + 1, j, k + 1);
				v4 = getVertex(i + 1, j + 1, k + 1); 
				
				_mesh.geometry.faces.push(new Triangle3D(this, [v1, v3, v2], mat, [uv1, uv3, uv2]));
				_mesh.geometry.faces.push(new Triangle3D(this, [v4, v2, v3], mat, [uv4, uv2, uv3]));
			}
			
			// face with normal (0, 1, 0)
			if(j == 0 || _grid.getBlockAt(i, j - 1, k) == null)
			{
				v1 = getVertex(i, j, k);
				v2 = getVertex(i + 1, j, k);
				v3 = getVertex(i, j, k + 1);
				v4 = getVertex(i + 1, j, k + 1); 
				
				_mesh.geometry.faces.push(new Triangle3D(this, [v1, v3, v2], mat, [uv1, uv3, uv2]));
				_mesh.geometry.faces.push(new Triangle3D(this, [v4, v2, v3], mat, [uv4, uv2, uv3]));
			}
			
			// face with normal (0, -1, 0)
			if(j == _grid.height - 1 || _grid.getBlockAt(i, j + 1, k) == null)
			{
				v1 = getVertex(i, j + 1, k);
				v2 = getVertex(i + 1, j + 1, k);
				v3 = getVertex(i, j + 1, k + 1);
				v4 = getVertex(i + 1, j + 1, k + 1); 
				
				_mesh.geometry.faces.push(new Triangle3D(this, [v1, v2, v3], mat, [uv1, uv2, uv3]));
				_mesh.geometry.faces.push(new Triangle3D(this, [v4, v3, v2], mat, [uv4, uv3, uv2]));
			}
			
			// face with normal (0, 0, 1)
			if(k == 0 || _grid.getBlockAt(i, j, k - 1) == null)
			{
				v1 = getVertex(i, j, k);
				v2 = getVertex(i + 1, j, k);
				v3 = getVertex(i, j + 1, k);
				v4 = getVertex(i + 1, j + 1, k); 
				
				_mesh.geometry.faces.push(new Triangle3D(this, [v1, v2, v3], mat, [uv1, uv2, uv3]));
				_mesh.geometry.faces.push(new Triangle3D(this, [v4, v3, v2], mat, [uv4, uv3, uv2]));
			}
			
			// face with normal (0, 0, -1)
			if(k == _grid.depth - 1 || _grid.getBlockAt(i, j, k + 1) == null)
			{
				v1 = getVertex(i, j, k + 1);
				v2 = getVertex(i + 1, j, k + 1);
				v3 = getVertex(i, j + 1, k + 1);
				v4 = getVertex(i + 1, j + 1, k + 1); 
				
				_mesh.geometry.faces.push(new Triangle3D(this, [v1, v3, v2], mat, [uv1, uv3, uv2]));
				_mesh.geometry.faces.push(new Triangle3D(this, [v4, v2, v3], mat, [uv4, uv2, uv3]));
			}
		}
	}
}