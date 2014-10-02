package screens
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import media.fonts.FontStyles;
	import media.sounds.Sounds;
	import menu.BlockableButton;
	import menu.PopUp;
	import menu.TextButton;
	import visuals.swipes.EventAnim;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class Menu extends MovieClip
	{
		protected var _titlelabel:TextField;
		
		private var _buttons:Vector.<MovieClip> = new Vector.<MovieClip>();
		private var _listeners:Vector.<Function> = new Vector.<Function>();
		
		protected var _backbutton:TextButton;
		protected var _backScreen:Class;
		
		protected var _ready:Boolean = false;
		
		public function Menu()
		{
			Main.swipe.addEventListener(EventAnim.DONE, activateButtons);
		}
		
		protected function setTitle(title:String):void
		{
			var titleformat:TextFormat = new TextFormat(FontStyles.F_JOYSTIX, 30, 0xFF0000);
			titleformat.align = TextFormatAlign.CENTER;
			
			_titlelabel = new TextField();
			G.setTextField(_titlelabel, titleformat);
			_titlelabel.autoSize = TextFieldAutoSize.CENTER;
			_titlelabel.text = title;
			G.textFieldFitSize(_titlelabel, G.STAGE_WIDTH);
			_titlelabel.filters = [new DropShadowFilter()];
			
			G.centreX(_titlelabel);
			_titlelabel.y = 25;
			addChild(_titlelabel);
		}
		
		function setBackButton(backScreen:Class):void
		{
			if (backScreen != null)
			{
				_backScreen = backScreen;
				_backbutton = new TextButton("Back");
				_backbutton.x = G.STAGE_WIDTH - _backbutton.width - 20;
				_backbutton.y = G.STAGE_HEIGHT - _backbutton.height - 20;
				addChild(_backbutton);
				addButtonListener(_backbutton, goBack);
			}
		}
		
		protected function goBack(e:MouseEvent):void
		{
			goTo(_backScreen);
		}

		/**
		 * Use this function instead of adding an event listener to a button.
		 * @param	button
		 * @param	listener
		 */
		protected function addButtonListener(button:MovieClip, listener:Function):void
		{
			_buttons.push(button);
			_listeners.push(listener);
			
			if (!_ready)
				button.mouseEnabled = button.mouseChildren = false;
			else
				button.addEventListener(MouseEvent.CLICK, listener);
		}
		
		private function activateButtons(e:Event):void
		{
			for (var i:uint = 0; i < _buttons.length; i++)
			{
				var button:MovieClip = _buttons[i];
				button.addEventListener(MouseEvent.CLICK, _listeners[i]);
				if (!(button is BlockableButton) || BlockableButton(button).clickable)
					button.mouseEnabled = button.mouseChildren = true;
			}
			
			removeEventListener(EventAnim.DONE, activateButtons);
			_ready = true;
		}
		
		protected function deactivateButtons():void
		{
			for (var i:uint = 0; i < _buttons.length; i++)
			{
				_buttons[i].removeEventListener(MouseEvent.CLICK, _listeners[i]);
				_buttons[i].mouseEnabled = _buttons[i].mouseChildren = false;
			}
		}
		
		protected function goTo(nextScreen:Class, fadeOut:Boolean = false, SwipeType:Class = null):void
		{
			cleanUp();
			deactivateButtons();
			if (fadeOut)
				Sounds.fadeOutSong();
			Main.changeScreen(nextScreen, SwipeType);
		}
		
		/**
		 * Abstract: override this to perform cleanup on a screen change.
		 */
		protected function cleanUp():void{}
		
	}

}