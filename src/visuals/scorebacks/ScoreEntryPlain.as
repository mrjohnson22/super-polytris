package visuals.scorebacks 
{
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import media.fonts.FontStyles;
	/**
	 * ...
	 * @author XJ
	 */
	public class ScoreEntryPlain extends ScoreEntry
	{
		private var _timer:FrameTimer;
		private var _wtimer:FrameTimer;
		private var _bcolor:ColorTransform;
		
		public function ScoreEntryPlain() 
		{
			_back = new Sprite();
			_back.graphics.beginFill(0);
			_back.graphics.drawRect(0, 0, S_WIDTH, S_HEIGHT);
			
			var textheight:Number = 32;
			var textformat:TextFormat = new TextFormat(FontStyles.F_JOYSTIX, 20, 0xFFFFFF);
			textformat.align = TextFormatAlign.RIGHT;
			
			_field = new TextField();
			G.setTextField(_field, textformat);
			_field.height = textheight;
			_field.width = S_WIDTH * 0.95;
			G.centreX(_field, _back);
			
			addChild(_back);
			addChild(_field);
			
			_timer = new FrameTimer(300, true, 3);
			_wtimer = new FrameTimer(300, true);
			
			_timer.addEventListener(TimerEvent.TIMER, flipColour, false, 0, true);
			_wtimer.addEventListener(TimerEvent.TIMER, flipColour, false, 0, true);
			_bcolor = new ColorTransform();
		}
		
		override public function playAttract():void 
		{
			_bcolor.color = 0xFFFFFF;
			_back.transform.colorTransform = _bcolor;
			_field.textColor = 0;
			
			_timer.reset();
			_timer.start();
		}
		
		override public function playWarning():void
		{
			super.playWarning();
			
			if (_timer.running)
				_timer.reset();
			
			_bcolor.color = 0xFFFFFF;
			_back.transform.colorTransform = _bcolor;
			_field.textColor = 0;
			
			_wtimer.reset();
			_wtimer.start();
		}
		
		override public function stopWarning():void 
		{
			super.stopWarning();
			_wtimer.stop();
			_bcolor.color = 0;
			_back.transform.colorTransform = _bcolor;
			_field.textColor = 0xFFFFFF;
		}
		
		private function flipColour(e:TimerEvent):void
		{
			var timer:FrameTimer = FrameTimer(e.target);
			if (timer.currentCount % 2 == 0) //even
			{
				_bcolor.color = 0xFFFFFF;
				_back.transform.colorTransform = _bcolor;
				_field.textColor = 0;
			}
			else
			{
				_bcolor.color = 0;
				_back.transform.colorTransform = _bcolor;
				_field.textColor = 0xFFFFFF;
			}
		}
		
		override public function cleanUp():void
		{
			_timer.stop();
			_wtimer.stop();
			_timer.removeEventListener(TimerEvent.TIMER, flipColour);
			_wtimer.removeEventListener(TimerEvent.TIMER, flipColour);
		}
		
	}

}