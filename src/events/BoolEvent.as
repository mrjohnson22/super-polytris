package events
{
	import flash.events.Event;
	
	public class BoolEvent extends Event
	{
		public static const GO:String = "B_Go";
		
		private var _truth:Boolean;
		public function get truth():Boolean
		{
			return _truth;
		}
		
		public function BoolEvent(type:String, truth:Boolean, bubbles:Boolean = false):void
		{
			super(type, bubbles);
			_truth = truth;
		}
	}
}