package org.papervision3d.materials.special
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.papervision3d.core.geom.renderables.Particle;
	import org.papervision3d.core.render.data.RenderSessionData;
	import org.papervision3d.core.render.draw.IParticleDrawer;
	/**
	 * A Particle material that is made from BitmapData object
	 * 
	 * @author Ralph Hauwert
 	 * @author Seb Lee-Delisle
  	 */
	public class BitmapParticleMaterial extends ParticleMaterial implements IParticleDrawer
	{
		
		private var scaleMatrix:Matrix;
		
		private var renderRect:Rectangle; 
		
		public var offset : Point = new Point(); 
	
		/**
		 * 
		 * @param bitmap	The BitmapData object to make the material from. 
		 * 
		 */		
		public function BitmapParticleMaterial(bitmap:BitmapData)
		{
			super(0,0);
			this.bitmap = bitmap;
			this.scaleMatrix = new Matrix();
			renderRect = new Rectangle() ;
		}
		
		/**
		 * Draws the particle as part of the render cycle. 
		 *  
		 * @param particle			The particle we're drawing
		 * @param graphics			The graphics object we're drawing into
		 * @param renderSessionData	The renderSessionData for this render cycle.
		 * 
		 */	
		 
		override public function drawParticle(particle:Particle, graphics:Graphics, renderSessionData:RenderSessionData):void
		{
			var newscale : Number = particle.renderScale*particle.size/bitmap.width;
			
			
			scaleMatrix.identity(); 
			scaleMatrix.tx = 0; // add bitmap offsets here
			scaleMatrix.ty = 0; //
			scaleMatrix.scale(newscale, newscale);
			
			scaleMatrix.translate(particle.vertex3D.vertex3DInstance.x, particle.vertex3D.vertex3DInstance.y); 
			
			
			var cullingrect:Rectangle = renderSessionData.viewPort.cullingRectangle;
			renderRect = cullingrect.intersection(particle.renderRect);
			graphics.beginBitmapFill(bitmap, scaleMatrix, false, smooth);
			graphics.drawRect(renderRect.x, renderRect.y, renderRect.width, renderRect.height);
			graphics.endFill();
			renderSessionData.renderStatistics.particles++;
			
		}
		
		
		 
		 /**
		 * This is called during the projection cycle. It updates the rectangular area that 
		 * the particle is drawn into. It's important for the culling phase. 
		 *  
		 * @param particle	The particle whose renderRect we're updating. 
		 * 
		 */			
		override public function updateRenderRect(particle : Particle) :void
		{
			
			var renderrect:Rectangle = particle.renderRect; 
			
			var newscale : Number = particle.renderScale*particle.size/bitmap.width;
			
			var osx:Number = 0;// TODO add "offset.x * newscale" here when bitmap offset is integrated. 
			var osy:Number = 0;//
			
			renderrect.x = particle.vertex3D.vertex3DInstance.x+osx;
			renderrect.y = particle.vertex3D.vertex3DInstance.y+osy;
			renderrect.width = newscale*bitmap.width;
			renderrect.height = newscale*bitmap.height;
			
			
		}
		
		
	}
}