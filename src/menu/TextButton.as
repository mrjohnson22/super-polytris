package menu 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import media.fonts.FontStyles;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class TextButton extends BlockableButton
	{
		protected var _button:MovieClip; //Use MovieClip since Buttons don't have Scale9Grid.
		protected var _field:TextField;
		
		protected var _veil:Sprite;
		
		public var id:int = 0;
		
		override public function set clickable(value:Boolean):void
		{
			if (_clickable == value)
				return;
			
			_clickable = value;
			_button.buttonMode = value;
			_button.mouseEnabled = value;
			_button.tabEnabled = value;
			if (!value)
			{
				addChild(_veil);
				_button.gotoAndStop(1);
			}
			else if (_veil.parent != null)
				removeChild(_veil);
		}
		
		override public function get width():Number 
		{
			return super.width;
		}
		
		override public function set width(value:Number):void 
		{
			_button.width = value;
			G.centreX(_field, _button);
			veilSetup();
		}
		
		/**
		 * NOTE: give listener to _button, not entire object. Reasons include the veil and the
		 * fact that only the button part is in Button Mode. **IMPORTANT**: to get the TextButton
		 * from an event, use e.target.parent, since the target will be _button.
		 * @param	type
		 * @param	listener
		 * @param	useCapture
		 * @param	priority
		 * @param	useWeakReference
		 */
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void 
		{
			_button.addEventListener(type, listener);
		}
		
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void 
		{
			_button.removeEventListener(type, listener);
		}
		
		/**
		 * A button which includes text and a clickable background. The button is resized to fit
		 * the entirety of the text. **NOTE:** Timeline must have _up, _over, and _down frame labels.
		 * @param	text The text that is to appear on the button.
		 * @param	buttonType The appearance of the button. Drawn in the Flash IDE.
		 */
		public function TextButton(text:String, ButtonType:Class = null, textColor:uint = 0xFFFFFF, size:Number = 20, font:String = FontStyles.F_JOYSTIX)
		{
			if (this is ModeButton)
				return;
			
			if (ButtonType == null)
				ButtonType = ButtonBack1;
			
			var format:TextFormat = new TextFormat(font, size, textColor);
			format.align = TextFormatAlign.CENTER;
			
			_field = new TextField();
			G.setTextField(_field, format);
			_field.autoSize = TextFieldAutoSize.LEFT;
			_field.text = text;
			
			_button = new ButtonType();
			_button.width = _field.width + 20;
			_button.height = _field.height + 10;
			
			addChild(_button);
			addChild(_field);
			G.centreX(_field, _button);
			G.centreY(_field, false, _button);
			
			_button.stop();
			_field.mouseEnabled = false;
			_button.buttonMode = true;
			
			veilSetup();
		}
		
		protected function veilSetup():void
		{
			if (_veil != null && _veil.parent != null)
				removeChild(_veil);
			_veil = new Sprite();
			_veil.graphics.beginFill(0, 0.5);
			_veil.graphics.drawRect(_button.x, _button.y, _button.width, _button.height);
		}
	}

}