package org.papervision3d.core.clipping
{
	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.core.geom.renderables.Triangle3D;
	import org.papervision3d.core.math.Matrix3D;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.core.math.Plane3D;
	import org.papervision3d.core.math.util.ClassificationUtil;
	import org.papervision3d.core.math.util.TriangleUtil;
	import org.papervision3d.core.proto.MaterialObject3D;
	import org.papervision3d.core.render.data.RenderSessionData;
	import org.papervision3d.objects.DisplayObject3D;
	
	public class FrustumClipping extends DefaultClipping
	{
		
		public var selectedPlanes:int = 0;
		private var project_scale:Number = 1;
		private var angle_horizontal:Number =  0;
		private var angle_vertical:Number   =  0;
		private var sh:Number               =  0;
		private var sv:Number               =  0;
		private var ch:Number               =  0;
		private var cv:Number               =  0;
		

		private var _bottomPlane:Plane3D = new Plane3D();
		private var _topPlane:Plane3D = new Plane3D();
		private var _leftPlane:Plane3D = new Plane3D();
		private var _rightPlane:Plane3D = new Plane3D();
		private var _nearPlane:Plane3D = new Plane3D();
		
		private var bNormal:Number3D = new Number3D();
		private var tNormal:Number3D = new Number3D(); 
		private var lNormal:Number3D = new Number3D();
		private var rNormal:Number3D = new Number3D();
		private var nNormal:Number3D = new Number3D();
		
		private var _forward:Number3D = new Number3D();
		
		private var repo:Array = new Array();
		private var cTriangle:Number = 0;
		
		public function FrustumClipping(planes:Number = 2)
		{
			super();
			
			selectedPlanes = planes;
			
		}
		
		public override function reset(renderSessionData:RenderSessionData):void{
			 
			  project_scale = 265;//renderSessionData.camera.fov*(renderSessionData.camera.zoom/10);
			 
			  angle_horizontal =  Math.atan2(renderSessionData.viewPort.viewportWidth/2,project_scale)-0.0001;
			  angle_vertical  =  Math.atan2(renderSessionData.viewPort.viewportHeight/2,project_scale)-0.0001;
			  sh          =  Math.sin(angle_horizontal);
			  sv            =  Math.sin(angle_vertical);
			  ch           =  Math.cos(angle_horizontal);
			  cv          =  Math.cos(angle_vertical);
			  
			  cTriangle = 0;

		}
		
		public override function setDisplayObject(object:DisplayObject3D, renderSessionData:RenderSessionData):void{
			getPlanes(Camera3D(renderSessionData.camera), object);
		}
		
		public override function testFace(triangle:Triangle3D, object:DisplayObject3D, renderSessionData:RenderSessionData):Boolean{

			/* var classification:Number = 0;
			
			if((selectedPlanes & NEAR)){
				classification =ClassificationUtil.classifyTriangle(triangle, _nearPlane);
				if(classification == ClassificationUtil.STRADDLE || classification == ClassificationUtil.BACK)
					return true;
				
			}
				
			if((selectedPlanes & BOTTOM)){
				classification = ClassificationUtil.classifyTriangle(triangle, _bottomPlane);
				if(classification == ClassificationUtil.STRADDLE || classification == ClassificationUtil.BACK)
					return true;
			}
			
			if((selectedPlanes & TOP)){
				classification = ClassificationUtil.classifyTriangle(triangle, _topPlane);
				if(classification == ClassificationUtil.STRADDLE || classification == ClassificationUtil.BACK)
					return true;	
			}
			
			if((selectedPlanes & LEFT)){
				classification = ClassificationUtil.classifyTriangle(triangle, _leftPlane);
				if(classification == ClassificationUtil.STRADDLE || classification == ClassificationUtil.BACK)
					return true;
			}
			
			if((selectedPlanes & RIGHT)){
				classification = ClassificationUtil.classifyTriangle(triangle, _rightPlane);
				if(classification == ClassificationUtil.STRADDLE || classification == ClassificationUtil.BACK)
					return true;
			}
				
			return false; */
			
			//testing is now needed in the actual loop, so lets not waste time
			return true;

		}
		
		private function getPlanes(camera:Camera3D, object:DisplayObject3D):void{
			
			
			var cMatrix:Matrix3D = Matrix3D.inverse(object.view);
			var cPos:Number3D = new Number3D(cMatrix.n14, cMatrix.n24, cMatrix.n34);
			
			setNearPlane(cPos, cMatrix, camera);
			setPlane(_bottomPlane, bNormal, cPos, cMatrix, 0, -cv, sv);
			setPlane(_topPlane, tNormal, cPos, cMatrix, 0, cv, sv);
			setPlane(_leftPlane, lNormal, cPos, cMatrix, ch, 0, sh);
			setPlane(_rightPlane, rNormal, cPos, cMatrix, -ch, 0, sh);
			
		}
		
		private function setNearPlane(pos:Number3D, view:Matrix3D, camera:Camera3D):void{
			
			
			nNormal.reset(view.n13, view.n23, view.n33);
			
			_forward.reset(view.n13, view.n23, view.n33);
			_forward.multiplyEq(camera.near);
			_forward = Number3D.add(_forward, pos);
			
			_nearPlane.setNormalAndPoint(nNormal, _forward);
			
		}
		
		private function setPlane(plane:Plane3D, norm:Number3D, pos:Number3D, view:Matrix3D, x:Number, y:Number, z:Number, d:Number=0):void{
			norm.reset(x, y, z);
			Matrix3D.multiplyVector3x3(view, norm);
			plane.setNormalAndPoint(norm, pos);
			
		}
		
		private function getNextTri():Triangle3D{
			
			var t:Triangle3D;
			
			if(repo.length == cTriangle){
				t = new Triangle3D(null, null);
				repo.push(t);
				cTriangle++;
				return t;
			}
			
			t = repo[cTriangle];
			cTriangle++;
			return t;
			
			
		}
		
		
		private function testClipped(plane:Plane3D, triangle:Triangle3D, object:DisplayObject3D, outputs:Array):void{
			
			//var tests:Array = outputs;
			var results:Array = [];
			
			var length:Number = outputs.length;
			
			for(var i:int=length-1;i>=0;i--){
				
				var t:Triangle3D = outputs[i];
				
				var classification:Number = ClassificationUtil.classifyTriangle(t, plane);
				
				if(classification != ClassificationUtil.STRADDLE){
					 if(classification == ClassificationUtil.BACK || classification == ClassificationUtil.COINCIDING )
						outputs.splice(i, 1); 
					continue;
				}
					
				outputs.splice(i, 1);
				
				var d:Number = plane.d;
				results = TriangleUtil.clipTriangleWithPlaneTris(t, plane, 0.01, getNextTri(), getNextTri());
				
				for each(var tt:Triangle3D in results)
					outputs.push(tt);
				
				if(plane.d != d)
					plane.d = d;
			}
			
			
		} 
		
		
		
		public override function clipFace(triangle:Triangle3D, object:DisplayObject3D, material:MaterialObject3D, renderSessionData:RenderSessionData, outputArray:Array):Number{
			
			var screenZ:Number = 0;
			var outputs:Array = [triangle];
			
			
			if(selectedPlanes & LEFT) testClipped(_leftPlane, triangle, object, outputs);
			if(selectedPlanes & TOP) testClipped(_topPlane, triangle, object, outputs);
			if(selectedPlanes & BOTTOM) testClipped(_bottomPlane, triangle, object, outputs);
			
			if(selectedPlanes & RIGHT) testClipped(_rightPlane, triangle, object, outputs);
			if(selectedPlanes & NEAR) testClipped(_nearPlane, triangle, object, outputs);
				
			
			for each(var f:Triangle3D in outputs)
				outputArray.push(f);
				
			return 0;
			
		}
		
		
		/**
		* FAR PLANE - not used atm...
		*/
		//static public var FAR  :int = 0x01;
	
		/**
		* NEAR PLANE
		*/
		static public var NEAR   :int = 0x02;
	
		/**
		* RIGHT PLANE selection
		*/
		static public var RIGHT  :int = 0x04;
	
		/**
		* Left plane selection
		*/
		static public var LEFT   :int = 0x08;
	
		/**
		* Top plane selection
		*/
		static public var TOP    :int = 0x10;
	
		/**
		* Bottom plane selection
		*/
		static public var BOTTOM :int = 0x20;
	
		/**
		* All planes selected.
		*/
		static public var ALL    :int = NEAR + RIGHT + LEFT + TOP + BOTTOM;
		
		/**
		 * no planes
		 */
		static public var NONE	 :int  = 0;
		
		
		
		
	}
}