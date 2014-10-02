package data
{
	import flash.ui.Keyboard;
	import media.sounds.SongList;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class DefaultSettings
	{
		//Piece maps use positive Cartesian coordinates for x/y points. That means up is +y!
		public static const PIECE_I:Array = [0, 0, 1, 0, 2, 0, 3, 0];
		public static const PIECE_L:Array = [0, 0, 1, 0, 2, 0, 2, 1];
		public static const PIECE_RL:Array = [0, 1, 0, 0, 1, 0, 2, 0];
		public static const PIECE_T:Array = [0, 0, 1, 0, 2, 0, 1, 1];
		public static const PIECE_Z:Array = [0, 1, 1, 1, 1, 0, 2, 0];
		public static const PIECE_S:Array = [2, 1, 1, 1, 1, 0, 0, 0];
		public static const PIECE_O:Array = [0, 0, 0, 1, 1, 1, 1, 0];
		
		private static const T:Boolean = true;
		private static const F:Boolean = false;
		public static const DIRS_I:Array = [[F, T, F, F], [F, T, F, T], [F, T, F, T], [F, F, F, T]];
		public static const DIRS_L:Array = [[F, T, F, F], [F, T, F, T], [T, F, F, T], [F, F, T, F]];
		public static const DIRS_RL:Array = [[F, F, T, F], [T, T, F, F], [F, T, F, T], [F, F, F, T]];
		public static const DIRS_T:Array = [[F, T, F, F], [T, T, F, T], [F, F, F, T], [F, F, T, F]];
		public static const DIRS_Z:Array = [[F, T, F, F], [F, F, T, T], [T, T, F, F], [F, F, F, T]];
		public static const DIRS_S:Array = [[F, F, F, T], [F, T, T, F], [T, F, F, T], [F, T, F, F]];
		public static const DIRS_O:Array = [[T, T, F, F], [F, T, T, F], [F, F, T, T], [T, F, F, T]];
		
		public static const COLORS_STND:Array = [0xFF0000, 0x00FF00, 0xFF6600, 0xFFFFFF, 0xFFFF00, 0xFF00FF, 0x00FFFF]; //MUST have exactly 7 colors.
		
		/**
		 * Reset all/the current key setting(s) to the default configuration.
		 * @param	reset
		 */
		public static function setDefaultKeys(reset:Boolean):void
		{
			var ks:KeySettings;
			if (reset)
			{
				ks = KeySettings.addKeyConfig();
				KeySettings.getKeyConfig(0, true);
			}
			else
				ks = KeySettings.currentConfig;
			
			ks.ktitle = "Default";
			
			ks.k_right = Keyboard.RIGHT;
			ks.k_left = Keyboard.LEFT;
			ks.k_up = Keyboard.UP;
			ks.k_down = Keyboard.DOWN;
			ks.k_rotcw = 88; //X
			ks.k_rotccw = 90; //Z
			ks.k_hold = Keyboard.SHIFT; //SHIFT
			ks.k_place = Keyboard.ENTER; //ENTER
			ks.k_pause = Keyboard.ESCAPE; //P
			
			ks.name_right = KeySettings.getAllowableName(ks.k_right);
			ks.name_left = KeySettings.getAllowableName(ks.k_left);
			ks.name_up = KeySettings.getAllowableName(ks.k_up);
			ks.name_down = KeySettings.getAllowableName(ks.k_down);
			ks.name_rotcw = KeySettings.getAllowableName(ks.k_rotcw);
			ks.name_rotccw = KeySettings.getAllowableName(ks.k_rotccw);
			ks.name_hold = KeySettings.getAllowableName(ks.k_hold);
			ks.name_place = KeySettings.getAllowableName(ks.k_place);
			ks.name_pause = KeySettings.getAllowableName(ks.k_pause);
			
			SaveData.saveKeySetting(ks, -1);
			SaveData.flush();
		}
		
		public static function setDefaultSettings():void
		{
			var cs:Settings;
			
			
			//----------STANDARD----------//
			
			cs = new Settings();
			cs[SettingNames.LOCKED] = true;
			Settings.addGameType(cs);
			
			cs[SettingNames.GTITLE] = "Standard";
			cs[SettingNames.GCOL] = 0xFF0000;
			cs[SettingNames.GTCOL] = 0x000000;
			cs[SettingNames.GDESC] = "A standard game of Tetris. Arrange tiles in lines to clear them and rack up points!";
			
			cs[SettingNames.PIECES] = [PIECE_I, PIECE_L, PIECE_RL, PIECE_T, PIECE_Z, PIECE_S, PIECE_O];
			cs[SettingNames.PPROPS] = [DIRS_I, DIRS_L, DIRS_RL, DIRS_T, DIRS_Z, DIRS_S, DIRS_O];
			
			cs[SettingNames.PAPP] = [0, 0, 0, 0, 0, 0, 0];
			cs[SettingNames.PCLEAR] = 0;
			cs[SettingNames.PLIKE] = [[1, 1, 1, 1, 1, 1, 1]]; //multi-dimensional, per level
			cs[SettingNames.PCOL] = COLORS_STND; //multi-dim for random, single for custom
			cs[SettingNames.NEXTNUM] = 1;
			cs[SettingNames.BINX] = 7;
			cs[SettingNames.BINY] = 20;
			cs[SettingNames.BORCOL] = -1;
			cs[SettingNames.SHADOWS] = false;
			cs[SettingNames.INVISIBLE] = false;
			cs[SettingNames.INVISILAND] = false;
			cs[SettingNames.SZONE] = 0;
			cs[SettingNames.DZONE] = 5;
			cs[SettingNames.SCOL] = 0xFFCC00;
			cs[SettingNames.DCOL] = 0xFF0000;
			cs[SettingNames.BGCOL] = 0x0098FF;
			cs[SettingNames.BINAPP] = 0;
			cs[SettingNames.BINCOL] = 0x666666;
			
			cs[SettingNames.RESPSLI] = -1; //auto-scroll response time for sliding
			cs[SettingNames.RCW] = true;
			cs[SettingNames.RCCW] = true;
			cs[SettingNames.RESPROT] = -1; //a-s response for turning
			
			cs[SettingNames.HOLDABLE] = false;
			cs[SettingNames.WALLKICK] = false;
			cs[SettingNames.FLOORKICK] = false;
			cs[SettingNames.LANDKICK] = false;
			cs[SettingNames.CEILKICK] = false;
			cs[SettingNames.SQUEEZE] = false;
			cs[SettingNames.ROTCEN] = true;
			cs[SettingNames.INST] = false;
			cs[SettingNames.TOPLOCK] = false;
			cs[SettingNames.SPAWNTYPE] = Settings.OVERFLOW_TOP;
			cs[SettingNames.SPAWNPOSY] = cs[SettingNames.BINY] - 1;
			cs[SettingNames.SAFESHIFT] = false;
			cs[SettingNames.TOPSHIFT] = false;
			cs[SettingNames.XSFIRST] = false;
			cs[SettingNames.SPAWNAFTERCLEAR] = true;
			
			cs[SettingNames.LEVELMAX] = 9;
			cs[SettingNames.FA] = [1000];
			cs[SettingNames.FARR] = false;
			cs[SettingNames.FDEC] = 100;
			cs[SettingNames.CWID] = cs[SettingNames.BINX];
			cs[SettingNames.CLEN] = 1;
			cs[SettingNames.CLEARDROP] = true;
			cs[SettingNames.GRAVITY] = false;
			cs[SettingNames.LUMP] = false;
			cs[SettingNames.CTIME] = 1300;
			cs[SettingNames.FREEZE] = true;
			cs[SettingNames.TIMELIMIT] = 0;
			cs[SettingNames.LIVES] = 0;
			cs[SettingNames.SCOREPEN] = false;
			cs[SettingNames.LEVELPEN] = false;
			
			cs[SettingNames.CLEARPOINTS] = [40, 100, 300, 1200];
			cs[SettingNames.TILEPOINTS] = 0;
			
			cs[SettingNames.LEVELMULT] = 1;
			cs[SettingNames.LEVELUPREQ] = Settings.L_NUMCLEARS;
			cs[SettingNames.LEVELUPA] = [10];
			cs[SettingNames.SOFTBONUS] = 1;
			cs[SettingNames.HARDBONUS] = 2;
			
			cs[SettingNames.BB_BONUS] = false;
			
			cs[SettingNames.STAGESIDE] = Settings.S_SIDE_LEFT;
			
			
			//----------ENHANCED----------//
			
			cs = new Settings();
			cs[SettingNames.LOCKED] = true;
			Settings.addGameType(cs);
			
			cs[SettingNames.GTITLE] = "Enhanced";
			cs[SettingNames.GCOL] = 0xFF9900;
			cs[SettingNames.GTCOL] = 0x000000;
			cs[SettingNames.GDESC] = "A standard 4-tile game, but with a few extra enhancements, like instant drops and gravity.";
			
			cs[SettingNames.PIECES] = [PIECE_I, PIECE_L, PIECE_RL, PIECE_T, PIECE_Z, PIECE_S, PIECE_O];
			cs[SettingNames.PPROPS] = [DIRS_I, DIRS_L, DIRS_RL, DIRS_T, DIRS_Z, DIRS_S, DIRS_O];
			
			cs[SettingNames.PAPP] = [0, 0, 0, 0, 0, 0, 0];
			cs[SettingNames.PCLEAR] = 0;
			cs[SettingNames.PLIKE] = [[1, 1, 1, 1, 1, 1, 1]]; //multi-dimensional, per level
			cs[SettingNames.PCOL] = COLORS_STND; //multi-dim for random, single for custom
			cs[SettingNames.NEXTNUM] = 7;
			cs[SettingNames.BINX] = 7;
			cs[SettingNames.BINY] = 20;
			cs[SettingNames.BORCOL] = 0;
			cs[SettingNames.SHADOWS] = true;
			cs[SettingNames.INVISIBLE] = false;
			cs[SettingNames.INVISILAND] = false;
			cs[SettingNames.SZONE] = 0;
			cs[SettingNames.DZONE] = 5;
			cs[SettingNames.SCOL] = 0xFFCC00;
			cs[SettingNames.DCOL] = 0xFF0000;
			cs[SettingNames.BGCOL] = 0x0098FF;
			cs[SettingNames.BINAPP] = 0;
			cs[SettingNames.BINCOL] = 0x666666;
			
			cs[SettingNames.RESPSLI] = 300; //auto-scroll response time for sliding
			cs[SettingNames.SPEEDSLI] = 1; //auto-scroll speed for sliding: high number = slow
			cs[SettingNames.RCW] = true;
			cs[SettingNames.RCCW] = true;
			cs[SettingNames.RESPROT] = -1; //a-s response for turning
			
			cs[SettingNames.HOLDABLE] = true;
			cs[SettingNames.WALLKICK] = true;
			cs[SettingNames.FLOORKICK] = true;
			cs[SettingNames.LANDKICK] = true;
			cs[SettingNames.CEILKICK] = true;
			cs[SettingNames.SQUEEZE] = true;
			cs[SettingNames.ROTCEN] = true;
			cs[SettingNames.INST] = true;
			cs[SettingNames.TOPLOCK] = false;
			cs[SettingNames.SPAWNTYPE] = Settings.OVERFLOW_TOP;
			cs[SettingNames.SPAWNPOSY] = cs[SettingNames.BINY] - 1;
			cs[SettingNames.SAFESHIFT] = false;
			cs[SettingNames.TOPSHIFT] = false;
			cs[SettingNames.XSFIRST] = false;
			cs[SettingNames.SPAWNAFTERCLEAR] = true;
			
			cs[SettingNames.FITMODE] = false;
			
			cs[SettingNames.LEVELMAX] = 9;
			cs[SettingNames.FA] = [1000];
			cs[SettingNames.FARR] = false;
			cs[SettingNames.FDEC] = 100;
			cs[SettingNames.CWID] = cs[SettingNames.BINX];
			cs[SettingNames.CLEN] = 1;
			cs[SettingNames.CLEARDROP] = true;
			cs[SettingNames.GRAVITY] = true;
			cs[SettingNames.LUMP] = false;
			cs[SettingNames.FCF] = 2;
			cs[SettingNames.CTIME] = 1300;
			cs[SettingNames.FREEZE] = true;
			cs[SettingNames.TIMELIMIT] = 0;
			cs[SettingNames.LIVES] = 0;
			cs[SettingNames.SCOREPEN] = false;
			cs[SettingNames.LEVELPEN] = false;
			
			cs[SettingNames.CLEARPOINTS] = [40, 100, 300, 1200];
			cs[SettingNames.TILEPOINTS] = 0;
			
			cs[SettingNames.LEVELMULT] = 1;
			cs[SettingNames.LEVELUPREQ] = Settings.L_NUMCLEARS;
			cs[SettingNames.LEVELUPA] = [10];
			cs[SettingNames.SOFTBONUS] = 1;
			cs[SettingNames.HARDBONUS] = 2;
			
			cs[SettingNames.BB_BONUS] = true;
			cs[SettingNames.BBCOMBOMOD] = [2, 3];
			cs[SettingNames.GRAVCOMBOMOD] = [2, 3, 4];
			
			cs[SettingNames.STAGESIDE] = Settings.S_SIDE_RIGHT;
			
			
			//----------PENTRIS----------//
			
			cs = new Settings();
			cs[SettingNames.LOCKED] = true;
			Settings.addGameType(cs);
			
			cs[SettingNames.GTITLE] = "Pentris";
			cs[SettingNames.GCOL] = 0x32CCFF;
			cs[SettingNames.GTCOL] = 0x000000;
			cs[SettingNames.GDESC] = "The same as Enhanced mode, but with 5-tile pieces. It's tougher than you think!";
			
			cs[SettingNames.PIECES] = [5];
			cs[SettingNames.PPROPS] = [[5,5]];
			
			cs[SettingNames.PAPP] = [0];
			cs[SettingNames.PCLEAR] = 0;
			cs[SettingNames.PLIKE] = [[1]]; //multi-dimensional, per level
			cs[SettingNames.PCOL] = [COLORS_STND]; //multi-dim for random, single for custom
			cs[SettingNames.NEXTNUM] = 7;
			cs[SettingNames.BINX] = 7;
			cs[SettingNames.BINY] = 20;
			cs[SettingNames.BORCOL] = 0;
			cs[SettingNames.SHADOWS] = true;
			cs[SettingNames.INVISIBLE] = false;
			cs[SettingNames.INVISILAND] = false;
			cs[SettingNames.SZONE] = 0;
			cs[SettingNames.DZONE] = 5;
			cs[SettingNames.SCOL] = 0xFFCC00;
			cs[SettingNames.DCOL] = 0xFF0000;
			cs[SettingNames.BGCOL] = 0x0098FF;
			cs[SettingNames.BINAPP] = 0;
			cs[SettingNames.BINCOL] = 0x666666;
			
			cs[SettingNames.RESPSLI] = 300; //auto-scroll response time for sliding
			cs[SettingNames.SPEEDSLI] = 1; //auto-scroll speed for sliding: high number = slow
			cs[SettingNames.RCW] = true;
			cs[SettingNames.RCCW] = true;
			cs[SettingNames.RESPROT] = -1; //a-s response for turning
			
			cs[SettingNames.HOLDABLE] = true;
			cs[SettingNames.WALLKICK] = true;
			cs[SettingNames.FLOORKICK] = true;
			cs[SettingNames.LANDKICK] = true;
			cs[SettingNames.CEILKICK] = true;
			cs[SettingNames.SQUEEZE] = true;
			cs[SettingNames.ROTCEN] = true;
			cs[SettingNames.INST] = true;
			cs[SettingNames.TOPLOCK] = false;
			cs[SettingNames.SPAWNTYPE] = Settings.OVERFLOW_TOP;
			cs[SettingNames.SPAWNPOSY] = cs[SettingNames.BINY] - 1;
			cs[SettingNames.SAFESHIFT] = true;
			cs[SettingNames.TOPSHIFT] = true;
			cs[SettingNames.XSFIRST] = false;
			cs[SettingNames.SPAWNAFTERCLEAR] = true;
			
			cs[SettingNames.FITMODE] = false;
			
			cs[SettingNames.LEVELMAX] = 9;
			cs[SettingNames.FA] = [1000];
			cs[SettingNames.FARR] = false;
			cs[SettingNames.FDEC] = 100;
			cs[SettingNames.CWID] = cs[SettingNames.BINX];
			cs[SettingNames.CLEN] = 1;
			cs[SettingNames.CLEARDROP] = true;
			cs[SettingNames.GRAVITY] = true;
			cs[SettingNames.LUMP] = false;
			cs[SettingNames.FCF] = 2;
			cs[SettingNames.CTIME] = 1300;
			cs[SettingNames.FREEZE] = true;
			cs[SettingNames.TIMELIMIT] = 0;
			cs[SettingNames.LIVES] = 0;
			cs[SettingNames.SCOREPEN] = false;
			cs[SettingNames.LEVELPEN] = false;
			
			cs[SettingNames.CLEARPOINTS] = [40, 100, 300, 1200, 3000];
			cs[SettingNames.TILEPOINTS] = 0;
			
			cs[SettingNames.LEVELMULT] = 1;
			cs[SettingNames.LEVELUPREQ] = Settings.L_NUMCLEARS;
			cs[SettingNames.LEVELUPA] = [5];
			cs[SettingNames.SOFTBONUS] = 1;
			cs[SettingNames.HARDBONUS] = 2;
			
			cs[SettingNames.BB_BONUS] = true;
			cs[SettingNames.BBCOMBOMOD] = [2, 3];
			cs[SettingNames.GRAVCOMBOMOD] = [2, 3, 4];
			
			cs[SettingNames.STAGESIDE] = Settings.S_SIDE_CENTRE;
			
			
			//----------MULTI-BLOCK----------//
			
			cs = new Settings();
			cs[SettingNames.LOCKED] = true;
			Settings.addGameType(cs);
			
			cs[SettingNames.GTITLE] = "Multi-Block";
			cs[SettingNames.GCOL] = 0x6600FF;
			cs[SettingNames.GTCOL] = 0xFFFFFF;
			cs[SettingNames.GDESC] = "The number of blocks increases as you clear more lines. Try to keep up!";
			
			cs[SettingNames.PIECES] = [3, 4, 5, 6, 7, 8, 9];
			cs[SettingNames.PPROPS] = [[3,3], [4,4], [5,5], [6,6], [7,7], [8,8], [9,9]];
			
			cs[SettingNames.PAPP] = [0, 0, 1, 1, 1, 1, 1];
			cs[SettingNames.PCLEAR] = 0;
			cs[SettingNames.PLIKE] = [[1, 0, 0, 0, 0, 0, 0],
						[0, 1, 0, 0, 0, 0, 0],
						[0, 0, 1, 0, 0, 0, 0],
						[0, 0, 0, 1, 0, 0, 0],
						[0, 0, 0, 0, 1, 0, 0],
						[0, 0, 0, 0, 0, 1, 0],
						[0, 0, 0, 0, 0, 0, 1]]; //multi-dimensional, per level
			//cs[SettingNames.ORDERED] = true;
			//cs[SettingNames.PORDER] = [[0,1, 3,1, 1,2]];
			cs[SettingNames.PCOL] = [COLORS_STND, COLORS_STND, COLORS_STND, COLORS_STND, COLORS_STND, COLORS_STND, COLORS_STND];
			cs[SettingNames.NEXTNUM] = 3;
			cs[SettingNames.BINX] = 10;
			cs[SettingNames.BINY] = 25;
			cs[SettingNames.BORCOL] = 0;
			cs[SettingNames.SHADOWS] = true;
			cs[SettingNames.INVISIBLE] = false;
			cs[SettingNames.INVISILAND] = false;
			cs[SettingNames.SZONE] = 3;
			cs[SettingNames.DZONE] = 8;
			cs[SettingNames.SCOL] = 0xFFCC00;
			cs[SettingNames.DCOL] = 0xFF0000;
			cs[SettingNames.BGCOL] = 0x0098FF;
			cs[SettingNames.BINAPP] = 0;
			cs[SettingNames.BINCOL] = 0x666666;
			
			cs[SettingNames.RESPSLI] = 300; //auto-scroll response time for sliding
			cs[SettingNames.SPEEDSLI] = 1; //auto-scroll speed for sliding: high number = slow
			cs[SettingNames.RCW] = true;
			cs[SettingNames.RCCW] = true;
			cs[SettingNames.RESPROT] = -1; //a-s response for turning
			
			cs[SettingNames.HOLDABLE] = true; //false
			cs[SettingNames.WALLKICK] = true; //false
			cs[SettingNames.FLOORKICK] = true; //false
			cs[SettingNames.LANDKICK] = true; //false
			cs[SettingNames.CEILKICK] = true; //false
			cs[SettingNames.SQUEEZE] = true; //false
			cs[SettingNames.ROTCEN] = true;
			cs[SettingNames.INST] = true;
			cs[SettingNames.TOPLOCK] = false; //false
			cs[SettingNames.SPAWNTYPE] = Settings.OVERFLOW_TOP;
			cs[SettingNames.SPAWNPOSY] = cs[SettingNames.BINY] - 1; //uint(cs[SettingNames.BINY] / 2)
			cs[SettingNames.SAFESHIFT] = true;
			cs[SettingNames.TOPSHIFT] = false;
			cs[SettingNames.XSFIRST] = false;
			cs[SettingNames.SPAWNAFTERCLEAR] = true;
			
			cs[SettingNames.FITMODE] = false;
			
			cs[SettingNames.FA] = [400, 500, 600, 700, 1000, 1000, 1300, 1500];
			cs[SettingNames.FARR] = true;
			cs[SettingNames.CWID] = cs[SettingNames.BINX];
			cs[SettingNames.CLEN] = 1;
			cs[SettingNames.CLEARDROP] = true;
			cs[SettingNames.GRAVITY] = false;
			cs[SettingNames.LUMP] = false;
			cs[SettingNames.FCF] = 2;
			cs[SettingNames.CTIME] = 1300;
			cs[SettingNames.FREEZE] = true;
			cs[SettingNames.CRESET] = false;
			cs[SettingNames.TIMELIMIT] = 0;
			cs[SettingNames.LIVES] = 0;
			cs[SettingNames.SCOREPEN] = false;
			cs[SettingNames.LEVELPEN] = false;
			
			cs[SettingNames.LEVELMAX] = 6;
			cs[SettingNames.CLEARPOINTS] = [40, 100, 300, 1200, 2000, 4000, 10000, 50000, 150000];
			cs[SettingNames.TILEPOINTS] = 0;
			
			cs[SettingNames.BB_BONUS] = true;
			
			cs[SettingNames.LEVELMULT] = 1;
			cs[SettingNames.LEVELUPREQ] = Settings.L_NUMCLEARS;
			cs[SettingNames.LEVELUPA] = [3, 10, 15, 20, 15, 10];
			cs[SettingNames.SOFTBONUS] = 1;
			cs[SettingNames.HARDBONUS] = 2;
			
			cs[SettingNames.BBCOMBOMOD] = [2, 3, 4, 5];
			
			cs[SettingNames.STAGESIDE] = Settings.S_SIDE_RIGHT;
			
			
			//----------3x3 CLEAR----------//
			
			cs = new Settings();
			cs[SettingNames.LOCKED] = true;
			Settings.addGameType(cs);
			
			cs[SettingNames.GTITLE] = "3x3 Clear";
			cs[SettingNames.GCOL] = 0x0000FF;
			cs[SettingNames.GTCOL] = 0xFFFFFF;
			cs[SettingNames.GDESC] = "Instead of lines, only 3x3 boxes of tiles will clear!";
			
			cs[SettingNames.PIECES] = [PIECE_I, PIECE_L, PIECE_RL, PIECE_T, PIECE_Z, PIECE_S, PIECE_O];
			cs[SettingNames.PPROPS] = [DIRS_I, DIRS_L, DIRS_RL, DIRS_T, DIRS_Z, DIRS_S, DIRS_O];
			
			cs[SettingNames.PAPP] = [0, 0, 0, 0, 0, 0, 0];
			cs[SettingNames.PCLEAR] = 0;
			cs[SettingNames.PLIKE] = [[1, 1, 1, 1, 1, 1, 1]]; //multi-dimensional, per level
			cs[SettingNames.PCOL] = COLORS_STND; //multi-dim for random, single for custom
			cs[SettingNames.NEXTNUM] = 7;
			cs[SettingNames.BINX] = 5;
			cs[SettingNames.BINY] = 20;
			cs[SettingNames.BORCOL] = 0;
			cs[SettingNames.SHADOWS] = true;
			cs[SettingNames.INVISIBLE] = false;
			cs[SettingNames.INVISILAND] = false;
			cs[SettingNames.SZONE] = 0;
			cs[SettingNames.DZONE] = 7;
			cs[SettingNames.SCOL] = 0xFFCC00;
			cs[SettingNames.DCOL] = 0xFF0000;
			cs[SettingNames.BGCOL] = 0x0098FF;
			cs[SettingNames.BINAPP] = 0;
			cs[SettingNames.BINCOL] = 0x666666;
			
			cs[SettingNames.RESPSLI] = 300; //auto-scroll response time for sliding
			cs[SettingNames.SPEEDSLI] = 1; //auto-scroll speed for sliding: high number = slow
			cs[SettingNames.RCW] = true;
			cs[SettingNames.RCCW] = true;
			cs[SettingNames.RESPROT] = -1; //a-s response for turning
			
			cs[SettingNames.HOLDABLE] = true;
			cs[SettingNames.WALLKICK] = true;
			cs[SettingNames.FLOORKICK] = true;
			cs[SettingNames.LANDKICK] = true;
			cs[SettingNames.CEILKICK] = true;
			cs[SettingNames.SQUEEZE] = true;
			cs[SettingNames.ROTCEN] = true;
			cs[SettingNames.INST] = true;
			cs[SettingNames.TOPLOCK] = false;
			cs[SettingNames.SPAWNTYPE] = Settings.OVERFLOW_TOP;
			cs[SettingNames.SPAWNPOSY] = cs[SettingNames.BINY] - 1;
			cs[SettingNames.SAFESHIFT] = false;
			cs[SettingNames.TOPSHIFT] = false;
			cs[SettingNames.XSFIRST] = false;
			cs[SettingNames.SPAWNAFTERCLEAR] = true;
			
			cs[SettingNames.FITMODE] = false;
			
			cs[SettingNames.LEVELMAX] = 9;
			cs[SettingNames.FA] = [1000];
			cs[SettingNames.FARR] = false;
			cs[SettingNames.FDEC] = 100;
			cs[SettingNames.CWID] = 3;
			cs[SettingNames.CLEN] = 3;
			cs[SettingNames.EXTENDABLE] = true;
			cs[SettingNames.CLEARDROP] = true;
			cs[SettingNames.GRAVITY] = true;
			cs[SettingNames.LUMP] = true;
			cs[SettingNames.FCF] = 2;
			cs[SettingNames.CTIME] = 1300;
			cs[SettingNames.FREEZE] = true;
			cs[SettingNames.TIMELIMIT] = 0;
			cs[SettingNames.LIVES] = 0;
			cs[SettingNames.SCOREPEN] = false;
			cs[SettingNames.LEVELPEN] = false;
			
			cs[SettingNames.CLEARPOINTS] = [200, 600, 1500, 4000, 10000];
			cs[SettingNames.TILEPOINTS] = 0;
			
			cs[SettingNames.LEVELMULT] = 1;
			cs[SettingNames.LEVELUPREQ] = Settings.L_NUMCLEARS;
			cs[SettingNames.LEVELUPA] = [10];
			cs[SettingNames.SOFTBONUS] = 1;
			cs[SettingNames.HARDBONUS] = 2;
			
			cs[SettingNames.BB_BONUS] = true;
			cs[SettingNames.BBCOMBOMOD] = [3];
			cs[SettingNames.GRAVCOMBOMOD] = [2, 3, 4];
			
			cs[SettingNames.STAGESIDE] = Settings.S_SIDE_CENTRE;
			
			
			//----------FIT MODE----------//
			
			cs = new Settings();
			cs[SettingNames.LOCKED] = true;
			Settings.addGameType(cs);
			
			cs[SettingNames.GTITLE] = "Fit Mode";
			cs[SettingNames.GCOL] = 0x009900;
			cs[SettingNames.GTCOL] = 0xFFFFFF;
			cs[SettingNames.GDESC] = "Pieces don't fall in this mode. Move them up, down, left & right and place them to clear 3x3 boxes!";
			cs[SettingNames.SONG_TYPE] = Settings.SONG_CHOICES.indexOf(SongList.WalkingontheAir);
			
			cs[SettingNames.PIECES] = [PIECE_I, PIECE_L, PIECE_RL, PIECE_T, PIECE_Z, PIECE_S, PIECE_O];
			cs[SettingNames.PPROPS] = [DIRS_I, DIRS_L, DIRS_RL, DIRS_T, DIRS_Z, DIRS_S, DIRS_O];
			
			cs[SettingNames.PAPP] = [0, 0, 0, 0, 0, 0, 0];
			cs[SettingNames.PCLEAR] = 0;
			cs[SettingNames.PLIKE] = [[1, 1, 1, 1, 1, 1, 1]]; //multi-dimensional, per level
			cs[SettingNames.PCOL] = COLORS_STND; //multi-dim for random, single for custom
			cs[SettingNames.NEXTNUM] = 7;
			cs[SettingNames.BINX] = 7;
			cs[SettingNames.BINY] = 20;
			cs[SettingNames.BORCOL] = -1;
			cs[SettingNames.SHADOWS] = true;
			cs[SettingNames.INVISIBLE] = false;
			cs[SettingNames.INVISILAND] = false;
			cs[SettingNames.SCOL] = 0xFFCC00;
			cs[SettingNames.DCOL] = 0xFF0000;
			cs[SettingNames.BGCOL] = 0x0098FF;
			cs[SettingNames.BINAPP] = 0;
			cs[SettingNames.BINCOL] = 0x666666;
			
			cs[SettingNames.RESPSLI] = 300; //auto-scroll response time for sliding
			cs[SettingNames.SPEEDSLI] = 1; //auto-scroll speed for sliding: high number = slow
			cs[SettingNames.RCW] = true;
			cs[SettingNames.RCCW] = true;
			cs[SettingNames.RESPROT] = -1; //a-s response for turning
			
			cs[SettingNames.HOLDABLE] = true;
			cs[SettingNames.WALLKICK] = true;
			cs[SettingNames.FLOORKICK] = true;
			cs[SettingNames.LANDKICK] = true;
			cs[SettingNames.CEILKICK] = true;
			cs[SettingNames.SQUEEZE] = true;
			cs[SettingNames.ROTCEN] = true;
			cs[SettingNames.INST] = true;
			cs[SettingNames.SPAWNTYPE] = Settings.OVERFLOW_TOP;
			cs[SettingNames.SPAWNPOSY] = uint(cs[SettingNames.BINY] / 2);
			cs[SettingNames.SAFESHIFT] = false;
			cs[SettingNames.TOPSHIFT] = false;
			cs[SettingNames.XSFIRST] = false;
			cs[SettingNames.SPAWNAFTERCLEAR] = true;
			
			cs[SettingNames.FITMODE] = true;
			cs[SettingNames.FITPASS] = true;
			cs[SettingNames.FITFORCE] = false;
			cs[SettingNames.FITCHANCES] = 2;
			
			cs[SettingNames.LEVELMAX] = 9;
			cs[SettingNames.FA] = [10000];
			cs[SettingNames.FARR] = false;
			cs[SettingNames.FDEC] = 1000;
			cs[SettingNames.CWID] = 3;
			cs[SettingNames.CLEN] = 3;
			cs[SettingNames.EXTENDABLE] = false;
			cs[SettingNames.CLEARDROP] = false;
			cs[SettingNames.GRAVITY] = false;
			cs[SettingNames.LUMP] = true;
			cs[SettingNames.CTIME] = 1300;
			cs[SettingNames.FREEZE] = true;
			cs[SettingNames.TIMELIMIT] = 0;
			cs[SettingNames.LIVES] = 0;
			cs[SettingNames.SCOREPEN] = false;
			cs[SettingNames.LEVELPEN] = false;
			
			cs[SettingNames.CLEARPOINTS] = [200, 600, 1500, 4000, 10000];
			cs[SettingNames.TILEPOINTS] = 0;
			
			cs[SettingNames.LEVELMULT] = 1;
			cs[SettingNames.LEVELUPREQ] = Settings.L_NUMCLEARS;
			cs[SettingNames.LEVELUPA] = [10];
			cs[SettingNames.SOFTBONUS] = 1;
			cs[SettingNames.HARDBONUS] = 2;
			cs[SettingNames.SETBONUS] = 10;
			
			cs[SettingNames.BB_BONUS] = true;
			cs[SettingNames.BBCOMBOMOD] = [3];
			
			cs[SettingNames.STAGESIDE] = Settings.S_SIDE_RIGHT;
			
			
			//----------TIME ATTACK----------//
			
			cs = new Settings();
			cs[SettingNames.LOCKED] = true;
			Settings.addGameType(cs);
			
			cs[SettingNames.GTITLE] = "Time Attack";
			cs[SettingNames.GCOL] = 0x6565FF;
			cs[SettingNames.GTCOL] = 0xFFFF00;
			cs[SettingNames.GDESC] = "Score points until time runs out! But the more you score, the more time you get!";
			
			cs[SettingNames.PIECES] = [PIECE_I, PIECE_L, PIECE_RL, PIECE_T, PIECE_Z, PIECE_S, PIECE_O];
			cs[SettingNames.PPROPS] = [DIRS_I, DIRS_L, DIRS_RL, DIRS_T, DIRS_Z, DIRS_S, DIRS_O];
			
			cs[SettingNames.PAPP] = [0, 0, 0, 0, 0, 0, 0];
			cs[SettingNames.PCLEAR] = 0;
			cs[SettingNames.PLIKE] = [[1, 1, 1, 1, 1, 1, 1]]; //multi-dimensional, per level
			cs[SettingNames.PCOL] = COLORS_STND; //multi-dim for random, single for custom
			cs[SettingNames.NEXTNUM] = 7;
			cs[SettingNames.BINX] = 7;
			cs[SettingNames.BINY] = 20;
			cs[SettingNames.BORCOL] = 0;
			cs[SettingNames.SHADOWS] = true;
			cs[SettingNames.INVISIBLE] = false;
			cs[SettingNames.INVISILAND] = false;
			cs[SettingNames.SZONE] = 5;
			cs[SettingNames.DZONE] = 5;
			cs[SettingNames.SCOL] = 0xFFCC00;
			cs[SettingNames.DCOL] = 0xFF0000;
			cs[SettingNames.BGCOL] = 0x0098FF;
			cs[SettingNames.BINAPP] = 0;
			cs[SettingNames.BINCOL] = 0x666666;
			
			cs[SettingNames.RESPSLI] = 300; //auto-scroll response time for sliding
			cs[SettingNames.SPEEDSLI] = 1; //auto-scroll speed for sliding: high number = slow
			cs[SettingNames.RCW] = true;
			cs[SettingNames.RCCW] = true;
			cs[SettingNames.RESPROT] = -1; //a-s response for turning
			
			cs[SettingNames.HOLDABLE] = true;
			cs[SettingNames.WALLKICK] = true;
			cs[SettingNames.FLOORKICK] = true;
			cs[SettingNames.LANDKICK] = true;
			cs[SettingNames.CEILKICK] = true;
			cs[SettingNames.SQUEEZE] = true;
			cs[SettingNames.ROTCEN] = true;
			cs[SettingNames.INST] = true;
			cs[SettingNames.TOPLOCK] = false;
			cs[SettingNames.SPAWNTYPE] = Settings.OVERFLOW_TOP;
			cs[SettingNames.SPAWNPOSY] = cs[SettingNames.BINY] - 1;
			cs[SettingNames.SAFESHIFT] = true;
			cs[SettingNames.TOPSHIFT] = true;
			cs[SettingNames.XSFIRST] = true;
			cs[SettingNames.SPAWNAFTERCLEAR] = true;
			
			cs[SettingNames.FITMODE] = false;
			
			cs[SettingNames.LEVELMAX] = 9;
			cs[SettingNames.FA] = [1000];
			cs[SettingNames.FARR] = false;
			cs[SettingNames.FDEC] = 100;
			cs[SettingNames.CWID] = cs[SettingNames.BINX];
			cs[SettingNames.CLEN] = 1;
			cs[SettingNames.CLEARDROP] = true;
			cs[SettingNames.GRAVITY] = true;
			cs[SettingNames.LUMP] = false;
			cs[SettingNames.FCF] = 2;
			cs[SettingNames.CTIME] = 1300;
			cs[SettingNames.FREEZE] = false;
			cs[SettingNames.CRESET] = false;
			cs[SettingNames.TIMELIMIT] = 30;
			cs[SettingNames.LIVES] = 0;
			cs[SettingNames.SCOREPEN] = false;
			cs[SettingNames.LEVELPEN] = false;
			
			cs[SettingNames.CLEARPOINTS] = [40, 100, 300, 1200];
			cs[SettingNames.TILEPOINTS] = 0;
			
			cs[SettingNames.LEVELMULT] = 1;
			cs[SettingNames.LEVELUPREQ] = Settings.L_NUMCLEARS;
			cs[SettingNames.LEVELUPA] = [10];
			cs[SettingNames.SOFTBONUS] = 1;
			cs[SettingNames.HARDBONUS] = 2;
			cs[SettingNames.SZONEMULT] = 2;
			cs[SettingNames.DZONEMULT] = 0.5;
			
			cs[SettingNames.TLVLUPBONUS] = [15];
			cs[SettingNames.TCLEARBONUS] = [3];
			cs[SettingNames.TLEVELMULTARR] = true;
			cs[SettingNames.TLEVELMULTA] = [1, 0.5, 0.3];
			
			cs[SettingNames.BB_BONUS] = true;
			cs[SettingNames.BBCOMBOMOD] = [2, 3, 4];
			cs[SettingNames.COMBOMOD] = [2, 3, 4];
			cs[SettingNames.GRAVCOMBOMOD] = [2, 3, 4];
			
			cs[SettingNames.STAGESIDE] = Settings.S_SIDE_RIGHT;
			
			
			//----------LINE CLEAR----------//
			
			cs = new Settings();
			cs[SettingNames.LOCKED] = true;
			Settings.addGameType(cs);
			
			cs[SettingNames.GTITLE] = "Line Clear";
			cs[SettingNames.GCOL] = 0xFFCC00;
			cs[SettingNames.GTCOL] = 0x000000;
			cs[SettingNames.GDESC] = "Can you score 5 Tetrises--max-sized clears with line pieces--in 2 minutes?";
			
			cs[SettingNames.PIECES] = [PIECE_I, PIECE_L, PIECE_RL, PIECE_T, PIECE_Z, PIECE_S, PIECE_O];
			cs[SettingNames.PPROPS] = [DIRS_I, DIRS_L, DIRS_RL, DIRS_T, DIRS_Z, DIRS_S, DIRS_O];
			
			cs[SettingNames.PAPP] = [0, 0, 0, 0, 0, 0, 0];
			cs[SettingNames.PCLEAR] = 0;
			cs[SettingNames.PLIKE] = [[3, 1, 1, 1, 1, 1, 1]]; //multi-dimensional, per level
			cs[SettingNames.PCOL] = COLORS_STND; //multi-dim for random, single for custom
			cs[SettingNames.NEXTNUM] = 7;
			cs[SettingNames.BINX] = 7;
			cs[SettingNames.BINY] = 30;
			cs[SettingNames.BORCOL] = -1;
			cs[SettingNames.SHADOWS] = true;
			cs[SettingNames.INVISIBLE] = false;
			cs[SettingNames.INVISILAND] = false;
			cs[SettingNames.SZONE] = 0;
			cs[SettingNames.DZONE] = 5;
			cs[SettingNames.SCOL] = 0xFFCC00;
			cs[SettingNames.DCOL] = 0xFF0000;
			cs[SettingNames.BGCOL] = 0x0098FF;
			cs[SettingNames.BINAPP] = 0;
			cs[SettingNames.BINCOL] = 0x666666;
			
			cs[SettingNames.RESPSLI] = 300; //auto-scroll response time for sliding
			cs[SettingNames.SPEEDSLI] = 1; //auto-scroll speed for sliding: high number = slow
			cs[SettingNames.RCW] = true;
			cs[SettingNames.RCCW] = true;
			cs[SettingNames.RESPROT] = -1; //a-s response for turning
			
			cs[SettingNames.HOLDABLE] = false;
			cs[SettingNames.WALLKICK] = true;
			cs[SettingNames.FLOORKICK] = true;
			cs[SettingNames.LANDKICK] = true;
			cs[SettingNames.CEILKICK] = true;
			cs[SettingNames.SQUEEZE] = true;
			cs[SettingNames.ROTCEN] = true;
			cs[SettingNames.INST] = true;
			cs[SettingNames.TOPLOCK] = false;
			cs[SettingNames.SPAWNTYPE] = Settings.OVERFLOW_TOP;
			cs[SettingNames.SPAWNPOSY] = cs[SettingNames.BINY] - 1;
			cs[SettingNames.SAFESHIFT] = true;
			cs[SettingNames.TOPSHIFT] = true;
			cs[SettingNames.XSFIRST] = false;
			cs[SettingNames.SPAWNAFTERCLEAR] = false;
			
			cs[SettingNames.FITMODE] = false;
			
			cs[SettingNames.LEVELMAX] = 3;
			cs[SettingNames.LEVELMAXWIN] = true;
			cs[SettingNames.FA] = [700, 500, 300];
			cs[SettingNames.FARR] = true;
			cs[SettingNames.CWID] = cs[SettingNames.BINX];
			cs[SettingNames.CLEN] = 1;
			cs[SettingNames.CLEARDROP] = true;
			cs[SettingNames.GRAVITY] = false;
			cs[SettingNames.LUMP] = false;
			cs[SettingNames.FCF] = 2;
			cs[SettingNames.CTIME] = 1300;
			cs[SettingNames.FREEZE] = true;
			cs[SettingNames.TIMELIMIT] = 120;
			cs[SettingNames.LIVES] = 2;
			cs[SettingNames.SCOREPEN] = false;
			cs[SettingNames.LEVELPEN] = false;
			
			cs[SettingNames.CLEARPOINTS] = [0, 0, 0, 1];
			cs[SettingNames.TILEPOINTS] = 0;
			
			cs[SettingNames.LEVELUPREQ] = Settings.L_SCORE;
			cs[SettingNames.LEVELUPA] = [2, 2, 1];
			cs[SettingNames.SOFTBONUS] = 0;
			cs[SettingNames.HARDBONUS] = 0;
			
			cs[SettingNames.BB_BONUS] = false;
			
			cs[SettingNames.WINBONUS] = 9995; //Bonus awarded for winning (reaching max level, if set as win).
			cs[SettingNames.WINLIVESBONUS] = 1000; //Win bonus, x # of lives remaining
			cs[SettingNames.WINTIMEBONUS] = 10; //Win bonus, x # seconds remaining (if time is allowed)
			
			cs[SettingNames.STAGESIDE] = Settings.S_SIDE_RIGHT;
			
			
			Settings.clearType();
			
			var n:int = Settings.numtypes;
			for (var i:int = 0; i < n; i++)
				SaveData.saveGameSetting(Settings.getGameType(i), i);
			SaveData.flush();
		}
	}
}