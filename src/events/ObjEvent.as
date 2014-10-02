package events
{
	import flash.events.Event;
	
	public class ObjEvent extends Event
	{
		public static const GO:String = "ObjEvent";
		
		private var _obj:Object;
		public function get obj():Object
		{
			return _obj;
		}
		
		public function ObjEvent(type:String, obj:Object, bubbles:Boolean = false):void
		{
			super(type, bubbles);
			_obj = obj;
		}
	}
}