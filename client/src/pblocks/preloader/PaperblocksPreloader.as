package pblocks.preloader
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.geom.Point;
	import flash.utils.getTimer;
	
	import mx.effects.Tween;
	import mx.effects.easing.Circular;
	import mx.events.FlexEvent;
	import mx.preloaders.IPreloaderDisplay;
	
	import pblocks.style.BackgroundSkin;

	/**
	 * The PaperBlocks preloader.
	 * TODO: Clean the hell out of this class. I hacked it together.
	 */
	public class PaperblocksPreloader extends Sprite implements IPreloaderDisplay
	{
		private const _blockSize:Number = 18.0;
		private const _blockWidth:uint = 3;
		private const _blockHeight:uint = 7;
		private const _blockDepth:uint = 3;
		
		private const _blockInterval:int = 1;
		private const _blockTweenDuration:int = 100;
		private const _blockTweenDistance:int = 40;
		
		private var _preloader:Sprite;
		private var _bg:BackgroundSkin;
		
		private var _blockCounts:Array;
		private var _validIndices:Array;
		
		private var _blockContainer:Sprite;
		private var _startTime:int;
		private var _lastTime:int;
		private var _numBlocksCurr:int;
		private var _numBlocksTarget:int;
		
		private var _blockComplete:Boolean = false;
		private var _loadComplete:Boolean = false;
		
		public function PaperblocksPreloader()
		{
			super();
			_bg = new BackgroundSkin();
			addChild(_bg);
			
			_blockCounts = new Array(_blockWidth * _blockDepth);
			_validIndices = new Array(_blockWidth, _blockHeight);
			var i:int;
			for(i = 0; i < _blockWidth * _blockDepth; i++)
			{
				_blockCounts[i] = 0;
				_validIndices[i] = i;
			}
			
			_blockContainer = new Sprite();
			addChild(_blockContainer);
			
			// dummy shapes to fill depth
			var j:int;
			var k:int;
			for(i = 0; i < _blockWidth * 2; i++)
			{
				for(j = 0; j < _blockHeight; j++)
				{
					for(k = 0; k < _blockDepth * 2; k++)
					{
						_blockContainer.addChild(new Shape());
					}
				}
			}
		}
		
		private function getBlockIndex(i:int, j:int):int
		{
			return j * i + i;
		}
		
		private function getBlockPoint(index:int):Point
		{
			var p:Point = new Point();
			p.x = index % _blockWidth;
			p.y = Math.floor(index / _blockDepth);
			return p;
		}
		
		private function getBlockDepth(i:int, j:int, k:int):int
		{
			var maxLayerDepth:int = _blockWidth * _blockDepth * 2;
			var layerDepth:int = maxLayerDepth - ((i + k) * ( i + k + 1) / 2 + k);
			var depth:int = layerDepth + j * maxLayerDepth;
			trace(i, j, k, depth);
			return depth;
		}
		
		private function getRandomValidBlockIndex():int
		{
			return _validIndices[Math.round(Math.random() * (_validIndices.length - 1))];
		}
		
		private function get numBlocksTotal():int
		{
			return _blockWidth * _blockHeight * _blockDepth;
		}
		
		private function doBlock():void
		{
			var index:int = getRandomValidBlockIndex();
			var block:PreloaderBlock = new PreloaderBlock();
			var p:Point = getBlockPoint(index);
			block.isoWidth = _blockSize;
			block.isoHeight = _blockSize;
			block.isoDepth = _blockSize;
			block.isoX = p.x * _blockSize;
			block.isoZ = p.y * _blockSize;
			block.isoY = _blockCounts[index] * _blockSize + _blockTweenDistance;
			var depth:int = getBlockDepth(p.x, _blockCounts[index], p.y);
			_blockCounts[index]++;
			if(_blockCounts[index] == _blockHeight)
			{
				for(var i:int = 0; i < _validIndices.length; i++)
				{
					if(_validIndices[i] == index)
					{
						_validIndices.splice(i, 1);
						break;
					}
				}
			}
			block.draw();
			_blockContainer.removeChildAt(depth);
			// TODO: Figure out why addChildAt complains of null child parameter sporadically
			if(block != null)
			{
				_blockContainer.addChildAt(block, depth);
			}
			var tween:Tween = new Tween(block, block.isoY, block.isoY - _blockTweenDistance, _blockTweenDuration);
			tween.easingFunction = Circular.easeOut;
			tween.setTweenHandlers(function(d:Number):void {block.isoY = d; block.draw();},
									 function(d:Number):void {block.isoY = d; block.draw();});
		}
		
		public function set preloader(obj:Sprite):void
		{
			_preloader = obj;
			_preloader.addEventListener( ProgressEvent.PROGRESS , progressHandler );    
            _preloader.addEventListener( Event.COMPLETE , completeHandler );
            _preloader.addEventListener( FlexEvent.INIT_PROGRESS , flexProgressHandler );
            _preloader.addEventListener( FlexEvent.INIT_COMPLETE , flexCompleteHandler );
		}
		
		public function initialize():void
		{
			_startTime = flash.utils.getTimer();
			_lastTime = _startTime;
			_numBlocksCurr = 0;
			_numBlocksTarget = 0;
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		private function enterFrameHandler(e:Event):void
		{
			var currTime:int = getTimer();
			if(_numBlocksCurr < _numBlocksTarget && currTime - _lastTime > _blockInterval)
			{
				_lastTime = currTime;
				doBlock();
				_numBlocksCurr++;
				if(_numBlocksCurr == numBlocksTotal)
				{
					if(_loadComplete)
					{
						dispatchEvent(new Event(Event.COMPLETE));
					}
					else
					{
						_blockComplete = true;
					}
				}
			}
		}
		
		private function progressHandler(e:ProgressEvent):void
		{
			_numBlocksTarget = Math.round(e.bytesLoaded / e.bytesTotal * numBlocksTotal);
		}
		
		private function completeHandler(e:Event):void
		{
			trace("Complete");
		}
		
		private function flexProgressHandler(e:FlexEvent):void
		{
		}
		
		private function flexCompleteHandler(e:FlexEvent):void
		{
			if(_blockComplete)
			{
				dispatchEvent(new Event(Event.COMPLETE));
			}
			else
			{
				_loadComplete = true;
			}
		}
		
		public function get stageHeight():Number
		{
			return 0;
		}
		
		public function set stageHeight(value:Number):void
		{
			_bg.setActualSize(_bg.width, value);
			_blockContainer.y = (value + _blockHeight * _blockSize) / 2.0;
		}
		
		public function get stageWidth():Number
		{
			return 0;
		}
		
		public function set stageWidth(value:Number):void
		{
			_bg.setActualSize(value, _bg.height);
			_blockContainer.x = value / 2;
		}
		
		// THE PROPERTIES BELOW ARE UNUSED ?
		
		public function get backgroundAlpha():Number
		{
			return 0;
		}
		
		public function set backgroundAlpha(value:Number):void
		{
		}
		
		public function get backgroundColor():uint
		{
			return 0;
		}
		
		public function set backgroundColor(value:uint):void
		{
		}
		
		public function get backgroundImage():Object
		{
			return null;
		}
		
		public function set backgroundImage(value:Object):void
		{
		}
		
		public function get backgroundSize():String
		{
			return null;
		}
		
		public function set backgroundSize(value:String):void
		{
		}
		
	}
}
