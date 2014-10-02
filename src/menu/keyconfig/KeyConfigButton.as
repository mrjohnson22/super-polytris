package menu.keyconfig
{
	import data.KeySettings;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import media.fonts.FontStyles;
	
	/**
	 * ...
	 * @author XJ
	 */
	internal class KeyConfigButton extends Sprite
	{
		private const S_WIDTH:Number = G.STAGE_WIDTH * 0.9;
		private const S_HEIGHT:Number = 32;
		
		private const LEFT_COLOR:Number = 0xCCCCCC;
		private const RIGHT_COLOR:Number = 0xFFFFFF;
		
		private var _fieldleft:TextField;
		private var _fieldright:TextField;
		private var _back:MovieClip;
		
		private var _bcolor:ColorTransform;
		
		private var _keyCode:uint = 0;
		
		public function get title():String
		{
			return _fieldleft.text;
		}
		
		public function set title(value:String):void
		{
			_fieldleft.text = value;
		}
		
		public function get keyCode():uint
		{
			return _keyCode;
		}
		
		public function get keyName():String
		{
			return _fieldright.text;
		}
		
		/**
		 * Only use this when setting a button without key input (ie when loading key configs).
		 * @param	keyCode
		 * @param	keyName
		 */
		internal function setKeyCodeAndName(keyCode:uint, keyName:String):void
		{
			_keyCode = keyCode;
			_fieldright.text = keyName;
		}
		
		public function KeyConfigButton(title:String, keyCode:uint, keyName:String)
		{
			tabChildren = false;
			tabEnabled = false;
			
			_back = new KeyButtonBack();
			_back.width = S_WIDTH;
			_back.height = S_HEIGHT;
			//_back.graphics.beginFill(0);
			//_back.graphics.drawRect(0, 0, S_WIDTH, S_HEIGHT);
			
			var textheight:Number = 32;
			var leftformat:TextFormat = new TextFormat(FontStyles.F_JOYSTIX, 20, LEFT_COLOR);
			leftformat.align = TextFormatAlign.LEFT;
			
			_fieldleft = new TextField();
			G.setTextField(_fieldleft, leftformat);
			_fieldleft.height = textheight;
			_fieldleft.width = S_WIDTH * 0.95 / 2;
			_fieldleft.x = _back.x + S_WIDTH * 0.05;
			
			var leftformat:TextFormat = new TextFormat(FontStyles.F_JOYSTIX, 20, RIGHT_COLOR);
			leftformat.align = TextFormatAlign.RIGHT;
			
			_fieldright = new TextField();
			G.setTextField(_fieldright, leftformat);
			_fieldright.height = textheight;
			_fieldright.width = S_WIDTH * 0.95 / 2;
			G.rightAlign(_fieldright, S_WIDTH * 0.05, _back);
			
			_fieldleft.text = title;
			_keyCode = keyCode;
			_fieldright.text = keyName;
			
			addChild(_back);
			addChild(_fieldleft);
			addChild(_fieldright);
			
			_bcolor = new ColorTransform();
			
			//mouseChildren = false;
			_fieldleft.mouseEnabled = false;
			_fieldright.mouseEnabled = false;
			_back.buttonMode = true;
		}
		
		public function lightUp():void
		{
			_bcolor.color = 0xFFFFFF;
			_back.transform.colorTransform = _bcolor;
			_fieldleft.textColor = 0;
			_fieldright.textColor = 0;
		}
		
		public function darken():void
		{
			_bcolor = new ColorTransform();
			_back.transform.colorTransform = _bcolor;
			_fieldleft.textColor = LEFT_COLOR;
			_fieldright.textColor = RIGHT_COLOR;
		}
		
		public function warning():void
		{
			_bcolor.color = 0xFF0000;
			_back.transform.colorTransform = _bcolor;
			_fieldleft.textColor = 0xFFFFFF;
			_fieldright.textColor = 0xFFFFFF;
		}
		
		/**
		 * Set the key value for this button, but only if the key is allowed.
		 * @param	value The character code of the selected key.
		 * @return	True if the key is allowed, false otherwise.
		 */
		public function setKeyVal(keyCode:uint, charCode:uint):Boolean
		{
			var keyName:String = KeySettings.getAllowableName(keyCode, charCode);
			if (keyName != "")
			{
				_keyCode = keyCode;
				_fieldright.text = keyName;
				return true;
			}
			return false;
		}
	}
}