package pblocks.view
{
	import flash.events.Event;
	
	import mx.core.UIComponent;
	
	import org.papervision3d.cameras.FreeCamera3D;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.core.proto.CameraObject3D;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.render.BasicRenderEngine;
	import org.papervision3d.view.Viewport3D;
	
	import pblocks.PaperblocksController;
	import pblocks.events.PaperblocksEvent;

	public class PaperblocksView extends UIComponent
	{
		protected var _canonicalWidth:Number = 100.0;
		protected var _canonicalHeight:Number = 100.0;
		protected var _canonicalZoom:Number = 1.0;
		protected var _canonicalFocus:Number = 100.0;
		protected function get _canonicalDistance():Number
		{
			var size:Number = Math.min(gameController.gameWidth, gameController.gameDepth) / 2;
			var canonicalSize:Number = Math.max(_canonicalWidth, _canonicalHeight) / 2;
			return _canonicalFocus * ((_canonicalZoom * size - canonicalSize) / canonicalSize);
		}
		
		protected var _camera:CameraObject3D;
		protected var _height:Number;
		protected var _width:Number;
		
		protected var _gameController:PaperblocksController;
		protected var _viewport:Viewport3D;
		protected var _backgroundViewport:Viewport3D;
		protected var _renderer:BasicRenderEngine;
		
		protected var _lookTarget:DisplayObject3D;
		protected var _upVector:Number3D = new Number3D(0.0, 1.0, 0.0);
		
		private var _backgroundValid:Boolean = true;
		
		public function PaperblocksView()
		{
			super();
		}
		
		public function invalidateBackground():void
		{
			_backgroundValid = false;
		}
		
		public function get gameController():PaperblocksController
		{
			return _gameController;
		}
		
		public function set gameController(g:PaperblocksController):void
		{
			_gameController = g;
			_gameController.addEventListener(PaperblocksEvent.GAME_START, gameStartHandler, false, 0, true);
			_gameController.addEventListener(PaperblocksEvent.GAME_OVER, gameOverHandler, false, 0, true);
			_gameController.addEventListener(PaperblocksEvent.BACKGROUND_CHANGE, backgroundChangeHandler, false, 0, true);
			initializeView();
		}
		
		protected function gameStartHandler(e:PaperblocksEvent):void
		{
			initializeView();
		}
		
		private function initializeView():void
		{
			initializeCamera();
			updateCamera();
			invalidateBackground();
			startRendering();
		}
		
		protected function gameOverHandler(e:PaperblocksEvent):void
		{
			
		}
		
		protected function backgroundChangeHandler(e:PaperblocksEvent):void
		{
			invalidateBackground();
		}
		
		protected function get scene():PaperblocksScene
		{
			if(null == _gameController)
			{
				return null;
			}
			return _gameController.scene;
		}
		
		protected function get backgroundScene():PaperblocksScene
		{
			if(null == _gameController)
			{
				return null;
			}
			return _gameController.backgroundScene;
		}
		
		protected function initializeCamera():void
		{
			_camera = new FreeCamera3D();
			_camera.focus = _canonicalFocus;
			_lookTarget = scene.gameCenter;
		}
		
		protected function updateCamera():void
		{
			if(null == _camera)
			{
				return;
			}
			var scaleX:Number = width / _canonicalWidth;
			var scaleY:Number = height / _canonicalHeight;
			var scale:Number = Math.min(scaleX, scaleY);
			_camera.zoom = _canonicalZoom * scale;
			_camera.lookAt(_lookTarget, _upVector);
		}
		
		protected override function createChildren():void
		{
			super.createChildren();
			_backgroundViewport = new Viewport3D(width, height, false, false, false, false);
			addChild(_backgroundViewport);
			_viewport = new Viewport3D(width, height, false, false, false, false);
			addChild(_viewport);
			_renderer = new BasicRenderEngine();
		}
		
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			_viewport.viewportWidth = unscaledWidth;
			_viewport.viewportHeight = unscaledHeight;
			_backgroundViewport.viewportWidth = unscaledWidth;
			_backgroundViewport.viewportHeight = unscaledHeight;
			invalidateBackground();
			updateCamera();
		}
		
		public function startRendering():void
		{
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			// TODO: how does the below affect perf?
			_viewport.containerSprite.cacheAsBitmap = true;
			_backgroundViewport.containerSprite.cacheAsBitmap = true;
		}
		
		public function stopRendering(reRender:Boolean = false, cacheAsBitmap:Boolean = false):void
		{
			removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			if(reRender)
			{
				singleRender();
			}
			if(cacheAsBitmap)
			{
				_viewport.containerSprite.cacheAsBitmap = true;
				_backgroundViewport.containerSprite.cacheAsBitmap = true;
			}
			else
			{
				_viewport.containerSprite.cacheAsBitmap = false;
				_backgroundViewport.containerSprite.cacheAsBitmap = false;
			}
		}
		
		public function singleRender():void
		{
			if(!_backgroundValid)
			{
				renderBackground();
				_backgroundValid = true;
			}
			renderScene();
		}
		
		public function renderScene():void
		{
			if(null == scene || null == _camera || null == _viewport)
			{
				return;
			}
			_renderer.renderScene(scene, _camera, _viewport);
		}
		
		public function renderBackground():void
		{
			if(null == backgroundScene || null == _camera || null == _backgroundViewport)
			{
				return;
			}
			_renderer.renderScene(backgroundScene, _camera, _backgroundViewport);
		}
		
		protected function enterFrameHandler(event:Event = null):void
		{
			singleRender();
		}
	}
}