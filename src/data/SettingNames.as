package data 
{
	/**
	 * ...
	 * @author XJ
	 */
	public class SettingNames 
	{
		/**
		 * This value is true for hard-coded game modes. They cannot be deleted or edited.
		 */
		public static const LOCKED:String = "locked";
		public static const FILEID:String = "fileid";
			
		// Titles
		public static const GTITLE:String = "gtitle";
		public static const GCOL:String = "gcol";
		public static const GTCOL:String = "gtcol";
		public static const GDESC:String = "gdesc";
		public static const GAUTHOR:String = "gauthor";
		public static const GEDITER:String = "gediter";
		
		// Style settings
		public static const VSTYLE:String = "vstyle";
		
		// Visual Settings
		public static const PLAYPOS:String = "playpos";
		public static const GBG_TYPE:String = "gbg_type";
		public static const SCORE_TYPE:String = "score_type";
		public static const SONG_TYPE:String = "song_type";
		
		// Piece data
		
		/** 
		 * If an element is a uint, it represents a group of randomly-shaped tiles
		 * with pieces\[i] tiles. If an array, it's an array of coordinates for a custom tile.
		 */
		public static const PIECES:String = "pieces";
		
		 /** 
		  * If piece i a custom piece, then pprops\[i] is a 2D array of length-4 arrays (one per tile) containing custom tile connections.
		  * Otherwise, pprops\[i] is a 1D array signifying the maximum area of a random piece.
		  */
		public static const PPROPS:String = "pprops";
		
		//per-piece appearances
		public static const PCOL:String = "pcol";
		public static const PAPP:String = "papp";
		
		//global appearances
		public static const PCLEAR:String = "pclear";
		
		/**
		 * Set to true if pieces should be ordered, and to false if they should be random (& based on randomizer arrays).
		 */
		public static const ORDERED:String = "ordered";
		
		/**
		 * plike[l]\[i] indicates the likelihood of getting piece i while on level l. Used only if not ordered.
		 */
		public static const PLIKE:String = "plike";
		
		/**
		 * porder[l][0,2,4...] indicates the order in which to drop pieces.
		 * porder[l][1,3,5...] indicates the frequency at which the piece is dropped.
		 * Used only if ordered.
		 */
		public static const PORDER:String = "porder";
		
		// Tiles
		public static const NEXTNUM:String = "nextnum";
		public static const BINX:String = "binx";
		public static const BINY:String = "biny";
		public static const BORCOL:String = "borcol";
		public static const SHADOWS:String = "shadows";
		public static const INVISIBLE:String = "invisible";
		public static const INVISILAND:String = "invisiland";
		public static const SZONE:String = "szone";
		public static const DZONE:String = "dzone";
		public static const SCOL:String = "scol";
		public static const DCOL:String = "dcol";
		public static const BGCOL:String = "bgcol";
		public static const BINAPP:String = "binapp";
		public static const BINCOL:String = "bincol";
		
		// Control
		public static const RESPSLI:String = "respsli";
		public static const SPEEDSLI:String = "speedsli"; //auto-scroll speed for sliding: high number = slow
		public static const RCW:String = "rcw";
		public static const RCCW:String = "rccw";
		public static const RESPROT:String = "resprot";
		public static const SPEEDROT:String = "speedrot"; //a-s speed for turning
		
		// Physics
		public static const HOLDABLE:String = "holdable";
		public static const WALLKICK:String = "wallkick";
		public static const FLOORKICK:String = "floorkick";
		public static const LANDKICK:String = "landkick";
		public static const CEILKICK:String = "ceilkick";
		public static const SQUEEZE:String = "squeeze";
		public static const ROTCEN:String = "rotcen";
		public static const DROP:String = "drop";
		public static const INST:String = "inst";
		public static const TOPLOCK:String = "toplock";
		public static const SPAWNTYPE:String = "spawntype";
		public static const SPAWNPOSY:String = "spawnposy";
		public static const SAFESHIFT:String = "safeshift";
		public static const TOPSHIFT:String = "topshift";
		public static const XSFIRST:String = "xsfirst";
		public static const SPAWNAFTERCLEAR:String = "spawnAfterClear";
		
		// Fit Mode settings
		public static const FITMODE:String = "fitmode";
		public static const FITPASS:String = "fitpass";
		public static const FITFORCE:String = "fitforce";
		
		// Other?
		public static const LEVELMAX:String = "levelmax";
		public static const LEVELMAXWIN:String = "levelmaxwin";
		public static const FA:String = "fa";
		public static const FARR:String = "farr";
		public static const FDEC:String = "fdec";
		public static const FMIN:String = "fmin";
		public static const CWID:String = "cwid";
		public static const CLEN:String = "clen";
		public static const EXTENDABLE:String = "extendable";
		public static const LTOR:String = "ltor";
		public static const BTOT:String = "btot";
		public static const CLEARDROP:String = "cleardrop";
		public static const GRAVITY:String = "gravity";
		public static const LUMP:String = "lump";
		public static const FCF:String = "fcf";
		//public static const FCA:String = "fca"; //fall chain array
		public static const CTIME:String = "ctime";
		public static const FREEZE:String = "freeze";
		public static const CRESET:String = "creset";
		public static const TIMELIMIT:String = "timelimit";
		public static const LIVES:String = "lives";
		public static const FITCHANCES:String = "fitchances";
		public static const SCOREPEN:String = "scorepen";
		public static const LEVELPEN:String = "levelpen";
		
		// Scoring
		public static const POINTC_T:String = "pointc_t";
		public static const CLEARPOINTS:String = "clearpoints";
		public static const TILEPOINTS:String = "tilepoints";
		
		//public var clearmult:uint = 1; //If # of clears > entries in clearpoints, score += this * # of clears * last entry in clearpoints
		public static const LEVELMULTARR:String = "levelmultarr";
		public static const LEVELMULT:String = "levelmult";
		public static const LEVELMULTA:String = "levelmulta";
		
		public static const LEVELUPREQ:String = "levelupreq";
		public static const LEVELUPA:String = "levelupa";
		
		public static const SOFTBONUS:String = "softbonus";
		public static const HARDBONUS:String = "hardbonus";
		public static const SETBONUS:String = "setbonus";
		public static const SETBONUSP_T:String = "setbonusp_t";
		
		public static const TLVLUPBONUS:String = "tlvlupbonus";
		public static const TPOINTC_T:String = "tpointc_t";
		public static const TCLEARBONUS:String = "tclearbonus";
		public static const TTILEBONUS:String = "ttilebonus";
		//public static const TCLEARMULT:String = "tclearmult"; //See clearmult: like this, but for time
		public static const TLEVELMULTARR:String = "tlevelmultarr";
		public static const TLEVELMULT:String = "tlevelmult";
		public static const TLEVELMULTA:String = "tlevelmulta";
		
		//Combo score multiplers
		public static const BB_BONUS:String = "bb_bonus";
		public static const BBCOMBOMOD:String = "bbcombomod";
		public static const COMBOMOD:String = "combomod";
		public static const GRAVCOMBOMOD:String = "gravcombomod";
		
		//Versions for time bonuses
		public static const TBBCOMBOMOD:String = "tbbcombomod";
		public static const TCOMBOMOD:String = "tcombomod";
		public static const TGRAVCOMBOMOD:String = "tgravcombomod";
		
		//Win bonuses
		public static const WINBONUS:String = "winbonus";
		public static const WINLIVESBONUS:String = "winlivesbonus";
		public static const WINCHANCESBONUS:String = "winchancesbonus";
		public static const WINTIMEBONUS:String = "wintimebonus";
		
		public static const DZONEMULT:String = "dzonemult";
		public static const SZONEMULT:String = "szonemult";
		
		public static const STAGESIDE:String = "stageside";
		
		//High score records
		public static const HISCORELIST:String = "hiscorelist";
		public static const INITIALLIST:String = "initiallist";
		public static const NGSCORELIST:String = "ngscorelist";

	}

}