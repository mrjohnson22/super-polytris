package visuals
{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class GOverText extends MovieClip
	{
		public static const END_ACTION:String = "End Anim Action";
		protected function endAction():void
		{
			stop();
			dispatchEvent(new Event(END_ACTION));
		}
	}
}