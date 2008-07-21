package pblocks
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.core.UIComponent;
	
	import org.papervision3d.Papervision3D;
	import org.papervision3d.objects.DisplayObject3D;
	
	import pblocks.data.BasicBlockset;
	import pblocks.data.BlockGrid;
	import pblocks.data.Blockset;
	import pblocks.data.ExtendedBlockset;
	import pblocks.data.FlatBlockset;
	import pblocks.events.LayerEvent;
	import pblocks.events.PaperblocksEvent;
	import pblocks.geom.BlockAccumulationMesh;
	import pblocks.geom.BlocksMesh3D;
	import pblocks.geom.GameBorderMesh;
	import pblocks.util.Color;
	import pblocks.view.PaperblocksScene;

	// the events, would be nice if the name could be a reference to the static member of the event class
	[Event(name="levelChange", type="pblocks.events.PaperblocksEvent")]
	[Event(name="scoreChange", type="pblocks.events.PaperblocksEvent")]
	[Event(name="nextBlock", type="pblocks.events.PaperblocksEvent")]
	[Event(name="gameOver", type="pblocks.events.PaperblocksEvent")]
	[Event(name="gameStart", type="pblocks.events.PaperblocksEvent")]
	[Event(name="layerComplete", type="pblocks.events.LayerEvent")]
	[Event(name="borderChange", type="pblocks.events.PaperblocksEvent")]
	/**
	 * The main game controller class for paperblocks.
	 */
	public class PaperblocksController extends UIComponent
	{
		// Game settings
		[Bindable]
		public var numBlocksXNext:uint = _numBlocksX;
		[Bindable]
		public var numBlocksYNext:uint = _numBlocksY;
		[Bindable]
		public var numBlocksZNext:uint = _numBlocksZ;
		[Bindable]
		public var blocksetNext:Class = BasicBlockset;
		
		private var _numBlocksX:uint = 5;
		[Bindable]
		public function get numBlocksX():uint
		{
			return _numBlocksX;
		}
		private function set numBlocksX(n:uint):void
		{
			_numBlocksX = n;
		}
		
		private var _numBlocksY:uint = 12;
		[Bindable]
		public function get numBlocksY():uint
		{
			return _numBlocksY;
		}
		private function set numBlocksY(n:uint):void
		{
			_numBlocksY = n;
		}
		
		private var _numBlocksZ:uint = 5;
		[Bindable]
		public function get numBlocksZ():uint
		{
			return _numBlocksZ;
		}
		private function set numBlocksZ(n:uint):void
		{
			_numBlocksZ = n;
		}
		
		private var _layersPerLevel:uint= 4;
		[Bindable]
		public function get layersPerLevel():uint
		{
			return _layersPerLevel;
		}
		private function set layersPerLevel(n:uint):void
		{
			_layersPerLevel = n;
		}
		
		private var _initialStepDuration:uint = 2000;
		[Bindable]
		public function get initialStepDuration():uint
		{
			return _initialStepDuration;
		}
		private function set initialStepDuration(n:uint):void
		{
			_initialStepDuration = n;
		}
		
		private var _scoreMultiplier:Number = 100.0;
		[Bindable]
		public function get scoreMultiplier():Number
		{
			return _scoreMultiplier;
		}
		private function set scoreMultiplier(n:Number):void
		{
			_scoreMultiplier = n;
		}
		
		private var _blockset:Class = BasicBlockset;
		[Bindable]
		public function get blockset():Class
		{
			return _blockset;
		}
		private function set blockset(c:Class):void
		{
			_blockset = c;
		}
		
		public function get blocksetInstance():Blockset
		{
			return _blocksetInstance;
		}
		
		/**
		 * Returns a data provider for all the available blocksets.
		 */
		public function get availableBlocksets():Array
		{
			return [{label:BasicBlockset.NAME, data:BasicBlockset},
					{label:FlatBlockset.NAME, data:FlatBlockset},
					{label:ExtendedBlockset.NAME, data:ExtendedBlockset}];
		}
		
		public function getBlocksetIndex(blockset:Class):int
		{
			var blocksets:Array = availableBlocksets;
			for(var i:int = 0; i < blocksets.length; i++)
			{
				if(blocksets[i].data === blockset)
				{
					return i;
				}
			}
			return -1;
		}
		
		public function getBlockset(index:int):Class
		{
			return availableBlocksets[index].data;
		}
		
		public function get gameWidth():Number
		{
			return numBlocksX * PaperblocksScene.BLOCK_SIZE;
		}
		
		public function get gameHeight():Number
		{
			return numBlocksY *  PaperblocksScene.BLOCK_SIZE;
		}
		
		public function get gameDepth():Number
		{
			return numBlocksZ *  PaperblocksScene.BLOCK_SIZE;
		}
		
		// Display settings
		
		private var _blockOpacity:Number = 0.25;
		/**
		 * The opacity of the current block.
		 */
		[Bindable]
		public function get blockOpacity():Number
		{
			return _blockOpacity;
		}
		public function set blockOpacity(opacity:Number):void
		{
			_blockOpacity = opacity;
			invalidateProperties();
			
		}
		
		private var _showSideWalls:Boolean = true;
		[Bindable]
		public function get showSideWalls():Boolean
		{
			return _showSideWalls;
		}
		public function set showSideWalls(b:Boolean):void
		{
			_showSideWalls = b;
			invalidateProperties();
		}
		
		private var _colorByDepth:Boolean = true;
		[Bindable]
		public function get colorByDepth():Boolean
		{
			return _colorByDepth;
		}
		public function set colorByDepth(b:Boolean):void
		{
			_colorByDepth = b;
			invalidateProperties();
		}
		
		// Game stats
		private var _score:uint;
		private var _layers:uint;
		
		[Bindable(event="levelChange")]
		public function get level():uint
		{
			return layers / layersPerLevel;
		}
		
		[Bindable(event="scoreChange")]
		public function get score():uint
		{
			return _score;
		}
		
		[Bindable(event="layerComplete")]
		public function get layers():uint
		{
			return _layers;
		}
		
		[Bindable(event="layerComplete")]
		public function get layersRemaining():uint
		{
			return layersPerLevel - _layers % layersPerLevel;
		}
		
		private var _blocksPlayed:int;
		[Bindable(event="blockPlayed")]
		public function get blocksPlayed():int
		{
			return _blocksPlayed;
		}
		
		private var _scene:PaperblocksScene;
		private var _backgroundScene:PaperblocksScene;
		private var _timer:Timer;
		
		// The primary game container
		private var _game:DisplayObject3D;
		// Same as above except for the background scene
		private var _backgroundGame:DisplayObject3D;
		
		// The current block traversing the well
		private var _currentBlock:BlocksMesh3D;
		// The next block
		private var _nextBlock:BlocksMesh3D;
		
		// The blockset instance
		private var _blocksetInstance:Blockset
		
		// The accumulation of all the blocks
		private var _accumulation:BlockAccumulationMesh;
		private var _border:GameBorderMesh;
		
		public function PaperblocksController()
		{
			Papervision3D.useDEGREES = false;
			_scene = new PaperblocksScene(this);
			_backgroundScene = new PaperblocksScene(this);
		}
		
		public function get scene():PaperblocksScene
		{
			return _scene;
		}
		
		public function get backgroundScene():PaperblocksScene
		{
			return _backgroundScene;
		}
		
		[Bindable(event="nextBlock")]
		public function get nextBlock():BlocksMesh3D
		{
			return _nextBlock;
		}
		
		protected override function createChildren():void
		{
			_timer = new Timer(initialStepDuration);
			_timer.addEventListener(TimerEvent.TIMER, gameStep);
			_game = new DisplayObject3D();
			_scene.addChild(_game);
			_backgroundGame = new DisplayObject3D();
			_backgroundScene.addChild(_backgroundGame);
		}
		
		protected override function commitProperties():void
		{
			if(_currentBlock != null)
			{
				_currentBlock.blockMaterial.fillAlpha = _blockOpacity;
			}
			if(_border != null && _border.generateWalls != _showSideWalls)
			{
				_border.generateWalls = _showSideWalls;
				dispatchEvent(new PaperblocksEvent(PaperblocksEvent.BACKGROUND_CHANGE));
			}
			if(_accumulation != null)
			{
				_accumulation.colorByDepth = _colorByDepth;
			}
		}
		
		private function updateGameSettings():void
		{
			blockset = blocksetNext;
			_blocksetInstance = new blockset();
			numBlocksX = numBlocksXNext;
			numBlocksY = numBlocksYNext;
			numBlocksZ = numBlocksZNext;
			var gameX:Number = -gameWidth / 2;
			var gameZ:Number = -gameDepth / 2;
			_game.x = gameX;
			_game.z = gameZ;
			_backgroundGame.x = gameX;
			_backgroundGame.z = gameZ;
		}
		
		private function resetGameStats():void
		{
			_score = 0;
			_layers = 0;
			_blocksPlayed = 0;
			updateTimer();
			dispatchEvent(new PaperblocksEvent(PaperblocksEvent.LEVEL_CHANGE));
			dispatchEvent(new PaperblocksEvent(PaperblocksEvent.SCORE_CHANGE));
			dispatchEvent(new LayerEvent(LayerEvent.LAYER_COMPLETE, 0));
		}
		
		public function startGame():void
		{
			updateGameSettings();
			var gameGrid:BlockGrid = new BlockGrid(numBlocksX, numBlocksY, numBlocksZ);
			if(_accumulation != null)
			{
				_game.removeChild(_accumulation);
			}
			if(_border != null)
			{
				_backgroundGame.removeChild(_border);
			}
			removeCurrentBlock();
			prepareNextBlock();
			_accumulation = new BlockAccumulationMesh(gameGrid);
			_game.addChild(_accumulation);
			_border = new GameBorderMesh(gameGrid);
			_backgroundGame.addChild(_border);
			invalidateProperties();
			_gameStopped = false;
			resetGameStats();
			dispatchEvent(new PaperblocksEvent(PaperblocksEvent.GAME_START));
		}
		
		private var _gameStopped:Boolean = true;
		public function stopGame():void
		{
			_gameStopped = true;
			_timer.stop();
		}
		
		private function gameStep(e:Event = null):void
		{
			if(null == _currentBlock)
			{
				doNextBlock();
				return;
			}
			_currentBlock.changeJ(-1, true);
			if(-1 == _currentBlock.j || _currentBlock.intersects(_accumulation))
			{
				_currentBlock.changeJ(1, false);
				_currentBlock.blockMaterial.fillAlpha = 1.0;
				_accumulation.union(_currentBlock);
				_blocksPlayed++;
				dispatchEvent(new PaperblocksEvent(PaperblocksEvent.BLOCK_PLAYED));
				_border.updateGameBorder();
				if(_currentBlock.j + _currentBlock.blockHeight >= numBlocksY)
				{
					removeCurrentBlock();
					gameOver();
					return;
				}
				doNextBlock();
				checkLayers();
				return;
			}
		}
		
		public function lowerBlock():void
		{
			if(_gameStopped)
			{
				return;
			}
			gameStep();
			updateTimer();
		}
		
		private function checkLayers():void
		{
			var completedLayers:Array = _accumulation.completedLayers;
			for each(var j:int in completedLayers)
			{
				// completeLayers in stored in reverse order so this is ok
				_accumulation.removeLayer(j);
			}
			var numCompleted:int = completedLayers.length;
			if(numCompleted > 0)
			{
				_border.updateGameBorder();
				dispatchEvent(new PaperblocksEvent(PaperblocksEvent.BACKGROUND_CHANGE));
				var levelChange:Boolean = numCompleted >= layersRemaining;
				_layers += numCompleted;
				_score += numBlocksX * numBlocksZ * numCompleted * numCompleted * scoreMultiplier;
				dispatchEvent(new PaperblocksEvent(PaperblocksEvent.SCORE_CHANGE));
				if(levelChange)
				{
					changeLevel();
				}
				dispatchEvent(new LayerEvent(LayerEvent.LAYER_COMPLETE, numCompleted));
			}
		}
		
		/**
		 * Update the timer interval to reflect the current level.
		 */
		private function updateTimer():void
		{
			if(_gameStopped)
			{
				return;
			}
			_timer.reset();
			_timer.delay = initialStepDuration / Math.sqrt(level + 1);;
			_timer.start();
		}
		
		private function changeLevel():void
		{
			// change the border
			_border.color = Color.randomColor();
			updateTimer();
			dispatchEvent(new PaperblocksEvent(PaperblocksEvent.LEVEL_CHANGE));
		}
		
		private function gameOver():void
		{
			stopGame();
			dispatchEvent(new PaperblocksEvent(PaperblocksEvent.GAME_OVER));
		}
		
		public function moveCurrentBlock(dirI:int, dirK:int):void
		{
			if(null != _currentBlock)
			{
				_currentBlock.changeI(dirI, true);
				_currentBlock.changeK(dirK, true);
				if(!isCurrentBlockValid())
				{
					_currentBlock.changeI(-dirI, false);
					_currentBlock.changeK(-dirK, false);
				}
			}
		}
		
		public function rotateXCurrentBlock(dir:int):void
		{
			if(null == _currentBlock)
			{
				return;
			}
			_currentBlock.rotateX(dir, true);
			if(!isCurrentBlockValid())
			{
				_currentBlock.rotateX(-dir, false);
			}
		}
		
		public function rotateYCurrentBlock(dir:int):void
		{
			if(null == _currentBlock)
			{
				return;
			}
			_currentBlock.rotateY(dir, true);
			if(!isCurrentBlockValid())
			{
				_currentBlock.rotateY(-dir, false);
			}
		}
		
		public function rotateZCurrentBlock(dir:int):void
		{
			if(null == _currentBlock)
			{
				return;
			}
			_currentBlock.rotateZ(dir, true);
			if(!isCurrentBlockValid())
			{
				_currentBlock.rotateZ(-dir, false);
			}
		}
				
		private function isCurrentBlockValid():Boolean
		{
			return !(_currentBlock.i < 0 || _currentBlock.i > numBlocksX - _currentBlock.blockWidth
				|| _currentBlock.j < 0
				|| _currentBlock.k < 0 || _currentBlock.k > numBlocksZ - _currentBlock.blockDepth
				|| _currentBlock.intersects(_accumulation));
		}
		
		private function doNextBlock():void
		{
			removeCurrentBlock();
			_currentBlock = _nextBlock;
			_currentBlock.blockMaterial.fillAlpha = _blockOpacity;
			prepareNextBlock();
			_game.addChild(_currentBlock);
		}
		
		private function prepareNextBlock():void
		{
			_nextBlock = new BlocksMesh3D(_blocksetInstance.getBlock());	
			_nextBlock.i = (numBlocksX - _nextBlock.blockWidth) / 2;
			_nextBlock.k = (numBlocksZ - _nextBlock.blockDepth) / 2;
			_nextBlock.j = numBlocksY - _nextBlock.blockHeight;
			dispatchEvent(new PaperblocksEvent(PaperblocksEvent.NEXT_BLOCK));
		}
		
		private function removeCurrentBlock():void
		{
			if(_currentBlock != null)
			{
				_game.removeChild(_currentBlock);
				_currentBlock = null;
			}
		}
	}
}