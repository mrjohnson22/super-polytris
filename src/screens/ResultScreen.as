package screens
{
	import com.greensock.TweenLite;
	import com.newgrounds.API;
	import com.newgrounds.APIEvent;
	import com.newgrounds.components.ScoreBrowser;
	import com.newgrounds.SaveFile;
	import com.newgrounds.ScoreBoard;
	import data.SaveData;
	import data.SettingNames;
	import data.Settings;
	import fl.transitions.easing.None;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.ui.Keyboard;
	import media.fonts.FontStyles;
	import media.sounds.SongList;
	import media.sounds.Sounds;
	import menu.ButtonBack2;
	import menu.PopUp;
	import menu.ScoreBack;
	import menu.TextButton;
	import visuals.backs.BG;
	import visuals.swipes.FadeSwipe;
	import visuals.TextFieldPlus;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class ResultScreen extends Menu
	{
		private static const NUM_INITIALS:uint = 3;
		
		private var _aftergame:Boolean;
		private var _highviewed:Boolean;
		
		private var _okaybutton:TextButton;
		private var _initlabel:TextFieldPlus;
		private var _hiscorelabel:TextFieldPlus;
		private var _score:int;
		private var _hirank:int;
		
		private var _hiscorebox:Sprite;
		private var _netscorebox:ScoreBrowser;
		private var _scoretag:String;
		
		private var _highView:MovieClip;
		private var _scoreView:MovieClip;
		
		/**
		 * Either the "Play Again" button (if after a game), or the "Reset Scores" button (if viewing scores).
		 */
		private var _button1:TextButton;
		
		/**
		 * Either the "Main Menu" button (if after a game(, or the "Back" button (if viewing scores).
		 */
		private var _button2:TextButton;
		
		private var _buttonsubmit:TextButton;
		private var _buttonviewnet:TextButton;
		private var _buttonviewloc:TextButton;
		
		private var _hiscoretexts:Vector.<TextFieldPlus>;
		
		private var cs:Settings;
		
		/**
		 * The screen which displays high score information. This same screen is displayed after a
		 * completed game, and shows the New High Score screen with name entry in the case of having
		 * earned a new high score.
		 * **NOTE:** If selecting a high score screen, set game mode BEFORE calling this screen!
		 */
		public function ResultScreen()
		{
			addChild(new BG());
			
			_score = GameScreen.getEndScore();
			
			//Create a local reference to currentGame, so Settings doesn't have to be referenced again and again.
			cs = Settings.currentGame;
			
			if (cs[SettingNames.FILEID] != 0)
				_scoretag = cs[SettingNames.FILEID].toString();
			else if (cs[SettingNames.LOCKED])
				_scoretag = cs[SettingNames.GTITLE];
			else
				_scoretag = null;
			
			//If viewing of a high score screen from a menu initiated this screen, then the score
			//will be an undefined value.
			_aftergame = _score != GameScreen.NOGAME;
			
			//If this screen is to be shown after a game, grab the score.
			if (_aftergame)
			{
				Sounds.playSong(SongList.Grenade);
				
				_hirank = checkHighScores(_score);
				if (_hirank != -1)
				{
					_highviewed = true;
					makeHighView();
				}
				else
				{
					_highviewed = false;
					makeScoreView();
				}
			}
			//If this screen was selected, choose the correct game mode. Otherwise, it's already correct.
			else
			{
				_highviewed = false;
				_hirank = -1;
				makeScoreView();
			}
		}
		
		private function makeHighView():void
		{
			_highView = new MovieClip();
			_highView.graphics.beginFill(0, 0); //this is important for the tween!
			_highView.graphics.drawRect(0, 0, G.STAGE_WIDTH, G.STAGE_HEIGHT);
			
			var labels:Vector.<DisplayObject> = new Vector.<DisplayObject>();
			
			var topformat:TextFormat = new TextFormat(FontStyles.F_JOYSTIX, 30, 0xFF0000);
			topformat.align = TextFormatAlign.CENTER;
			
			var toplabel:TextField = new TextField();
			G.setTextField(toplabel, topformat);
			toplabel.autoSize = TextFieldAutoSize.CENTER;
			toplabel.text = "NEW HIGH SCORE!!";
			toplabel.filters = [new DropShadowFilter()];
			labels.push(toplabel);
			
			_hiscorelabel = new TextFieldPlus(FontStyles.F_JOYSTIX, 40, G.STAGE_WIDTH * 0.8);
			_hiscorelabel.blink = true;
			_hiscorelabel.makeBorder(0x0000FF);
			_hiscorelabel.text = _score.toString();
			labels.push(_hiscorelabel);
			
			var lowformat:TextFormat = new TextFormat(FontStyles.F_JOYSTIX, 20, 0xFF0000);
			lowformat.align = TextFormatAlign.CENTER;
			
			var lowlabel:TextField = new TextField();
			G.setTextField(lowlabel, lowformat);
			lowlabel.autoSize = TextFieldAutoSize.CENTER;
			lowlabel.text = "Enter Initials";
			lowlabel.filters = [new DropShadowFilter()];
			labels.push(lowlabel);
			
			_initlabel = new TextFieldPlus(FontStyles.F_JOYSTIX, 30, 90);
			_initlabel.makeBorder(0x0000FF);
			labels.push(_initlabel);
			Main.stage.addEventListener(KeyboardEvent.KEY_DOWN, typeInitials);
			
			var container:Sprite = new Sprite();
			var ypos:Number = 0;
			for (var i:uint = 0; i < labels.length; i += 2)
			{
				container.addChild(labels[i]);
				labels[i].y = ypos;
				ypos += labels[i].height + 20;
				
				container.addChild(labels[i + 1]);
				labels[i + 1].y = ypos;
				ypos += labels[i + 1].height + 30;
				
				G.centreX(labels[i]);
				G.centreX(labels[i + 1]);
			}
			
			G.centreY(container);
			_highView.addChild(container);
			
			
			_okaybutton = new TextButton("Okay");
			G.centreX(_okaybutton);
			G.bottomAlign(_okaybutton);
			_highView.addChild(_okaybutton);
			_okaybutton.clickable = false;
			_okaybutton.addEventListener(MouseEvent.CLICK, slideHighToScore);
			
			addChild(_highView);
		}
		
		private function typeInitials(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.ENTER && _okaybutton.clickable)
			{
				slideHighToScore();
				return;
			}
			
			if (e.keyCode == Keyboard.BACKSPACE)
				_initlabel.text = _initlabel.text.slice(0, -1);
			else if (_initlabel.text.length < NUM_INITIALS)
			{
				var char:String = String.fromCharCode(e.charCode).toUpperCase();
				//restrict to numbers and letters only
				if (('A' <= char && char <= 'Z') || ('0' <= char && char <= '9'))
					_initlabel.text += char;
			}
			
			//activate button if initials are not empty
			_okaybutton.clickable = _initlabel.text != "";
		}
		
		private function makeHighList():void
		{
			if (_hiscoretexts != null && _hirank != -1)
				_hiscoretexts[_hirank].blink = false;
			_hiscoretexts = new Vector.<TextFieldPlus>();
			
			if (_hiscorebox != null)
				_scoreView.removeChild(_hiscorebox);
			_hiscorebox = new Sprite();
			
			var container:Sprite = new Sprite();
			var field:TextFieldPlus;
			var place:String;
			var initials:String;
			var hiscore:String;
			var hiscoreMaxChars:uint = Math.max(7, cs[SettingNames.HISCORELIST][0].toString().length);
			for (var i:uint = 0; i < Settings.NUM_SCORES; i++)
			{
				//IMPORTANT: **MUST** use a font with equal spacing!!!
				field = new TextFieldPlus(FontStyles.F_JOYSTIX, 20);
				
				if (i == 0)
					place = " 1st";
				else if (i == 1)
					place = " 2nd";
				else if (i == 2)
					place = " 3rd";
				else if (i == 9)
					place = "10th"
				else
					place = " " + (i + 1).toString() + "th";
				
				initials = "";
				hiscore = "";
				
				if (cs[SettingNames.HISCORELIST][i] != 0)
				{
					hiscore = cs[SettingNames.HISCORELIST][i].toString();
					while (hiscore.length < hiscoreMaxChars)
						hiscore = " " + hiscore;
					
					initials = cs[SettingNames.INITIALLIST][i].toString();
					while(initials.length < NUM_INITIALS)
						initials = " " + initials;
					
					if (cs[SettingNames.NGSCORELIST][i])
						field.color1 = Settings.NET_SCORE_COLOR;
				}
				else
				{
					while (hiscore.length < hiscoreMaxChars)
						hiscore += "-";
					
					initials = "---";
				}
				
				field.text = place + " " + initials + " " + hiscore;
				field.y = field.height * i;
				
				_hiscoretexts.push(field);
				container.addChild(field);
			}
			
			const margin:Number = 15;
			var back:Sprite = new ScoreBack();
			back.width = container.width + margin * 2;
			back.height = container.height + margin * 2;
			
			G.centreX(container, back);
			G.centreY(container, false, back);
			
			_hiscorebox.addChild(back);
			_hiscorebox.addChild(container);
			
			G.centreX(_hiscorebox);
			G.centreY(_hiscorebox);
			_scoreView.addChild(_hiscorebox);
		}
		
		private function allowKeyListeners(e:Event = null):void
		{
			if (_aftergame)
				Main.stage.addEventListener(Event.ENTER_FRAME, playAgainKey);
		}
		
		private function stopKeyListeners(e:Event = null):void
		{
			if (_aftergame)
				Main.stage.removeEventListener(Event.ENTER_FRAME, playAgainKey);
		}
		
		private function makeScoreView():void
		{
			Main.stage.addEventListener(PopUp.E_POPUP, stopKeyListeners);
			Main.stage.addEventListener(PopUp.E_POPUPGONE, allowKeyListeners);
			
			_scoreView = new MovieClip();
			_scoreView.graphics.beginFill(0, 0); //this is important for the tween!
			_scoreView.graphics.drawRect(0, 0, G.STAGE_WIDTH, G.STAGE_HEIGHT);
			
			var topformat:TextFormat = new TextFormat(FontStyles.F_YEAR200X, 30, 0xFF0000);
			topformat.align = TextFormatAlign.CENTER;
			
			var toplabel:TextField = new TextField();
			G.setTextField(toplabel, topformat);
			toplabel.autoSize = TextFieldAutoSize.CENTER;
			toplabel.text = "High Scores";
			toplabel.filters = [new DropShadowFilter()];
			
			
			var typeformat:TextFormat = new TextFormat(FontStyles.F_JOYSTIX, 30, cs[SettingNames.GCOL]);
			typeformat.align = TextFormatAlign.CENTER;
			
			var typelabel:TextField = new TextField();
			G.setTextField(typelabel, typeformat);
			typelabel.autoSize = TextFieldAutoSize.CENTER;
			typelabel.text = cs[SettingNames.GTITLE];
			typelabel.filters = [new GlowFilter(0xFFFFFF)];
			
			//This must define & place _hiscorebox.
			makeHighList();
			//If a new score was earned, make that entry blink
			if (_hirank != -1)
				_hiscoretexts[_hirank].blink = true;
			
			G.centreX(toplabel);
			G.centreX(typelabel);
			typelabel.y = _hiscorebox.y - typelabel.height - 20;
			toplabel.y = typelabel.y - toplabel.height - 20;
			
			_scoreView.addChild(toplabel);
			_scoreView.addChild(typelabel);
			
			var bcontainer:Sprite = new Sprite();
			
			_buttonsubmit = new TextButton("Submit High Score", ButtonBack2);
			if (cs.gtype == -1 || _scoretag == null)
				_buttonsubmit.visible = false;
			
			_buttonviewnet = new TextButton("View Online Scores", ButtonBack2);
			_buttonviewloc = new TextButton("View Local Scores", ButtonBack2);
			_buttonviewloc.visible = false;
			
			if (_scoretag == null)
				_buttonviewnet.visible = false;
			
			if (_aftergame)
			{
				_button1 = new TextButton("Play Again");
				_button2 = new TextButton("Main Menu");
				
				//If _highviewed, that means you got a (visible) high score that you can submit.
				//Check that, since getHighestLocalScore() won't include that score yet.
				if (_scoretag == null)
					_buttonsubmit.visible = false;
				if (getHighestLocalScore() == 0 && !_highviewed)
					_buttonsubmit.clickable = false;
				
				//If the new high score view appears first, only want to add button listeners
				//once the tween ends. Otherwise, add them now. Do this to prevent duplicate listeners!
				if (!_highviewed)
					addAfterHighScoreListeners();
			}
			else
			{
				_button1 = new TextButton("Reset Scores");
				_button2 = new TextButton("Back");
				
				//NOTE: gtype is -1 when viewing the scores of a shared mode from UsermodeScreen.
				if (cs.gtype != -1)
				{
					if (cs[SettingNames.HISCORELIST][0] != 0)
						addButtonListener(_button1, resetScoresAsk);
					else
						_button1.clickable = false;
					
					if (_scoretag == null)
						_buttonsubmit.visible = false;
					else if (getHighestLocalScore() == 0)
						_buttonsubmit.clickable = false;
				}
				else
				{
					_button1.visible = false;
					_buttonsubmit.visible = false;
				}
				
				addButtonListener(_button2, backToScreen);
				addNetworkListeners();
			}
			
			var ytop:Number = 0;
			const margin:Number = 5;
			for each (var button:TextButton in [_buttonviewnet, _buttonsubmit, _button1, _button2])
			{
				if (button.visible)
				{
					G.centreX(button);
					button.y = ytop;
					bcontainer.addChild(button);
					ytop += button.height + margin;
				}
			}
			if (_buttonviewnet.visible)
			{
				G.centreX(_buttonviewloc);
				_buttonviewloc.y = _buttonviewnet.y;
				bcontainer.addChild(_buttonviewloc);
			}
			
			bcontainer.y = _hiscorebox.y + _hiscorebox.height + margin;
			_scoreView.addChild(bcontainer);
			addChild(_scoreView);
		}
		
		private function requestNetScores(e:MouseEvent):void
		{
			if (_netscorebox == null)
			{
				_buttonviewnet.clickable = false;
				loadScores();
			}
			else
				showNetScores();
		}
		
		private function loadScores():void
		{
			API.addEventListener(APIEvent.SCORES_LOADED, showNetScores);
			API.loadScores(APIUtils.SB_NAME, ScoreBoard.ALL_TIME, 1, 10, _scoretag);
		}
		
		private function showNetScores(e:APIEvent = null):void
		{
			PopUp.fadeOut();
			if (e != null)
			{
				API.removeEventListener(APIEvent.SCORES_LOADED, showNetScores);
				if (!e.success)
				{
					APIUtils.makeErrorPopUp("High scores could not be loaded. Try again later.");
					return;
				}
			}
			_hiscorebox.visible = false;
			if (_netscorebox == null)
			{
				_netscorebox = new ScoreBrowser();
				G.matchSizeV(_netscorebox, Infinity, _hiscorebox.height, true);
				G.centreX(_netscorebox);
				G.centreY(_netscorebox, false, _hiscorebox);
				_scoreView.addChild(_netscorebox);
			}
			else
				_netscorebox.visible = true;
			
			if (e != null)
				_netscorebox.loadScores();
			
			_buttonviewnet.visible = false;
			_buttonviewloc.visible = true;
		}
		
		private function hideNetScores(e:MouseEvent):void
		{
			_netscorebox.visible = false;
			_hiscorebox.visible = true;
			
			_buttonviewnet.clickable = true;
			_buttonviewnet.visible = true;
			_buttonviewloc.visible = false;
		}
		
		private function resetScoresAsk(e:MouseEvent):void
		{
			PopUp.makePopUp(
			"Are you sure you want to clear all high scores for this mode?",
			Vector.<String>(["Yes, clear scores", "Cancel"]),
			Vector.<Function>([function(e:MouseEvent):void
			{
				cs.clearScores();
				SaveData.saveGameSetting(cs);
				SaveData.flush();
				
				makeHighList();
				_hirank = -1;
				
				_button1.clickable = false;
				_buttonsubmit.clickable = false; //Can't submit 0 score
				
				PopUp.fadeOut();
			}, PopUp.fadeOut]));
		}
		
		private function submitScoresAsk(e:MouseEvent):void
		{
			if (!API.hasUserSession)
			{
				APIUtils.makeErrorPopUp("You can only submit scores when logged in to a Newgrounds account.");
				return;
			}
			
			APIUtils.actOnConnect(function():void
			{
				PopUp.makePopUp(
				"Since this mode is a " + (cs[SettingNames.FILEID] != 0 ? "shared mode" : "default mode")
				+ ", your top score can be submitted to an online leaderboard. Continue?",
				Vector.<String>(["Submit Now", "Cancel"]),
				Vector.<Function>([function(e:MouseEvent):void
				{
					PopUp.setInteractionEnabled(false);
					API.addEventListener(APIEvent.SCORE_POSTED, postedScore);
					API.postScore(APIUtils.SB_NAME, getHighestLocalScore(), _scoretag);
				}, PopUp.fadeOut]));
			});
		}
		
		private function postedScore(e:APIEvent):void
		{
			API.removeEventListener(APIEvent.SCORE_POSTED, postedScore);
			if (!e.success)
			{
				PopUp.fadeOut();
				APIUtils.makeErrorPopUp();
				return;
			}
			_buttonsubmit.clickable = false; //Don't allow submitting multiple times
			loadScores();
		}
		
		private function addNetworkListeners():void
		{
			if (_buttonsubmit.visible && _buttonsubmit.clickable && _scoretag != null)
				addButtonListener(_buttonsubmit, submitScoresAsk);
			if (_buttonviewnet.visible)
			{
				addButtonListener(_buttonviewnet, requestNetScores);
				addButtonListener(_buttonviewloc, hideNetScores);
			}
		}
		
		private function addAfterHighScoreListeners():void
		{
			addButtonListener(_button1, playAgain);
			addButtonListener(_button2, backToMain);
			addNetworkListeners();
			
			allowKeyListeners();
		}
		
		private function playAgain(e:MouseEvent = null):void
		{
			goTo(GameScreen, true);
		}
		private function playAgainKey(e:Event):void
		{
			if (Key.isTap(Keyboard.ENTER))
				playAgain();
		}
		
		private function backToMain(e:MouseEvent = null):void
		{
			goTo(MainMenu, true);
		}
		
		private function backToScreen(e:MouseEvent):void
		{
			goTo(Main.PrevScreen, false, FadeSwipe);
		}
		
		private function slideHighToScore(e:MouseEvent = null):void
		{
			Main.stage.removeEventListener(KeyboardEvent.KEY_DOWN, typeInitials);
			_okaybutton.removeEventListener(MouseEvent.CLICK, slideHighToScore);
			
			//Update the score list once both the score and the initials are ready, and then save the scores.
			updateHighScores(_score, _initlabel.text, _hirank);
			SaveData.saveGameSetting(cs);
			SaveData.flush();
			
			makeScoreView();
			_scoreView.x = -_scoreView.width;
			
			var duration:Number = 2;
			TweenLite.to(_highView, duration, { x:G.STAGE_WIDTH, ease:None.easeNone, onComplete:removeHighView } );
			TweenLite.to(_scoreView, duration, { x:0, ease:None.easeNone } );
			
			Main.resetFocus();
		}
		
		/**
		 * If a high score was earned, returns the rank of the new score (minus 1).
		 * If the score earned did not break any records, -1 is returned.
		 * @param	score The score to possibly put into the list of high scores.
		 * @param	startat The rank (index) at which to start checking for a high score entry point.
		 * @return Rank - 1 of score if a high score, -1 if no high score.
		 */
		private function checkHighScores(score:uint, startat:uint = 0):int
		{
			//A score of 0 is the same as no score at all.
			if (score == 0)
				return -1;
			
			for (var i:uint = startat; i < Settings.NUM_SCORES; i++)
				if (score > cs[SettingNames.HISCORELIST][i])
					return i;
			
			return -1;
		}
		
		/**
		 * Updates the high score & name initial lists in the game mode's memory.
		 * @param	hiscore The high score earned.
		 * @param	initials The name initials.
		 * @param	rank The rank of the score, minus 1.
		 */
		private function updateHighScores(hiscore:uint, initials:String, rank:uint):void
		{
			cs[SettingNames.HISCORELIST].pop();
			cs[SettingNames.HISCORELIST].splice(rank, 0, hiscore);
			
			cs[SettingNames.INITIALLIST].pop();
			cs[SettingNames.INITIALLIST].splice(rank, 0, initials);
			
			cs[SettingNames.NGSCORELIST].pop();
			cs[SettingNames.NGSCORELIST].splice(rank, 0, false);
		}
		
		private function getHighestLocalScore():uint
		{
			for (var i:uint = 0; i < Settings.NUM_SCORES; i++)
			{
				if (!cs[SettingNames.NGSCORELIST][i])
					return cs[SettingNames.HISCORELIST][i];
			}
			return 0;
		}
		
		private function removeHighView():void
		{
			_hiscorelabel.blink = false;
			removeChild(_highView);
			//TweenLite.killTweensOf(_highView);
			_highView = null;
			addAfterHighScoreListeners();
		}
		
		override protected function cleanUp():void 
		{
			API.stopPendingCommands();
			API.removeEventListener(APIEvent.SCORE_POSTED, postedScore);
			
			Main.stage.removeEventListener(PopUp.E_POPUP, stopKeyListeners);
			Main.stage.removeEventListener(PopUp.E_POPUPGONE, allowKeyListeners);
			stopKeyListeners();
			if (_hirank != -1)
				_hiscoretexts[_hirank].blink = false;
			
			super.cleanUp();
		}
		
	}

}