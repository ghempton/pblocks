package pblocks.events
{
	import flash.events.Event;

	public class PaperblocksEvent extends Event
	{
		public static const LEVEL_CHANGE:String = "levelChange";
		public static const SCORE_CHANGE:String = "scoreChange";
		public static const NEXT_BLOCK:String = "nextBlock";
		public static const BLOCK_PLAYED:String = "blockPlayed";
		public static const GAME_OVER:String = "gameOver";
		public static const GAME_START:String = "gameStart";
		public static const BACKGROUND_CHANGE:String = "borderChange";
		
		// TODO: propagate this event and render on demand
		public static const SCENE_CHANGE:String = "sceneChange";
		
		public function PaperblocksEvent(type:String)
		{
			super(type);
		}
	}
}