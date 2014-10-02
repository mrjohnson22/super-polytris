package menu 
{
	import data.KeySettings;
	import data.SettingNames;
	import data.Settings;
	import events.BoolEvent;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import media.fonts.FontStyles;
	import menu.keyconfig.KeyConfig;
	import visuals.backs.PauseBack;
	import visuals.swipes.EventAnim;
	import visuals.swipes.PauseEntryAnim;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class PauseMenu extends MovieClip 
	{
		private var _menuContainer:Sprite;
		private var _keyContainer:Sprite;
		private var _quitContainer:Sprite;
		
		private var _pausebutton:MovieClip;
		private var _bg:MovieClip;
		private var _anim:EventAnim;
		private var _outanim:EventAnim;
		private var _titlelabel:TextField;
		
		private var _btn_resume:TextButton;
		private var _btn_keyconfig:TextButton;
		private var _btn_quit:TextButton;
		
		private var _keyconfig:KeyConfig;
		private var _keyback:TextButton;
		
		private var _quityes:TextButton;
		private var _quitno:TextButton;
		
		private var _activeContainer:Sprite;
		
		private var _pauseFunction:Function;
		private var _unpauseFunction:Function;
		private var _quitFunction:Function;
		
		private var _paused:Boolean = false;
		public function get paused():Boolean
		{
			return _paused;
		}
		
		public function PauseMenu(pauseFunction:Function, unpauseFunction:Function, quitFunction:Function) 
		{
			_pauseFunction = pauseFunction;
			_unpauseFunction = unpauseFunction;
			_quitFunction = quitFunction;
			
			_pausebutton = new PauseButton();
			const pmargin:Number = 20;
			if (Settings.currentGame[SettingNames.STAGESIDE] != Settings.S_SIDE_RIGHT)
				G.rightAlign(_pausebutton, pmargin);
			else
				_pausebutton.x = pmargin;
			G.bottomAlign(_pausebutton, pmargin);
			addChild(_pausebutton);
			
			//Main menu
			_menuContainer = new Sprite();
			
			var titleformat:TextFormat = new TextFormat(FontStyles.F_JOYSTIX, 60, 0xFF0000);
			titleformat.align = TextFormatAlign.CENTER;
			
			_titlelabel = new TextField();
			G.setTextField(_titlelabel, titleformat);
			_titlelabel.autoSize = TextFieldAutoSize.CENTER;
			_titlelabel.filters = [new DropShadowFilter()];
			_titlelabel.text = "PAUSED";
			
			G.centreX(_titlelabel);
			_titlelabel.y = G.STAGE_HEIGHT / 4;
			var tmargin:Number = _titlelabel.y + _titlelabel.height + 30;
			
			_btn_resume = new TextButton("Resume Game");
			_btn_keyconfig = new TextButton("Configure Controls");
			_btn_quit = new TextButton("Quit Game");
			//Don't add listeners yet; these buttons are the first to appear, so activate them
			//only once the menu "entry effects" have finished.
			
			var buttonlist:Vector.<TextButton> = new Vector.<TextButton>();
			buttonlist.push(_btn_resume);
			buttonlist.push(_btn_keyconfig);
			buttonlist.push(_btn_quit);
			
			var bcontainer:Sprite = new Sprite();
			var ypos = tmargin;
			for each (var button:TextButton in buttonlist)
			{
				G.centreX(button);
				button.y = ypos;
				ypos += button.height + 10;
				bcontainer.addChild(button);
			}
			
			//G.betweenY(bcontainer, _titlelabel, null);
			_menuContainer.addChild(bcontainer);
			
			//Options menu
			_keyContainer = new Sprite();
			
			var kcontainer:Sprite = new Sprite();
			_keyconfig = new KeyConfig();
			_keyback = new TextButton("Back");
			G.centreX(_keyback, _keyconfig);
			_keyback.y = _keyconfig.y + _keyconfig.height + 20;
			kcontainer.addChild(_keyconfig);
			kcontainer.addChild(_keyback);
			G.centreX(kcontainer);
			G.centreY(kcontainer);
			_keyContainer.addChild(kcontainer);
			_keyconfig.addEventListener(BoolEvent.GO, validKeys);
			
			//Quit menu
			_quitContainer = new Sprite();
			
			var quitformat:TextFormat = new TextFormat(FontStyles.F_JOYSTIX, 25, 0xFF0000);
			quitformat.align = TextFormatAlign.CENTER;
			
			var quitlabel:TextField = new TextField();
			G.setTextField(quitlabel, quitformat);
			quitlabel.autoSize = TextFieldAutoSize.CENTER;
			quitlabel.text = (Settings.currentGame.gtype == -1 ? "WARNING:\nThis mode is not yet saved!\n" : "") + "Are you sure you\nwant to quit?";
			G.matchSizeV(quitlabel, G.STAGE_WIDTH * 0.9, 300, false);
			
			G.centreX(quitlabel);
			quitlabel.y = tmargin;
			quitlabel.filters = [new DropShadowFilter()];
			_quitContainer.addChild(quitlabel);
			
			_quityes = new TextButton("Yes");
			_quitno = new TextButton("No");
			_quitno.width = _quityes.width;
			
			var qcontainer:Sprite = new Sprite();
			_quitno.x = _quityes.x + _quityes.width + 10;
			qcontainer.addChild(_quityes);
			qcontainer.addChild(_quitno);
			G.centreX(qcontainer);
			qcontainer.y = quitlabel.y + quitlabel.height + 30;
			_quitContainer.addChild(qcontainer);
		}
		
		private function pauseKey(e:Event):void
		{
			if (Key.isTap(KeySettings.currentConfig.k_pause))
			{
				Main.stage.removeEventListener(Event.ENTER_FRAME, pauseKey);
				if (!_paused)
					pauseAction();
				else
					unpauseAction();
			}
		}
		
		/**
		 * Allow the "pause" button to respond to being clicked, and to perform the externally-defined
		 * pause function upon being clicked. Also allows pressing the pause key to pause the game.
		 */
		public function enable():void
		{
			_pausebutton.addEventListener(MouseEvent.CLICK, pauseAction);
			_pausebutton.buttonMode = true;
			Main.stage.addEventListener(Event.ENTER_FRAME, pauseKey);
		}
		
		public function disable():void
		{
			_pausebutton.removeEventListener(MouseEvent.CLICK, pauseAction);
			_pausebutton.buttonMode = false;
			Main.stage.removeEventListener(Event.ENTER_FRAME, pauseKey);
		}
		
		public function cleanUp():void
		{
			disableButtons();
			disable();
			_keyconfig.cleanUp();
			_keyconfig.removeEventListener(BoolEvent.GO, validKeys);
		}
		
		private function pauseAction(e:MouseEvent = null):void
		{
			//For safety: can't pause when already paused.
			if (_paused)
				return;
			
			_paused = true;
			//removeChild(_pausebutton);
			disable();
			_pauseFunction();
			
			_anim = new PauseEntryAnim();
			_anim.addEventListener(EventAnim.READY, showFirstMenu);
			_anim.addEventListener(EventAnim.DONE, enableButtons);
			addChild(_anim);
		}
		
		private function unpauseAction(e:MouseEvent = null):void
		{
			if (!_paused)
				return;
			//_paused = false;
			_outanim = new PauseEntryAnim(); //maybe PauseExitAnim.
			_outanim.addEventListener(EventAnim.READY, hideMenu);
			_outanim.addEventListener(EventAnim.DONE, doUnpauseFunction); //Unpauses once the animation is complete.
			addChild(_outanim);
		}
		
		private function doUnpauseFunction(e:Event):void
		{
			_outanim.removeEventListener(EventAnim.DONE, doUnpauseFunction);
			_unpauseFunction();
			_paused = false;
			enable();
		}
		
		private function quitAction(e:MouseEvent = null):void
		{
			_quitFunction(e);
		}
		
		private function showFirstMenu(e:Event):void
		{
			removeChild(_pausebutton);
			_bg = new PauseBack();
			addChildAt(_titlelabel, 0);
			addChildAt(_menuContainer, 0);
			addChildAt(_bg, 0);
			_activeContainer = _menuContainer;
			
			_anim.removeEventListener(EventAnim.READY, showFirstMenu);
			Main.stage.addEventListener(Event.ENTER_FRAME, pauseKey);
		}
		
		private function hideMenu(e:Event):void
		{
			removeChild(_titlelabel);
			removeChild(_activeContainer);
			disableButtons();
			_paused = false;
			
			removeChild(_bg);
			_bg.stop();
			_bg = null;
			
			addChildAt(_pausebutton, 0);
			
			_outanim.removeEventListener(EventAnim.READY, hideMenu);
			Main.stage.focus = Main.stage;
		}
		
		private function enableButtons(e:Event):void
		{
			_btn_resume.addEventListener(MouseEvent.CLICK, unpauseAction);
			_btn_keyconfig.addEventListener(MouseEvent.CLICK, viewConfig);
			_btn_quit.addEventListener(MouseEvent.CLICK, viewQuit);
			
			_quityes.addEventListener(MouseEvent.CLICK, quitAction);
			_quitno.addEventListener(MouseEvent.CLICK, viewMain);
			
			_keyback.addEventListener(MouseEvent.CLICK, viewMain);
			
			_anim.removeEventListener(EventAnim.DONE, enableButtons);
			Main.stage.focus = Main.stage;
		}
		
		private function disableButtons():void
		{
			_btn_resume.removeEventListener(MouseEvent.CLICK, unpauseAction);
			_btn_keyconfig.removeEventListener(MouseEvent.CLICK, viewConfig);
			_btn_quit.removeEventListener(MouseEvent.CLICK, viewQuit);
			
			_quityes.removeEventListener(MouseEvent.CLICK, quitAction);
			_quitno.removeEventListener(MouseEvent.CLICK, viewMain);
			
			_keyconfig.removeEventListener(BoolEvent.GO, validKeys);
			_keyback.removeEventListener(MouseEvent.CLICK, viewMain);
		}
		
		private function viewMain(e:MouseEvent):void
		{
			viewMenu(_menuContainer);
			Main.stage.addEventListener(Event.ENTER_FRAME, pauseKey);
		}
		
		private function viewConfig(e:MouseEvent):void
		{
			viewMenu(_keyContainer);
			_titlelabel.visible = false;
		}
		
		private function validKeys(e:BoolEvent):void
		{
			_keyback.clickable = e.truth;
		}
		
		private function viewQuit(e:MouseEvent):void
		{
			viewMenu(_quitContainer);
		}
		
		private function viewMenu(vmenu:Sprite):void
		{
			_keyconfig.deActivate();
			_titlelabel.visible = true; //in case it was made false by some other menu.
			Main.stage.removeEventListener(Event.ENTER_FRAME, pauseKey);
			if (_activeContainer != null)
			{
				_activeContainer.mouseChildren = false;
				removeChild(_activeContainer);
			}
			_activeContainer = vmenu;
			vmenu.mouseChildren = true;
			addChild(vmenu);
			Main.stage.focus = Main.stage;
		}
		
	}

}