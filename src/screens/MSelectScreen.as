package screens
{
	import com.newgrounds.API;
	import com.newgrounds.APIEvent;
	import com.newgrounds.SaveFile;
	import data.SaveData;
	import data.SettingNames;
	import data.Settings;
	import events.IDEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import media.sounds.SongList;
	import media.sounds.Sounds;
	import menu.DescContainer;
	import menu.ModeButton;
	import menu.ModeContainer;
	import menu.PopUp;
	import visuals.backs.BG;
	import visuals.swipes.FadeSwipe;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class MSelectScreen extends Menu
	{
		private var _modeContainer:ModeContainer;
		private var _descContainer:DescContainer;
		
		public function MSelectScreen()
		{
			addChild(new BG());
			setTitle("Mode Select");
			APIUtils.clearLastLoadedFile();
			Sounds.playSong(SongList.Summertime);
			
			var cs:Settings = Settings.currentGame;
			
			_modeContainer = new ModeContainer();
			G.centreX(_modeContainer);
			_modeContainer.y = _titlelabel.y + _titlelabel.height + 10;
			addChild(_modeContainer);
			
			_descContainer = new DescContainer(false);
			G.centreX(_descContainer);
			_descContainer.y = _modeContainer.y + _modeContainer.height + 10;
			addChild(_descContainer);
			
			_modeContainer.addEventListener(IDEvent.GO, selectMode);
			_descContainer.addEventListener(DescContainer.E_START, startGame);
			_descContainer.addEventListener(DescContainer.E_SCORE, viewHighScore);
			_descContainer.addEventListener(DescContainer.E_COPY, copyMode);
			_descContainer.addEventListener(DescContainer.E_EDIT, editMode);
			_descContainer.addEventListener(DescContainer.E_DEL, deleteMode);
			_descContainer.addEventListener(DescContainer.E_SHARE, shareMode);
			
			if (cs != null)
				_modeContainer.selected = cs.gtype;
			
			setBackButton(MainMenu);
		}
		
		private function selectMode(e:IDEvent):void
		{
			Settings.setGameType(e.id);
			_descContainer.updateSelected();
			//any visual update here...?
		}
		
		private function startGame(e:Event):void
		{
			goTo(PrepareScreen, false, FadeSwipe);
		}
		
		private function viewHighScore(e:Event):void
		{
			goTo(ResultScreen, false, FadeSwipe);
		}
		
		private function copyMode(e:Event):void
		{
			if (Settings.numtypes >= Settings.MAX_GAMES - 1) //The > is for safety.
			{
				PopUp.makePopUp(
				Settings.MAX_MESSAGE,
				Vector.<String>(["Okay"]),
				Vector.<Function>([PopUp.fadeOut]));
				return;
			}
			
			var ds:Settings = Settings.copyGameType(Settings.currentGame, false, true, false);
			SaveData.saveGameSetting(ds); //Should be added to end of mode list.
			SaveData.flush();
			Settings.setGameType(ds.gtype); //This will be the selected mode upon refresh.
			goTo(MSelectScreen); //Refresh the screen to more easily reposition all of the mode buttons.
		}
		
		private function editMode(e:Event):void
		{
			//Settings.setGameType(e.id);
			goTo(EditScreen, true);
		}
		
		private function deleteMode(e:Event):void
		{
			var cs:Settings = Settings.currentGame;
			var dummybutton:ModeButton = new ModeButton(cs[SettingNames.GTITLE], cs[SettingNames.GTCOL], cs[SettingNames.GCOL], false);
			dummybutton.mouseChildren = dummybutton.mouseEnabled = dummybutton.tabChildren = dummybutton.tabEnabled = false;
			PopUp.makePopUp(
			"Are you sure you want to delete this mode?",
			Vector.<String>(["Yes", "No"]),
			Vector.<Function>([function(e:MouseEvent):void
			{
				var toselect:uint = Math.max(0, Settings.currentGame.gtype - 1);
				SaveData.removeGameSetting(Settings.currentGame);
				SaveData.flush();
				Settings.setGameType(toselect); //This will be the selected mode upon refresh.
				goTo(MSelectScreen); //Refresh the screen to more easily reposition all of the mode buttons.
			}, PopUp.fadeOut]),
			dummybutton);
		}
		
		private function shareMode(e:Event):void
		{
			if (!API.hasUserSession)
			{
				APIUtils.makeErrorPopUp("You can only share modes when logged into a Newgrounds account.");
				return;
			}
			var cs:Settings = Settings.currentGame;
			if (cs[SettingNames.FILEID] != 0 || cs[SettingNames.GAUTHOR] == Settings.DEFAULT_AUTHOR)
			{
				PopUp.makePopUp(
				cs[SettingNames.FILEID] != 0 ? "This mode is already being shared! For you to be able to share it again, you must make a significant change to the mode (scores will be reset)."
											 : "You cannot share a default mode! For you to be able to share it, you must make a significant change to the mode (scores will be reset).",
				Vector.<String>(["Okay"]),
				Vector.<Function>([PopUp.fadeOut]));
				return;
			}
			APIUtils.actOnConnect(function():void
			{
				var dummybutton:ModeButton = new ModeButton(cs[SettingNames.GTITLE], cs[SettingNames.GTCOL], cs[SettingNames.GCOL], false);
				dummybutton.mouseChildren = dummybutton.mouseEnabled = dummybutton.tabChildren = dummybutton.tabEnabled = false;
				PopUp.makePopUp(
				"Are you sure you would like to publicly share this mode on the Newgrounds servers?",
				Vector.<String>(["Yes", "No"]),
				Vector.<Function>([function(e:MouseEvent):void
				{
					var file:SaveFile = API.createSaveFile(APIUtils.SG_SHARED);
					if (file != null)
					{
						PopUp.setInteractionEnabled(false);
						file.name = cs[SettingNames.GTITLE];
						file.data = Settings.copyGameType(cs, false, false, false);
						file.createIcon(dummybutton);
						Settings(file.data).netLinkAllScores();
						API.addEventListener(APIEvent.FILE_SAVED, onFileSaved);
						file.save();
						//Note: shared modes don't have their Settings->[FILEID] set, but their SaveFile->.id is!!!
					}
					else
					{
						PopUp.fadeOut();
						APIUtils.makeErrorPopUp();
					}
				},
				PopUp.fadeOut]),
				dummybutton
				);
			});
		}

		private function onFileSaved(e:APIEvent):void
		{
			PopUp.fadeOut();
			if (e.success)
			{
				Settings.currentGame[SettingNames.FILEID] = SaveFile(e.data).id;
				SaveData.saveGameSetting(Settings.currentGame);
				API.removeEventListener(APIEvent.FILE_SAVED, onFileSaved);
				
				PopUp.makePopUp("Success!",
				Vector.<String>(["View Usermade Modes", "No thanks"]),
				Vector.<Function>([viewUsermodes, PopUp.fadeOut]));
				_descContainer.updateSelected(); //Update to signify that the mode is linked to a file now.
			}
			else
			{
				APIUtils.makeErrorPopUp();
			}
		}
		
		private function viewUsermodes(e:Event):void
		{
			goTo(UsermodeScreen);
		}
		
		override protected function cleanUp():void 
		{
			_modeContainer.removeEventListener(IDEvent.GO, selectMode);
			_descContainer.removeEventListener(DescContainer.E_START, startGame);
			_descContainer.removeEventListener(DescContainer.E_SCORE, viewHighScore);
			_descContainer.removeEventListener(DescContainer.E_EDIT, copyMode);
			_descContainer.removeEventListener(DescContainer.E_EDIT, editMode);
			_descContainer.removeEventListener(DescContainer.E_EDIT, deleteMode);
			_descContainer.removeEventListener(DescContainer.E_SHARE, shareMode);
			_modeContainer.cleanUp();
			_descContainer.cleanUp();
		}
		
	}

}