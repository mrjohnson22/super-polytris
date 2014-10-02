package visuals.scorebacks 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class ScoreEntry extends MovieClip 
	{
		protected const S_WIDTH:Number = 115;
		protected const S_HEIGHT:Number = 32;
		
		protected var _field:TextField;
		protected var _back:Sprite;
		
		public function get text():String
		{
			return _field.text;
		}
		public function set text(value:String):void
		{
			_field.text = value;
			G.textFieldFitSize(_field, _field.width);
		}
		
		private var _playing:Boolean = false;
		public function get playing():Boolean
		{
			return _playing;
		}
		
		public function playAttract():void
		{
			if (_playing) return;
		}
		public function playWarning():void
		{
			if (_playing) return;
			_playing = true;
		}
		public function stopWarning():void
		{
			if (!_playing) return;
			_playing = false;
		}
		public function cleanUp():void{}
	}

}