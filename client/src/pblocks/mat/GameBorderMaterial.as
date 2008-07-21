package pblocks.mat
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.utils.Dictionary;
	
	import org.papervision3d.core.geom.renderables.Triangle3D;
	import org.papervision3d.core.render.data.RenderSessionData;
	
	import pblocks.util.Color;
	import pblocks.view.PaperblocksScene;
	
	public class GameBorderMaterial extends BlockMaterialFast
	{
		private var _color1:uint;
		private var _color2:uint;
		
		private var _colors:Dictionary;
		
		public function GameBorderMaterial()
		{
			super(0xefefef);
			doubleSided = false;
			color = fillColor;
		}
		
		public override function set color(c:uint):void
		{
			super.color = c;
			_color1 = fillColor;
			_color2 = Color.darken(fillColor, .02);
			_colors = new Dictionary(true);
		}
		
		public override function drawTriangle(face3D:Triangle3D, graphics:Graphics, renderSessionData:RenderSessionData, altBitmap:BitmapData=null, altUV:Matrix=null):void
		{
			if(_colors[face3D] == null)
			{
				// determine which of the alternate colors we are going to use
				var x:Number = (face3D.v0.x + face3D.v1.x + face3D.v2.x) / 3;
				var y:Number = (face3D.v0.y + face3D.v1.y + face3D.v2.y) / 3;
				var z:Number = (face3D.v0.z + face3D.v1.z + face3D.v2.z) / 3;
				var alternate:int = int(x / PaperblocksScene.BLOCK_SIZE) % 2;
				alternate ^= int(y / PaperblocksScene.BLOCK_SIZE) % 2;
				alternate ^= int(z / PaperblocksScene.BLOCK_SIZE) % 2;
				_colors[face3D] = alternate == 0 ? _color1 : _color2;
			}
			fillColor = _colors[face3D];
			super.drawTriangle(face3D, graphics, renderSessionData, altBitmap, altUV);
		}
	}
}