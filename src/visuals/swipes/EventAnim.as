package visuals.swipes
{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class EventAnim extends MovieClip
	{
		public static const READY:String = "Ready Trigger";
		public static const DONE:String = "Done Trigger";
		
		public function EventAnim()
		{
			playAnim();
		}
		
		protected function startAction(e:Event = null):void
		{
			dispatchEvent(new Event(READY));
		}
		
		protected function cleanUp(e:Event = null):void
		{
			stopAnim();
			dispatchEvent(new Event(DONE));
			parent.removeChild(this);
		}
		
		protected function playAnim():void
		{
			play(); //plays by default, may not need this here.
		}
		
		protected function stopAnim():void
		{
			stop();
		}
	}
}