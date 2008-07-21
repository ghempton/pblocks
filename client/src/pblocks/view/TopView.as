package pblocks.view
{
	import org.papervision3d.core.math.Number3D;
	
	public class TopView extends OrthographicView
	{
		protected override function initializeCamera():void
		{
			super.initializeCamera();
			_camera.x = 0;
			_camera.z = 0;
			_camera.y = _canonicalDistance + gameController.gameHeight;
			// set the up vector to be positive z axis
			_upVector = new Number3D(0.0, 0.0, 1.0);
		}
	}
}