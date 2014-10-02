package menu.keyconfig
{
	import data.DefaultSettings;
	import data.KeySettings;
	import data.SaveData;
	import data.SettingNames;
	import data.Settings;
	import events.BoolEvent;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import media.fonts.FontStyles;
	import menu.ICleanable;
	import menu.TextButton;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class KeyConfig extends Sprite implements ICleanable
	{
		private const MSG_TITLE:String = "Click an entry to configure key";
		private const MSG_PRESS:String = "Press key for ";
		private const MSG_CONFLICT:String = "Actions use same key!!";
		
		private var cs:Settings;
		private var ks:KeySettings;
		
		private var _keylist:Vector.<KeyConfigButton> = new Vector.<KeyConfigButton>();
		//private var _unusedlist:Vector.<KeyConfigButton> = new Vector.<KeyConfigButton>();
		//private var _totallist:Vector.<KeyConfigButton> = new Vector.<KeyConfigButton>();
		private var _conflictlist:Vector.<KeyConfigButton> = new Vector.<KeyConfigButton>();
		
		private var _bleft:KeyConfigButton;
		private var _bright:KeyConfigButton;
		private var _bup:KeyConfigButton;
		private var _bdown:KeyConfigButton;
		private var _brotccw:KeyConfigButton;
		private var _brotcw:KeyConfigButton;
		private var _bhold:KeyConfigButton;
		private var _bplace:KeyConfigButton;
		private var _bpause:KeyConfigButton;
		
		private var _activebutton:KeyConfigButton;
		private var _defaultbutton:TextButton;
		
		private var _titlelabel:TextField; //for name of config type
		private var _msglabel:TextField;
		private var _msgformat:TextFormat;
		
		private var _conflicted:Boolean = false;
		public function get conflicted():Boolean
		{
			return _conflicted;
		}
		
		public function KeyConfig()
		{
			cs = Settings.currentGame;
			ks = KeySettings.currentConfig;
			var buttonContainer:Sprite = new Sprite();
			
			_bleft = new KeyConfigButton("Move Left", ks.k_left, ks.name_left);
			_bright = new KeyConfigButton("Move Right", ks.k_right, ks.name_right);
			_keylist.push(_bleft, _bright);
			
			if (cs == null)
			{
				_bplace = new KeyConfigButton("Place Piece*", ks.k_place, ks.name_place);
				_bup = new KeyConfigButton("Up*/Inst.Drop", ks.k_up, ks.name_up);
				_bdown = new KeyConfigButton("Down*/Fast", ks.k_down, ks.name_down);
				_keylist.push(_bdown, _bup, _bplace);
			}
			else if (cs[SettingNames.FITMODE])
			{
				_bplace = new KeyConfigButton("Place Piece", ks.k_place, ks.name_place);
				_bup = new KeyConfigButton("Move Up", ks.k_up, ks.name_up);
				_bdown = new KeyConfigButton("Move Down", ks.k_down, ks.name_down);
				_keylist.push(_bdown, _bup, _bplace);
			}
			else
			{
				if (cs[SettingNames.DROP])
				{
					_bdown = new KeyConfigButton("Fast Drop", ks.k_down, ks.name_down);
					_keylist.push(_bdown);
				}
				
				if (cs[SettingNames.INST])
				{
					_bup = new KeyConfigButton("Instant Drop", ks.k_up, ks.name_up);
					_keylist.push(_bup);
				}
			}
			
			if (cs == null || cs[SettingNames.RCCW])
			{
				_brotccw = new KeyConfigButton("Rotate Left", ks.k_rotccw, ks.name_rotccw);
				_keylist.push(_brotccw);
			}
			
			if (cs == null || cs[SettingNames.RCW])
			{
				_brotcw = new KeyConfigButton("Rotate Right", ks.k_rotcw, ks.name_rotcw);
				_keylist.push(_brotcw);
			}
			
			if (cs == null || cs[SettingNames.HOLDABLE])
			{
				_bhold = new KeyConfigButton("Hold Piece", ks.k_hold, ks.name_hold);
				_keylist.push(_bhold);
			}
			
			_bpause = new KeyConfigButton("Pause Game", ks.k_pause, ks.name_pause);
			_keylist.push(_bpause);
			
			var ypos:Number = 0;
			for each (var button:KeyConfigButton in _keylist)
			{
				button.addEventListener(MouseEvent.CLICK, makeActive);
				button.y = ypos;
				ypos += button.height;
				buttonContainer.addChild(button);
			}
			
			if (cs == null)
			{
				var starlabel:TextField = new TextField();
				var starformat:TextFormat = new TextFormat(FontStyles.F_JOYSTIX, 20, 0xFFFFFF);
				G.setTextField(starlabel, starformat);
				starlabel.autoSize = TextFieldAutoSize.LEFT;
				starlabel.text = "* Fit Mode control";
				starlabel.y = ypos;
				buttonContainer.addChild(starlabel);
			}
			
			var bmargin:Number = 5;
			var back:MovieClip = new KeyConfigBack();
			back.width = buttonContainer.width + bmargin * 2;
			back.height = buttonContainer.height + bmargin * 2;
			buttonContainer.x = buttonContainer.y = bmargin;
			
			var completeContainer:Sprite = new Sprite();
			completeContainer.addChild(back);
			completeContainer.addChild(buttonContainer);
			
			var labelmargin:Number = 10;
			
			_msglabel = new TextField();
			_msgformat = new TextFormat(FontStyles.F_JOYSTIX, 20, 0xFFFFFF);
			_msgformat.align = TextFormatAlign.CENTER;
			G.setTextField(_msglabel, _msgformat);
			_msglabel.width = G.STAGE_WIDTH; //to prevent negative x.
			_msglabel.height = 32;
			
			conflictCheck(); //This puts text in _msglabel.
			G.centreX(completeContainer, _msglabel); //but don't want anything to have negative x.
			completeContainer.y = _msglabel.y + _msglabel.height + labelmargin;
			
			_defaultbutton = new TextButton("Reset to Defaults");
			_defaultbutton.addEventListener(MouseEvent.CLICK, setToDefault);
			G.centreX(_defaultbutton, completeContainer);
			_defaultbutton.y = completeContainer.y + completeContainer.height + labelmargin;
			
			addChild(completeContainer);
			addChild(_msglabel);
			addChild(_defaultbutton);
		}
		
		private function setToDefault(e:MouseEvent):void
		{
			DefaultSettings.setDefaultKeys(false);
			if (_bdown != null)
				_bdown.setKeyCodeAndName(ks.k_down, ks.name_down);
			if (_bhold != null)
				_bhold.setKeyCodeAndName(ks.k_hold, ks.name_hold);
			if (_bleft != null)
				_bleft.setKeyCodeAndName(ks.k_left, ks.name_left);
			if (_bpause != null)
				_bpause.setKeyCodeAndName(ks.k_pause, ks.name_pause);
			if (_bplace != null)
				_bplace.setKeyCodeAndName(ks.k_place, ks.name_place);
			if (_bright != null)
				_bright.setKeyCodeAndName(ks.k_right, ks.name_right);
			if (_brotccw != null)
				_brotccw.setKeyCodeAndName(ks.k_rotccw, ks.name_rotccw);
			if (_brotcw != null)
				_brotcw.setKeyCodeAndName(ks.k_rotcw, ks.name_rotcw);
			if (_bup != null)
				_bup.setKeyCodeAndName(ks.k_up, ks.name_up);
			
			conflictCheck();
		}
		
		private function makeActive(e:MouseEvent):void
		{
			//Darken the currently lit button appropriately.
			if (_activebutton)
			{
				if (_conflictlist.indexOf(_activebutton) == -1)
					_activebutton.darken();
				else
					_activebutton.warning();
			}
			else
			{
				_defaultbutton.clickable = false;
				Main.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyAssign);
			}
			
			_activebutton = KeyConfigButton(e.target.parent);
			_activebutton.lightUp();
			_msglabel.text = MSG_PRESS + _activebutton.title;
		}
		
		public function cleanUp():void
		{
			for each (var button:KeyConfigButton in _keylist)
				button.removeEventListener(MouseEvent.CLICK, makeActive);
			deActivate();
		}
		
		public function deActivate():void
		{
			if (_activebutton != null)
			{
				_activebutton.darken();
				_activebutton = null;
				_defaultbutton.clickable = true;
				Main.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyAssign);
				conflictCheck();
			}
		}
		
		private function conflictCheck():void
		{
			_conflicted = false;
			while (_conflictlist.length > 0)
				_conflictlist.pop().darken();
			
			for (var i:uint = 0; i < _keylist.length; i++)
			{
				for (var j:uint = i + 1; j < _keylist.length; j++)
				{
					if (_keylist[i].keyCode == _keylist[j].keyCode)
					{
						_keylist[i].warning();
						_keylist[j].warning();
						_conflictlist.push(_keylist[i], _keylist[j]);
						if (!_conflicted) _conflicted = true;
					}
				}
			}
			_msglabel.text = _conflicted ? MSG_CONFLICT : MSG_TITLE;
			
			dispatchEvent(new BoolEvent(BoolEvent.GO, !_conflicted));
		}
		
		private function keyAssign(e:KeyboardEvent):void
		{
			var keyCode:uint = e.keyCode;
			
			//Ignore forbidden keys.
			for each (var bad:uint in KeySettings.KEYBADS)
				if (keyCode == bad)
					return;
			
			if (_activebutton.setKeyVal(e.keyCode, e.charCode))
			{
				var keyName:String = _activebutton.keyName;
				switch (_activebutton)
				{
					case _bleft: 
						ks.k_left = keyCode;
						ks.name_left = keyName;
						break;
					
					case _bright: 
						ks.k_right = keyCode;
						ks.name_right = keyName;
						break;
					
					case _bdown: 
						ks.k_down = keyCode;
						ks.name_down = keyName;
						break;
					
					case _bup: 
						ks.k_up = keyCode;
						ks.name_up = keyName;
						break;
					
					case _brotccw: 
						ks.k_rotccw = keyCode;
						ks.name_rotccw = keyName;
						break;
					
					case _brotcw: 
						ks.k_rotcw = keyCode;
						ks.name_rotcw = keyName;
						break;
					
					case _bhold: 
						ks.k_hold = keyCode;
						ks.name_hold = keyName;
						break;
					
					case _bplace: 
						ks.k_place = keyCode;
						ks.name_place = keyName;
						break;
						
					case _bpause:
						ks.k_pause = keyCode;
						ks.name_pause = keyName;
						break;
					
					default: 
						break;
				}
				deActivate();
				SaveData.saveKeySetting(ks);
				SaveData.flush();
			}
		}
	}
}