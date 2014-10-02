package menu.editing.previews 
{
	import data.Settings;
	import flash.display.MovieClip;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class PreviewItem extends MovieClip
	{
		protected var cs:Settings;
		
		public function PreviewItem()
		{
			refreshSettings();
			firstDraw();
			addEventListener(Event.REMOVED_FROM_STAGE, _cleanUp);
		}
		public function refreshSettings():void
		{
			this.cs = Settings.currentGame;
		}
		
		protected function firstDraw():void{};
		public function update():void { };
		protected function cleanUp():void { };
		
		private function _cleanUp(e:Event):void
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, _cleanUp);
			cleanUp();
		};
	}
	
}