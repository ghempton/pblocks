package pblocks.ui
{
	import flash.utils.getQualifiedClassName;
	
	import mx.containers.TitleWindow;
	import mx.events.CloseEvent;
	
	import pblocks.PaperblocksGame;
	
	public class PaperblocksWindow extends TitleWindow
	{
		private var _game:PaperblocksGame;
		
		[Bindable]
		public function get game():PaperblocksGame
		{
			return _game;
		}
		
		public function set game(g:PaperblocksGame):void
		{
			_game = g;
		}
		
		public function PaperblocksWindow()
		{
			super();
			this.showCloseButton = true;
			this.addEventListener(CloseEvent.CLOSE, closeHandler);
		}
		
		private function closeHandler(e:CloseEvent):void
		{
			close();
		}
		
		public function get windowClass():Class
		{
			var className:String = flash.utils.getQualifiedClassName(this);
			return flash.utils.getDefinitionByName(className) as Class;
		}
		
		public function close():void
		{
			game.closeWindow(windowClass);
		}
		
	}
}