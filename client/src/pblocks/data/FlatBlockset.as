package pblocks.data
{
	/**
	 * The flat blockset consists of all polycubes which fit into a single layer.
	 * Effectively all the n-polyminoes up to n=4, excluding 4 squares in a row.
	 */
	public class FlatBlockset extends PolyCubeBlockset
	{
		public static const NAME:String = "Flat";
		
		public override function get name():String
		{
			return NAME;
		}
		
		public function FlatBlockset()
		{
			super(3, 1, 3, 4);
		}
		
	}
}