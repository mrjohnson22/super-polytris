package visuals.clearstyles
{
	import flash.events.TimerEvent;
	
	//Also the class used for RapidBlink.
	public class Blink extends ClearSuite
	{
		protected var _blinker:FrameTimer;
		protected function get time():uint
		{
			return 5;
		}
		
		public function Blink()
		{
			_blinker = new FrameTimer(time);
			_blinker.addEventListener(TimerEvent.TIMER, toggleVisible);
			_blinker.start();
		}
		
		protected function toggleVisible(e:TimerEvent = null):void
		{
			if (parent)
				parent.visible = !parent.visible;
		}
		
		override public function remove():void
		{
			parent.visible = true;
			_blinker.removeEventListener(TimerEvent.TIMER, toggleVisible);
			_blinker.stop();
		}
	}
}