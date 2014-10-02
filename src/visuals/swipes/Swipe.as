package visuals.swipes
{
	import events.GameEvent;
	import flash.events.Event;
	
	public class Swipe extends EventAnim
	{
		private var _Screen:Class;
		/**
		 * Set the screen that should be switched to.
		 * (Not set in the constructor so that a general constructor can be used by library objects.)
		 */
		public function set Screen(value:Class):void
		{
			_Screen = value;
		}
		
		override protected function startAction(e:Event = null):void 
		{
			dispatchEvent(new GameEvent(GameEvent.CHANGE, _Screen));
		}
		
	}
}