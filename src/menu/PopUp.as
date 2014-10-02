package menu 
{
	import flash.display.DisplayObject;
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
	public class PopUp extends Sprite 
	{
		public static const E_POPUP:String = "Popupevent";
		public static const E_POPUPGONE:String = "Popupgone";
		
		private static var _instance:PopUp;
		private static var _behinds:Vector.<PopUp> = new Vector.<PopUp>();
		private static var _staticmake:Boolean = false;
		//private static const FADE_TIME:Number = 0.25;
		
		private var _back:Sprite;
		private var _messagelabel:TextField;
		private var _contents:DisplayObject;
		
		private var _buttons:Vector.<TextButton> = new Vector.<TextButton>();
		private var _buttonFunctions:Vector.<Function> = new Vector.<Function>();
		
		public static function makePopUp(message:String, buttonNames:Vector.<String> = null, buttonFunctions:Vector.<Function> = null,
			contents:DisplayObject = null, ButtonType:Class = null, font:String = FontStyles.F_JOYSTIX):void
		{
			if (buttonNames == null || buttonFunctions == null)
			{
				buttonNames = new Vector.<String>();
				buttonFunctions = new Vector.<Function>();
			}	
			else if (buttonNames.length != buttonFunctions.length)
				throw new Error("Must have as many button names as button functions.");
			if (_instance != null)
			{
				_instance.setInteractionEnabled(false);
				_behinds.push(_instance);
			}
			else
				Main.enableInteraction(false);
			
			_staticmake = true;
			_instance = new PopUp(message, buttonNames, buttonFunctions, contents, ButtonType, font);
			_staticmake = false;
		}
		
		/**
		 * Make the currently active PopUp instance fade out.
		 * @param	e
		 */
		public static function fadeOut(e:Event = null):void
		{
			if (_instance != null)
			{
				_instance.removeButtonListeners();
				_instance.removeEventListener(Event.ENTER_FRAME, _instance.fadeInInstance);
				_instance.addEventListener(Event.ENTER_FRAME, _instance.fadeOutInstance);
			}
		}
		
		/**
		 * Enable or disable interaction with the currently active PopUp instance.
		 */
		public static function setInteractionEnabled(enabled:Boolean):void
		{
			if (_instance != null)
				_instance.setInteractionEnabled(enabled);
		}
		
		public static function getInteractionEnabled():Boolean
		{
			return _instance.mouseChildren;
		}
		
		/**
		 * On-demand function to remove all PopUp instances immediately.
		 */
		public static function cleanUp():void
		{
			while (_instance != null)
				_instance.cleanUpInstance(true);
		}
		
		public function PopUp(message:String, buttonNames:Vector.<String>, buttonFunctions:Vector.<Function>,
			contents:DisplayObject = null, ButtonType:Class = null, font:String = FontStyles.F_JOYSTIX)
		{
			if (!_staticmake)
				throw new Error("Cannot instantiate. Create a PopUp with the static PopUp.makePopUp instead.");
			
			_back = new Sprite();
			_back.graphics.beginFill(0, 0.9);
			_back.graphics.drawRect(0, 0, G.STAGE_WIDTH, G.STAGE_HEIGHT);
			addChild(_back);
			
			var messageformat:TextFormat = new TextFormat(font, 20, 0xFFFFFF);
			messageformat.align = TextFormatAlign.CENTER;
			
			_messagelabel = new TextField();
			G.setTextField(_messagelabel, messageformat);
			_messagelabel.autoSize = TextFieldAutoSize.CENTER; // To auto-set the height.
			_messagelabel.width = _back.width * 0.95;
			_messagelabel.wordWrap = true;
			_messagelabel.text = message;
			G.centreX(_messagelabel);
			
			var buttonContainer:Sprite = new Sprite();
			var ytop:Number = 0;
			var bmargin:Number = 5;
			for (var i:uint = 0; i < buttonNames.length; i++)
			{
				var button:TextButton = new TextButton(buttonNames[i], ButtonType, 0xFFFFFF, 20, font);
				G.centreX(button, _back);
				button.y = ytop;
				ytop += button.height + bmargin;
				buttonContainer.addChild(button);
				button.mouseChildren = false;
				_buttons.push(button);
			}
			_buttonFunctions = buttonFunctions;

			if (contents == null)
			{
				_messagelabel.y = G.STAGE_HEIGHT / 2 - _messagelabel.height - 10;
				buttonContainer.y = G.STAGE_HEIGHT / 2;
			}
			else
			{
				_contents = contents;
				G.centreX(_contents);
				G.centreY(_contents);
				_messagelabel.y = _contents.y - _messagelabel.height - 10;
				buttonContainer.y = _contents.y + _contents.height + 10;
				addChild(_contents);
			}
			
			addChild(_messagelabel);
			addChild(buttonContainer);
			
			Main.layermid.addChild(this);
			alpha = 0;
			addEventListener(Event.ENTER_FRAME, fadeInInstance);
			
			//Only dispatch an event if this is the first popup.
			if (_behinds.length == 0)
				Main.stage.dispatchEvent(new Event(E_POPUP));
		}
		
		private function setInteractionEnabled(enabled:Boolean):void
		{
			mouseChildren = enabled;
			tabChildren = enabled;
		}
		
		private function fadeInInstance(e:Event):void
		{
			const fadeSpeed:Number = 0.2;
			alpha = Math.min(alpha + fadeSpeed, 1);
			if (alpha == 1)
			{
				removeEventListener(Event.ENTER_FRAME, fadeInInstance);
				addButtonListeners();
			}
		}
		
		private function fadeOutInstance(e:Event):void
		{
			const fadeSpeed:Number = 0.2;
			alpha = Math.max(alpha - fadeSpeed, 0);
			if (alpha == 0)
			{
				removeEventListener(Event.ENTER_FRAME, fadeOutInstance);
				cleanUpInstance(false);
			}
		}
		
		private function addButtonListeners():void
		{
			for (var i:uint = 0; i < _buttons.length; i++)
			{
				var button:TextButton = _buttons[i];
				button.addEventListener(MouseEvent.CLICK, _buttonFunctions[i]);
				//button.addEventListener(MouseEvent.CLICK, removeButtonListeners);
				button.mouseChildren = true;
			}
		}
		
		private function removeButtonListeners(e:MouseEvent = null):void
		{
			for (var i:uint = 0; i < _buttons.length; i++)
			{
				var button:TextButton = _buttons[i];
				button.removeEventListener(MouseEvent.CLICK, _buttonFunctions[i]);
				//button.removeEventListener(MouseEvent.CLICK, removeButtonListeners);
				button.mouseChildren = false;
			}
			if (_contents is ICleanable)
				ICleanable(_contents).cleanUp();
		}
		
		/**
		 * Removes the PopUp instance from the display list.
		 * @param	multiple Set to true if this function is used to remove all popups.
		 */
		private function cleanUpInstance(multiple:Boolean):void
		{
			if (!multiple || _behinds.length == 0)
				Main.resetFocus();
			
			//Only remove listeners if they are still active.
			if (_buttons.length > 0 && _buttons[0].hasEventListener(MouseEvent.CLICK))
				removeButtonListeners();
			parent.removeChild(this);
			
			//If the faded popup is behind another one, don't need to nullify anything.
			//Only do something when a FRONT popup has faded.
			var i:int = _behinds.indexOf(this);
			if (i != -1)
			{
				_behinds.splice(i, 1);
				return;
			}
			
			//Only restore clickability when the only remaining popUp disappears
			if (_behinds.length == 0)
			{
				Main.enableInteraction(true);
				Main.stage.dispatchEvent(new Event(E_POPUPGONE));
				_instance = null;
			}
			else
			{
				_instance = _behinds.pop();
				_instance.setInteractionEnabled(true);
			}
		}
		
	}

}