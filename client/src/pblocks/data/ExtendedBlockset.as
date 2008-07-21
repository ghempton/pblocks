package pblocks.data
{
	/**
	 * The extended blockset consists of all n-polycubes up to n=5.
	 */
	public class ExtendedBlockset extends PolyCubeBlockset
	{
		public static const NAME:String = "Extended";
		
		public override function get name():String
		{
			return NAME;
		}
		
		public function ExtendedBlockset()
		{
			super(5, 5, 5, 5);
		}
		
	}
}