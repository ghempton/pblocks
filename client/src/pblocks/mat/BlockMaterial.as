package pblocks.mat
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.LineScaleMode;
	import flash.geom.Matrix;
	
	import org.papervision3d.core.geom.renderables.Triangle3D;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.core.material.TriangleMaterial;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.core.render.data.RenderSessionData;
	import org.papervision3d.core.render.draw.ITriangleDrawer;
	
	import pblocks.util.Color;

	/**
	 * The main material used for the blocks.
	 */
	public class BlockMaterial extends TriangleMaterial implements ITriangleDrawer
	{
		public function BlockMaterial(color:uint=0xcccccc)
		{
			lineAlpha = 1.0;
			lineThickness = 1.0;
			fillAlpha = 1.0;
			this.color = color;
			doubleSided = true;
		}
		
		public function get color():uint
		{
			return fillColor;
		}
		
		public function set color(c:uint):void
		{
			fillColor = c;
			lineColor = Color.darken(c, 0.5);
		}
		
		public override function drawTriangle(face3D:Triangle3D, graphics:Graphics, renderSessionData:RenderSessionData, altBitmap:BitmapData=null, altUV:Matrix=null):void
		{
			// find the corner vertex
			var vert1:Vertex3D, vert2:Vertex3D, vert3:Vertex3D;
			var minVal:Number = Number.MAX_VALUE;
			
			for(var i:int = 0; i < face3D.vertices.length; i++)
			{
				var curr:Vertex3D = Vertex3D(face3D.vertices[i]);
				var prev:Vertex3D = Vertex3D(face3D.vertices[(i - 1 + face3D.vertices.length) % face3D.vertices.length]);
				var next:Vertex3D = Vertex3D(face3D.vertices[(i + 1) % face3D.vertices.length]);
				var v1:Number3D = Number3D.sub(prev.toNumber3D(), curr.toNumber3D());
				var v2:Number3D = Number3D.sub(next.toNumber3D(), curr.toNumber3D());
				var dot:Number = Number3D.dot(v1, v2);
				if(dot < minVal)
				{
					vert1 = curr;
					vert2 = prev;
					vert3 = next;
					minVal = dot;
				}
			}
			
			// draw the edges of the corner
			drawHalfQuad(graphics, vert1, vert2, vert3);

			renderSessionData.renderStatistics.triangles++;
		}
		
		protected function drawHalfQuad(graphics:Graphics, vert1:Vertex3D, vert2:Vertex3D, vert3:Vertex3D):void
		{
			graphics.beginFill(fillColor, fillAlpha);
			graphics.lineStyle( lineThickness, lineColor, lineAlpha, false, LineScaleMode.NONE );
			graphics.moveTo( vert1.vertex3DInstance.x, vert1.vertex3DInstance.y );
			graphics.lineTo( vert2.vertex3DInstance.x, vert2.vertex3DInstance.y );
			graphics.lineStyle();
			graphics.lineTo( vert3.vertex3DInstance.x, vert3.vertex3DInstance.y );
			graphics.lineStyle( lineThickness, lineColor, lineAlpha, false, LineScaleMode.NONE );
			graphics.lineTo( vert1.vertex3DInstance.x, vert1.vertex3DInstance.y );
			graphics.lineStyle();
			graphics.endFill();
		}
	}
}