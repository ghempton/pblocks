package pblocks.ui
{
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import mx.controls.Button;
	
	import pblocks.util.Char;

	public class KeyPicker extends Button
	{
		public function KeyPicker()
		{
			super();
			stopChangeKey();
		}
		
		private var _keyChanging:Boolean = false;
		
		private var _keyCode:int;
		[Bindable]
		// TODO: why the fuck doesn't inspectable work for me
		[Inspectable(category="Other", verbose=1)]
		public function get keyCode():int
		{
			return _keyCode;
		}
		public function set keyCode(c:int):void
		{
			_keyCode = c;
			this.dispatchEvent(new Event(Event.CHANGE));
			invalidateProperties();
		}
		
		protected override function clickHandler(e:MouseEvent):void
		{
			super.clickHandler(e);
			startChangeKey();
		}
		
		private function startChangeKey():void
		{
			toolTip = "Press a key!";
			_keyChanging = true;
		}
		
		protected override function keyDownHandler(e:KeyboardEvent):void
		{
			super.keyDownHandler(e);
			if(_keyChanging)
			{
				keyCode = e.keyCode;
				stopChangeKey();
			}
		}
		
		private function stopChangeKey():void
		{
			toolTip = "Click to change!";
			_keyChanging = false;
		}
		
		protected override function commitProperties():void
		{
			super.commitProperties();
			label = Char.keyCodeToString(keyCode);
		}
	}
}