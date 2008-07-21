package pblocks.view
{
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.scenes.Scene3D;
	
	import pblocks.PaperblocksController;

	/**
	 * A basic Scene3D extension which references back to the controller.
	 */
	public class PaperblocksScene extends Scene3D
	{
		public static const BLOCK_SIZE:Number = 50.0;
		
		private var _controller:PaperblocksController;
		private var _gameCenter:DisplayObject3D;
		
		public function PaperblocksScene(controller:PaperblocksController)
		{
			_controller = controller;	
			// set the game center to a new display object at (0,0,0)
			_gameCenter = new DisplayObject3D();
		}
		
		public function get gameCenter():DisplayObject3D
		{
			return _gameCenter;
		}
		
		public function get gameController():PaperblocksController
		{
			return _controller;
		}
	}
}