package pblocks.view
{
	/**
	 * Abstract class for the orthographic secondary game views.
	 */
	public class OrthographicView extends PaperblocksView
	{
		protected const INFINITY:Number = 100000;
		
		public function OrthographicView()
		{
			super();
			// setting this to infinity simulates an orthographic view
			_canonicalZoom = INFINITY;
		}
	}
}