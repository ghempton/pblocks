package pblocks.style
{
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.InterpolationMethod;
	import flash.display.SpreadMethod;
	import flash.geom.Matrix;
	
	import mx.core.IFlexDisplayObject;

	/**
	 * A simple skin for drawing the background of the game.
	 */
	public class BackgroundSkin extends Sprite implements IFlexDisplayObject
	{
		private const _color1:uint = 0xcccccc;
		private const _color2:uint = 0x0099cc;
		
		private var _width:Number = 0.0;
		private var _height:Number = 0.0;
		
		public function BackgroundSkin()
		{
			super();
		}
		
		public function get measuredWidth():Number
		{
			return 0.0;
		}
		
		public function get measuredHeight():Number
		{
			return 0.0;
		}
		
		public function move(x:Number, y:Number):void
		{
			this.x = x;
			this.y = y;
		}
		
		public function setActualSize(newWidth:Number, newHeight:Number):void
		{
			width = newWidth;
			height = newHeight;
			drawBackground();
		}
		
		public override function get width():Number
		{
			return _width;
		}
		public override function set width(value:Number):void
		{
			_width = value;
		}
		
		public override function get height():Number
		{
			return _height;
		}
		public override function set height(value:Number):void
		{
			_height = value;
		}
		
		private function drawBackground():void
		{
			var g:Graphics = graphics;
			g.clear();
			
			var type:String = GradientType.RADIAL;
			var colors:Array = [_color1, _color2];
			var alphas:Array = [1, 1];
			var ratios:Array = [0, 255];
			var spreadMethod:String = SpreadMethod.PAD;
			var interp:String = InterpolationMethod.RGB;
			var focalPtRatio:Number = 0;
			
			var matrix:Matrix = new Matrix();
			var boxRotation:Number = Math.PI/2;
			var tx:Number = 0;
			var ty:Number = 0;
			matrix.createGradientBox(width, height, boxRotation, tx, ty);
			
			g.beginGradientFill(type, 
			                colors,
			                alphas,
			                ratios, 
			                matrix, 
			                spreadMethod, 
			                interp, 
			                focalPtRatio);
			                
			g.drawRect(0, 0, width, height);
			g.endFill();
		}
		
	}
}