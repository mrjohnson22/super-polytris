package screens
{
	import com.greensock.TweenLite;
	import com.newgrounds.API;
	import com.newgrounds.APIEvent;
	import com.newgrounds.components.VoteBar;
	import com.newgrounds.SaveFile;
	import data.KeySettings;
	import data.SaveData;
	import data.SettingNames;
	import data.Settings;
	import fl.transitions.easing.None;
	import flash.display.GradientType;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import media.fonts.FontStyles;
	import media.sounds.SongList;
	import media.sounds.SoundBox;
	import media.sounds.SoundList;
	import media.sounds.Sounds;
	import menu.PauseMenu;
	import menu.PopUp;
	import objects.GamePiece;
	import objects.GameTile;
	import objects.PlayStage;
	import visuals.backs.gamebacks.GBG;
	import visuals.boxes.NextBox;
	import visuals.GOverText;
	import visuals.GOverText1;
	import visuals.ScoreList;
	import visuals.swipes.EventAnim;
	import visuals.swipes.ReadyAnim;
	import visuals.Tile;
	import visuals.WinText1;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class GameScreen extends MovieClip implements ISwappable
	{
		public static const NOGAME:int = -1;
		
		/**
		 * The score upon the end of the game. This value is what is "grabbed" after the GameScreen is removed.
		 */
		private static var _endscore:int = -1; //Equal to NOGAME.
		public static function getEndScore():uint
		{
			var endscore:uint = _endscore;
			_endscore = NOGAME;
			return endscore;
		}
		
		private var cs:Settings;
		private var ks:KeySettings;
		
		private var _gbg:GBG;
		
		private var _nextboxes:Vector.<NextBox> = new Vector.<NextBox>();
		private var _nextpieces:Vector.<GamePiece> = new Vector.<GamePiece>();
		private var _holdpiece:GamePiece;
		
		private var _danger:Boolean = false;
		private var _safe:Boolean = false;
		private var _timedanger:Boolean = false;
		private var _timedangertext:TextField;
		
		private var _overlap:Boolean = false;
		private var _passable:Boolean = false;
		private var _swiper:Sprite;
		private var _clearswiper:Sprite;
		private var _scolor:ColorTransform;
		
		private var _ymax:uint; //highest possible y
		private var _ytop:int; //current top of set tiles. -1 = empty bin!
		
		private var _lifelost:Boolean = false;
		private var _wingame:Boolean = false;
		
		//game over animation values
		private var _overstarted:Boolean = false;
		private var _overplay:Boolean = false;
		private var _liferestore:Boolean = false;
		private var _dead:uint = 0;
		private var _endtext:GOverText;
		
		//applied values & default values
		private var s:Number = G.S;
		private var _squ:Boolean;
		
		private var clearCheck:Function;
		private var clearDrop:Function;
		
		private var timerTick:Function;
		
		private var _holding:Boolean;
		private var _dropping:Boolean = false;
		
		private var _bbcombo:uint;
		private var _combo:uint;
		private var _gravcombo:uint;
		
		private var _fallspeed:uint; //frame delay between fall events/until auto-set
		
		private var _clearrows:Vector.<uint> = new Vector.<uint>();
		private var _clearboxes:Vector.<Array> = new Vector.<Array>();
		
		private var _xstart:uint;
		private var _xend:uint;
		private var _hdir:int;
		private var _ystart:uint;
		private var _yend:uint;
		private var _vdir:int;
		
		private var _piecesset:Array = [];
		private var _ppropset:Array = [];
		private var _pappset:Array = [];
		//private var _pclearset:Array = [];
		private var _pcolset:Array = [];
		
		/**
		 * A counter to scroll through the ordered pieces (if order is imposed).
		 */
		private var _pi:uint = 0;
		
		// FORCED SETTINGS
		private var _toplock:Boolean;
		private var _lump:Boolean;
		private var _NextIBox:Class;
		private var _NextBox:Class;
		private var _HoldBox:Class;
		private var _spawnafterclear:Boolean;
		
		private var _playStage:PlayStage;
		private var _playZone:Sprite;
		private var _allStage:Sprite;
		
		private var _timer:FrameTimer;
		private var _cleartimer:FrameTimer;
		private var _gravtimer:FrameTimer;
		private var _endtimer:FrameTimer;
		
		private var _piece:GamePiece;
		private var _shad:GamePiece;
		private var _tilemap:Array;
		private var _cleartiles:Vector.<GameTile> = new Vector.<GameTile>();
		private var _setpieces:Vector.<GamePiece> = new Vector.<GamePiece>();
		private var _gravpieces:Vector.<GamePiece> = new Vector.<GamePiece>();
		private var _droppieces:Vector.<GamePiece> = new Vector.<GamePiece>();
		
		private var _nextbox:NextBox;
		private var _holdbox:NextBox;
		private var _pausebutton:PauseMenu;
		
		private var _scorelist:ScoreList;
		
		private var _deadsound:SoundBox;
		
		//private var _testbar:Sprite;
		
		//Values that refer to the above elements
		private var _score:uint = 0;
		private function get score():uint
		{
			return _score;
		}
		private function set score(value:uint):void
		{
			if (value > Settings.MAXSCORE) //Don't worry about overflow...
				value = Settings.MAXSCORE; //Score cap
			_score = value;
			_scorelist.score = value;
			
			if (level < cs[SettingNames.LEVELMAX] && cs[SettingNames.LEVELUPREQ] == Settings.L_SCORE)
			{
				reqcount = value;
				levelUpCheck();
			}
		}
		
		private var _lives:int;
		private function get lives():int
		{
			return _lives;
		}
		private function set lives(value:int):void
		{
			_lives = value;
			_scorelist.lives = Math.max(value, 0);
			
			//Possible that time is being decremented for the win game bonus.
			if (_wingame)
				return;
			
			//Only flash on no lives if not in Fit Mode, or if you are, if default chances is more than 0.
			//Note that if default lives is zero, the lives box doesn't show up at all.
			if (value == 0 && (!cs[SettingNames.FITMODE] || cs[SettingNames.FITCHANCES] == 0))
				_scorelist.startHoldLives();
		}
		
		private var _chances:int;
		private function get chances():int
		{
			return _chances;
		}
		private function set chances(value:int):void
		{
			_chances = value;
			_scorelist.chances = Math.max(value, 0);
			//Only flash the lives box if the default # of chances is above zero.
			if (value == 0 && cs[SettingNames.FITCHANCES] > 0)
				_scorelist.startHoldLives();
		}
		
		private var _timeleft:uint;
		private function get timeleft():uint
		{
			return _timeleft;
		}
		private function set timeleft(value:uint):void
		{
			if (value > Settings.MAXTIME) //...because this can go down, so overflow wouldn't work here.
				value = Settings.MAXTIME; //Time cap
			_timeleft = value;
			_scorelist.time = value;
			
			//Possible that time is being decremented for the win game bonus.
			if (_wingame)
				return;
			
			if (_timeleft == 0)
				timeOut();
			else if (_timeleft <= Settings.TIME_WARNING)
			{
				timedanger = true;
				_timedangertext.text = _timeleft.toString();
			}
			else
				timedanger = false;
		}
		
		/**
		 * Number of clears/tiles/etc to get to next level.
		 */
		private var _nextlevel:uint;
		private var _level:uint;
		private function get level():uint
		{
			return _level;
		}
		
		/**
		 * Sets both _level and _nextlevel.
		 */
		private function set level(value:uint):void
		{
			if (cs[SettingNames.LEVELMAXWIN] && value == cs[SettingNames.LEVELMAX] - 1)
				_scorelist.startHoldLevel();
			else
				_scorelist.stopHoldLevel();
			
			if (value > _level)
			{
				_scorelist.flashLevel();
				_gbg.levelUp();
			}
			
			_level = value;
			_scorelist.level = value;
			
			if (value == cs[SettingNames.LEVELMAX])
			{
				_nextlevel = Infinity;
				_scorelist.clearStop();
				if (cs[SettingNames.LEVELMAXWIN])
				{
					_wingame = true;
					return;
				}
			}
			else
			{
				_nextlevel = getLevelUpReq(value);
				_scorelist.next = _nextlevel - _reqcount;
			}
			
			if (_timer != null) //Need this because level is set before _timer is initialized.
			{
				if (cs[SettingNames.FARR])
					_timer.secondsDelay = cs[SettingNames.FA][_level];
				else
					_timer.secondsDelay = Math.max(cs[SettingNames.FA][0] - cs[SettingNames.FDEC] * _level, cs[SettingNames.FMIN]);
				
				_fallspeed = _timer.frameDelay;
				if (_gravtimer != null)
					_gravtimer.frameDelay = Math.floor(_fallspeed / cs[SettingNames.FCF]);
			}
			
			updateRandomizer();
		}
		
		private function get danger():Boolean
		{
			return _danger;
		}
		
		private function set danger(value:Boolean):void
		{
			if (_danger == value)
				return;
			
			_danger = value;
			_gbg.danger = value;
			if (_danger && cs[SettingNames.FITMODE])
			{
				_scolor.color = 0xFF0000;
				_swiper.transform.colorTransform = _scolor;
			}
			
			//Make sure to cancel this in Fit Mode, since danger can happen.
			if (!cs[SettingNames.FITMODE] && cs[SettingNames.DZONEMULT] != 1)
				_scorelist.danger = value;
		}
		
		private function get safe():Boolean
		{
			return _safe;
		}
		
		private function set safe(value:Boolean):void
		{
			if (_safe == value)
				return;
			
			_safe = value;
			if (cs[SettingNames.SZONEMULT] != 1)
				_scorelist.safe = value;
			//maybe a responding background.
			//_gbg.safe = value;
		}
		
		private function get timedanger():Boolean
		{
			return _timedanger;
		}
		
		private function set timedanger(value:Boolean):void
		{
			if (_timedanger == value)
				return;
			
			_timedanger = value;
			_timedangertext.visible = value;
			_gbg.timedanger = value;
			if (value)
			{
				fixDepths(); //This adds the text to the play zone.
				_scorelist.startHoldTime();
			}
			else
			{
				if (_timedangertext.parent != null)
					_timedangertext.parent.removeChild(_timedangertext);
				_scorelist.stopHoldTime();
			}
		}
		
		private function get ytop():int
		{
			return _ytop;
		}
		
		private function set ytop(value:int):void
		{
			_ytop = value;
			if (cs[SettingNames.FITMODE])
				return;
			if (!cs[SettingNames.FITMODE])
			{
				danger = (cs[SettingNames.DZONE] != 0 && _ytop >= (cs[SettingNames.BINY] - cs[SettingNames.DZONE])); //Check if it's zero first, since >= works nicely.
				safe = (_ytop < cs[SettingNames.SZONE]); //Use < so that a szone of 0 is safe on a blank screen.
			}
		}
		
		private function getLevelUpReq(newlevel:uint):int
		{
			if (newlevel >= cs[SettingNames.LEVELMAX])
				return -1; //Error if asking for value out of level range(cs[SettingNames.LEVELUPA], newlevel);
			
			var reqtot:uint = 0;
			for (var l:uint = 0; l <= newlevel; l++)
				reqtot += G.safeIndex(cs[SettingNames.LEVELUPA], l);
			return reqtot;
		}
		
		/**
		 * The value that must increase to earn a level up. May be clears, sets, time, etc.
		 */
		private var _reqcount:uint;
		private function get reqcount():uint 
		{
			return _reqcount;
		}
		private function set reqcount(value:uint):void 
		{
			if (level == cs[SettingNames.LEVELMAX])
				return;
			_reqcount = value;
			_scorelist.reqval = value;
			if ( (level < cs[SettingNames.LEVELMAX]) && (_nextlevel - value > 0) )
				_scorelist.next = _nextlevel - value;
		}
		
		public function GameScreen()
		{
			//setBackground(new GBGPlain);
			cs = Settings.currentGame;
			ks = KeySettings.currentConfig;
			
			_gbg = new Settings.GBG_TYPES[cs[SettingNames.GBG_TYPE]]();
			addChildAt(_gbg, 0);
			
			_scorelist = new ScoreList();
			
			_deadsound = new SoundBox(SoundList.Dead1);
			
			var i:uint;
			var j:uint;
			
			_squ = (cs[SettingNames.CWID] != cs[SettingNames.BINX] || cs[SettingNames.CLEN] > 1);
			
			//Create 2D array to contain map of placed & falling tiles.
			_ymax = cs[SettingNames.BINY] + (_toplock ? 0 : Settings.MAX_NUM_TILES);
			_tilemap = G.create2DArray(cs[SettingNames.BINX], _ymax);
			
			if (!_squ)
			{
				clearCheck = clearCheckL;
				clearDrop = clearDropL;
			}
			else
			{
				clearCheck = clearCheckS;
				clearDrop = clearDropS;
				
				if (cs[SettingNames.LTOR])
				{
					_xstart = 0;
					_xend = cs[SettingNames.BINX] - 1;
					_hdir = 1;
				}
				else
				{
					_xstart = cs[SettingNames.BINX] - 1;
					_xend = 0;
					_hdir = -1;
				}
				
				if (cs[SettingNames.BTOT])
				{
					_ystart = 0;
					_yend = _ymax - 1;
					_vdir = 1;
				}
				else
				{
					_ystart = _ymax - 1;
					_yend = 0;
					_vdir = -1;
				}
			}
			
			timerTick = !cs[SettingNames.FITMODE] ? fallPiece : fitPiece;
			
			//if (cs[SettingNames.HOLDABLE]) { _holding = false; }
			_holding = !cs[SettingNames.HOLDABLE];
			
			level = 0;
			score = 0;
			ytop = -1;
			_endscore = 0;
			
			_bbcombo = 0;
			_combo = 0;
			_gravcombo = 0;
			lives = cs[SettingNames.LIVES];
			reqcount = 0;
			
			// FORCED SETTINGS
			_toplock = cs[SettingNames.TOPLOCK] || cs[SettingNames.FITMODE]; //Force toplock in Fit Mode.
			_lump = !cs[SettingNames.GRAVITY] || cs[SettingNames.LUMP]; //Force lumping when gravity is off.
			_spawnafterclear = cs[SettingNames.FREEZE] && cs[SettingNames.SPAWNAFTERCLEAR]; //Turn off Spawn After Clear when not freezing.
			
			_timer = new FrameTimer(cs[SettingNames.FA][0], true);
			_fallspeed = _timer.frameDelay;
			_timer.addEventListener(TimerEvent.TIMER, timerTick);
			
			_cleartimer = new FrameTimer(cs[SettingNames.CTIME], true, 1);
			_cleartimer.addEventListener(TimerEvent.TIMER_COMPLETE, ridTiles);
			
			if (cs[SettingNames.GRAVITY])
			{
				//_gravtimer = new FrameTimer(cs[SettingNames.FCF] > 0 ? Math.floor(cs[SettingNames.FA][0] / cs[SettingNames.FCF]) : cs[SettingNames.FCA][0]);
				_gravtimer = new FrameTimer(Math.floor(cs[SettingNames.FA][0] / cs[SettingNames.FCF]), true);
				_gravtimer.addEventListener(TimerEvent.TIMER, gravCheck);
			}
			
			if (cs[SettingNames.TIMELIMIT] > 0)
			{
				_endtimer = new FrameTimer(1000, true);
				_endtimer.addEventListener(TimerEvent.TIMER, timeOutTick);
				//_endtimer.addEventListener(TimerEvent.TIMER_COMPLETE, timeOut);
				
				_timedangertext = new TextField();
				_timedangertext.alpha = 0.75;
				var timeformat:TextFormat = new TextFormat(FontStyles.F_JOYSTIX, 80, 0xFF0000);
				G.setTextField(_timedangertext, timeformat);
				_timedangertext.autoSize = TextFieldAutoSize.CENTER;
				_timedangertext.visible = false;
				
				timeleft = cs[SettingNames.TIMELIMIT];
			}
			
			_playStage = new PlayStage(cs);
			_playZone = _playStage.playZone;
			if (_timedangertext != null)
			{
				//May have to enter a dummy value to set proper sizing.
				if (!timedanger)
					_timedangertext.text = Settings.TIME_WARNING.toString();
				
				G.matchSizeV(_timedangertext, s * cs[SettingNames.BINX], s * cs[SettingNames.BINY], false);
				_timedangertext.x = (s * cs[SettingNames.BINX] - _timedangertext.width) / 2;
				_timedangertext.y = -s * cs[SettingNames.BINY] / 2 - _timedangertext.height / 2;
			}
			
			//set up nextboxes
			var nextbounds:Rectangle;
			var nextStage:Sprite;
			var boxspace:Number;
			if (cs[SettingNames.NEXTNUM] > 0)
			{
				_nextbox = new Settings.INEXT_STYLES[cs[SettingNames.VSTYLE]]();
				_nextboxes.push(_nextbox);
				if (cs[SettingNames.NEXTNUM] > 1)
				{
					nextStage = new Sprite();
					boxspace = 10;
					while (_nextboxes.length != cs[SettingNames.NEXTNUM])
					{
						var next:NextBox = new Settings.NEXT_STYLES[cs[SettingNames.VSTYLE]]();
						next.y = (_nextboxes.length - 1) * (next.height + boxspace);
						_nextboxes.push(next);
						nextStage.addChild(next);
					}
					
					//nextbounds is a rectangle manually drawn in the GameScreen symbol.
					//It limits the allowable size of next boxes, as well as centres their
					//position on the Stage.
					nextbounds = new Rectangle(0, 0, 100, 480);
					if (nextStage.height > nextbounds.height)
						G.matchSizeC(nextStage, nextbounds, true);
				}
			}
			
			if (cs[SettingNames.HOLDABLE])
				_holdbox = new Settings.HOLD_STYLES[cs[SettingNames.VSTYLE]]();
			
			//Fill in all preview windows
			while (_nextpieces.length < cs[SettingNames.NEXTNUM])
				putInPreview(newPiece(), _nextpieces.length);
			
			
			//Set up HUD positions
			_allStage = new Sprite();
			G.centreY(_scorelist);
			if (_holdbox != null)
			{
				_holdbox.y = 40;
				_allStage.addChild(_holdbox);
			}
			if (_nextbox != null)
			{
				_nextbox.y = 40;
				_allStage.addChild(_nextbox);
			}
			
			var noBox:Boolean = _nextbox == null && _holdbox == null;
			//If there isn't a column of previews, and EITHER a hold box & single preview,
			//align that box with the score panel.
			var alignBox:MovieClip = null;
			if (!noBox && nextStage == null)
			{
				if (_nextbox != null && _holdbox == null)
					alignBox = _nextbox;
				else if (_nextbox == null && _holdbox != null)
					alignBox = _holdbox;
			}
			
			var boxmargin:Number = 20;
			var closescore:Number;
			//var pbwid:Number = 280;
			//var pblen:Number = 670;
			G.matchSizeV(_playStage, G.STAGE_WIDTH * 0.45, G.STAGE_HEIGHT * 0.95, true);
			if (cs[SettingNames.STAGESIDE] == Settings.S_SIDE_CENTRE)
			{
				_playStage.x = _scorelist.width + boxmargin;
				if (_holdbox != null) G.rightAlign(_holdbox, 0, _scorelist);
				if (_nextbox != null) _nextbox.x = _playStage.x + _playStage.width + boxmargin;
				
				alignBox = _holdbox; //for lowering the scorelist later.
			}
			else if (cs[SettingNames.STAGESIDE] == Settings.S_SIDE_LEFT)
			{
				closescore = _playStage.x + _playStage.width + boxmargin;
				if (noBox)
					_scorelist.x = closescore;
				else if (alignBox != null)
				{
					_scorelist.x = closescore;
					G.centreX(alignBox, _scorelist);
				}
				else
				{
					_nextbox.x = _playStage.x + _playStage.width + boxmargin;
					if (_holdbox != null) _holdbox.x = _nextbox.x + _nextbox.width + boxmargin;
					if (nextStage == null)
						_scorelist.x = closescore;
					else
						_scorelist.x = _nextbox.x + _nextbox.width + boxmargin;
					
					alignBox = _holdbox;
				}
			}
			else //if (cs[SettingNames.STAGESIDE] == Settings.S_SIDE_RIGHT)
			{
				closescore = _scorelist.x + _scorelist.width + boxmargin;
				if (noBox)
					_playStage.x = closescore;
				else if (alignBox != null)
				{
					_playStage.x = closescore;
					G.centreX(alignBox, _scorelist);
				}
				else
				{
					if (nextStage == null)
					{
						_nextbox.x = _holdbox.x + _holdbox.width + boxmargin;
						G.rightAlign(_scorelist, 0, _nextbox);
					}
					else
					{
						if (_holdbox != null) G.rightAlign(_holdbox, 0, _scorelist);
						_nextbox.x = _scorelist.x + _scorelist.width + boxmargin;
					}
					_playStage.x = _nextbox.x + _nextbox.width + boxmargin;
					
					alignBox = _holdbox;
				}
			}
			if (alignBox != null && _scorelist.y < alignBox.y + alignBox.height)
				_scorelist.y = alignBox.y + alignBox.height + boxmargin;
			G.centreY(_playStage, true);
			
			if (nextStage)
			{
				G.centreX(nextStage, _nextbox);
				nextStage.y = _nextbox.y + _nextbox.height + boxspace;
				_allStage.addChild(nextStage);
			}
			
			_allStage.addChild(_scorelist);
			_allStage.addChild(_playStage);
			G.centreX(_allStage);
			addChild(_allStage);
			
			//Finishing touches
			_pausebutton = new PauseMenu(pauseGame, unpauseGame, quitGame);
			addChild(_pausebutton); //add this last, for top depth
			
			var readyanim:EventAnim = new ReadyAnim();
			addChild(readyanim);
			
			//Listen for countdown completion
			readyanim.addEventListener(EventAnim.READY, startAction, false, 0, true);
			
			/*_testbar = new Sprite();
			_testbar.graphics.beginFill(0xFF0000, 0);// 0.5);
			_testbar.graphics.drawRect(0, 0, cs[SettingNames.BINX] * s, s);
			_playZone.addChild(_testbar);*/
			
			//Create forced fit swiper/timer
			if (cs[SettingNames.FITMODE])
			{
				chances = cs[SettingNames.FITCHANCES];
				_scolor = new ColorTransform();
				makeSomeSwiper(true);
			}
			
			Sounds.playSong(Settings.SONG_CHOICES[cs[SettingNames.SONG_TYPE]]);
		}
		
		private function updateRandomizer():void
		{
			//no need to update the randomizers if already at the end of the randomizer arrays.
			if (level > (!cs[SettingNames.ORDERED] ? cs[SettingNames.PLIKE].length : cs[SettingNames.PORDER].length) - 1)
				return;
				
			var l:uint = level;
			
			//clear old randomizer arrays
			_piecesset = [];
			_ppropset = [];
			_pappset = [];
			//_pclearset = [];
			_pcolset = [];
			
			if (!cs[SettingNames.ORDERED])
			{
				for (var i:uint = 0; i < cs[SettingNames.PIECES].length; i++)
				{
					//Make extra copies of tile properties in randomizer arrays
					//based on their likelihood values
					for (var p:uint = 0; p < cs[SettingNames.PLIKE][l][i]; p++)
					{
						_piecesset.push(cs[SettingNames.PIECES][i]);
						_ppropset.push(cs[SettingNames.PPROPS][i]);
						_pappset.push(G.safeIndex(cs[SettingNames.PAPP], i));
						//_pclearset.push(G.safeIndex(cs[SettingNames.PCLEAR], i));
						_pcolset.push(G.safeIndex(cs[SettingNames.PCOL], i));
					}
				}
			}
			else
			{
				_pi = 0; //start order from beginning
				for (var i:uint = 0; i < cs[SettingNames.PORDER][l].length; i += 2)
				{
					//Make extra copies of tile properties in randomizer arrays
					//based on their likelihood values
					for (var p:uint = 0; p < cs[SettingNames.PORDER][l][i+1]; p++)
					{
						var i2:uint = cs[SettingNames.PORDER][l][i];
						_piecesset.push(cs[SettingNames.PIECES][i2]);
						_ppropset.push(cs[SettingNames.PPROPS][i2]);
						_pappset.push(G.safeIndex(cs[SettingNames.PAPP], i2));
						//_pclearset.push(G.safeIndex(cs[SettingNames.PCLEAR], i2));
						_pcolset.push(G.safeIndex(cs[SettingNames.PCOL], i2));
					}
				}
			}
		}
		
		private function putInPreview(piece:GamePiece, box:int):void
		{
			//Need proper piece registration for this to work! Top left corner.
			_nextpieces[box] = piece;
			G.matchSizeC(piece, _nextboxes[box].viewbox, false);
			G.centreX(piece, _nextboxes[box].viewbox);
			G.centreY(piece, false, _nextboxes[box].viewbox);
			_nextboxes[box].addChild(piece);
		}
		
		/**
		 * Places a piece into the playZone in the start position. Returns
		 * true if piece entered safely; false if not.
		 * @param	piece The piece to put into the playZone.
		 * @return	True if safe, false if game over.
		 */
		private function placePiece(piece:GamePiece):Boolean
		{
			if (timedanger)
				_playZone.addChild(_timedangertext);
			
			_piece = piece;
			_piece.placePiece(cs[SettingNames.SPAWNPOSY]);
			_playZone.addChild(_piece);
			
			var xmax:int = int.MIN_VALUE;
			var xmin:int = int.MAX_VALUE;
			for each (var tile:GameTile in _piece.tiles)
			{
				if (tile.xpos > xmax)
					xmax = tile.xpos;
				if (tile.xpos < xmin)
					xmin = tile.xpos;
			}
			if (xmax >= cs[SettingNames.BINX])
				_piece.movePiece(cs[SettingNames.BINX] - xmax - 1, 0);
			else if (xmin < 0)
				_piece.movePiece(-xmin, 0); //double negative = positive
			
			if (cs[SettingNames.FITMODE])
			{
				_overlap = false;
				_passable = cs[SettingNames.FITPASS];
				tileCollide(0, 0, true);
			}
			
			if (cs[SettingNames.SHADOWS])
				updateShadow();
			
			_piece.visible = !cs[SettingNames.INVISIBLE];
			
			//If spawn on top of set tiles, only lose life if in Fall Mode.
			return cs[SettingNames.FITMODE] || !overCheck();
		}
		
		private function fixDepths():void
		{
			if (_playZone == null)
				return;
			if (_timedanger)
				_playZone.addChild(_timedangertext);
			if (_swiper != null)
				_playZone.addChild(_swiper);
			if (_piece != null)
				_playZone.addChild(_piece);
		}
		
		private function updateShadow():void
		{
			//For first call
			if (_shad == null)
			{
				_shad = GamePiece.simplePiece( -1);
				_playZone.addChildAt(_shad, 0);
			}
			else if (!_shad.visible)
				_shad.visible = true;
			
			for (var i:uint = 0; i < _piece.numtiles; i++)
			{
				var stile:GameTile;
				var tile:GameTile = _piece.tiles[i];
				
				//If current piece has more tiles than previous piece, add tiles to shadow.
				if (i >= _shad.numtiles)
				{
					stile = new GameTile(_shad, 0, -1, -1);
					stile.alpha = Settings.SHADOW_ALPHA;
					_shad.tiles.push(stile);
					_shad.addChild(stile);
				}
				else
					stile = _shad.tiles[i];
				
				stile.x = tile.x;
				stile.y = tile.y;
				stile.xpos = tile.xpos;
				stile.ypos = tile.ypos;
				//Don't care about cor, as it doesn't need to rotate. Don't care about dirs either.
			}
			
			//If current piece has fewer tiles than previous, remove tiles.
			//Don't use removeTile, as that performs dir checks.
			while (i < _shad.numtiles)
				_shad.removeTile(_shad.tiles[i]);
			
			instDrop(_shad);
		}
		
		private function holdPiece():void
		{
			//Can only hold once per turn.
			if (_holding)
				return;
			
			_timer.resetTime();
			_holding = true;
			resetOverlap();
			if (_holdpiece)
			{
				var temp:GamePiece = _piece;
				placePiece(_holdpiece);
				_holdpiece = temp;
			}
			else
			{
				_holdpiece = _piece;
				nextPiece();
			}
			
			_holdpiece.resetPosition();
			G.matchSizeC(_holdpiece, _holdbox.viewbox, false);
			G.centreX(_holdpiece, _holdbox.viewbox);
			G.centreY(_holdpiece, false, _holdbox.viewbox);
			_holdbox.addChild(_holdpiece);
		}
		
		/**
		 * Puts the next piece in the preview queue into the playZone,
		 * or generates a new piece if the queue does not exist. Returns
		 * true if the piece fits, false if an overflow (game over) occurs.
		 * @return True if safe, false if game over.
		 */
		private function nextPiece():Boolean
		{
			var lifelost:Boolean;
			
			//If there are preview pieces.
			if (cs[SettingNames.NEXTNUM] != 0)
			{
				//Take piece from topmost preview box, put into playing field.
				lifelost = placePiece(_nextpieces.shift());
				
				//Shift each preview piece to the higher box,
				//starting from the second box, working down.
				for (var i:uint = 0; i < _nextpieces.length; i++)
				{
					//Recentre only if entering final nextbox, which has a different size.
					if (i == 0)
					{
						G.centreX(_nextpieces[i], _nextboxes[i].viewbox);
						G.centreY(_nextpieces[i], false, _nextboxes[i].viewbox);
					}
					_nextboxes[i].addChild(_nextpieces[i]);
				}				
				putInPreview(newPiece(), _nextpieces.length);
			}
			//If there are no preview pieces.
			else
			{
				lifelost = placePiece(newPiece());
			}
			return lifelost;
		}
		
		private function newPiece():GamePiece
		{
			var pc:uint;
			if (!cs[SettingNames.ORDERED])
				pc = Math.floor(Math.random() * _piecesset.length);
			else
			{
				pc = _pi;
				if (++_pi == _piecesset.length)
					_pi = 0;
			}
			//If chosen piece is a custom piece, it will be in Array form.
			if (_piecesset[pc] is Array && _pcolset[pc] is uint)
				return new GamePiece(_piecesset[pc], _ppropset[pc], _pcolset[pc], cs[SettingNames.BORCOL], _pappset[pc], cs[SettingNames.PCLEAR]);
			else if (_piecesset[pc] is uint && _pcolset[pc] is Array)
				return GamePiece.createRandomPiece(_piecesset[pc], _ppropset[pc][0], _ppropset[pc][1], _pcolset[pc], cs[SettingNames.BORCOL], _pappset[pc], cs[SettingNames.PCLEAR]);
			else
				throw new Error("Invalid types. Expected data & colour to be Array & uint (or vice-versa).");
		}
		
		/**
		 * Checks if the PIECE in play has collided with a landed tile, or would collide with one
		 * if it were shifted by xmod & ymod units horizontally/vertically.
		 * @param	xmod Units to shift horizontally.
		 * @param	ymod Units to shift vertically.
		 * @param	overlapCheck Checks all tiles for overlapping placed ones, and sets
		 * their overlap property to true.
		 * @return	True for a collision, false otherwise.
		 */
		private function tileCollide(xmod:int, ymod:int, overlapCheck:Boolean = false):Boolean
		{
			for each (var tile:GameTile in _piece.tiles)
			{
				if (_tilemap[tile.xpos + xmod][tile.ypos + ymod])
				{
					if (!overlapCheck)
						return true;
					tile.overlap = true;
					if (!_overlap) _overlap = true;
					if (!_passable) _passable = true;
				}
			}
			if (!_overlap && !cs[SettingNames.FITPASS])
				_passable = false;
			return false;
		}
		
		private function resetOverlap():void
		{
			_overlap = false;
			for each (var tile:GameTile in _piece.tiles)
				tile.overlap = false;
		}
		
		private function sideCollide(xmod:int):Boolean
		{
			for each (var tile:GameTile in _piece.tiles)
			{
				if (tile.xpos + xmod < 0 || tile.xpos + xmod >= cs[SettingNames.BINX])
					return true;
			}
			return false;
		}
		
		private function ceilCollide(ymod:int):Boolean
		{
			var above:uint = 0;
			for each (var tile:GameTile in _piece.tiles)
			{
				if (tile.ypos + ymod >= cs[SettingNames.BINY])
				{
					//If piece hits top of bin boundaries and toplock is true,
					//it counts as a collision.
					if (_toplock)
						return true;
					
					//If toplock is false, a piece is out of bounds vertically
					//when all of its tiles are above the ceiling.
					if (++above == _piece.numtiles)
						return true;
				}
			}
			return false;
		}
		
		private const SAFE:uint = 0;
		private const TILE:uint = 1;
		private const SIDE:uint = 2;
		private const CEIL:uint = 3;
		
		private function wallCheck(xmod:int, ymod:int):uint
		{
			var above:uint = 0;
			for each (var tile:GameTile in _piece.tiles)
			{
				if (tile.xpos + xmod < 0 || tile.xpos + xmod >= cs[SettingNames.BINX])
					return SIDE;
				
				if (tile.ypos + ymod >= cs[SettingNames.BINY])
				{
					//If piece hits top of bin boundaries and toplock is true,
					//it counts as a collision.
					if (_toplock)
						return CEIL;
					
					//If toplock is false, a piece is out of bounds vertically
					//when all of its tiles are above the ceiling.
					if (++above == _piece.numtiles)
						return CEIL;
				}
				
				if (((cs[SettingNames.FITMODE] && !cs[SettingNames.FITPASS]) || !cs[SettingNames.FITMODE]) && _tilemap[tile.xpos + xmod][tile.ypos + ymod])
					return TILE;
			}
			
			return SAFE;
		}
		
		/**
		 * Checks if a given piece has landed on the bottom of the bin or
		 * on an already landed piece. Returns the T/F result.
		 * @param	piece Check if this piece landed.
		 * @return	True if landed, false otherwise.
		 */
		private function landCheck(piece:GamePiece, ignoreGravPieces:Boolean = false):Boolean
		{
			for each (var tile:GameTile in piece.tiles)
			{
				//If tile examined has a lower connection, skip it, as it could
				//never land on another tile. The lower tile gets in the way!
				if (tile.dirs[2])
					continue;
				
				//Has piece hit the bottom of the bin?
				if (tile.ypos <= 0)	//<= 0 for above, <= -1 for within
					return true;
				
				//Has piece landed on tiles in the bin?
				if (_tilemap[tile.xpos][tile.ypos - 1])
				{
					//If set as such, ignore it when a piece lands on a gravpiece.
					var opiece:GamePiece = _tilemap[tile.xpos][tile.ypos - 1].piece;
					if (ignoreGravPieces && opiece.gravfall)
						continue;
					
					return true;
				}
				
			}
			
			return false;
		}
		
		private function setPiece():void
		{
			//Since the piece is no longer controlled, _piece should be empty.
			//Don't let _piece exist as a _setpieces entry!
			var piece:GamePiece = _piece;
			_piece = null;
			
			//Piece landed, so can hold a new piece.
			if (_holding)
				_holding = false;
			
			//Bonus points for setting the piece
			score += cs[SettingNames.SETBONUS] * (cs[SettingNames.SETBONUSP_T] ? 1 : piece.numtiles);
			
			if (level < cs[SettingNames.LEVELMAX])
			{
				if (cs[SettingNames.LEVELUPREQ] == Settings.L_PIECESETS)
					reqcount++;
				else if (cs[SettingNames.LEVELUPREQ] == Settings.L_TILESETS)
					reqcount += piece.numtiles;
				
				//Level up, if correct to do so.
				if (cs[SettingNames.LEVELUPREQ] == Settings.L_PIECESETS || cs[SettingNames.LEVELUPREQ] == Settings.L_TILESETS)
					levelUpCheck();
			}
			
			//If piece is broken, break it up now.
			var bpieces:Vector.<GamePiece> = piece.breakCheck();
			if (bpieces == null)
				bpieces = Vector.<GamePiece>([piece]);
			
			for each (piece in bpieces)
			{
				piece.visible = true;
				//Once landed, each tile enters the tilemap.
				for each (var tile:GameTile in piece.tiles)
				{
					_tilemap[tile.xpos][tile.ypos] = tile;
					tile.visible = !cs[SettingNames.INVISILAND];
					
					if (tile.ypos > ytop)
						ytop = tile.ypos;
						//_testbar.y = -(tile.ypos + 1) * s;
				}
					
				addPiece(piece);
				//Don't lump yet! If gravity happens, need to do grav checks first.
			}
			
			//If there are _gravpieces, check for them again in case landed piece
			//changed them! Also check if Fit Mode/broken pieces, in case piece is set above ground.
			if (cs[SettingNames.GRAVITY] && (_gravpieces.length > 0 || bpieces.length > 1 || cs[SettingNames.FITMODE]))
			{
				findGravPieces();
				
				if (_lump)
					for each (piece in bpieces)
						if (!piece.gravfall)
							lumpPiece(piece);
				
				//If landed piece blocked the path of falling tiles, cancel the _gravtimer!
				if (_gravpieces.length == 0 && _gravtimer.running)
				{
					_gravtimer.reset();
					//Don't reset the gravcombo if pieces are still going to be cleared!! Unfair to cancel combos on piece set in that case.
					if (!_cleartimer.running)
						_gravcombo = 0;
				}
				else if (_gravpieces.length > 0)
				{
					_gravtimer.start();
					if (cs[SettingNames.FREEZE])
					{
						_timer.reset();
						if (_endtimer != null)
							_endtimer.stop();
						
						if (_spawnafterclear)
							_shad.visible = false;
					}
				}
			}
			else if (_lump)
				for each (piece in bpieces)
					lumpPiece(piece);
			
			//Since spawnAfterClear == true needs freeze == true, is this safe? Yes: no nextPiece if freeze, grav, and spawnafter.
			if (!cs[SettingNames.FREEZE] || _gravpieces.length == 0)
				clearCheckAction(true, false); //This handles dropping a piece.
			else if (!_spawnafterclear)
				nextPiece(); //Game over may happen, but no real need to return
			
			Sounds.playSingleSound(SoundList.Thud1);
			fixDepths();
		}
		
		private function lumpPiece(piece:GamePiece):void
		{
			var otile:GameTile;
			var atile:GameTile;
			var tiles:Vector.<GameTile> = piece.tiles.slice();
			var newpieces:Vector.<GamePiece> = new Vector.<GamePiece>();
			for each (var tile:GameTile in tiles)
			{
				if (!tile.dirs[0] && tile.ypos + 1 < _ymax && _tilemap[tile.xpos][tile.ypos + 1])
				{
					otile = _tilemap[tile.xpos][tile.ypos + 1];
					if (!otile.piece.gravfall)
					{
						tile.dirs[0] = otile;
						otile.dirs[2] = tile;
						if (newpieces.indexOf(otile.piece) == -1)
							newpieces.push(otile.piece);
					}
				}
				if (!tile.dirs[1] && tile.xpos + 1 < cs[SettingNames.BINX] && _tilemap[tile.xpos + 1][tile.ypos])
				{
					otile = _tilemap[tile.xpos + 1][tile.ypos];
					if (!otile.piece.gravfall)
					{
						tile.dirs[1] = otile;
						otile.dirs[3] = tile;
						if (newpieces.indexOf(otile.piece) == -1)
							newpieces.push(otile.piece);
					}
				}
				if (!tile.dirs[2] && tile.ypos - 1 >= 0 &&_tilemap[tile.xpos][tile.ypos - 1])
				{
					otile = _tilemap[tile.xpos][tile.ypos - 1];
					if (!otile.piece.gravfall)
					{
						tile.dirs[2] = otile;
						otile.dirs[0] = tile;
						if (newpieces.indexOf(otile.piece) == -1)
							newpieces.push(otile.piece);
					}
				}
				if (!tile.dirs[3] && tile.xpos - 1 >= 0 && _tilemap[tile.xpos - 1][tile.ypos])
				{
					otile = _tilemap[tile.xpos - 1][tile.ypos];
					if (!otile.piece.gravfall)
					{
						tile.dirs[3] = otile;
						otile.dirs[1] = tile;
						if (newpieces.indexOf(otile.piece) == -1)
							newpieces.push(otile.piece);
					}
				}
			}
			
			//Quit if there are no new pieces.
			if (newpieces.length == 0)
				return;
			
			for each (var newpiece:GamePiece in newpieces)
			{
				//Remove the old piece from _setpieces, as since it's being merged,
				//it no longer exists on its own.
				_setpieces.splice(_setpieces.indexOf(newpiece), 1);
				
				//Place each tile of every added piece into the main piece.
				for each (var newtile:GameTile in newpiece.tiles) //????????????????????????
				{
					piece.addChild(newtile);
					piece.tiles.push(newtile);
					newtile.piece = piece;
				}
			}
			
			piece.borDraw();
		}
		
		/**
		 * In Fall Mode, moves the controlled piece down by one unit, checking if the piece
		 * is landed and setting it if so. Executed on every tick of _timer.
		 * @param	e
		 */
		private function fallPiece(e:TimerEvent = null):void
		{
			//If piece won't land after moving down, move it down and possibly add to the score.
			if (!landCheck(_piece))
			{
				_piece.movePiece(0, -1);
				if (_dropping && cs[SettingNames.SOFTBONUS] != 0)
					score += cs[SettingNames.SOFTBONUS];
			}
			else
				setPiece();
		}
		
		/**
		 * Create a new swiper graphic for either the fit timer or the clear timer.
		 * @param	fit_clear Set to true if this swiper is for the fit timer, or false if it's for the clear timer.
		 */
		private function makeSomeSwiper(fit_clear:Boolean):void
		{
			var tswiper:Sprite;
			var color:uint = fit_clear ? 0xFFFFFF : 0xFF9900;
			
			var swidth:Number = 20;
			var sheight:Number = s * cs[SettingNames.BINY];
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(swidth, sheight);
			
			tswiper = new Sprite();
			tswiper.graphics.beginGradientFill(
				GradientType.LINEAR,
				[color, color, color],
				[0.8, 0.7, 0],
				[0, 50, 255],
				matrix);
			tswiper.graphics.drawRect(0, 0, swidth, sheight);
			tswiper.x = s * cs[SettingNames.BINX];
			tswiper.y = -sheight;
			_playZone.addChild(tswiper);
			
			if (fit_clear)
				_swiper = tswiper;
			else
				_clearswiper = tswiper;
		}
		
		private function moveSwiper():void
		{
			var p:Number = (_timer.frameDelay - _timer.timeCount) / _timer.frameDelay;
			_swiper.x = s * cs[SettingNames.BINX] * p - 5;
			if (p <= 0.3)
				danger = true;
		}
		
		private function moveClearSwiper():void
		{
			var p:Number = (_cleartimer.frameDelay - _cleartimer.timeCount) / _cleartimer.frameDelay;
			_clearswiper.x = s * cs[SettingNames.BINX] * p - 5;
		}
		
		/**
		 * Create a new fit timer swiper, and fade out the old one.
		 * @param	remove Set to true if the swiper should be removed outright.
		 */
		private function newSwiper(remove:Boolean = false):void
		{
			var tempswiper:Sprite = _swiper;
			if (!remove)
				makeSomeSwiper(true);
			else
				_swiper = null;
			if (tempswiper != null)
			{
				TweenLite.to(tempswiper, 1, { alpha:0, ease:None.easeNone, onComplete:function() {
					_playZone.removeChild(tempswiper);
					TweenLite.killTweensOf(tempswiper);
				}});
			}
		}
		
		/**
		 * Remove the clear timer swiper by fading it out.
		 */
		private function removeClearSwiper():void
		{
			if (_clearswiper == null)
				return;
			var tempswiper:Sprite = _clearswiper;
			_clearswiper = null;
			TweenLite.to(tempswiper, 1, { alpha:0, ease:None.easeNone, onComplete:function() {
				_playZone.removeChild(tempswiper);
				TweenLite.killTweensOf(tempswiper);
			}});
		}
		
		/**
		 * _timer's TimerEvent in Fit Mode.
		 * @param	e
		 */
		private function fitPiece(e:TimerEvent = null):void
		{
			danger = false;
			
			//If TimerEvent null, caused by button press. Otherwise, forced fit by time limit.
			if (!_overlap)
			{
				if (e == null)
					_timer.resetTime();
				newSwiper();
				setPiece();
			}
			else if (e != null) //Only timer can force a fit on overlap.
			{
				Sounds.playSound(SoundList.Thud1);
				if (--chances == -1)
				{
					_lifelost = true;
					//loseLife();
				}
				else if (cs[SettingNames.FITFORCE])
				{
					for (var i:int = _piece.numtiles - 1; i >= 0; i--)
					{
						var tile:GameTile = _piece.tiles[i];
						if (tile.overlap)
							_piece.removeTile(tile);
					}
					newSwiper();
					setPiece();
				}
				else
				{
					newSwiper();
					_playZone.removeChild(_piece);
					nextPiece();
				}
			}
			fixDepths();
		}
		
		private function findGravPieces(lefta:Array = null, bota:Array = null, wida:Array = null, lena:Array = null):void
		{
			//Clean out _gravpieces to start check from scratch.
			while (_gravpieces.length > 0)
				removeGravPiece(_gravpieces[0]);
			
			//First, put all pieces into _gravpieces.
			for each (var piece:GamePiece in _setpieces)
				addGravPiece(piece);
			
			//Start by examining pieces that lie on the bottom of the bin. These
			//pieces, and those on top of them, are grounded. Remove them from _gravpieces.
			for (var x:uint = 0; x < cs[SettingNames.BINX]; x++)
			{
				//Don't re-check pieces: only check those that are still marked as falling.
				if (_tilemap[x][0] && _tilemap[x][0].piece.gravfall)
					pieceOnTop(_tilemap[x][0].piece);
			}
			
			/*if (lena == null)
				return;
			
			for (var i:uint = 0; i < lefta.length; i++)
			{
				var left:uint = lefta[i];
				var bot:uint = bota[i];
				var wid:uint = wida[i];
				var len:uint = lena[i];
				
				var right:uint = left + wid - 1;
				var top:uint = bot + len - 1;
				
				for each (piece in _gravpieces)
				{
					var inside:Boolean = false;
					for each (var tile:GameTile in piece.tiles)
					{
						if (left <= tile.xpos && tile.xpos < right && top < tile.ypos)
						{
							inside = true;
							break;
						}
					}
					
					if (!inside)
						removeGravPiece(piece);
				}
			}*/
		}
		
		private function isRowEmpty(row:uint):Boolean
		{
			var x:uint;
			for (x = 0; x < cs[SettingNames.BINX]; x++)
			{
				if (_tilemap[x][row])
					return false;
			}
			return true;
		}
		
		/**
		 * Drops all suspended piece (all pieces in _gravpieces) by one unit.
		 */
		private function gravCheck(e:TimerEvent = null):void
		{
			if (e == null && _gravpieces.length == 0)
				return;
			
			//Drop all pieces BEFORE checking for landing, so pieces will be set
			//*as soon* as it visibly lands on something. Move them all at once
			//so they remain at consistant positions relative to each other.
			
			//Make a copy of _gravpieces, otherwise will skip over pieces!
			var gravpieces:Vector.<GamePiece> = _gravpieces.slice();
			var piece:GamePiece;
			var tile:GameTile;
			
			//Tiles will move, so remove them from _tilemap.
			for each (piece in gravpieces)
			{
				for each (tile in piece.tiles)
					_tilemap[tile.xpos][tile.ypos] = null;
			}
			
			//Move all tiles together, IF THEY AREN'T LANDING ON THE CONTROLLED PIECE!!
			if (!cs[SettingNames.FREEZE])
			{
				var hit:Boolean = false;
				for each (var piece:GamePiece in gravpieces)
				{
					//ignore the controlled piece if it's passable
					if (!_passable)
					{
						for each (tile in piece.tiles)
						{
							for each (var ctile:GameTile in _piece.tiles)
							{if (tile.xpos == ctile.xpos && tile.ypos - 1 == ctile.ypos)
								{
									hit = true;
									break;
								}
							}
							if (hit)
								break;
						}
						if (hit)
						{
							hit = false;
							continue;
						}
					}
					
					//Only move piece if it wouldn't land on the controlled piece.			
					piece.movePiece(0, -1);
					
					//Update ytop, but not if a clearDropS caused this drop.
					if (e != null) {
						for each (tile in piece.tiles) {
							if (tile.ypos + 1 == ytop && isRowEmpty(tile.ypos + 1)) {
								ytop--;
								//_testbar.y = -(tile.ypos + 1) * s;
								break; //Only do it once, since the piece only falls by 1 space.
							}
						}
					}
				}
			}
			//Don't need these checks if game is frozen.
			else
			{
				for each (piece in gravpieces) {
					piece.movePiece(0, -1);
					
					//Update ytop, but not if a clearDropS caused this drop.
					if (e != null) {
						for each (tile in piece.tiles) {
							if (tile.ypos + 1 == ytop && isRowEmpty(tile.ypos + 1)) {
								ytop--;
								//_testbar.y = -(tile.ypos + 1) * s;
								break; //Only do it once, since the piece only falls by 1 space.
							}
						}
					}
				}
			}
			
			//Now that tiles have moved (or not), put them back into _tilemap.
			for each (var piece:GamePiece in gravpieces)
				for each (tile in piece.tiles)
					_tilemap[tile.xpos][tile.ypos] = tile;
			
			//If the controlled piece is on the screen (either !freeze or early spawn), update the shadow & overlap!
			if (_piece != null)
			{
				if (cs[SettingNames.SHADOWS])
					updateShadow();
				if (_passable)
				{
					resetOverlap();
					tileCollide(0, 0, true);
				}
			}
			
			//Now check if they landed anywhere.
			for each (var piece:GamePiece in gravpieces)
			{
				if (landCheck(piece, true))
				{
					pieceOnTop(piece);
					if (_lump)
						lumpPiece(piece);
				}
			}
			
			//Only continue if the timer called this function! Maybe it was called for a clearDrop.
			if (e == null) return;
			
			//Only always check for a line if game is running (and NEVER during a clearDrop (e==null)).
			//Otherwise, do it when there are no falling pieces.
			if (e != null && (!cs[SettingNames.FREEZE] || _gravpieces.length == 0))
				clearCheckAction(false, true);
			
			//If no falling pieces, stop the gravity timer.
			if (_gravpieces.length == 0)
			{
				if (_gravtimer != null)
					_gravtimer.reset();
				//If none falling AND no line clear, resume game.
				if (_cleartiles.length == 0)
				{
					if (!_cleartimer.running)
						_gravcombo = 0;
					
					//Don't do any of this is the gravCheck was only to do a clearDrop.
					if (e != null)
					{
						if (cs[SettingNames.FREEZE])
						{
							//If next piece didn't enter already, enter it now.
							if (_spawnafterclear) //TODO is this okay???
							{
								//exit on game over.
								if (!nextPiece())
									return;
							}
							
							_timer.start();
							if (_endtimer != null)
								_endtimer.start();
						}
					}
				}
			}
		}
		
		/**
		 * Drops the given piece until it lands, in a single frame. If piece is
		 * the controlled piece, the piece will be set.
		 * @param	piece
		 */
		private function instDrop(piece:GamePiece):void
		{
			var i:uint;
			var tiles:GameTile;
			var movedby:uint = 0;
			
			while (!landCheck(piece))
			{
				movedby++;
				piece.movePiece(0, -1);
			}
			
			if (piece == _piece)
			{
				//hard drop bonus
				setPiece(); //***
				if (cs[SettingNames.HARDBONUS] != 0)
					score += cs[SettingNames.HARDBONUS] * movedby;
			}
		}
		
		private function clearCheckAction(insertNextPiece:Boolean, grav:Boolean):void
		{
			var tile:GameTile;
			var oldclears:Vector.<GameTile> = new Vector.<GameTile>();
			
			if (_cleartiles.length > 0)
			{
				oldclears = _cleartiles.slice();
				_cleartiles = new Vector.<GameTile>();
			}
			
			//Check for a successful clear.
			clearCheck();
			if (_cleartiles.length > 0) //If there is a clear, do the following.
			{
				if (cs[SettingNames.FREEZE] && _spawnafterclear && cs[SettingNames.SHADOWS])
					_shad.visible = false;
				
				//For no spawnAfterClear (or no freeze), piece enters before clearing tiles.
				if (insertNextPiece && (!cs[SettingNames.FREEZE] || !_spawnafterclear))
				{
					//exit on game over.
					if (!nextPiece())
						return;
				}
				
				//If set as such, a clear will pause the controllable game action.
				if (cs[SettingNames.FREEZE] && _timer.running)
				{
					_timer.reset();
					if (_endtimer != null)
						_endtimer.stop();
				}
				
				//Perform following actions for NEW clears.
				if (oldclears.length != _cleartiles.length)
				{
					Sounds.playSound(SoundList.Clear1);
					
					//Back-to-back clear combo. NOT for gravity drops!
					if (!grav && cs[SettingNames.BB_BONUS] && ++_bbcombo > 1)
						_scorelist.showBBComboPop(_bbcombo);
					
					//If game doesn't freeze, combo count increases for every clear made during same clear time.
					if (!cs[SettingNames.FREEZE] && ++_combo > 1)
						_scorelist.showComboPop(_combo);
					
					if (grav)
						_scorelist.showGravComboPop(++_gravcombo);
					
					//Clear timer starts, from the beginning. If not frozen, may not reset.
					if (_cleartimer.running)
					{
						if (cs[SettingNames.CRESET])
						{
							removeClearSwiper();
							_cleartimer.resetTime();
							makeSomeSwiper(false);
						}
					}
					else
					{
						_cleartimer.start();
						makeSomeSwiper(false);
					}
				}
				
				//Add clear animation for new _cleartiles.
				for each (tile in _cleartiles)
				{
					if (!tile.hasCleared())
					{
						tile.visible = true;
						tile.addClearStyle();
					}
				}
				//For tiles that were once cleared but not any more (typically for square clears),
				//remove their clear animation.
				for each (tile in oldclears)
				{
					if (_cleartiles.indexOf(tile) == -1)
					{
						tile.visible = !cs[SettingNames.INVISILAND];
						tile.removeClearStyle();
					}
				}
			}
			//If no clear, the next piece should enter now.
			//UNLESS there are falling pieces while spawning after a clear.
			else
			{
				if (!grav && cs[SettingNames.BB_BONUS] && _bbcombo > 0)
					_bbcombo = 0;
				
				if (insertNextPiece && (_gravpieces.length == 0 || (!cs[SettingNames.FREEZE] || !_spawnafterclear)))
					nextPiece();
			}
		}
		
		private function clearCheckL():void
		{
			//First, reset all specific clear variables.
			if (_clearrows.length > 0)
				_clearrows = new Vector.<uint>();
			
			var x:uint;
			var y:uint;
			
			for (y = 0; y < _ymax; y++)
			{
				for (x = 0; x < cs[SettingNames.BINX]; x++)
				{
					//If a block is missing in a row, move up to the next row.
					//Also ignore falling pieces!
					if (!_tilemap[x][y] || _tilemap[x][y].piece.gravfall)
						break;
				}
				
				if (x == cs[SettingNames.BINX])
				{
					_clearrows.push(y);
					
					for (var x2:uint = 0; x2 < cs[SettingNames.BINX]; x2++)
						_cleartiles.push(_tilemap[x2][y]);
				}
			}
		}
		
		private function clearCheckS():void
		{
			//Discount all previously cleared boxes!
			_clearboxes = new Vector.<Array>();
			//_clearboxes = G.twoDarray(2, 0);
			
			var hcount:uint;
			var vcount:uint;
			var clent:uint;
			var y2:uint;
			var newb:uint;
			var newp:uint;
			
			for (var y:int = _ystart; y * _vdir <= _yend * _vdir; y += _vdir)
			{
				if (y * _vdir > _yend * _vdir)
					break;
				
				hcount = 0;
				vcount = 0;
				clent = cs[SettingNames.CLEN];
				newb = 0;
				newp = 0;
				
				for (var x:int = _xstart; x * _hdir <= _xend * _hdir; x += _hdir)
				{
					if (hcount == 0 && x * _hdir > _xend * _hdir)
						break;
					
					//Don't count falling pieces!
					if (_tilemap[x][y] && !_tilemap[x][y].piece.gravfall)
					{
						if (_cleartiles.indexOf(_tilemap[x][y]) != -1)
						{
							if (!cs[SettingNames.EXTENDABLE])
								continue;
						}
						else if (newp == 0 && cs[SettingNames.EXTENDABLE])
							newp = 1;
						
						if (vcount == 0 && cs[SettingNames.EXTENDABLE])
						{
							while (_tilemap[x][y + (++vcount * _vdir)])
							{
								if (newp == 0 && _cleartiles.indexOf(_tilemap[x][y + vcount * _vdir]) == -1)
									newp = vcount + 1;
							}
							if (vcount >= cs[SettingNames.CLEN])
							{
								hcount++;
								if (newb == 0 || newp < newb)
									newb = newp;
								if (clent != vcount)
									clent = vcount;
							}
							else
							{
								hcount = 0;
								vcount = 0;
								clent = cs[SettingNames.CLEN];
								newp = 0;
								newb = 0;
								continue;
							}
						}
						else
						{
							hcount++;
							if (newb == 0 || newp < newb)
								newb = newp;
							
							y2 = 0;
							while (++y2 < clent && _tilemap[x][y + y2 * _vdir])
							{
								if (!newp && _cleartiles.indexOf(_tilemap[x][y + y2 * _vdir]) == -1)
									newp = y2 + 1;
							}
							if (y2 < clent) //in case of early break
							{
								if (y2 >= cs[SettingNames.CLEN])
								{
									clent = y2;
									if (newp > y2)
										newp = 0;
								}
								else if (--hcount < cs[SettingNames.CWID])
								{
									hcount = 0;
									vcount = 0;
									clent = cs[SettingNames.CLEN];
									newp = 0;
									newb = 0;
									continue;
								}
								else if (cs[SettingNames.EXTENDABLE])
								{
									if (newb > 0)
										clearCount(x - _hdir, y + clent * _vdir - _vdir, hcount, clent);
									hcount = 0;
									vcount = 0;
									clent = cs[SettingNames.CLEN];
									newp = 0;
									newb = 0;
									continue;
								}
							}
						}
						if ( (!cs[SettingNames.EXTENDABLE] && hcount == cs[SettingNames.CWID]) || (cs[SettingNames.EXTENDABLE] && x == _xend && hcount >= cs[SettingNames.CWID]) )
						{
							if (newb > 0 || !cs[SettingNames.EXTENDABLE])
								clearCount(x, y + clent * _vdir - _vdir, hcount, clent);
							hcount = 0;
							vcount = 0;
							clent = cs[SettingNames.CLEN];
							newp = 0;
							newb = 0;
							continue;
						}
					}
					else if (cs[SettingNames.EXTENDABLE] && hcount >= cs[SettingNames.CWID])
					{
						if (newb > 0)
							clearCount(x - _hdir, y + clent * _vdir - _vdir, hcount, clent);
						hcount = 0;
						vcount = 0;
						clent = cs[SettingNames.CLEN];
						newp = 0;
						newb = 0;
						continue;
					}
					else
					{
						hcount = 0;
						vcount = 0;
						clent = cs[SettingNames.CLEN];
						newp = 0;
						newb = 0;
						continue;
					}
				}
			}
		}
		
		private function clearCount(x2, y2, hcount, clent)
		{
			var x1:uint = x2 - hcount * _hdir + _hdir;
			var y1:uint = y2 - clent * _vdir + _vdir;
			
			for (var y:int = y1; y * _vdir <= y2 * _vdir; y += _vdir)
			{
				for (var x:int = x1; x * _hdir <= x2 * _hdir; x += _hdir)
				{
					//If extendable, there might be overlapping clear boxes.
					//Don't clear them twice!
					if (_cleartiles.indexOf(_tilemap[x][y]) == -1)
						_cleartiles.push(_tilemap[x][y]);
				}
			}
			
			var left:uint = cs[SettingNames.LTOR] ? x1 : x2;
			var top:uint = !cs[SettingNames.BTOT] ? y1 : y2;
			//var bot:uint = cs[SettingNames.BTOT] ? y1 : y2;
			
			/* _clearboxes[i] = box #i.
			 * [i][0/1]: left/top coordinate of the box.
			 * [i][2/3]: width/height of the box.
			 */
			_clearboxes.push([left, top, hcount, clent]);
		}
		
		private function addPiece(piece:GamePiece):void
		{
			_setpieces.push(piece);
			_playZone.addChild(piece);
		}
		
		private function removePiece(piece:GamePiece):void
		{
			_setpieces.splice(_setpieces.indexOf(piece), 1);
			_playZone.removeChild(piece);
		}
		
		private function addGravPiece(piece:GamePiece):void
		{
			if (!piece.gravfall)
			{
				_gravpieces.push(piece);
				piece.gravfall = true;
			}
		}
		
		private function removeGravPiece(piece:GamePiece):void
		{
			if (piece.gravfall)
			{
				_gravpieces.splice(_gravpieces.indexOf(piece), 1);
				piece.gravfall = false;
			}
		}
		
		private function ridTiles(e:TimerEvent):void
		{
			if (_clearswiper != null)
				removeClearSwiper();
			
			var opieces:Vector.<GamePiece> = new Vector.<GamePiece>();
			
			//Mark all removed tiles. No need to unmark them: they will be removed.
			for each (var tile:GameTile in _cleartiles)
				tile.checked = true;
			
			//Remove all cleared tiles, checking for broken pieces.
			for each (var tile:GameTile in _cleartiles)
			{
				//Remove the tile from the tilemap, and from the piece it was from.
				_tilemap[tile.xpos][tile.ypos] = null;
				tile.piece.removeTile(tile);
				
				//Keep a reference to each piece with a removed tile (no duplicate references).
				if (opieces.indexOf(tile.piece) == -1)
					opieces.push(tile.piece);
			}
			
			//Check if any of the pieces tiles were removed from were broken apart.
			for each (var opiece:GamePiece in opieces)
			{
				//If piece of removed tile is now empty, remove it from _setpieces.
				if (opiece.numtiles == 0)
				{
					removePiece(opiece);
					continue;
				}
				
				var bpieces:Vector.<GamePiece> = opiece.breakCheck();
				
				//If piece is broken, put all new pieces into _setpieces, and
				//remove the original piece they came from.
				if (bpieces != null)
				{
					removePiece(opiece);
					for each (var bpiece:GamePiece in bpieces)
						addPiece(bpiece);
				}
			}
			
			scoreUpdate();
			//if (_wingame)
				//return;
			
			//Since all cleared tiles are now removed, empty _cleartiles and reset combo.
			_cleartiles = new Vector.<GameTile>();
			_combo = 0;
			
			//Appropriately shift higher tiles down, if set to do so.
			if (cs[SettingNames.CLEARDROP])
			{
				clearDrop();
				if (_overlap)
				{
					resetOverlap();
					tileCollide(0, 0, true);
				}
			}
			if (cs[SettingNames.SHADOWS] && _piece != null)
				updateShadow();
			
			//Update the top of the bin.
			var y:int = ytop;
			while (y > 0 && isRowEmpty(y))
				y--;
			ytop = y;
			//_testbar.y = -(ytop + 1) * s;
			
			//If gravity is enabled, check for suspended pieces.
			//To do this, find all grounded pieces. All others are suspended.
			if (cs[SettingNames.GRAVITY])
				findGravPieces();
			
			//If no falling pieces or no freeze, BUT ALWAYS IN SQUARE CLEAR MODE, check for cleared pieces.
			if ((!cs[SettingNames.FREEZE] || _gravpieces.length == 0) && _squ)
				clearCheckAction(false, true);
			
			fixDepths();
			
			//If there are no cleared or suspended pieces, resume game.
			if (_cleartiles.length == 0 && _gravpieces.length == 0)
			{
				//spawnAfterClear: piece enters after line is cleared. Perform Game Over check too.
				//Only enter if no pieces are falling.
				if (cs[SettingNames.FREEZE] && _spawnafterclear)
				{
					//exit on game over.
					if (!nextPiece())
						return;
				}
				
				//After clearing, resume timer (if it was stopped).
				if (cs[SettingNames.FREEZE])
				{
					_timer.start();
					if (_endtimer != null)
						_endtimer.start();
				}
				
				//Always reset gravcombo here.
				_gravcombo = 0;
			}
			//Otherwise, if pieces are suspended, start dropping them while leaving game paused (if freeze).
			else if (_gravpieces.length > 0 && _gravtimer != null)
				_gravtimer.start();
		}
		
		private function levelUpCheck():void
		{
			//In case you level up by more than 1 level, keep a seperate counter!
			var levelstep:uint = level;
			var nextstep:int = _nextlevel;
			while (levelstep < cs[SettingNames.LEVELMAX] && reqcount >= nextstep)
			{
				levelstep++;
				nextstep = getLevelUpReq(levelstep);
			}
			
			if (levelstep > level)
			{
				if (cs[SettingNames.TIMELIMIT] != 0)
				{
					var time:Number = 0;
					//Add a level-up time bonus for EACH level gained!
					for (var i:uint = level; i < levelstep; i++)
						time += G.safeIndex(cs[SettingNames.TLVLUPBONUS], i);
					addTime(Math.floor(time));
				}
				
				level = levelstep; //All level up handling done here.
			}
		}
		
		private function scoreUpdate():void
		{
			var scoreup:Number = 0; //increase score by this
			var time:Number = 0; //increase time by this
			
			var lm:Number; //level point modifier
			var bm:Number; //back to back modifier
			var cm:Number; //combo point modifier
			var gm:Number; //gravity combo modifier
			
			var lt:Number; //level point modifier
			var bt:Number; //back to back modifier
			var ct:Number; //combo point modifier
			var gt:Number; //gravity combo modifier
			
			var i:uint;
			
			//Level bonus
			if (!cs[SettingNames.LEVELMULTARR])
				lm = (level + 1) * cs[SettingNames.LEVELMULT];
			else
				lm = G.safeIndex(cs[SettingNames.LEVELMULTA], level);
			
			//Back to back bonus
			if (cs[SettingNames.BB_BONUS] && _bbcombo > 1)
				bm = G.safeIndex(cs[SettingNames.BBCOMBOMOD], _bbcombo - 2); //Need -2 since combo of 2 gives index 0 bonus, etc
			else
				bm = 1;
			
			//Combo bonus
			if (!cs[SettingNames.FREEZE] && _combo > 1)
				cm = G.safeIndex(cs[SettingNames.COMBOMOD], _combo - 2); //Same reasoning as above
			else
				cm = 1;
			
			//Gravity bonus
			if (cs[SettingNames.GRAVITY] && _gravcombo > 1)
				gm = G.safeIndex(cs[SettingNames.GRAVCOMBOMOD], _gravcombo - 1); //x1 is worth something! so -1, not -2.
			else
				gm = 1;
			
			var mod:Number = lm * bm * cm * gm;
			
			
			//Time versions of everything above
			if (cs[SettingNames.TIMELIMIT] > 0)
			{
				//Level bonus
				if (!cs[SettingNames.TLEVELMULTARR])
					lt = (level + 1) * cs[SettingNames.TLEVELMULT];
				else
					lt = G.safeIndex(cs[SettingNames.TLEVELMULTA], level);
				
				//Back to back bonus
				if (cs[SettingNames.BB_BONUS] && _bbcombo > 1)
					bt = G.safeIndex(cs[SettingNames.TBBCOMBOMOD], _bbcombo - 2); //Need -2 since combo of 2 gives index 0 bonus, etc
				else
					bt = 1;
				
				//Combo bonus
				if (!cs[SettingNames.FREEZE] && _combo > 1)
					ct = G.safeIndex(cs[SettingNames.TCOMBOMOD], _combo - 2);
				else
					ct = 1;
				
				//Gravity bonus
				if (cs[SettingNames.GRAVITY] && _gravcombo > 1)
					gt = G.safeIndex(cs[SettingNames.TGRAVCOMBOMOD], _gravcombo - 1);
				else
					gt = 1;
			}
			
			var tmod:Number = lt * bt * ct * gt;
			
			if (!_squ)
			{
				//Find GROUPS of cleared lines.
				var rowheights:Vector.<uint> = new Vector.<uint>();
				var rowheight:uint = 1;
				for (i = 0; i < _clearrows.length - 1; i++)
				{
					if (_clearrows[i] == _clearrows[i + 1] - 1)
						rowheight++;
					else
					{
						rowheights.push(rowheight);
						rowheight = 1;
					}
				}
				rowheights.push(rowheight); //Loop neglects final row! Take care of it here.
				
				if (cs[SettingNames.POINTC_T])
					//Points based on GROUPS of LINES cleared.
					for each (rowheight in rowheights)
						scoreup += G.safeIndex(cs[SettingNames.CLEARPOINTS], rowheight - 1) * mod;
				else
					//Points per each TILE cleared.
					scoreup += _clearrows.length * cs[SettingNames.BINX] * cs[SettingNames.TILEPOINTS] * mod;
				
				if (cs[SettingNames.TIMELIMIT] > 0)
				{
					if (cs[SettingNames.TPOINTC_T])
						for each (rowheight in rowheights)
							time += G.safeIndex(cs[SettingNames.TCLEARBONUS], rowheight - 1) * tmod;
					else
						time += _clearrows.length * cs[SettingNames.BINX] * cs[SettingNames.TTILEBONUS] * tmod;
				}
				
				if (level < cs[SettingNames.LEVELMAX])
				{
					if (cs[SettingNames.LEVELUPREQ] == Settings.L_NUMCLEARS)
						reqcount += _clearrows.length;
					else if (cs[SettingNames.LEVELUPREQ] == Settings.L_TILECLEARS)
						reqcount += _clearrows.length * cs[SettingNames.BINX]; //I'm a lazy bum, so allow tile count for line clears.
				}
			}
			else
			{
				if (cs[SettingNames.POINTC_T])
					//Points based on NUMBER of BOXES cleared.
					//TODO: think about score based on square area...NAH.
					scoreup += G.safeIndex(cs[SettingNames.CLEARPOINTS], _clearboxes.length - 1) * mod;
				else
					//Points for each TILE cleared.
					scoreup += _cleartiles.length * cs[SettingNames.TILEPOINTS] * mod;
				
				if (cs[SettingNames.TIMELIMIT] > 0)
				{
					if (cs[SettingNames.TPOINTC_T])
						time += G.safeIndex(cs[SettingNames.TCLEARBONUS], _clearboxes.length - 1) * tmod;
					else
						time += _cleartiles.length * cs[SettingNames.TTILEBONUS] * tmod;
				}
				
				if (level < cs[SettingNames.LEVELMAX])
				{
					if (cs[SettingNames.LEVELUPREQ] == Settings.L_NUMCLEARS)
						reqcount += _clearboxes.length;
					else if (cs[SettingNames.LEVELUPREQ] == Settings.L_TILECLEARS)
						reqcount += _cleartiles.length;
				}
			}
			
			//Zone multipliers
			if (safe)
				scoreup *= cs[SettingNames.SZONEMULT];
			else if (!cs[SettingNames.FITMODE] && danger)
				scoreup *= cs[SettingNames.DZONEMULT];
			
			score += Math.floor(scoreup);
			
			time *= tmod;
			addTime(Math.floor(time));
			
			//Level up, if correct to do so.
			if (level < cs[SettingNames.LEVELMAX] && (cs[SettingNames.LEVELUPREQ] == Settings.L_NUMCLEARS || cs[SettingNames.LEVELUPREQ] == Settings.L_TILECLEARS))
				levelUpCheck();
		}
		
		private function addTime(value:uint):void
		{
			if (value == 0)
				return;
			var oldtime:uint = timeleft;
			timeleft += value;
			_scorelist.showTimeAddPop(timeleft - oldtime); //Do this to account for the time cap.
		}
		
		/**
		 * Checks if a piece has another piece on top of it. Called recursively.
		 * @param piece	The piece to check.
		 * @param grav Set to false if pieces are being checked for a clear drop instead of gravity.
		 */
		private function pieceOnTop(piece:GamePiece, grav:Boolean = true):void
		{
			if (grav)
			{
				removeGravPiece(piece);
				if (piece.dropping)
					piece.dropping = false;
			}
			else
				piece.dropping = true;
			
			for each (var tile:GameTile in piece.tiles)
			{
				if (tile.dirs[0])
					continue;
				
				if (_tilemap[tile.xpos][tile.ypos + 1])
				{
					var above:GamePiece = _tilemap[tile.xpos][tile.ypos + 1].piece;
					if ((grav && above.gravfall) || (!grav && !above.dropping))
						pieceOnTop(above);
				}
			}
		}
		
		private function clearDropL():void
		{			
			var first_row:uint = _clearrows.shift(); //at least one
			var empty_row:* = _clearrows.shift();
			var down:uint = 1;
			
			var droppieces:Vector.<GamePiece> = new Vector.<GamePiece>();
			
			for (var y:uint = first_row + 1; y < _ymax; y++)
			{
				if (empty_row != undefined && y == int(empty_row))
				{
					down++;
					empty_row = _clearrows.shift();
					continue;
				}
				
				for (var x:uint = 0; x < cs[SettingNames.BINX]; x++)
				{
					if (_tilemap[x][y])
					{
						//Move individual tiles down. It's okay to do this as long
						//as the piece stays intact.
						var tile:GameTile = _tilemap[x][y];
						tile.y += s * down;
						tile.ypos -= down;
						
						_tilemap[tile.xpos][tile.ypos] = tile;
						_tilemap[x][y] = null;
						
						if (droppieces.indexOf(tile.piece) == -1)
							droppieces.push(tile.piece);
					}
				}
			}
			
			if (_lump)
			{
				for each (var droppiece:GamePiece in droppieces)
					lumpPiece(droppiece);
			}
		}
		
		private function clearDropS():void
		{
			//Have all airbourne pieces, but only those which above cleared boxes will fall.
			//Each airbourne piece drops a distance equal to the size of the cleared box it was above.
			_clearboxes.sort(function(a:Array, b:Array) {
				return b[1] - a[1]; //Sort from highest to lowest.
			});
			for (var i:uint = 0; i < _clearboxes.length; i++)
			{
				var left:uint = _clearboxes[i][0];
				var top:uint = _clearboxes[i][1];
				var right:uint = left + _clearboxes[i][2] - 1;
				var bot:uint = top - _clearboxes[i][3] + 1;
				
				var piece:GamePiece;
				var tile:GameTile;
				//All pieces directly on top of clear squares, and on top of THOSE pieces, will drop,
				//but only if they are also fallable by gravity!
				for (var x:uint = left; x <= right; x++)
				{
					tile = _tilemap[x][top + 1];
					if (tile != null)
					{
						piece = tile.piece;
						if (!piece.dropping)
							pieceOnTop(piece, false);
					}
				}
				
				//Which of the droppable pieces are blocked by non-droppable ones, and fallable by gravity?
				findGravPieces();
				//Make a copy of _gravpieces, otherwise will skip over pieces!
				var gravpieces:Vector.<GamePiece> = _gravpieces.slice();
				for each (piece in gravpieces)
				{
					if (piece.gravfall && !piece.dropping)
						pieceOnTop(piece);
				}
				//If no pieces can fall, check next clear square.
				if (_gravpieces.length == 0)
					continue;
				
				//The dropping attribute has served its purpose; can reset it now.
				for each (piece in _gravpieces)
					piece.dropping = false;
				
				//Now move each piece down, accounting for possible collisions.
				//TODO inner? maybe not.
				for (var d:uint = 0; d < _clearboxes[i][3]; d++)
					gravCheck();
				
				//Remove any remaining gravpieces, as the drop is finished for them (for the current square).
				while (_gravpieces.length > 0)
					removeGravPiece(_gravpieces[0]);
			}
		}
		
		/**
		 * Moves controllable piece 1 unit left or right, but not if the piece is blocked
		 * by the side of the bin or set tiles.
		 * @param	dir If 1, move the piece to the right. If -1, move left.
		 * @param	vert If true, this function moves the piece vertically instead of horizontally.
		 * dir set to 1 moves the piece down, -1 moves it up.
		 * @return
		 */
		private function slidePiece(dir:int, vert:Boolean = false):Boolean
		{
			var tile:GameTile;
			
			if ( (!vert && sideCollide(dir)) || (vert && ceilCollide(dir)) )
			{
				Sounds.playSingleSound(SoundList.Thud1);
				return false;
			}
			
			if (vert && dir == -1) //down
			{
				for each (var tile:GameTile in _piece.tiles)
				{
					if (tile.ypos + dir < 0)
					{
						Sounds.playSingleSound(SoundList.Thud1);
						return false;
					}
				}
			}
			
			var xmod:int = !vert ? dir : 0;
			var ymod:int = vert ? dir : 0;
			
			if (_overlap) resetOverlap();
			if (tileCollide(xmod, ymod, _passable))
			{
				Sounds.playSingleSound(SoundList.Thud1);
				return false;
			}
			
			_piece.movePiece(xmod, ymod);
			if (cs[SettingNames.SHADOWS])
				updateShadow();
			
			//Sounds.playSingleSound(SoundList.Tone1);
			return true;
		}
		
		private function wallCheckSides():Array
		{
			var walldirs:Array = new Array(4); //[false, false, false, false]
			var hit:Boolean = false;
			var tile:GameTile;
			
			//Hit top of bin
			if (ceilCollide(0))
			{
				walldirs[0] = true;
				hit = true;
			}
			
			for each (tile in _piece.tiles)
			{
				//Hit bottom of bin
				if (tile.ypos < 0)
				{
					if (!walldirs[2])
						walldirs[2] = true;
					
					if (!hit)
						hit = true;
				}
				
				//Hit side of bin
				if (tile.xpos < 0 || tile.xpos >= cs[SettingNames.BINX])
				{
					if (!walldirs[3] && tile.xcor < 0)
						walldirs[3] = true;
					
					if (!walldirs[1] && tile.xcor > 0)
						walldirs[1] = true;
					
					if (!hit)
						hit = true;
				}
				
				//Hit landed tiles
				//First make sure tile is inside play field!
				//THEN: Check if tile exists with same x/y.
				if ( !_passable
				  && (0 <= tile.xpos && tile.xpos < cs[SettingNames.BINX])
				  && (0 <= tile.ypos && tile.ypos < _ymax)
				  && _tilemap[tile.xpos][tile.ypos])
				{
					if (!hit)
						hit = true;
					
					//Left/right
					if (!walldirs[3] && tile.xcor < 0)
						walldirs[3] = true;
					if (!walldirs[1] && tile.xcor > 0)
						walldirs[1] = true;
					
					//Top/bottom
					if (tile.xcor == 0)
					{
						if (!walldirs[0] && tile.ycor > 0)
							walldirs[0] = true;
						if (!walldirs[2] && tile.ycor < 0)
							walldirs[2] = true;
					}
				}
			}
			if (hit)
				return walldirs;
			
			if (_passable)
				tileCollide(0, 0, true);
			
			return null;
		}
		
		private function rotPiece(left_right:Boolean):void
		{
			if (_overlap) resetOverlap();
			
			var start_pos:Point = new Point(_piece.tiles[0].xpos, _piece.tiles[0].ypos);
			_piece.rotPiece(left_right);
			
			var walldirs:Array;
			var lastdirs:Array = new Array(4);
			
			var i:uint;
			var reset:Boolean = false;
			var resettime:Boolean = false;
			
			const maxloop:uint = cs[SettingNames.BINX] + cs[SettingNames.BINY];
			var loopcount:uint = 0;
			
			//TODO: Option for setPiece when piece collides on bottom? I think this is done.
			
			while ( (walldirs = wallCheckSides()) != null)
			{
				if (loopcount++ > maxloop)
				{
					trace("BAAAAAAAAAD!!!");
					reset = true;
					break;
				}
				//If a piece is squished on the top & bottom, abort!
				if ((walldirs[0] || lastdirs[0]) && (walldirs[2] || lastdirs[2]))
				{
					reset = true;
					break;
				}
				
				//If a piece is squished on the left & right, squeeze upward (if allowed).
				if ((walldirs[3] || lastdirs[3]) && (walldirs[1] || lastdirs[1]))
				{
					if (cs[SettingNames.SQUEEZE])
					{
						_piece.movePiece(0, 1);
						if (!resettime) resettime = true; //Delay next time tick
					}
					else
					{
						reset = true;
						break;
					}
					
					//If piece is blocked on top while squished, abort!
					if (walldirs[0])
					{
						reset = true;
						break;
					}
				}
				
				//Otherwise, if a piece just hits ONE side, slide it over (if allowed).
				else if ((walldirs[3] || lastdirs[3]) || (walldirs[1] || lastdirs[1]))
				{
					if (cs[SettingNames.WALLKICK])
					{
						if (walldirs[3])
							_piece.movePiece(1, 0);
						else if (walldirs[1])
							_piece.movePiece( -1, 0);
						else
						{
							reset = true; //maybe?
							break;
						}
					}
					else
					{
						reset = true;
						break;
					}
				}
				
				//If a piece is blocked at the bottom, slide it up (if allowed).
				if (walldirs[2])
				{
					if (cs[SettingNames.FLOORKICK])
					{
						_piece.movePiece(0, 1);
						if (!resettime) resettime = true;
					}
					else
					{
						reset = true;
						break;
					}
				}
				
				//Otherwise, if a piece is blocked only on top, slide it down (if allowed).
				else if (walldirs[0])
				{
					if (cs[SettingNames.CEILKICK])
					{
						_piece.movePiece(0, -1);
						//timer.resetTime(); ??? maybe.
					}
					else
					{
						reset = true;
						break;
					}
				}
				//maybe???
				/*else
				{
					//trace("this would have happened");
					reset = true;
					break;
				}*/
				
				//Save a copy of current wall collisions for next iteration.
				lastdirs = walldirs.slice();
			}
			
			if (reset)
			{
				_piece.rotPiece(!left_right);
				_piece.movePiece(start_pos.x - _piece.tiles[0].xpos, start_pos.y - _piece.tiles[0].ypos);
			}
			else if (cs[SettingNames.SHADOWS])
				updateShadow();
			
			//If _piece is one tile above a surface, delay _timer (if set as such).
			//Also delay timer if it was told to reset. DON'T do any of this if piece wasn't able to turn.
			//Only delay timer for fall mode!!
			if (!cs[SettingNames.FITMODE] && !reset && ((cs[SettingNames.LANDKICK] && landCheck(_piece)) || resettime))
				_timer.resetTime();
		}
		
		/**
		 * Checks if a playZone overflow (game over) occurs.
		 * @return True if game over, false if not.
		 */
		private function overCheck():Boolean
		{
			//If no collisions exist, everything is fine.
			if (!tileCollide(0, 0, false))
				return false;
			
			if (!cs[SettingNames.SAFESHIFT] && !cs[SettingNames.TOPSHIFT])
			{
				//loseLife();
				_lifelost = true;
				return true;
			}
			
			var bincount:uint = 0;
			var xshift:int = int(cs[SettingNames.SAFESHIFT] && cs[SettingNames.XSFIRST]);
			var yshift:int = int(cs[SettingNames.TOPSHIFT] && !cs[SettingNames.XSFIRST]);
			var topreach:Boolean = false;
			var res:uint;
			
			while ((res = wallCheck(xshift, yshift)) != SAFE)
			{
				//safeshift: Shift piece left/right until there's room.
				if (cs[SettingNames.SAFESHIFT])
				{
					//If piece hit both edges of bin...
					if (res == SIDE && ++bincount == 2)
					{
						//...and piece can move up, move back to centre and shift up.
						if (cs[SettingNames.TOPSHIFT] && cs[SettingNames.XSFIRST])
						{
							bincount = 0;
							xshift = 0;
							yshift++;
						}
						//...and piece can't move up, game over!
						else
						{
							//loseLife();
							_lifelost = true;
							return true;
						}
					}
					//If piece didn't hit both sides, move left/right.
					else if (!cs[SettingNames.TOPSHIFT] || cs[SettingNames.XSFIRST])
					{
						xshift *= -1;
						if (xshift >= 0)
							xshift++;
					}
				}
				
				//topshift: Shift piece upwards until there's room.
				if (cs[SettingNames.TOPSHIFT])
				{
					//If hit ceiling...
					if (res == CEIL)
					{
						//...and piece can't move left/right, game over!
						if ((cs[SettingNames.SAFESHIFT] && cs[SettingNames.XSFIRST]) || !cs[SettingNames.SAFESHIFT])
						{
							//loseLife();
							_lifelost = true;
							return true;
							//topreach = true;
							//break;
						}
						//...and piece can move, shift left/right until safe.
						else
						{
							yshift = 0;
							xshift *= -1;
							if (xshift >= 0)
								xshift++;
						}
					}
					//If didn't hit ceiling, shift up until there's room.
					else if (!cs[SettingNames.SAFESHIFT] || !cs[SettingNames.XSFIRST])
						yshift++;
				}
			}
			
			_piece.movePiece(xshift, yshift);
			if (cs[SettingNames.SHADOWS])
				updateShadow();
			return false;
		}
		
		private function holdAction():void
		{
			removeClearSwiper();
			
			_timer.reset();
			_cleartimer.reset();
			if (_gravtimer != null)
			{
				_gravtimer.reset();
				_gravcombo = 0;
			}
			_combo = 0;
			
			if (_endtimer != null)
				_endtimer.stop();
			
			if (danger) danger = false;
			if (safe) safe = false;
			if (timedanger) timedanger = false;
			
			_overplay = true;
		}
		
		//What to do when overCheck finds a game over condition.
		private function loseLife(loseAll:Boolean = false):void
		{
			holdAction();
			danger = false;
			//If set to lose all lives, do so. Otherwise, just lose one.
			if (!loseAll)
			{
				if (--lives > -1)
				{
					if (cs[SettingNames.SCOREPEN])
						score = 0;
					if (cs[SettingNames.LEVELPEN])
						level = 0;
				}
				if (cs[SettingNames.FITMODE])
					chances = cs[SettingNames.FITCHANCES]; //reset chances on next life
			}
			else
			{
				lives = -1;
				if (cs[SettingNames.FITMODE]) chances = -1;
			}
			
			_overplay = true;
			_deadsound.play( -1);
		}
		
		private function winGame():void
		{
			//maybe more can go here.
			holdAction();
		}
		
		private function timeOut(e:TimerEvent = null)
		{
			_endtimer.removeEventListener(TimerEvent.TIMER, timeOutTick);
			//_endtimer.removeEventListener(TimerEvent.TIMER, timeOut);
			//loseLife(true);
			_lifelost = true;
		}
		
		private function timeOutTick(e:TimerEvent)
		{
			timeleft--;
			
			if (!_lifelost && cs[SettingNames.LEVELUPREQ] == Settings.L_TIME //check for _lifelost, in case of time out.
				&& level < cs[SettingNames.LEVELMAX] && ++reqcount > _nextlevel) // Don't need levelUpCheck: time can't get > 1 level per tick.
				level++;
		}
		
		private function pauseGame(e:Event = null):void
		{
			_timer.stop();
			Sounds.songVolume = 0.3;
			Key.pauseHoldCount();
			
			if (_cleartimer.running)
				_cleartimer.stop();
			
			if (_gravtimer != null && _gravtimer.running)
				_gravtimer.stop();
			
			if (_endtimer != null)
				_endtimer.stop();
			
			for each (var cleartile:GameTile in _cleartiles)
				cleartile.pauseClearStyle();
		}
		
		private function unpauseGame(e:Event = null):void
		{
			_timer.start();
			Sounds.songVolume = 1;
			Key.startHoldCount();
			
			//Only resume _cleartimer if it was running before.
			if (_cleartimer.timeCount != 0)
				_cleartimer.start();
			
			if (_gravtimer != null && _gravpieces.length > 0)
				_gravtimer.start();
			
			if (_endtimer != null)
				_endtimer.start();
			
			for each (var cleartile:GameTile in _cleartiles)
				cleartile.resumeClearStyle();
			
			ks = KeySettings.currentConfig; //in case keys are changed in the pause menu.
			Key.resetAllHold();
		}
		
		/**
		 * What to do once the pre-game countdown is complete.
		 * @param	e
		 */
		private function startAction(e:Event):void
		{
			nextPiece();
			
			_timer.start();
			if (_endtimer != null)
				_endtimer.start();
			
			Key.startHoldCount();
			Main.stage.addEventListener(Event.ENTER_FRAME, OEN);
			
			_pausebutton.enable();
			
			fixDepths();
		}
		
		
		private function OEN(e:Event):void
		{
			if (_lifelost || _wingame)
			{
				if (!_overstarted)
				{
					if (_lifelost)
						loseLife(timeleft == 0);
					else if (_wingame)
						holdAction();
					
					_overstarted = true;
					_pausebutton.disable();
				}
				else if (_overplay)
					overAnim();
			}
			else if (_liferestore)
				restoreAnim();
			else if (_timer.running)
			{
				if (cs[SettingNames.FITMODE])
					moveSwiper();
				if (!cs[SettingNames.FREEZE] && _clearswiper != null)
					moveClearSwiper();
				
				//DID auto-slide/rotate speeds
				
				//Rotating
				if (Key.isDown(ks.k_rotccw, ks.k_rotcw))
					Key.resetHold(ks.k_rotccw, ks.k_rotcw);
				
				if (cs[SettingNames.RCCW] && (Key.isTap(ks.k_rotccw) || (Key.isHeld(ks.k_rotccw, cs[SettingNames.RESPROT], true, cs[SettingNames.SPEEDROT]))))
					rotPiece(true);
				if (cs[SettingNames.RCW] && (Key.isTap(ks.k_rotcw) || (Key.isHeld(ks.k_rotcw, cs[SettingNames.RESPROT], true, cs[SettingNames.SPEEDROT]))))
					rotPiece(false);
				
				//Shifting
				if (Key.isDown(ks.k_left, ks.k_right))
					Key.resetHold(ks.k_left, ks.k_right);
				
				if (Key.isTap(ks.k_left) || Key.isHeld(ks.k_left, cs[SettingNames.RESPSLI], true, cs[SettingNames.SPEEDSLI]))
					slidePiece( -1);
				if (Key.isTap(ks.k_right) || Key.isHeld(ks.k_right, cs[SettingNames.RESPSLI], true, cs[SettingNames.SPEEDSLI]))
					slidePiece(1);
				
				//Up & Down shifting, only for Fit Mode. Remember, ypos increases upward!
				if (cs[SettingNames.FITMODE])
				{
					if (Key.isTap(ks.k_up) || Key.isHeld(ks.k_up, cs[SettingNames.RESPSLI], true, cs[SettingNames.SPEEDSLI]))
						slidePiece(1, true);
					if (Key.isTap(ks.k_down) || Key.isHeld(ks.k_down, cs[SettingNames.RESPSLI], true, cs[SettingNames.SPEEDSLI]))
						slidePiece( -1, true);
				}
				
				//Soft drop: only check for TAP of drop key, and stop drop on LIFT of key.
				//Only valid for Fall Mode, hence the else.
				else if (_fallspeed != 1) //If already dropping at max speed, no soft drop!
				{
					if (cs[SettingNames.DROP] && Key.isDown(ks.k_down) && !_dropping)
					{
						_timer.frameDelay = 1;
						_dropping = true;
					}
					else if (_dropping && Key.isUp(ks.k_down))
					{
						_dropping = false;
						_timer.frameDelay = _fallspeed;
					}
				}
				
				if (cs[SettingNames.HOLDABLE] && Key.isTap(ks.k_hold))
					holdPiece();
				else if (!cs[SettingNames.FITMODE] && cs[SettingNames.INST] && Key.isTap(ks.k_up)) //use else to prevent two "next block" conditions
				{
					_timer.resetTime();
					instDrop(_piece); //***
				}
				else if (cs[SettingNames.FITMODE] && Key.isTap(ks.k_place))
				{
					fitPiece();
				}
			}
			
			/*if (_overplay)
				overAnim();
			else if (_liferestore)
				restoreAnim();*/
		}
		
		private function overAnim():void
		{
			var y:uint = _dead++;
			
			if (_swiper != null && _swiper.parent != null)
				newSwiper(true);
			
			for (var x:uint = 0; x < cs[SettingNames.BINX]; x++)
			{
				//if (_tilemap[x][y])
				//	_playZone.removeChild(_tilemap[x][y]);
				
				var bin:Tile = new Tile(cs[SettingNames.BINCOL], cs[SettingNames.BINAPP], null);
				bin.x =  s * x;
				bin.y = -s * y;
				_tilemap[x][y] = bin;
				_playZone.addChild(bin);
			}
			
			//If blocks cover the entire play zone...
			if (_dead == cs[SettingNames.BINY])
			{
				//...and lives are left & the game hasn't been won...
				if (lives != -1 && !_wingame)
				{
					//...remove all pieces from the bin.
					_playZone.removeChild(_piece);
					_piece = null;
					_playZone.removeChild(_shad);
					_shad = null;
					
					for each (var setpiece:GamePiece in _setpieces)
						_playZone.removeChild(setpiece);
					_setpieces = new Vector.<GamePiece>();
					
					//Remove references to tiles above ceiling.
					for (x = 0; x < cs[SettingNames.BINX]; x++)
					{
						for (y = cs[SettingNames.BINY]; y < _ymax; y++)
						{
							if (_tilemap[x][y])
							{
								//_playZone.removeChild(_tilemap[x][y]);
								_tilemap[x][y] = null;
							}
						}
					}
					_lifelost = false;
					
					_overplay = false;
					_liferestore = true;
					if (cs[SettingNames.FITMODE])
						newSwiper();
				}
				//Otherwise, end the game.
				else
				{
					finishUp();
					removeChild(_pausebutton);
					
					_deadsound.stop();
					Sounds.stopSong();
					Sounds.playSound(!_wingame ? SoundList.Lose1 : SoundList.Win1);
					
					//Display the Game Over animation.
					if (!_wingame)
					{
						_endtext = new GOverText1();
						_endtext.addEventListener(GOverText.END_ACTION, finalAction);
					}
					else
					{
						_endtext = new WinText1();
						_endtext.addEventListener(GOverText.END_ACTION, winGameBonus);
					}
					addChild(_endtext);
				}
			}
		}
		
		private function winGameBonus(e:Event = null):void
		{
			if (_endtext.hasEventListener(GOverText.END_ACTION))
				_endtext.removeEventListener(GOverText.END_ACTION, winGameBonus);
			
			if (lives > 0 || chances > 0)
			{
				_timer.secondsDelay = 300;
				_timer.addEventListener(TimerEvent.TIMER, winGameLifeBonus);
				_timer.start();
			}
			else if (timeleft > 0)
			{
				_timer.secondsDelay = 100;
				_timer.addEventListener(TimerEvent.TIMER, winGameTimeBonus);
				_timer.start();
			}
			else
			{
				score += cs[SettingNames.WINBONUS];
				finalAction();
			}
		}
		
		private function winGameLifeBonus(e:TimerEvent):void
		{
			if (lives > 0)
			{
				lives--;
				score += cs[SettingNames.WINLIVESBONUS];
				Sounds.playSingleSound(SoundList.Bonusdrain1);
			}
			else if (chances > 0)
			{
				chances--;
				score += cs[SettingNames.WINCHANCESBONUS];
				Sounds.playSingleSound(SoundList.Bonusdrain1);
			}
			else
			{
				_timer.stop();
				_timer.removeEventListener(TimerEvent.TIMER, winGameLifeBonus);
				winGameBonus();
			}
		}
		
		private function winGameTimeBonus(e:TimerEvent):void
		{
			var dec:uint = 5;
			// Decrement values directly from the scorelist, to keep things inert.
			if (timeleft > 0)
			{
				if (timeleft > dec)
				{
					timeleft -= dec;
					score += cs[SettingNames.WINTIMEBONUS] * dec;
				}
				else
				{
					score += cs[SettingNames.WINTIMEBONUS] * timeleft;
					timeleft = 0;
				}
				Sounds.playSingleSound(SoundList.Bonusdrain1);
			}
			else
			{
				_timer.stop();
				_timer.removeEventListener(TimerEvent.TIMER, winGameTimeBonus);
				winGameBonus();
			}
		}
		
		private function goToResults():void
		{
			_endscore = score;
			Main.changeScreen(ResultScreen);
		}
		
		private function goToMain():void
		{
			_endscore = NOGAME;
			Main.changeScreen(MainMenu);
		}
		
		private var _votebar:VoteBar;
		private function finalAction(e:Event = null):void
		{
			if (cs[SettingNames.FILEID] != 0)
			{
				if (API.hasUserSession)
				{
					_votebar = new VoteBar();
					_votebar.ratingName = APIUtils.RT_GAME;
					_votebar.title = "Rate Mode:";
					PopUp.makePopUp("Give this mode a rating!",
					Vector.<String>(["Skip"]),
					Vector.<Function>([function(e:MouseEvent):void
					{
						API.stopPendingCommands();
						saveModeOrNot(true);
					}]),
					_votebar);
					addEventListener(Event.ENTER_FRAME, voteBarFrameWatch);
					API.addEventListener(APIEvent.VOTE_COMPLETE, voteError);
					API.loadSaveFile(cs[SettingNames.FILEID], true);
				}
				else
					saveModeOrNot(false);
			}
			else
				goToResults();
		}
		
		private function voteBarFrameWatch(e:Event):void
		{
			//Prevent being able to click the "skip" button after the vote is sent.
			if (_votebar.currentFrameLabel == "voting" && PopUp.getInteractionEnabled())
				PopUp.setInteractionEnabled(false);
			if (_votebar.currentFrame == 50)
				saveModeOrNot(true);
		}
		
		/**
		 * Only use this if the vote fails. Otherwise, saveModeOrNot() happens when the VoteBar's animation plays.
		 * @param	e
		 */
		private function voteError(e:APIEvent):void
		{
			if (!e.success)
				saveModeOrNot(true);
		}
		
		private function saveModeOrNot(fromVote:Boolean):void
		{
			//Don't call this function twice.
			if (fromVote)
			{
				if (_votebar == null)
					return;
				_votebar = null;
				removeEventListener(Event.ENTER_FRAME, voteBarFrameWatch);
				API.removeEventListener(APIEvent.VOTE_COMPLETE, voteError);
			}
			
			if (cs.gtype == -1 && Settings.numtypes < Settings.MAX_GAMES)
			{
				PopUp.fadeOut();
				PopUp.makePopUp("Do you want to add this mode to your collection?\nYour score will only be saved if you do.",
				Vector.<String>(["Yes, add this mode!", "Discard it"]),
				Vector.<Function>([
				function(e:MouseEvent):void
				{
					SaveData.saveGameSetting(cs);
					SaveData.flush();
					goToResults();
				},
				function(e:MouseEvent):void
				{
					goToMain();
				}]));
			}
			else
				goToResults();
		}
		
		private function finishUp():void
		{
			//TODO probably not, but might need to clean up the fade out tweens of swipers.
			_scorelist.cleanUp();
			_pausebutton.cleanUp();
			
			Main.stage.removeEventListener(Event.ENTER_FRAME, OEN);
			_timer.removeEventListener(TimerEvent.TIMER, timerTick);
			_cleartimer.removeEventListener(TimerEvent.TIMER_COMPLETE, ridTiles);
			if (_gravtimer != null)
				_gravtimer.removeEventListener(TimerEvent.TIMER, gravCheck);
			if (_endtimer != null)
				_endtimer.removeEventListener(TimerEvent.TIMER, timeOutTick);
		}
		
		private function quitGame(e:Event):void
		{
			finishUp();
			Sounds.fadeOutSong();
			_endscore = NOGAME;
			Main.changeScreen(MainMenu);
		}
		
		private function restoreAnim():void
		{
			var y:uint = --_dead;
			
			for (var x:uint = 0; x < cs[SettingNames.BINX]; x++)
			{
				_playZone.removeChild(_tilemap[x][y]);
				_tilemap[x][y] = null;
			}
			
			//Once all tiles are removed, resume the game.
			if (_dead == 0)
			{
				_deadsound.stop();
				_liferestore = false;
				_overstarted = false;
				ytop = -1;
				//_testbar.y = 0;
				_timer.start();
				if (_endtimer != null)
					_endtimer.start();
				nextPiece();
				_pausebutton.enable();
			}
		}
		
		public function onSwap():void
		{
			Sounds.songVolume = 1;
		}
	}
}