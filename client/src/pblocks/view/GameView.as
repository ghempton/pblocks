package pblocks.view
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import mx.managers.IFocusManagerComponent;
	
	import org.ascollada.utils.FPS;
	
	import pblocks.events.PaperblocksEvent;
	
	// The main game view
	public class GameView extends PaperblocksView implements IFocusManagerComponent
	{
		private var _bg:Sprite;
		private var _cameraPhi:Number;
		private var _cameraTheta:Number;
		private var _cameraRadius:Number;
		
		private var _mouseDown:Boolean = false;
		private var _startPhi:Number;
		private var _startTheta:Number;
		private var _startMouseX:Number;
		private var _startMouseY:Number;
		
		private var _radiusDelta:Number;
		private var _thetaDelta:Number;
		private var _phiDelta:Number;
		private var _minPhi:Number;
		private var _maxPhi:Number;
		private var _maxRadius:Number;
		private var _minRadius:Number;
		
		private var _fps:FPS;
		private var _showFPS:Boolean = false;
		
		/* TODO: Enable perspective changing
		private var _defaultCanonicalZoom:Number = _canonicalZoom;
		[Bindable]
		public function get perspective():Number
		{
			return _canonicalZoom;
		}
		public function set perspective(p:Number):void
		{
			_canonicalZoom = 1/p * _defaultCanonicalZoom
		}
		*/
		
		[Bindable]
		public function get showFPS():Boolean
		{
			return _showFPS;
		}
		public function set showFPS(b:Boolean):void
		{
			_showFPS = b;
			invalidateProperties();
		}
		
		// The key bindings
		[Bindable]
		public var moveUpKey:int = 38;
		[Bindable]
		public var moveLeftKey:int = 37;
		[Bindable]
		public var moveDownKey:int = 40;
		[Bindable]
		public var moveRightKey:int = 39;
		[Bindable]
		public var lowerBlockKey:int = 32;
		[Bindable]
		public var restoreViewKey:int = 36;
		[Bindable]
		public var rotateCWXKey:int = 81;
		[Bindable]
		public var rotateCCWXKey:int = 65;
		[Bindable]
		public var rotateCWYKey:int = 87;
		[Bindable]
		public var rotateCCWYKey:int = 83;
		[Bindable]
		public var rotateCWZKey:int = 69;
		[Bindable]
		public var rotateCCWZKey:int = 68;
		
		public function GameView()
		{
			super();
		}
		
		protected override function gameStartHandler(e:PaperblocksEvent):void
		{
			super.gameStartHandler(e);
			initCameraSettings();
			restoreDefaultView();
			enableInteraction();
		}
		
		private function initCameraSettings():void
		{
			_radiusDelta = 10.0;
			_thetaDelta = .01;
			_phiDelta = .01;
			_minPhi = 0.0;
			_maxPhi = Math.PI / 2;
			_minRadius = _canonicalDistance;
			_maxRadius = _minRadius + 3 * gameController.gameHeight;
		}
		
		public function restoreDefaultView():void
		{
			cameraPhi = _maxPhi;
			cameraTheta = -Math.PI / 2;
			cameraRadius = _minRadius + gameController.gameHeight;
		}
		
		public function get cameraPhi():Number
		{
			return _cameraPhi;
		}
		
		public function set cameraPhi(r:Number):void
		{
			_cameraPhi = Math.min(_maxPhi, Math.max(_minPhi, r));
			invalidateProperties();
		}
		
		public function get cameraTheta():Number
		{
			return _cameraTheta;
		}
		
		public function set cameraTheta(r:Number):void
		{
			// convert to [0, 2pi)
			_cameraTheta = (r % (2 * Math.PI) + 2 * Math.PI) % (2 * Math.PI);
			invalidateProperties();
		}
		
		public function get cameraRadius():Number
		{
			return _cameraRadius;
		}
		
		public function set cameraRadius(d:Number):void
		{
			_cameraRadius = Math.min(_maxRadius, Math.max(_minRadius, d));
			invalidateProperties();
		}
		
		protected override function commitProperties():void
		{	
			super.commitProperties();
			if(null != _camera)
			{
				_camera.x = _cameraRadius * Math.cos(_cameraPhi) * Math.cos(_cameraTheta);
				_camera.z = _cameraRadius * Math.cos(_cameraPhi) * Math.sin(_cameraTheta);
				_camera.y = _cameraRadius * Math.sin(_cameraPhi);
			}
			if(_showFPS && !_viewport.contains(_fps))
			{
				_viewport.addChild(_fps);
			}
			else if(!_showFPS && _viewport.contains(_fps))
			{
				_viewport.removeChild(_fps);
			}
			_camera.lookAt(scene.gameCenter);
			invalidateBackground();
		}
		
		protected override function createChildren():void
		{
			_bg = new Sprite();
			addChild(_bg);
			super.createChildren();
			_fps = new FPS();
		}
		
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			drawBackground(unscaledWidth, unscaledHeight);
		}
		
		private function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
		{
			var g:Graphics = _bg.graphics;
			g.clear();
			g.beginFill(0, 0);
			g.drawRect(0, 0, unscaledWidth, unscaledHeight);
			g.endFill();
		}
		
		private function gameKeyDownHandler(e:KeyboardEvent):void
		{
			switch(e.keyCode)
			{
				case moveUpKey:
					gameController.moveCurrentBlock(0, 1);
					break;
				case moveLeftKey:
					gameController.moveCurrentBlock(-1, 0);
					break;
				case moveDownKey:
					gameController.moveCurrentBlock(0, -1);
					break;
				case moveRightKey:
					gameController.moveCurrentBlock(1, 0);
					break;
				case rotateCWXKey:
					gameController.rotateXCurrentBlock(1);
					break;
				case lowerBlockKey:
					gameController.lowerBlock();
					break;
				case restoreViewKey:
					restoreDefaultView();
					break;
				case rotateCCWXKey:
					gameController.rotateXCurrentBlock(-1);
					break;
				case rotateCWYKey:
					gameController.rotateYCurrentBlock(1);
					break;
				case rotateCCWYKey:
					gameController.rotateYCurrentBlock(-1);
					break;
				case rotateCWZKey:
					gameController.rotateZCurrentBlock(1);
					break;
				case rotateCCWZKey:
					gameController.rotateZCurrentBlock(-1);
					break;
			}
		}
		
		private function enableInteraction():void
		{
			focusManager.setFocus(this);
			addEventListener(KeyboardEvent.KEY_DOWN, gameKeyDownHandler, false, 0.0, true);
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0.0, true);
			addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, false, 0.0, true);
			addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, false, 0.0, true);
			addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler, false, 0.0, true);
		}
		
		private function disableInteraction():void
		{
			removeEventListener(KeyboardEvent.KEY_DOWN, gameKeyDownHandler);
			removeEventListener(MouseEvent.MOUSE_MOVE, mouseDownHandler);
			removeEventListener(MouseEvent.MOUSE_MOVE, mouseUpHandler);
			removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			removeEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
		}
		
		protected function mouseDownHandler(e:MouseEvent):void
		{
			_mouseDown = true;
			_startMouseX = e.stageX;
			_startMouseY = e.stageY;
			_startPhi = cameraPhi;
			_startTheta = cameraTheta;
		}
		
		protected function mouseUpHandler(e:MouseEvent):void
		{
			_mouseDown = false;
		}
		
		protected function mouseMoveHandler(e:MouseEvent):void
		{
			if(_mouseDown)
			{
				var dx:Number = e.stageX - _startMouseX;
				var dy:Number = e.stageY - _startMouseY;
				cameraTheta = _startTheta + _thetaDelta * dx;
				cameraPhi = _startPhi - _phiDelta * dy;
			}
		}
		
		protected function mouseWheelHandler(e:MouseEvent):void
		{
			var delta:Number = -e.delta * _radiusDelta;
			cameraRadius += delta;
		}
	}
}