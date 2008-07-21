package pblocks.view
{
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.objects.DisplayObject3D;
	
	public class SideView extends OrthographicView
	{
		protected override function get _canonicalDistance():Number
		{
			var size:Number = Math.min(gameController.gameWidth, gameController.gameHeight) / 2;
			var canonicalSize:Number = Math.max(_canonicalWidth, _canonicalHeight) / 2;
			return _canonicalFocus * ((_canonicalZoom * size - canonicalSize) / canonicalSize);
		}
		
		protected override function initializeCamera():void
		{
			super.initializeCamera();
			_lookTarget = new DisplayObject3D();
			_lookTarget.y = gameController.gameHeight / 2;
			_camera.y = _lookTarget.y;
			_camera.x = 0;
			_camera.z = -_canonicalDistance + gameController.gameDepth;
		}
	}
}