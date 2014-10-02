package events
{
	import flash.events.Event;
	
	public class IDEvent extends Event
	{
		public static const GO:String = "Go";
		
		private var _id:int;
		public function get id():int
		{
			return _id;
		}
		
		public function IDEvent(type:String, id:uint, bubbles:Boolean = false):void
		{
			super(type, bubbles);
			_id = id;
		}
	}
}