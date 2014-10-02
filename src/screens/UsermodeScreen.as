package screens
{
	import com.newgrounds.API;
	import com.newgrounds.APIEvent;
	import com.newgrounds.components.SaveBrowser;
	import com.newgrounds.SaveFile;
	import data.SettingNames;
	import data.Settings;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import media.sounds.SongList;
	import media.sounds.Sounds;
	import menu.DescContainer;
	import menu.ModeButton;
	import menu.PopUp;
	import visuals.backs.BG;
	import visuals.swipes.FadeSwipe;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class UsermodeScreen extends Menu
	{	
		private var cs:Settings;
		private var _browser:SaveBrowser;
		private var _descContainer:DescContainer;
		
		public function UsermodeScreen()
		{
			addChild(new BG());
			setTitle("Usermade Modes");
			Settings.clearType();
			Sounds.playSong(SongList.Summertime);
			
			_browser = new SaveBrowser();
			_browser.saveGroupName = APIUtils.SG_SHARED;
			_browser.title = APIUtils.SG_SHARED;
			G.centreX(_browser);
			_browser.y = _titlelabel.y + _titlelabel.height + 10;
			addChild(_browser);
			
			_descContainer = new DescContainer(true);
			G.centreX(_descContainer);
			_descContainer.y = _browser.y + _browser.height;
			addChild(_descContainer);
			
			API.addEventListener(APIEvent.FILE_LOADED, selectMode);
			_descContainer.addEventListener(DescContainer.E_START, startGame);
			_descContainer.addEventListener(DescContainer.E_SCORE, viewHighScore);
			
			// Trigger selectMode(e) if a game mode is already loaded (from submission page or previous screen).
			if (APIUtils.getLastLoadedFile() != null && APIUtils.getLastLoadedFile().group.name == APIUtils.SG_SHARED)
				APIUtils.getLastLoadedFile().load();
			
			setBackButton(Main.PrevScreen == MSelectScreen ? MSelectScreen : MainMenu);
		}
		
		private function selectMode(e:APIEvent):void
		{
			if (e.success)
			{
				var file:SaveFile = SaveFile(e.data);
				cs = Settings.copyGameType(file.data, false, false, false);
				cs[SettingNames.FILEID] = file.id; //Don't save this yet; it gets saved if the mode is stored locally.
				Settings.setGameTypeForced(cs);
				_descContainer.updateSelected();
			}
			else
				APIUtils.makeErrorPopUp();
		}
		
		private function equivalentFile():Settings
		{
			//Note: don't need to worry about skipping this mode's entry in the mode list, because it shouldn't be in it!
			for (var i:uint = 0; i < Settings.numtypes; i++)
				if (Settings.getGameType(i)[SettingNames.FILEID] == cs[SettingNames.FILEID])
					return Settings.getGameType(i);
			
			return null;
		}
		
		private function startGame(e:Event):void
		{
			var dummybutton:ModeButton;
			var es:Settings = equivalentFile();
			if (es != null)
			{
				dummybutton = new ModeButton(es[SettingNames.GTITLE], es[SettingNames.GTCOL], es[SettingNames.GCOL], false);
				dummybutton.mouseChildren = dummybutton.mouseEnabled = dummybutton.tabChildren = dummybutton.tabEnabled = false;
				PopUp.makePopUp("This mode already exists in local memory. Would you like to play that mode now?",
				Vector.<String>(["Yes", "No"]),
				Vector.<Function>([function(e:MouseEvent):void
				{
					Settings.setGameType(es.gtype);
					APIUtils.clearLastLoadedFile();
					goTo(PrepareScreen, false, FadeSwipe);
				}, PopUp.fadeOut]),
				dummybutton);
			}
			else if (Settings.numtypes < Settings.MAX_GAMES)
				goTo(PrepareScreen, false, FadeSwipe);
			else
				PopUp.makePopUp("There are no remaining slots for custom game modes. Unless you delete one, you WON'T be able to keep this mode after you've played it.",
				Vector.<Function>(["Play anyways", "View Mode Select Screen"]),
				Vector.<Function>([
				function(e:MouseEvent):void
				{
					goTo(PrepareScreen, false, FadeSwipe);
				},
				function(e:MouseEvent):void
				{
					goTo(MSelectScreen, false, FadeSwipe);
				}]));
		}
		
		private function viewHighScore(e:Event):void
		{
			goTo(ResultScreen, false, FadeSwipe);
		}
		
		override protected function cleanUp():void 
		{
			API.stopPendingCommands();
			API.removeEventListener(APIEvent.FILE_LOADED, selectMode);
			_descContainer.removeEventListener(DescContainer.E_START, startGame);
			_descContainer.removeEventListener(DescContainer.E_SCORE, viewHighScore);
		}
	}

}