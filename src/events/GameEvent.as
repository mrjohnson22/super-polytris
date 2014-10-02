package events
{
	import flash.events.Event;
	
	public class GameEvent extends Event
	{
		public static const CHANGE:String = "change";
		
		private var _Screen:Class;
		public function get Screen():Class
		{
			return _Screen;
		}
		
		public function GameEvent(type:String, Screen:Class, bubbles:Boolean = false):void
		{
			super(type, bubbles);
			_Screen = Screen;
			
		}
	}
}