package screens
{
	import data.SettingNames;
	import data.Settings;
	import events.BoolEvent;
	import flash.events.MouseEvent;
	import menu.BlockableButton;
	import menu.ButtonStart;
	import menu.keyconfig.KeyConfig;
	import visuals.backs.BG;
	import visuals.swipes.FadeSwipe;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class PrepareScreen extends Menu
	{	
		private var cs:Settings;
		
		private var _keyconfig:KeyConfig;
		private var _startbutton:BlockableButton;
		
		public function PrepareScreen()
		{
			cs = Settings.currentGame;
			
			addChild(new BG());
			setTitle(cs[SettingNames.GTITLE] + ": Review Controls");
			setBackButton(Main.PrevScreen);
			
			_keyconfig = new KeyConfig();
			G.centreX(_keyconfig);
			G.centreY(_keyconfig);
			//_keyconfig.y = _titlelabel.y + _titlelabel.height + 20;
			addChild(_keyconfig);
			
			_startbutton = new ButtonStart();
			G.centreX(_startbutton);
			_startbutton.y = _backbutton.y - _startbutton.height - 20;
			addButtonListener(_startbutton, startGame);
			addChild(_startbutton);
			
			_startbutton.clickable = !_keyconfig.conflicted;
			_keyconfig.addEventListener(BoolEvent.GO, updateStart);
		}
		
		private function updateStart(e:BoolEvent):void
		{
			_startbutton.clickable = e.truth;
		}
		
		private function startGame(e:MouseEvent):void
		{
			goTo(GameScreen, true);
		}
		
		override protected function goBack(e:MouseEvent):void 
		{
			goTo(_backScreen, false, FadeSwipe);
		}
		
		override protected function cleanUp():void 
		{
			_keyconfig.cleanUp();
		}
	}

}