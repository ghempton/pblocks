package pblocks.preloader
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	
	import pblocks.util.Color;

	/**
	 * Simple isometric block for preloader.
	 */
	public class PreloaderBlock extends Sprite
	{
		private const ISO_ANGLE:Number = Math.asin(Math.tan(Math.PI / 6));
		private var _color:uint;
		private var _lineColor:uint;
		
		private var _isoX:Number = 0.0;
		private var _isoY:Number = 0.0;
		private var _isoZ:Number = 0.0;
		private var _isoWidth:Number = 4.0;
		private var _isoHeight:Number = 4.0;
		private var _isoDepth:Number = 4.0;
		
		public function PreloaderBlock()
		{
			super();
			color = Color.randomColor();
		}
		
		public function get color():Number
		{
			return _color;
		}
		public function set color(value:Number):void
		{
			_color = value;
			_lineColor = Color.brighten(value, .2);
		}
		
		public function get isoX():Number
		{
			return _isoX;
		}
		public function set isoX(value:Number):void
		{
			_isoX = value;
			projectLocation();
		}
		
		public function get isoY():Number
		{
			return _isoY;
		}
		public function set isoY(value:Number):void
		{
			_isoY = value;
			projectLocation();
		}
		
		public function get isoZ():Number
		{
			return _isoZ;
		}
		public function set isoZ(value:Number):void
		{
			_isoZ = value;
			projectLocation();
		}
		
		private function projectLocation():void
		{
			x = (_isoX - _isoZ) * Math.cos(ISO_ANGLE);
			y = - (_isoX + _isoZ) * Math.sin(ISO_ANGLE) - isoY;
		}
		
		public function get isoWidth():Number
		{
			return _isoWidth;
		}
		public function set isoWidth(value:Number):void
		{
			_isoWidth = value;
		}
		
		public function get isoHeight():Number
		{
			return _isoWidth;
		}
		public function set isoHeight(value:Number):void
		{
			_isoWidth = value;
		}
		
		public function get isoDepth():Number
		{
			return _isoWidth;
		}
		public function set isoDepth(value:Number):void
		{
			_isoWidth = value;
		}
		
		public function draw():void
		{
			var g:Graphics = graphics;
			g.clear();
			g.moveTo(0,0);
			g.lineStyle(1.0, _lineColor);
			// draw the exterior border with the fill
			var sideWidthX:Number = Math.cos(ISO_ANGLE) * isoWidth;
			var sideHeightX:Number = Math.sin(ISO_ANGLE) * isoWidth;
			var sideWidthZ:Number = Math.cos(ISO_ANGLE) * isoDepth;
			var sideHeightZ:Number = Math.sin(ISO_ANGLE) * isoDepth;
			g.beginFill(_color, 1);
			g.moveTo(0,0);
			g.lineTo(sideWidthX, - sideHeightX);
			g.lineTo(sideWidthX, - sideHeightX - isoHeight);
			g.lineTo(sideWidthX - sideWidthZ, - sideHeightX - sideHeightZ - isoHeight);
			g.lineTo(sideWidthX - 2 * sideWidthZ, - sideHeightX - isoHeight);
			g.lineTo(sideWidthX - 2 * sideWidthZ, - sideHeightX);
			g.lineTo(0,0);
			g.endFill();
			// Fill in the remaining lines
			g.lineTo(0, - isoHeight);
			g.lineTo(sideWidthX, - sideHeightX - isoHeight);
			g.moveTo(0, - isoHeight);
			g.lineTo(-sideWidthZ, - sideHeightZ - isoHeight);
		}
	}
}