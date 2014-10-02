package menu 
{
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class Nextbar extends MovieClip
	{
		private var _clickable:Boolean;
		
		public function get clickable():Boolean
		{
			return _clickable;
		}
		
		public function set clickable(value:Boolean):void
		{
			_clickable = value;
			buttonMode = value;
			mouseEnabled = value;
			visible = value;
			gotoAndStop(0);
		}
		
		public function Nextbar() 
		{
			mouseChildren = false;
			tabChildren = false;
			tabEnabled = false;
			clickable = true;
		}
		
	}

}