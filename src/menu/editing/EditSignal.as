package menu.editing 
{
	import flash.display.MovieClip;
	import menu.editing.previews.PreviewItem;
	/**
	 * ...
	 * @author XJ
	 */
	public class EditSignal 
	{
		private var _title:String;
		public function get title():String
		{
			return _title;
		}
		
		private var _desc:String;
		public function get desc():String
		{
			return _desc;
		}
		
		private var _Preview:Class;
		public function get Preview():Class
		{
			return _Preview;
		}
		
		public function EditSignal(title:String, desc:String, Preview:Class)
		{
			_title = title;
			_desc = desc;
			_Preview = Preview;
		}
	}

}