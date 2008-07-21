package pblocks.view
{
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.objects.DisplayObject3D;
	
	import pblocks.events.PaperblocksEvent;
	import pblocks.geom.BlocksMesh3D;
	
	// TODO: This class could be more elegant
	public class NextBlockView extends OrthographicView
	{
		protected const ISO_ANGLE:Number = Math.asin(Math.tan(Math.PI / 6));
		
		private var _nextBlock:BlocksMesh3D;
		private var _scene:PaperblocksScene;
		
		public function NextBlockView()
		{
			// TODO: kind of ugly here
			_scene = new PaperblocksScene(null);
			initializeCamera();
		}
		
		public function get nextBlock():BlocksMesh3D
		{
			return _nextBlock;
		}
		
		public function set nextBlock(b:BlocksMesh3D):void
		{
			if(null != _nextBlock)
			{
				_scene.removeChild(_nextBlock);
			}
			_nextBlock = BlocksMesh3D(b.clone());
			_scene.addChild(_nextBlock);
			// center the block in the scene
			_nextBlock.x = -_nextBlock.centerX;
			_nextBlock.y = -_nextBlock.centerY;
			_nextBlock.z = -_nextBlock.centerZ;
			renderScene();
		}
		
		protected override function get scene():PaperblocksScene
		{
			return _scene;
		}
		
		protected override function gameStartHandler(e:PaperblocksEvent):void
		{
			super.gameStartHandler(e);
			// We only need to render when there is a new block
			stopRendering();
		}
		
		protected override function initializeCamera():void
		{
			super.initializeCamera();
			var dist:Number = INFINITY * PaperblocksScene.BLOCK_SIZE * 4;
			_camera.x = dist * Math.cos(ISO_ANGLE) * Math.cos(Math.PI / 4);
			_camera.z = dist * Math.cos(ISO_ANGLE) * Math.sin(Math.PI / 4);
			_camera.y = dist * Math.sin(ISO_ANGLE);
		}
	}
}