package screens
{
	import com.newgrounds.API;
	import com.newgrounds.APIEvent;
	import com.newgrounds.components.SaveBrowser;
	import com.newgrounds.SaveFile;
	import com.newgrounds.SaveQuery;
	import data.SaveData;
	import data.Settings;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import media.fonts.FontStyles;
	import menu.keyconfig.KeyConfig;
	import menu.PopUp;
	import menu.TextButton;
	import visuals.backs.BG;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class OptionsScreen extends Menu
	{
		private var _btn_keyconfig:TextButton;
		private var _btn_savedata:TextButton;
		private var _btn_loaddata:TextButton;
		private var _btn_scorereset:TextButton;
		private var _btn_gamereset:TextButton;
		
		private var _delaytimer:FrameTimer = new FrameTimer(1500, true, 1);
		private var _browser:SaveBrowser;
		private var _savequery:SaveQuery;
		
		public function OptionsScreen()
		{
			addChild(new BG());
			setTitle("Options");
			setBackButton(MainMenu);
			_delaytimer.addEventListener(TimerEvent.TIMER_COMPLETE, delayFadeOut);
			
			_btn_keyconfig = new TextButton("Configure Controls");
			_btn_savedata = new TextButton("Save Game Data");
			_btn_loaddata = new TextButton("Load Game Data");
			_btn_scorereset = new TextButton("Reset High Scores");
			_btn_gamereset = new TextButton("! Reset All Game Data !");
			
			addButtonListener(_btn_keyconfig, showKeyConfig);
			addButtonListener(_btn_savedata, saveData);
			addButtonListener(_btn_loaddata, loadData);
			addButtonListener(_btn_scorereset, resetScoresAsk);
			addButtonListener(_btn_gamereset, resetModesAsk);
			
			var buttonlist:Vector.<TextButton> = new Vector.<TextButton>();
			buttonlist.push(_btn_keyconfig, _btn_savedata, _btn_loaddata, _btn_scorereset, _btn_gamereset);
			
			var bcontainer:Sprite = new Sprite();
			var ypos = 0;
			for each (var button:TextButton in buttonlist)
			{
				G.centreX(button);
				button.y = ypos;
				ypos += button.height + 10;
				bcontainer.addChild(button);
			}
			bcontainer.filters = [new DropShadowFilter(10)];
			
			G.centreY(bcontainer);
			addChild(bcontainer);
			
			API.addEventListener(APIEvent.FILE_SAVED, onFileSaved);
			API.addEventListener(APIEvent.FILE_LOADED, confirmLoadData);
			API.addEventListener(APIEvent.FILE_DELETED, onFileDelete);
			
			if (APIUtils.getLastLoadedFile() != null && APIUtils.getLastLoadedFile().group.name == APIUtils.SG_DATA)
				addEventListener(Event.ADDED_TO_STAGE, loadDataImmediate);
		}
		
		private function showKeyConfig(e:MouseEvent):void
		{
			var keyconfig:KeyConfig = new KeyConfig();
			PopUp.makePopUp(
			"Configure Controls",
			Vector.<String>(["Done"]),
			Vector.<Function>([PopUp.fadeOut]),
			keyconfig);
		}
		
		private function saveData(e:MouseEvent):void
		{
			if (!APIUtils.hasUserSession())
			{
				PopUp.makePopUp("You must be logged into a Newgrounds account in order to save/load data.",
				Vector.<String>(["Okay"]), Vector.<Function>([PopUp.fadeOut]));
				return;
			}
			APIUtils.actOnConnect(function():void
			{
				PopUp.makePopUp(
				"Do you want to save a backup of all current data (custom modes, high scores) on your Newgrounds account?"
				+ " It can be loaded back later from any computer, as long as you're signed in to Newgrounds with the account you're using now.",
				Vector.<String>(["Yes, save", "No, don't save"]),
				Vector.<Function>([function(e:MouseEvent):void
				{
					var file:SaveFile = API.createSaveFile(APIUtils.SG_DATA);
					if (file != null)
					{
						PopUp.setInteractionEnabled(false);
						var date:Date = new Date();
						var datestring:String = (date.getMonth() + 1).toString() + "/" + date.getDate().toString() + "/" + date.getFullYear().toString();
						
						var icon:Sprite = new Sprite();
						icon.graphics.beginFill(0);
						icon.graphics.drawRect(0, 0, 100, 100);
						var datelabel:TextField = new TextField();
						G.setTextField(datelabel, new TextFormat(FontStyles.F_JOYSTIX, 15, 0xFFFFFF));
						datelabel.autoSize = TextFieldAutoSize.CENTER; // To auto-set the height.
						datelabel.text = datestring;
						G.matchSizeC(datelabel, icon, true);
						G.centreX(datelabel, icon);
						G.centreY(datelabel, false, icon);
						icon.addChild(datelabel);
						
						file.name = "Save Data: " + datestring;
						file.description = "Game data saved on " + datestring + ".";
						var allmodes:Array = [];
						for (var i:uint = 0; i < Settings.numtypes; i++)
							allmodes.push(Settings.copyGameType(Settings.getGameType(i), false, false, false));
						file.data = allmodes;
						file.createIcon(icon);
						file.save();
					}
					else
					{
						PopUp.fadeOut();
						APIUtils.makeErrorPopUp();
					}
				}, PopUp.fadeOut]));
			});
		}
		
		private function onFileSaved(e:APIEvent):void
		{
			PopUp.fadeOut();
			if (e.success)
			{
				PopUp.makePopUp("Success!");
				_delaytimer.start();
			}
			else
				APIUtils.makeErrorPopUp();
		}
		
		private function delayFadeOut(e:TimerEvent):void
		{
			_delaytimer.reset();
			PopUp.fadeOut();
		}
		
		private function loadData(e:MouseEvent):void
		{
			if (!APIUtils.hasUserSession())
			{
				PopUp.makePopUp("You must be logged into a Newgrounds account in order to save/load data.",
				Vector.<String>(["Okay"]), Vector.<Function>([PopUp.fadeOut]));
				return;
			}
			APIUtils.actOnConnect(function():void
			{
				_browser = new SaveBrowser();
				_browser.saveGroupName = APIUtils.SG_DATA;
				_browser.title = APIUtils.SG_DATA;
				
				_savequery = API.createSaveQueryByDate(APIUtils.SG_DATA);
				_savequery.addCondition(SaveQuery.AUTHOR_NAME, SaveQuery.OPERATOR_EQUAL, APIUtils.username);
				_browser.setQuery(_savequery);
				
				PopUp.makePopUp("Load or delete a previously backed-up game state.",
				Vector.<String>(["Cancel"]),
				Vector.<Function>([function(e:MouseEvent):void
				{
					_browser = null;
					API.stopPendingCommands();
					PopUp.fadeOut();
				}]),
				_browser);
			});
		}
		
		private function confirmLoadData(e:APIEvent):void
		{
			if (e.success)
			{
				var file:SaveFile = SaveFile(e.data);
				PopUp.makePopUp("Load this data file, or delete it?"
				+ "\nWARNING: Loading will overwrite all current game data!",
				Vector.<String>(["Load file", "Delete file", "Cancel"]),
				Vector.<Function>(
				[function(e:MouseEvent):void
				{
					SaveData.loadSavedGameSettings(file.data as Array);
					PopUp.fadeOut();
					PopUp.fadeOut();
					PopUp.makePopUp("Success!");
					_delaytimer.start();
				},
				function(e:MouseEvent):void
				{
					PopUp.setInteractionEnabled(false);
					file.deleteFile();
				},
				PopUp.fadeOut]));
			}
			else
				APIUtils.makeErrorPopUp("Load failed, try again.");
		}
		
		private function loadDataImmediate(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, loadDataImmediate);
			if (API.hasUserSession && APIUtils.getLastLoadedFile().authorName != APIUtils.username)
			{
				APIUtils.makeErrorPopUp("The file you loaded doesn't belong to your Newgrounds account! You can only load backup data you have created.");
				return;
			}
			SaveData.loadSavedGameSettings(APIUtils.getLastLoadedFile().data as Array);
			APIUtils.clearLastLoadedFile();
			PopUp.makePopUp("Loaded " + SaveFile.currentFile.name + "!",
			Vector.<String>(["Okay"]),
			Vector.<Function>([PopUp.fadeOut]));
		}
		
		private function onFileDelete(e:APIEvent):void
		{
			PopUp.fadeOut();
			if (e.success)
			{
				_browser.loadFiles();
				PopUp.makePopUp("File deleted.");
				_delaytimer.start();
			}
			else
				APIUtils.makeErrorPopUp("Error in deleting file.");
		}
		
		private function resetScoresAsk(e:MouseEvent):void
		{
			PopUp.makePopUp(
			"Are you sure you want to clear all high scores for every mode?",
			Vector.<String>(["Yes, clear *ALL* scores", "Cancel"]),
			Vector.<Function>([function(e:MouseEvent):void
			{
				for (var i:uint = 0, n:uint = Settings.numtypes; i < n; i++)
				{
					var cs:Settings = Settings.getGameType(i);
					cs.clearScores();
					SaveData.saveGameSetting(cs);
				}
				SaveData.flush();
				PopUp.fadeOut();
				PopUp.makePopUp("Scores reset.");
				_delaytimer.start();
			}, PopUp.fadeOut]));
		}
		
		private function resetModesAsk(e:MouseEvent):void
		{
			PopUp.makePopUp(
			"Are you sure you want to reset *ALL* mode data? This will restore all default modes, but will permanently delete all high scores and custom modes!\n(Only backup data & keyboard settings won't be deleted.)",
			Vector.<String>(["Yes, reset *ALL* data", "Cancel"]),
			Vector.<Function>([function(e:MouseEvent):void
			{
				SaveData.removeAllGameSettings();
				SaveData.flush();
				PopUp.fadeOut();
				PopUp.makePopUp("Data reset.");
				_delaytimer.start();
			}, PopUp.fadeOut])
			);
		}
		
		override protected function cleanUp():void 
		{
			_delaytimer.removeEventListener(TimerEvent.TIMER_COMPLETE, delayFadeOut);
			APIUtils.clearLastLoadedFile();
			API.stopPendingCommands();
			API.removeEventListener(APIEvent.FILE_SAVED, onFileSaved);
			API.removeEventListener(APIEvent.FILE_LOADED, confirmLoadData);
			API.removeEventListener(APIEvent.FILE_DELETED, onFileDelete);
		}
	}
}