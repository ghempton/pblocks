package pblocks.events
{
	public class LayerEvent extends PaperblocksEvent
	{
		public static const LAYER_COMPLETE:String = "layerComplete";
		
		private var _numLayers:int;
		
		public function LayerEvent(type:String, numLayers:int)
		{
			_numLayers = numLayers;
			super(type);
		}
		
		public function get numLayers():int
		{
			return _numLayers;
		}
	}
}