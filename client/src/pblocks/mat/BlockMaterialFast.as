package pblocks.mat
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	
	import org.papervision3d.core.render.command.RenderTriangle;
	import org.papervision3d.core.render.data.RenderSessionData;
	/**
	 * The same as BlockMaterial, but assumes that the triangle vertices are already ordered
	 * such that the first vertex is the one with the largest incident angle, rather than calculating
	 * that at render time.
	 */
	public class BlockMaterialFast extends BlockMaterial
	{
		public function BlockMaterialFast(color:uint=0xcccccc)
		{
			super(color);
		}
		
		public override function drawTriangle(face3D:RenderTriangle, graphics:Graphics, renderSessionData:RenderSessionData, altBitmap:BitmapData=null, altUV:Matrix=null):void
		{
			drawHalfQuad(graphics, face3D.triangle.v0, face3D.triangle.v1, face3D.triangle.v2);

			renderSessionData.renderStatistics.triangles++;
		}
	}
}