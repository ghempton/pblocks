package pblocks.util
{
	public class Color
	{
		public static function brighten(color:uint, amount:Number):uint
		{
			var r:uint = color >> 16 & 0xff;
			var g:uint = color >> 8 & 0xff;
			var b:uint = color & 0xff;
			
			r += (0xff - r) * amount;
			g += (0xff - g) * amount;
			b += (0xff - b) * amount;
			
			return (r << 16) + (g << 8) + b;
		}
		
		public static function darken(color:uint, amount:Number):uint
		{
			var r:uint = color >> 16 & 0xff;
			var g:uint = color >> 8 & 0xff;
			var b:uint = color & 0xff;
			
			r -= r * amount;
			g -= g * amount;
			b -= b * amount;
			
			return (r << 16) + (g << 8) + b;
		}
		
		public static function randomColor():uint
		{
			return Math.round(Math.random() * 0xffffff);
		}
	}
}