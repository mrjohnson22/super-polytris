package data
{
	import media.sounds.SongList;
	import visuals.backs.gamebacks.GBGPlain;
	import visuals.boxes.*;
	import visuals.clearstyles.Blink;
	import visuals.clearstyles.RapidBlink;
	import visuals.scorebacks.ScoreEntryPlain;
	import visuals.tilestyles.ShadedCircle;
	import visuals.tilestyles.ShadedSquare;
	
	public dynamic class Settings
	{
		public static const MAX_GAMES:uint = 80;
		public static const MAX_MESSAGE:String = "No room left for more game modes! You must delete a mode in order to add a new one.";
		
		// Titles
		public static const MAX_TITLE_LEN:uint = 20;
		public static const MAX_DESC_LEN:uint = 200;//125;
		public static const DEFAULT_AUTHOR:String = "Default Mode";
		public static const DEFAULT_EDITER:String = "Default Mode";
		
		// Style settings
		public static const MAX_VSTYLES:uint = 1; //TODO: 1 for now, but will be more later...actually, no.
		public static const INEXT_STYLES:Array = [INextBox1];
		public static const NEXT_STYLES:Array = [NextBox1];
		public static const HOLD_STYLES:Array = [HoldBox1];
		
		public static const SONG_CHOICES:Array = [SongList.Zero, SongList.WalkingontheAir, SongList.Summertime, SongList.StopAndGo];
		public static const SONG_NAMES:Array = ["Zero (Korobeiniki Remix)", "Walking on the Air", "Summ3rtime", "Stop & Go (Ubiktune Edit)"];
		
		// Visual settings
		public static const S_SIDE_LEFT:int = -1;
		public static const S_SIDE_CENTRE:int = 0;
		public static const S_SIDE_RIGHT:int = 1;
		
		public static const GBG_TYPES:Array = [GBGPlain];
		public static const SCORE_TYPES:Array = [ScoreEntryPlain];
		
		public static const COLORS_PICK:Array = [0xFFFFFF, 0x666666, 0x333333, 0, 0x660000, 0xFF00FF, 0xFF0000, 0xFF6600, 0xFFFF00, 0x00FF00, 0x00FFFF, 0x0098FF, 0x00066FF];
		
		// Piece data
		public static const MAX_NUM_PIECES:uint = 50;
		public static const MAX_NUM_TILES:uint = 10;
		
		// Per-piece appearances
		public static const APP_STYLES:Array = [ShadedSquare, ShadedCircle, null];
		public static const APP_NAMES:Array = ["Shaded Square", "Shaded Circle", "Plain Square"];
		public static const CLEAR_STYLES:Array = [Blink, RapidBlink];
		public static const CLEAR_NAMES:Array = ["Blink", "Rapid Blink"];
		
		public static const MAX_PIECE_LIKE:uint = 20;
		public static const MAX_PIECE_FREQ:uint = 20;
		
		// Tiles
		public static const MAX_NEXTNUM:uint = 10;
		public static const MAX_BINX:uint = 30;
		public static const MAX_BINY:uint = 50;
		
		public static const OVERFLOW_BOT:int = 1;
		public static const OVERFLOW_TOP:int = -1;
		
		public static const SHADOW_ALPHA:Number = 0.75;
		
		// Controls
		public static const MIN_RESPTIME:uint = 0;
		public static const MAX_RESPTIME:uint = 2000;
		public static const STEP_RESPTIME:uint = 100;
		public static const MIN_CTIME:uint = 0;
		public static const MAX_CTIME:uint = 5000;
		public static const STEP_CTIME:uint = 100;
		
		// Other?
		public static const MAX_NUM_LEVELS = 100;
		public static const TIME_WARNING:uint = 10;
		
		public static const MIN_F:Number = 0; //Note: A (second or frame) delay of 0 in a FrameTimer is the same as an EnterFrame.
		public static const MAX_F:Number = 10000;
		public static const STEP_F:Number = 100;
		
		public static const MIN_FCF:Number = 0.5;
		public static const MAX_FCF:Number = 4;
		public static const STEP_FCF:Number = 0.5;
		
		// Scoring
		public static const MAXSCORE:uint = 100000000;
		public static const MAXTIME:uint = 3600;
		public static const MAX_SCOREUP:uint = 1000000;
		public static const MAX_SCOREUPTINY:uint = 1000; //For smaller things.
		public static const MAX_NUM_LIVES:uint = 10;
		public static const MAX_NUM_CHANCES:uint = 10;
		public static const MAX_LEVELUPREQ:uint = 1000;
		
		public static const L_NUMCLEARS:uint = 0;
		public static const L_TILECLEARS:uint = 1;
		public static const L_PIECESETS:uint = 2;
		public static const L_TILESETS:uint = 3;
		public static const L_TIME:uint = 4;
		public static const L_SCORE:uint = 5;
		
		public static const MIN_LEVELMULT:Number = 0;
		public static const MAX_LEVELMULT:Number = 10;
		public static const STEP_LEVELMULT:Number = 0.1;
		
		public static const MAX_BONUSCOUNT:uint = 20;
		public static const MIN_BONUS:Number = 0.1;
		public static const MAX_BONUS:Number = 10;
		public static const STEP_BONUS:Number = 0.1;
		
		public static const MIN_ZONEMULT:Number = 0;
		public static const MAX_ZONEMULT:Number = 10;
		public static const STEP_ZONEMULT:Number = 0.1;
		
		public static const MIN_TIMELIMIT:uint = 5;
		public static const MAX_TIMELIMIT:uint = 1800;
		
		//High score records
		public static const NUM_SCORES:uint = 10; //Number of high score entries saved
		public static const NET_SCORE_COLOR:uint = 0xFF9900; //Colour to use for text that indicates linked scores.
		
		public function Settings()
		{
			this[SettingNames.LOCKED] = false;
			this[SettingNames.FILEID] = 0;
			
			this[SettingNames.GTITLE] = "New Mode";
			this[SettingNames.GCOL] = 0xFF0000;
			this[SettingNames.GTCOL] = 0xFFFFFF;
			this[SettingNames.GDESC] = "A custom mode.";
			this[SettingNames.GAUTHOR] = DEFAULT_AUTHOR;
			this[SettingNames.GEDITER] = DEFAULT_EDITER;
			
			this[SettingNames.VSTYLE] = 0;
			this[SettingNames.PLAYPOS] = S_SIDE_CENTRE;
			this[SettingNames.GBG_TYPE] = 0; //
			this[SettingNames.SCORE_TYPE] = 0; //
			this[SettingNames.SONG_TYPE] = 0;
			
			this[SettingNames.PIECES] = [4];
			this[SettingNames.PPROPS] = [[4,4]];
			this[SettingNames.PCOL] = [[0xFF0000, 0x00FF00, 0xFF6600, 0xFFFFFF, 0xFFFF00, 0xFF00FF, 0x00FFFF]]; //multi-dim for random, single for custom
			this[SettingNames.PAPP] = [0];
			
			this[SettingNames.PCLEAR] = 0;//:Array = [0];
			this[SettingNames.ORDERED] = false;
			this[SettingNames.PLIKE] = [[1]];
			this[SettingNames.PORDER] = [[0,1]];
			
			this[SettingNames.NEXTNUM] = 4;
			this[SettingNames.BINX] = 7;
			this[SettingNames.BINY] = 20;
			this[SettingNames.BORCOL] = 0;
			this[SettingNames.SHADOWS] = true;
			this[SettingNames.INVISIBLE] = false; //invisible during control
			this[SettingNames.INVISILAND] = false; //invisible after landing
			this[SettingNames.SZONE] = 0;
			this[SettingNames.DZONE] = 5;
			this[SettingNames.SCOL] = 0xFFFF00;
			this[SettingNames.DCOL] = 0xFF0000;
			this[SettingNames.BGCOL] = 0x0098FF;
			this[SettingNames.BINAPP] = 0; //Appearance of bin tiles. = index of APP_TILES to use.
			this[SettingNames.BINCOL] = 0x666666;
			
			this[SettingNames.RESPSLI] = 300; //auto-scroll response time for sliding, in milliseconds
			this[SettingNames.SPEEDSLI] = 1; //auto-scroll speed for sliding, in frames: high number = slow
			this[SettingNames.RCW] = true;
			this[SettingNames.RCCW] = true;
			this[SettingNames.RESPROT] = 300; //a-s response for turning, in millis
			this[SettingNames.SPEEDROT] = 1; //a-s speed for turning, in frames
			
			this[SettingNames.HOLDABLE] = true;
			this[SettingNames.WALLKICK] = true;
			this[SettingNames.FLOORKICK] = true;
			this[SettingNames.LANDKICK] = false;
			this[SettingNames.CEILKICK] = true;
			this[SettingNames.SQUEEZE] = true;
			this[SettingNames.ROTCEN] = true; //Centre a rotated piece
			this[SettingNames.DROP] = true; //Allow/ban soft drop key
			this[SettingNames.INST] = true; //Allow/ban instant drop key
			this[SettingNames.TOPLOCK] = false;
			this[SettingNames.SPAWNTYPE] = -1; //DID: force bottom overflow if toplock is true!
			this[SettingNames.SPAWNPOSY] = 19; //DID: In Settings, decrease this if biny decreases!
			this[SettingNames.SAFESHIFT] = false; //move piece left/right on spawn if there's no room
			this[SettingNames.TOPSHIFT] = false; //move piece up on spawn if there's no room
			this[SettingNames.XSFIRST] = false;  //inactive UNLESS *both* safeshift and topshift are true
			this[SettingNames.SPAWNAFTERCLEAR] = true; //can't have this AND combo both true! the latter meaning !freeze. but both can be false.
			
			this[SettingNames.FITMODE] = false; //If false, Fall Mode (standard). If true, Fit Mode (4-way movement).
			this[SettingNames.FITPASS] = true; //If true, can move blocks through set tiles
			this[SettingNames.FITFORCE] = true; //If true, forced fit on overlap causes non-overlapped tiles to stay. False, piece disappears.
			
			this[SettingNames.LEVELMAX] = 9;
			this[SettingNames.LEVELMAXWIN] = false; //If true, reaching the max level will win the game.
			this[SettingNames.FA] = [900]; //fall speed per level OR time until forced fit per level
			this[SettingNames.FARR] = false; //if false, fa[0] just provides the starting speed, and fa[1...] are unused
			this[SettingNames.FDEC] = 100; //if farr is true, speed decrement (makes faster)
			this[SettingNames.FMIN] = MIN_F; //maximum speed (if farr is false)
			this[SettingNames.CWID] = 7; //clear width
			this[SettingNames.CLEN] = 1; //clear length
			this[SettingNames.EXTENDABLE] = false;
			this[SettingNames.LTOR] = true; //left to right (square clear priority)
			this[SettingNames.BTOT] = true; //bottom to top
			this[SettingNames.CLEARDROP] = true;
			this[SettingNames.GRAVITY] = false; //gravity on loose blocks
			this[SettingNames.LUMP] = false; //adjacent blocks "connect"
			this[SettingNames.FCF] = 2; //fall chain fraction: gravity blocks fall with speed of standard fall speed / this.
			this[SettingNames.CTIME] = 1300; //time for flashing pieces to be cleared, in milliseconds
			this[SettingNames.FREEZE] = true; //if game freeze after a clear
			this[SettingNames.CRESET] = true; //if additional clears cause clear time to reset
			this[SettingNames.TIMELIMIT] = 0;
			this[SettingNames.LIVES] = 0;
			this[SettingNames.FITCHANCES] = 0; //in Fit Mode only: # of bad forced fits until screen clear/game over.
			this[SettingNames.SCOREPEN] = false;
			this[SettingNames.LEVELPEN] = false;
			
			this[SettingNames.POINTC_T] = true; //True if points per clear, false if points per tile. (Latter only possible for box clears? Nah.)
			this[SettingNames.CLEARPOINTS] = [40, 100, 300, 1200]; //Points per HEIGHT of LINE GROUP, *or* per NUMBER of BOXES.
			this[SettingNames.TILEPOINTS] = 0; //Points per tile (only for BOX clears? uh how about not, I'm lazy.). Mutually exclusive with clearpoints!
			
			this[SettingNames.LEVELMULTARR] = false; //If true, use the array instead of the single value
			this[SettingNames.LEVELMULT] = 1; //Multiply score additions by level * this number
			this[SettingNames.LEVELMULTA] = [1]; //Mult score add's by entry of this per level
			
			this[SettingNames.LEVELUPREQ] = L_NUMCLEARS; //What type of value must be reached to a level up
			this[SettingNames.LEVELUPA] = [10]; //Custom level milestones
			
			this[SettingNames.SOFTBONUS] = 1; //points per "tick" during soft drop
			this[SettingNames.HARDBONUS] = 2; //points for each unit of drop of a hard drop
			this[SettingNames.SETBONUS] = 0; //points (per tile or piece) for setting a piece
			this[SettingNames.SETBONUSP_T] = true; //award set points per piece (true) or tile (false)
			
			this[SettingNames.TLVLUPBONUS] = [0]; //How much time to add on a level up
			this[SettingNames.TPOINTC_T] = true; //Like pointc_t, but for time bonuses.
			this[SettingNames.TCLEARBONUS] = [0]; //How much time to add on x number of clears
			this[SettingNames.TTILEBONUS] = 0; //Time additions per tile (for BOX only?...no). Mutually exclusive with tclearbonus!
			this[SettingNames.TLEVELMULTARR] = false;
			this[SettingNames.TLEVELMULT] = 1; //Multiply time additions by level * this
			this[SettingNames.TLEVELMULTA] = [1]; //Mult time add's by entry of this per level
			
			this[SettingNames.BB_BONUS] = true; //Enable/disable back-to-back clear bonus
			this[SettingNames.BBCOMBOMOD] = [1]; //bonus for back-to-back clears
			this[SettingNames.COMBOMOD] = [1]; //bonus for multiple clears during same clear period (only when no freeze). NOTE: combomod[0] is for x2 combo!!!
			this[SettingNames.GRAVCOMBOMOD] = [1]; //bonus for gravity clears
			
			this[SettingNames.TBBCOMBOMOD] = [1];
			this[SettingNames.TCOMBOMOD] = [1];
			this[SettingNames.TGRAVCOMBOMOD] = [1];
			
			this[SettingNames.WINBONUS] = 0; //Bonus awarded for winning (reaching max level, if set as win).
			this[SettingNames.WINLIVESBONUS] = 0; //Win bonus, x # of lives remaining
			this[SettingNames.WINCHANCESBONUS] = 0; //Win bonus, x # of chances remaining (if in fit mode)
			this[SettingNames.WINTIMEBONUS] = 0; //Win bonux, x # seconds remaining (if time is allowed)
			
			this[SettingNames.DZONEMULT] = 1; //danger zone multiplier
			this[SettingNames.SZONEMULT] = 1; //safe zone multipler
			
			this[SettingNames.STAGESIDE] = 0; //-1 = left, 0 = centre, 1 = right
			
			clearScores();
		}
		
		public function get gtype():int
		{
			return _allTypes.indexOf(this);
		}
		
		//static properties
		private static var _allTypes:Vector.<Settings> = new Vector.<Settings>();
		
		/**
		 * Returns the number of how many game types currently exist.
		 */
		public static function get numtypes():int
		{
			return _allTypes.length;
		}
		
		/**
		 * [read-only] Returns the currently active game mode. (Set the game mode with the setGameType function.)
		 */
		private static var _currentGame:Settings;
		public static function get currentGame():Settings
		{
			return _currentGame;
		}
		public static function clearType():void
		{
			_currentGame = null;
		}
		
		/**
		 * Set the current selected game type by index. Also return the selected Settings instance.
		 * @param	gameType The index of the game type to choose.
		 * @return	The game type that is now set as the current game type.
		 */
		public static function setGameType(gameType:uint):Settings
		{
			if (gameType >= numtypes)
				return null;
			
			return _currentGame = _allTypes[gameType];
		}
		
		/**
		 * Set the current selected game type to a Settings instance.
		 * @param	gameType The game to set as the current one.
		 */
		public static function setGameTypeForced(gameType:Settings):void
		{
			_currentGame = gameType;
		}
		
		/**
		 * Returns the specified game type Settings instance by index.
		 * @param	gameType The index of the game type to get.
		 * @return	The requested game type.
		 */
		public static function getGameType(gameType:uint):Settings
		{
			return _allTypes[gameType];
		}
		
		/**
		 * Add a game type to the list of game types.
		 * @param	gtype The index of the new type. Set to -1 to add the type to the end of the types list.
		 */
		internal static function addGameType(cs:Settings, gtype:int = -1):void
		{
			if (gtype < 0 || gtype > numtypes)
				_allTypes.push(cs);
			else
				_allTypes.splice(gtype, 0, cs);
		}
		
		internal static function removeGameType(cs:Settings):void
		{
			_allTypes.splice(_allTypes.indexOf(cs), 1);
		}
		
		internal static function removeAllGameTypes():void
		{
			_allTypes = new Vector.<Settings>();
		}
		
		/**
		 * Create and return a new game type that is a copy of an existing one. The copy will inherit the author of the provided mode.
		 * @param	cs The game type to copy. If the type is null, a new game type will be returned.
		 * @param	clear_scores If true, scores for the new mode will be reset. Otherwise, its high scores will be copied from the provided mode.
		 * @param	no_lock If true, the new mode will be unlocked instead of inheriting the copied mode's lock.
		 * @param	reset_file If true, the new mode will not link to any publicly shared SaveFile ID.
		 * @return	A proper copy of the provided game type.
		 */
		public static function copyGameType(cs:Object, clear_scores:Boolean, no_lock:Boolean, reset_file:Boolean):Settings
		{
			var ds:Settings = new Settings();
			ds.copySettingsOf(cs, clear_scores, no_lock, reset_file);
			ds[SettingNames.GAUTHOR] = cs[SettingNames.GAUTHOR];
			
			return ds;
		}
		
		/**
		 * Copy the settings of another mode to this one. This mode's author will NOT be changed.
		 * @param	props An object containing all properties of the game type to copy.
		 * @param	clear_scores If true, scores for the new mode will be reset. Otherwise, its high scores will be copied from the provided mode.
		 * @param	no_lock If true, the new mode will be unlocked instead of inheriting the copied mode's lock.
		 * @param	reset_file If true, the new mode will not link to any publicly shared SaveFile ID.
		 */
		public function copySettingsOf(cs:Object, clear_scores:Boolean, no_lock:Boolean, reset_file):void
		{
			var key:String;
			//Reset this Settings instance
			/*for (key in this)
				delete this[key];*/
			
			//Treat certain properties differently; don't iterate over them.
			var pprops:Array = cs[SettingNames.PPROPS];
			delete cs[SettingNames.PPROPS];
			
			var hiscorelist:Array = cs[SettingNames.HISCORELIST];
			var initiallist:Array = cs[SettingNames.INITIALLIST];
			var ngscorelist:Array = cs[SettingNames.NGSCORELIST];
			delete cs[SettingNames.HISCORELIST];
			delete cs[SettingNames.INITIALLIST];
			delete cs[SettingNames.NGSCORELIST];
			
			var gauthor:String = cs[SettingNames.GAUTHOR];
			delete cs[SettingNames.GAUTHOR];
			
			//Copy all standard properties.
			for (key in cs)
			{
				if (cs[key] is Array)
					G.arrayCopy2D(this[key] = [], cs[key]);
				else
					this[key] = cs[key];
			}
			
			//Copy & restore special properties.
			G.arrayCopy3D(this[SettingNames.PPROPS] = [], pprops);
			cs[SettingNames.PPROPS] = pprops;
			
			clearScores();
			if (!clear_scores)
			{
				this[SettingNames.HISCORELIST] = hiscorelist.slice();
				this[SettingNames.INITIALLIST] = initiallist.slice();
				this[SettingNames.NGSCORELIST] = ngscorelist.slice();
			}
			cs[SettingNames.HISCORELIST] = hiscorelist;
			cs[SettingNames.INITIALLIST] = initiallist;
			cs[SettingNames.NGSCORELIST] = ngscorelist;
			
			if (no_lock)
				this[SettingNames.LOCKED] = false;
			
			if (reset_file)
				this[SettingNames.FILEID] = 0;
			
			cs[SettingNames.GAUTHOR] = gauthor;
		}
		
		public function clearScores():void
		{
			this[SettingNames.HISCORELIST] = [];
			this[SettingNames.INITIALLIST] = [];
			this[SettingNames.NGSCORELIST] = [];
			
			for (var i:uint = 0; i < NUM_SCORES; i++)
			{
				this[SettingNames.HISCORELIST][i] = 0;
				this[SettingNames.INITIALLIST][i] = null;
				this[SettingNames.NGSCORELIST][i] = false;
			}
		}
		
		public function netLinkAllScores():void
		{
			for (var i:uint = 0; i < NUM_SCORES; i++)
				this[SettingNames.NGSCORELIST][i] = true;
		}
	}
}