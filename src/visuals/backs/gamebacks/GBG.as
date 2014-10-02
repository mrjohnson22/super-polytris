package visuals.backs.gamebacks 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class GBG extends MovieClip
	{
		protected var _bg:MovieClip;
		protected var _danger:Boolean;
		protected var _timedanger:Boolean;
		public function set danger(value:Boolean):void
		{
			_danger = value;
		}
		public function set timedanger(value:Boolean):void
		{
			_timedanger = value;
		}
		
		public function GBG()
		{
			addEventListener(Event.REMOVED_FROM_STAGE, _cleanUp);
		}
		
		public function levelUp():void { }
		protected function cleanUp():void { }
		
		private function _cleanUp(e:Event):void
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, _cleanUp);
			cleanUp();
		}
	}
	
}