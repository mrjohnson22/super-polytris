package visuals 
{
	import flash.display.JointStyle;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class TextFieldPlus extends Sprite 
	{
		private var _field:TextField;
		public function get text():String
		{
			return _field.text;
		}
		public function set text(value:String):void
		{
			_field.text = value;
		}
		
		public function makeInput(isInput:Boolean, maxChars:int = 0, restrict:String = null):void
		{
			if (_field.selectable == isInput)
				return;
			
			if (isInput)
			{
				_field.selectable = true;
				_field.type = TextFieldType.INPUT;
				_field.multiline = false;
				
				_field.restrict = restrict;
				_field.maxChars = maxChars;
			}
			else
			{
				_field.selectable = false;
				_field.type = TextFieldType.DYNAMIC;
			}
		}
		
		public function set type(value:String):void
		{
			_field.type = value;
		}
		
		private var _format:TextFormat;
		
		private var _color1:uint = 0xFFFFFF;
		private var _color2:uint = 0;
		
		/**
		 * The default text colour of this label.
		 */
		public function set color1(value:uint):void
		{
			if (_field.textColor == _color1)
				_field.textColor = value;
			_color1 = value;
		}
		
		/**
		 * The colour the text has while in the "bright" stage of a blink.
		 */
		public function set color2(value:uint):void
		{
			if (_field.textColor == _color2)
				_field.textColor = value;
			_color2 = value;
		}
		
		private var _blinktimer:FrameTimer;
		
		public function TextFieldPlus(font:String, size:Number, width:Number = 0, align:String = TextFormatAlign.CENTER)
		{
			_format = new TextFormat(font, size);
			_format.align = align;
			
			_field = new TextField();
			G.setTextField(_field, _format);
			
			//Autosize ONLY for proper height sizing!
			_field.text = " ";
			_field.autoSize = TextFieldAutoSize.LEFT;
			
			//Use auto-set width if input width is 0.
			if (width != 0)
			{
				var safeheight:Number = _field.height;
				_field.autoSize = TextFieldAutoSize.NONE;
				_field.width = width;
				_field.height = safeheight;
			}
			
			_field.text = "";
			
			_field.textColor = _color1;
			_field.background = true;
			_field.backgroundColor = _color2;
			
			_blinktimer = new FrameTimer(15);
			addEventListener(Event.REMOVED_FROM_STAGE, removeTimerListener);
			
			addChild(_field);
		}
		
		public function set blink(value:Boolean):void
		{
			if (_blinktimer.running == value)
				return;
			
			if (value)
			{
				_blinktimer.addEventListener(TimerEvent.TIMER, blinkColor);
				_blinktimer.start();
			}
			else if (_blinktimer.running)
			{
				_blinktimer.reset();
				_blinktimer.removeEventListener(TimerEvent.TIMER, blinkColor);
				
				_field.textColor = _color1;
				_field.backgroundColor = _color2;
			}
		}
		
		public function makeBorder(color:uint):void
		{
			graphics.lineStyle(10, color, 1, false, "normal", null, JointStyle.MITER);
			graphics.drawRect(0, 0, _field.width, _field.height);
		}
		
		public function removeBorder():void
		{
			graphics.clear();
		}
		
		private function blinkColor(e:TimerEvent):void
		{
			var newbcolor:uint;
			var newtcolor:uint;
			if (_field.backgroundColor == _color1)
			{
				newbcolor = _color2;
				newtcolor = _color1;
			}
			else
			{
				newbcolor = _color1;
				newtcolor = _color2;
			}
			_field.textColor = newtcolor;
			_field.backgroundColor = newbcolor;
		}
		
		private function removeTimerListener(e:Event):void
		{
			if (_blinktimer.hasEventListener(TimerEvent.TIMER))
				_blinktimer.removeEventListener(TimerEvent.TIMER, blinkColor);
		}
		
	}

}