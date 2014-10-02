package menu.editing 
{
	import com.greensock.TweenLite;
	import data.SaveData;
	import data.SettingNames;
	import data.Settings;
	import events.IDEvent;
	import events.ObjEvent;
	import fl.containers.ScrollPane;
	import fl.controls.Button;
	import fl.controls.ButtonLabelPlacement;
	import fl.controls.CheckBox;
	import fl.controls.ScrollPolicy;
	import fl.core.UIComponent;
	import fl.data.DataProvider;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	import menu.ButtonBackTab;
	import menu.editing.comps.*;
	import menu.editing.pieces.EditPieceBank;
	import menu.editing.pieces.EditPieceBar;
	import menu.editing.pieces.EditPieceBarOrdered;
	import menu.editing.previews.*;
	import menu.ICleanable;
	import menu.PopUp;
	import menu.TextButton;
	import objects.GamePiece;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class EditPane extends Sprite 
	{
		public static const E_UPDATE:String = "Updated settings";
		
		private static const BARNUM:Number = 7;
		
		private static const SLIDE_TIME:Number = 0.4;
		
		private static const NAME_PAGES:Vector.<String> = Vector.<String>(["General", "Controls", "Pieces", "Rules"]);
		private static const NUM_PAGES:uint = NAME_PAGES.length;
		private static const PAGE_GEN:uint = 0;
		private static const PAGE_CTRL:uint = 1;
		private static const PAGE_PIECE:uint = 2;
		private static const PAGE_RULES:uint = 3;
		
		/**
		 * The mode that is being edited.
		 */
		internal var es:Settings;
		
		/**
		 * The mode that will be saved/updated.
		 */
		private var cs:Settings;
		public function get actualGame():uint
		{
			return cs.gtype;
		}
		
		private var _scrollpane:ScrollPane;
		private var _scrollpsave:Number = 0;
		private var _scrollposs:Vector.<Number> = new Vector.<Number>(NUM_PAGES);
		private var _tabbuttons:Vector.<TextButton> = new Vector.<TextButton>(NUM_PAGES);
		private const _tabhidey:Number = 10;
		
		private var _barlists:Vector.<Vector.<EditBarBase>> = new Vector.<Vector.<EditBarBase>>(NUM_PAGES);
		private var _panelist:Vector.<Sprite> = new Vector.<Sprite>(NUM_PAGES);
		private var _currentpage:uint;
		
		private var _ynbuttons:Vector.<Button> = new Vector.<Button>();
		private var _dirtypanes:Vector.<Sprite> = new Vector.<Sprite>();
		
		private var _widgetlist:Vector.<IEditComponent> = new Vector.<IEditComponent>();
		private var _scoreresetters:Vector.<IEditComponent> = new Vector.<IEditComponent>();
		private var _listenlist:Vector.<UIComponent> = new Vector.<UIComponent>();
		private var _listeners:Vector.<Function> = new Vector.<Function>();
		
		private var _bar_gtitle:EditBar;
		private var _w_gtitle:EditCompText;
		private var _w_gcol:EditCompColor;
		private var _w_gtcol:EditCompColor;
		
		private var _bar_gdesc:EditBar;
		private var _w_gdesc:EditCompText;
		
		private var _bar_binsize:EditBar;
		private var _w_binwid:EditCompStepper;
		private var _w_binlen:EditCompStepper;
		
		private var _bar_binstyle:EditBar;
		private var _w_binapp:EditCompCombo;
		private var _w_bincol:EditCompColor;
		private var _w_bgcol:EditCompColor;
		
		private var _bar_fitmode:EditBar;
		private var _w_fitmode:EditCompButton;
		private var _bar_fitpass:EditBar;
		private var _w_fitpass:EditCompButton;
		private var _bar_fitforce:EditBar;
		private var _w_fitforce:EditCompButton;
		
		private var _bar_zones:EditBar;
		private var _w_szone:EditCompStepper; //max = biny - dzone
		private var _w_scol:EditCompColor;
		private var _w_dzone:EditCompStepper; //max = biny - szone
		private var _w_dcol:EditCompColor;
		
		private var _bar_clearsize:EditBar;
		private var _w_clearwid:EditCompStepper;
		private var _w_clearlen:EditCompStepper;
		private var _w_clearline:CheckBox;
		
		private var _bar_extendable:EditBar;
		private var _w_extendable:EditCompButton;
		/*private var _w_extendableon:RadioButton;
		private var _w_extendableoff:RadioButton;
		private var _g_extendable:RadioButtonGroup*/
		
		private var _bar_priority:EditBar;
		private var _w_priority:EditCompCombo;
		private var _dp_priority:Array;
		
		private var _bar_nextnum:EditBar;
		private var _w_nextnum:EditCompStepper;
		
		private var _bar_stageside:EditBar;
		private var _w_stageside:EditCompCombo;
		private var _dp_stageside:Array;
		
		private var _bar_song:EditBar;
		private var _w_song:EditCompCombo;
		
		private var _bar_holdable:EditBar;
		private var _w_holdable:EditCompButton;
		
		private var _bar_fastdrop:EditBar;
		private var _w_fastdrop:EditCompButton;
		
		private var _bar_instdrop:EditBar;
		private var _w_instdrop:EditCompButton;
		
		private var _bar_rotate:EditBar;
		private var _w_rotate:EditCompCombo;
		private var _dp_rotate:Array;
		
		private var _bar_rotcen:EditBar;
		private var _w_rotcen:EditCompButton;
		
		private var _bar_autoresrot:EditBar;
		private var _w_autoresrotval:EditCompStepper;
		private var _w_autoresrottog:EditCompButton;
		
		private var _bar_autoressli:EditBar;
		private var _w_autoresslival:EditCompStepper;
		private var _w_autoresslitog:EditCompButton;
		
		private var _dp_autospeed:Array;
		private var _bar_autospeedrot:EditBar;
		private var _w_autospeedrot:EditCompCombo;
		private var _bar_autospeedsli:EditBar;
		private var _w_autospeedsli:EditCompCombo;
		
		private var _bar_kicks:EditBar;
		private var _w_wallkick:EditCompCheck;
		private var _w_floorkick:EditCompCheck;
		private var _w_ceilkick:EditCompCheck;
		
		private var _bar_squeeze:EditBar;
		private var _w_squeeze:EditCompButton;
		
		private var _bar_freeze:EditBar;
		private var _w_freeze:EditCompButton;
		
		private var _bar_ctimereset:EditBar;
		private var _w_ctimereset:EditCompButton;
		
		private var _bar_ctime:EditBar;
		private var _w_ctime:EditCompStepper;
		
		private var _bar_shadows:EditBar;
		private var _w_shadows:EditCompButton;
		
		private var _bar_invis:EditBar;
		private var _w_invis:EditCompCombo;
		private var _dp_invis:Array;
		
		private var _bar_clearstyle:EditBar;
		private var _w_clearstyle:EditCompCombo;
		
		private var _bar_spawnpos:EditBar;
		private var _w_spawnposy:EditCompStepper;
		private var _w_spawntop:CheckBox;
		private var _w_spawntype:EditCompCombo;
		private var _dp_spawntype:Array;
		
		private var _bar_toplock:EditBar;
		private var _w_toplock:EditCompButton;
		
		private var _bar_safeshift:EditBar;
		private var _w_safeshift:EditCompCombo;
		private var _dp_safeshift:Array;
		
		private var _bar_spawnafterclear:EditBar;
		private var _w_spawnafterclear:EditCompButton;
		
		private var _bar_cleardrop:EditBar;
		private var _w_cleardrop:EditCompButton;
		
		private var _bar_addpiece:EditBar;
		private var _w_addgroup:Button;
		private var _w_addcustom:Button;
		
		private var _piecebank:EditPieceBank;
		
		private var _bar_ordered:EditBar;
		private var _w_ordered:EditCompCombo;
		private var _dp_ordered:Array;
		
		private var _bar_editorder:EditBar;
		private var _w_editorder:EditCompArray;
		
		private var _bar_editlikes:EditBar;
		private var _w_editlikes:EditCompArray;
		
		private var _bar_falltype:EditBar;
		private var _w_falltype:EditCompCombo;
		private var _dp_falltype:Array;
		
		private var _bar_fallauto:EditBar;
		private var _w_fallautostart:EditCompStepper;
		private var _w_fallautodec:EditCompStepper;
		private var _w_fallautolimit:EditCompStepper;
		
		private var _bar_fallcustom:EditBar;
		private var _w_fallcustom:EditCompArray;
		
		private var _bar_gravity:EditBar;
		private var _w_gravity:EditCompButton;
		
		private var _bar_lump:EditBar;
		private var _w_lump:EditCompButton;
		
		private var _bar_gravspeed:EditBar;
		private var _w_gravspeed:EditCompStepper;
		
		private var _bar_border:EditBar;
		private var _w_border:EditCompButton;
		private var _w_borcol:EditCompColor;
		
		private var _bar_lives:EditBar;
		private var _w_lives:EditCompStepper;
		
		private var _bar_levelupreq:EditBar;
		private var _w_levelupreq:EditCompCombo;
		private var _dp_levelupreq:Array;
		private var _w_levelupamount:EditCompArray;
		
		private var _bar_loselife:EditBar;
		private var _w_loselife:EditCompCombo;
		private var _dp_loselife:Array;
		
		private var _bar_chances:EditBar;
		private var _w_chances:EditCompStepper;
		
		private var _bar_timelimit:EditBar;
		private var _w_timelimittog:EditCompButton;
		private var _w_timelimitval:EditCompStepper;
		
		private var _bar_tlvlupbonus:EditBar;
		private var _w_tlvlupbonus:EditCompArray;
		
		private var _bar_levelmax:EditBar;
		private var _w_levelmax:EditCompStepper;
		private var _w_levelmaxwin:EditCompCheck;
		
		private var _bar_levelmulttype:EditBar;
		private var _w_levelmulttype:EditCompCombo;
		private var _dp_levelmulttype:Array;
		
		private var _bar_levelmultauto:EditBar;
		private var _w_levelmultauto:EditCompStepper;
		
		private var _bar_levelmultcustom:EditBar;
		private var _w_levelmultcustom:EditCompArray;
		
		private var _bar_tlevelmulttype:EditBar;
		private var _w_tlevelmulttype:EditCompCombo;
		
		private var _bar_tlevelmultauto:EditBar;
		private var _w_tlevelmultauto:EditCompStepper;
		
		private var _bar_tlevelmultcustom:EditBar;
		private var _w_tlevelmultcustom:EditCompArray;
		
		private var _bar_winbonus:EditBar;
		private var _w_winbonus:EditCompStepper;
		
		private var _bar_winbonuslives:EditBar;
		private var _w_winbonuslives:EditCompStepper;
		
		private var _bar_winbonuschances:EditBar;
		private var _w_winbonuschances:EditCompStepper;
		
		private var _bar_winbonustime:EditBar;
		private var _w_winbonustime:EditCompStepper;
		
		private var _bar_cpointstyle:EditBar;
		private var _w_cpointstyle:EditCompCombo;
		private var _dp_cpointstyle:Array;
		
		private var _bar_clearpoints:EditBar;
		private var _w_clearpoints:EditCompArray;
		
		private var _bar_tilepoints:EditBar;
		private var _w_tilepoints:EditCompStepper;
		
		private var _bar_ctimestyle:EditBar;
		private var _w_ctimestyle:EditCompCombo;
		
		private var _bar_cleartime:EditBar;
		private var _w_cleartime:EditCompArray;
		
		private var _bar_tiletime:EditBar;
		private var _w_tiletime:EditCompStepper;
		
		private var _bar_backbonus:EditBar;
		private var _w_backbonustog:EditCompButton;
		private var _w_backbonusval:EditCompArray;
		
		private var _bar_multibonus:EditBar;
		private var _w_multibonus:EditCompArray;
		
		private var _bar_gravbonus:EditBar;
		private var _w_gravbonus:EditCompArray;
		
		private var _bar_tbackbonus:EditBar;
		private var _w_tbackbonustog:EditCompButton;
		private var _w_tbackbonusval:EditCompArray;
		
		private var _bar_tmultibonus:EditBar;
		private var _w_tmultibonus:EditCompArray;
		
		private var _bar_tgravbonus:EditBar;
		private var _w_tgravbonus:EditCompArray;
		
		private var _bar_setbonus:EditBar;
		private var _w_setbonustype:EditCompCombo;
		private var _dp_setbonustype:Array;
		private var _w_setbonusval:EditCompStepper;
		
		private var _bar_fastdropbonus:EditBar;
		private var _w_fastdropbonus:EditCompStepper;
		
		private var _bar_instdropbonus:EditBar;
		private var _w_instdropbonus:EditCompStepper;
		
		private var _bar_zonebonus:EditBar;
		private var _w_szonebonus:EditCompStepper;
		private var _w_dzonebonus:EditCompStepper;
		
		
		private var _selected:EditBar;
		private var _hovered:EditBar;
		
		private var _defaultset:Boolean = false;
		
		override public function get width():Number
		{
			return EditBarBase.E_WIDTH;
		}
		
		override public function get height():Number
		{
			return _scrollpane.height + _tabbuttons[0].height;
		}
		
		public function EditPane() 
		{
			cs = Settings.currentGame;
			if (cs == null)
			{
				//New mode: set author for the first (and only!) time.
				es = new Settings();
				es[SettingNames.GAUTHOR] = APIUtils.username;
			}
			else
				es = Settings.copyGameType(cs, false, true, false);
			
			//Always update editer name.
			es[SettingNames.GEDITER] = APIUtils.username;
			Settings.setGameTypeForced(es);
			
			_scrollpane = new ScrollPane();
			_scrollpane.setSize(EditBarBase.E_WIDTH, EditBarBase.E_HEIGHT * BARNUM);
			_scrollpane.horizontalScrollPolicy = ScrollPolicy.OFF;
			_scrollpane.verticalScrollPolicy = ScrollPolicy.ON;
			_scrollpane.tabEnabled = false;
			
			var i:uint;
			var pane:Sprite;
			for (i = 0; i < NUM_PAGES; i++)
			{
				_barlists[i] = new Vector.<EditBarBase>();
				_panelist[i] = new Sprite();
				_scrollposs[i] = 0;
			}
			
			const NS_WID:Number = 55;
			const YBSMALL_WID:Number = 55;
			
			//------------Start of widget setup------------//
			
			_w_gtitle = new EditCompText();
			_w_gtitle.maxChars = Settings.MAX_TITLE_LEN;
			_w_gcol = new EditCompColor();
			_w_gtcol = new EditCompColor();
			
			_bar_gtitle = new EditBar("Mode Name",
			"Set the mode's name, and the appearance of its button in the Mode Select menu.",
			PreviewModeButton, null);
			_bar_gtitle.addWidget(_w_gtitle);
			_bar_gtitle.addWidget(_w_gtcol, "Colour:");
			_bar_gtitle.addWidget(_w_gcol);
			_barlists[PAGE_GEN].push(_bar_gtitle);
			
			_widgetlist.push(_w_gtitle, _w_gcol, _w_gtcol);
			
			
			_w_gdesc = new EditCompText();
			_w_gdesc.maxChars = Settings.MAX_DESC_LEN;
			_w_gdesc.width = EditBarBase.E_WIDTH / 2;
			
			_bar_gdesc = new EditBar("Description",
			"Enter a brief description of the mode. Make sure it explains your mode's rules! It will appear when the mode selected in the Mode Select menu.",
			null, null);
			_bar_gdesc.addWidget(_w_gdesc);
			_barlists[PAGE_GEN].push(_bar_gdesc);
			
			_widgetlist.push(_w_gdesc);
			
			
			_w_binwid = new EditCompStepper();
			_w_binlen = new EditCompStepper();
			_w_binwid.maximum = Settings.MAX_BINX;
			_w_binlen.maximum = Settings.MAX_BINY;
			_w_binwid.minimum = 1;
			_w_binlen.minimum = 1;
			_w_binwid.width = NS_WID;
			_w_binlen.width = NS_WID;
			
			addChangeListener(_w_binwid, updateClearArea);
			addChangeListener(_w_binlen, updateClearArea);
			
			_bar_binsize = new EditBar("Bin Size",
			"Set the dimensions of the playing field.",
			PreviewPlayStage,
			function():void
			{
				if (_defaultset)
					updateClearArea();
				else
					updateSpawnPos();
			});
			_bar_binsize.addWidget(_w_binwid, "Wid:");
			_bar_binsize.addWidget(_w_binlen, "Hgt:");
			_barlists[PAGE_GEN].push(_bar_binsize);
			
			_widgetlist.push(_w_binlen, _w_binwid);
			_scoreresetters.push(_w_binlen, _w_binwid);
			
			
			_w_binapp = new EditCompCombo();
			_w_bincol = new EditCompColor();
			_w_bgcol = new EditCompColor();
			_w_binapp.dataProvider = new DataProvider(Settings.APP_NAMES.slice());
			
			_bar_binstyle = new EditBar("Bin Style",
			"Set the style & colour of the bin's edge tiles, and the colour of the bin's background.",
			PreviewPlayStage, null);
			_bar_binstyle.addWidget(_w_binapp);
			_bar_binstyle.addWidget(_w_bincol);
			_bar_binstyle.addWidget(_w_bgcol, "BG:");
			_barlists[PAGE_GEN].push(_bar_binstyle);
			
			_widgetlist.push(_w_binapp, _w_bincol, _w_bgcol);
			
			
			_w_szone = new EditCompStepper();
			_w_scol = new EditCompColor();
			_w_dzone = new EditCompStepper();
			_w_dcol = new EditCompColor();
			_w_szone.minimum = 0;
			_w_dzone.minimum = 0;
			_w_szone.width = NS_WID;
			_w_dzone.width = NS_WID;
			
			addChangeListener(_w_szone, updateZoneLimits);
			addChangeListener(_w_dzone, updateZoneLimits);
			
			_bar_zones = new EditBar("Zones",
			"Configure the safe & danger zones. During gameplay, if the highest tile in the bin is in one of these zones, you may earn a bonus.",
			PreviewPlayStage,
			function():void
			{
				updateZoneLimits();
			});
			_bar_zones.addWidget(_w_szone, "Safe:");
			_bar_zones.addWidget(_w_scol);
			_bar_zones.addWidget(_w_dzone, "Danger:");
			_bar_zones.addWidget(_w_dcol);
			_barlists[PAGE_GEN].push(_bar_zones);
			
			_widgetlist.push(_w_szone, _w_scol, _w_dzone, _w_dcol);
			_scoreresetters.push(_w_szone, _w_dzone);
			
			_w_clearwid = new EditCompStepper();
			_w_clearlen = new EditCompStepper();
			_w_clearwid.maximum = es[SettingNames.BINX];
			_w_clearlen.maximum = es[SettingNames.BINY];
			_w_clearwid.minimum = 1;
			_w_clearlen.minimum = 1;
			_w_clearwid.width = NS_WID;
			_w_clearlen.width = NS_WID;
			_w_clearline = new CheckBox();
			_w_clearline.labelPlacement = ButtonLabelPlacement.LEFT;
			_w_clearline.label = "Line";
			
			addChangeListener(_w_clearwid, uncheckLine);
			addChangeListener(_w_clearline, checkLine);
			addChangeListener(_w_clearwid, updateExtendable);
			addChangeListener(_w_clearlen, updateExtendable);
			
			_bar_clearsize = new EditBar("Clear Size",
			"Designate the size of the rectangle of tiles that will be cleared.",
			PreviewPlayStageExtend, function():void
			{
				_w_clearline.selected = (es[SettingNames.CWID] == _w_binwid.value);
				updateExtendable();
			});
			_bar_clearsize.addWidget(_w_clearline);
			_bar_clearsize.addWidget(_w_clearwid, "W:");
			_bar_clearsize.addWidget(_w_clearlen, "H:");
			_barlists[PAGE_GEN].push(_bar_clearsize);
			
			_widgetlist.push(_w_clearlen, _w_clearwid);
			_scoreresetters.push(_w_clearlen, _w_clearwid);
			
			
			_w_extendable = new EditCompButton();
			addChangeListener(_w_extendable, updatePriority);
			_ynbuttons.push(_w_extendable);
			/*_w_extendableon = new RadioButton();
			_w_extendableoff = new RadioButton();
			_w_extendableon.labelPlacement = ButtonLabelPlacement.LEFT;
			_w_extendableoff.labelPlacement = ButtonLabelPlacement.LEFT;
			_w_extendableon.label = "On";
			_w_extendableoff.label = "Off";
			_w_extendableon.width = RB_WID;
			_w_extendableoff.width = RB_WID;
			_g_extendable = new RadioButtonGroup("g_ext");
			_g_extendable.addRadioButton(_w_extendableon);
			_g_extendable.addRadioButton(_w_extendableoff);
			_g_extendable.addEventListener(Event.CHANGE, updatePriority);*/
			
			_bar_extendable = new EditBar("Extendable Clears",
			"If enabled, rectangles longer & wider than the specified clear size will be cleared, and overlapping rectangles will clear.",
			PreviewPlayStageExtend, function():void
			{
				setYNButtonLabel(_w_extendable);
				updatePriority();
			});
			_bar_extendable.addWidget(_w_extendable);
			//_bar_extendable.addWidget(_w_extendableoff);
			//_bar_extendable.addWidget(_w_extendableon);
			_barlists[PAGE_GEN].push(_bar_extendable);
			
			_widgetlist.push(_w_extendable);
			_scoreresetters.push(_w_extendable);
			
			
			_w_priority = new EditCompCombo();
			_dp_priority = [
			{label:"Top right", data:[false, false]},
			{label:"Top left", data:[false, true]},
			{label:"Bottom right", data:[true, false]},
			{label:"Bottom left", data:[true, true]}
			];
			_w_priority.dataProvider = new DataProvider(_dp_priority);
			
			_bar_priority = new EditBar("Clear Priority",
			"If a created rectangle of tiles is larger than the clear area, decide which side gets cleared first.",
			PreviewPlayStagePriority, null);
			_bar_priority.addWidget(_w_priority);
			_bar_extendable.reliers.push(_bar_priority);
			_barlists[PAGE_GEN].push(_bar_priority);
			
			_widgetlist.push(_w_priority);
			_scoreresetters.push(_w_priority);
			
			
			_w_nextnum = new EditCompStepper();
			_w_nextnum.maximum = Settings.MAX_NEXTNUM;
			_w_nextnum.minimum = 0;
			_w_nextnum.width = NS_WID;
			
			_bar_nextnum = new EditBar("# of Preview Boxes",
			"Choose how many \"Next\" windows will appear in the game. Collectively, the windows show you the queue of upcoming pieces.",
			null, null);
			_bar_nextnum.addWidget(_w_nextnum);
			_barlists[PAGE_GEN].push(_bar_nextnum);
			
			_widgetlist.push(_w_nextnum);
			_scoreresetters.push(_w_nextnum);
			
			
			_w_stageside = new EditCompCombo();
			_dp_stageside = [
			{label:"Left", data:Settings.S_SIDE_LEFT},
			{label:"Middle", data:Settings.S_SIDE_CENTRE},
			{label:"Right", data:Settings.S_SIDE_RIGHT}
			];
			_w_stageside.dataProvider = new DataProvider(_dp_stageside);
			
			_bar_stageside = new EditBar("Play Position",
			"Choose where to place the play zone on the screen.",
			null, null); //TODO
			_bar_stageside.addWidget(_w_stageside);
			_barlists[PAGE_GEN].push(_bar_stageside);
			
			_widgetlist.push(_w_stageside);
			
			
			_w_song = new EditCompCombo();
			_w_song.dataProvider = new DataProvider(Settings.SONG_NAMES.slice());
			_w_song.width *= 1.6;
			
			_bar_song = new EditBar("Game Music",
			"Choose the background music for this mode.",
			null, null); //TODO
			_bar_song.addWidget(_w_song);
			_barlists[PAGE_GEN].push(_bar_song);
			
			_widgetlist.push(_w_song);
			
			
			_w_fitmode = new EditCompButton();
			addChangeListener(_w_fitmode, fitmodeUpdates);
			_ynbuttons.push(_w_fitmode);
			
			_bar_fitmode = new EditBar("Fit Mode",
			"In Fit Mode, pieces don't fall. Instead, you can move them up, down, left, & right, and you set them in place with the push of a button (or until time runs out).",
			null, //TODO
			function():void
			{
				setYNButtonLabel(_w_fitmode);
				fitmodeUpdates();
			});
			_bar_fitmode.addWidget(_w_fitmode);
			_barlists[PAGE_CTRL].push(_bar_fitmode);
			
			_widgetlist.push(_w_fitmode);
			_scoreresetters.push(_w_fitmode);
			
			
			_w_fitpass = new EditCompButton();
			_ynbuttons.push(_w_fitpass);
			
			_bar_fitpass = new EditBar("Pass-Through",
			"(Fit Mode setting) If turned on, you may move pieces through tiles that have been placed in the bin. If off, set tiles act as walls.",
			null, //TODO
			function():void
			{
				setYNButtonLabel(_w_fitpass);
			});
			_bar_fitpass.addWidget(_w_fitpass);
			_barlists[PAGE_CTRL].push(_bar_fitpass);
			
			
			_w_fitforce = new EditCompButton();
			_ynbuttons.push(_w_fitforce);
			
			_bar_fitforce = new EditBar("Force Fit",
			"(Fit Mode setting) If turned off, a piece that has been forcably set when time runs out will not be placed in the bin if it overlaps with any set tiles. If turned on, any non-overlapping tiles will be placed.",
			null, //TODO
			function():void
			{
				setYNButtonLabel(_w_fitforce);
			});
			_bar_fitforce.addWidget(_w_fitforce);
			_barlists[PAGE_CTRL].push(_bar_fitforce);
			
			
			_w_fastdrop = new EditCompButton();
			_ynbuttons.push(_w_fastdrop);
			
			_bar_fastdrop = new EditBar("Fast Drop",
			"If set to \"On\", you can make a piece fall faster by holding down a button.",
			null, function():void
			{
				setYNButtonLabel(_w_fastdrop);
			});
			_bar_fastdrop.addWidget(_w_fastdrop);
			_barlists[PAGE_CTRL].push(_bar_fastdrop);
			
			_widgetlist.push(_w_fastdrop);
			_scoreresetters.push(_w_fastdrop);
			
			
			_w_instdrop = new EditCompButton();
			_ynbuttons.push(_w_instdrop);
			
			_bar_instdrop = new EditBar("Instant Drop",
			"If set to \"On\", you can drop a piece instantly with the push of a button.",
			null, function():void
			{
				setYNButtonLabel(_w_instdrop);
			});
			_bar_instdrop.addWidget(_w_instdrop);
			_barlists[PAGE_CTRL].push(_bar_instdrop);
			
			_widgetlist.push(_w_instdrop);
			_scoreresetters.push(_w_instdrop);
			
			
			_w_holdable = new EditCompButton();
			_ynbuttons.push(_w_holdable);
			
			_bar_holdable = new EditBar("Holdable",
			"If set to \"On\", you'll be able to hold a piece in reserve.",
			null, function():void
			{
				setYNButtonLabel(_w_holdable);
			});
			_bar_holdable.addWidget(_w_holdable);
			_barlists[PAGE_CTRL].push(_bar_holdable);
			
			_widgetlist.push(_w_holdable);
			_scoreresetters.push(_w_holdable);
			
			
			_dp_autospeed = [
			{label:"Fastest", data:1},
			{label:"Medium", data:2},
			{label:"Slow", data:3},
			{label:"Slowest", data:4}
			];
			
			_w_autoresslitog = new EditCompButton();
			_w_autoresslitog.width = YBSMALL_WID;
			addChangeListener(_w_autoresslitog, enableAutoresSli);
			_ynbuttons.push(_w_autoresslitog);
			
			_w_autoresslival = new EditCompStepper();
			_w_autoresslival.minimum = Settings.MIN_RESPTIME / 1000;
			_w_autoresslival.maximum = Settings.MAX_RESPTIME / 1000;
			_w_autoresslival.stepSize = Settings.STEP_RESPTIME / 1000;
			_w_autoresslival.width = NS_WID;
			
			_bar_autoressli = new EditBar("Auto-Slide",
			"Set how long a direction key must be held for the current piece to start sliding while the key is held.",
			null, function():void //TODO
			{
				setYNButtonLabel(_w_autoresslitog);
				enableAutoresSli();
			});
			_bar_autoressli.addWidget(_w_autoresslitog);
			_bar_autoressli.addWidget(_w_autoresslival, "Time (sec):");
			_barlists[PAGE_CTRL].push(_bar_autoressli);
			
			_widgetlist.push(_w_autoresslitog, _w_autoresslival);
			
			
			_w_autospeedsli = new EditCompCombo();
			_w_autospeedsli.dataProvider = new DataProvider(_dp_autospeed);
			
			_bar_autospeedsli = new EditBar("Auto-Slide Speed",
			"Decide how fast a piece will move while auto-sliding.",
			null, null); //TODO
			_bar_autospeedsli.addWidget(_w_autospeedsli);
			_barlists[PAGE_CTRL].push(_bar_autospeedsli);
			
			_widgetlist.push(_w_autospeedsli);
			
			
			_w_rotate = new EditCompCombo();
			_dp_rotate = [
			{label:"Both ways", data:[true, true]},
			{label:"Right (clockwise) only", data:[true, false]},
			{label:"Left (counter-cw) only", data:[false, true]},
			{label:"No rotation", data:[false, false]}
			];
			_w_rotate.dataProvider = new DataProvider(_dp_rotate);
			_w_rotate.width *= 1.5;
			addChangeListener(_w_rotate, rotateUpdates);
			
			_bar_rotate = new EditBar("Rotation",
			"Decide if rotating pieces is allowed, or limit rotation to one direction only.",
			null, function():void
			{
				rotateUpdates();
			});
			_bar_rotate.addWidget(_w_rotate);
			_barlists[PAGE_CTRL].push(_bar_rotate);
			
			_widgetlist.push(_w_rotate);
			_scoreresetters.push(_w_rotate);
			
			
			_w_rotcen = new EditCompButton();
			_ynbuttons.push(_w_rotcen);
			
			_bar_rotcen = new EditBar("Centre Rotate",
			"If set to \"On\", pieces will be centered whenever they are rotated. Otherwise, they will rotate around a single tile.",
			PreviewRotcen, function():void
			{
				setYNButtonLabel(_w_rotcen);
			});
			_bar_rotcen.addWidget(_w_rotcen);
			_barlists[PAGE_CTRL].push(_bar_rotcen);
			
			_widgetlist.push(_w_rotcen);
			_scoreresetters.push(_w_rotcen);
			
			
			_w_autoresrottog = new EditCompButton();
			_w_autoresrottog.width = YBSMALL_WID;
			addChangeListener(_w_autoresrottog, enableAutoresRot);
			_ynbuttons.push(_w_autoresrottog);
			
			_w_autoresrotval = new EditCompStepper(); //convert from millis to seconds!
			_w_autoresrotval.minimum = Settings.MIN_RESPTIME / 1000;
			_w_autoresrotval.maximum = Settings.MAX_RESPTIME / 1000;
			_w_autoresrotval.stepSize = Settings.STEP_RESPTIME / 1000;
			_w_autoresrotval.width = NS_WID;
			
			_bar_autoresrot = new EditBar("Auto-Rotate",
			"Set how long the \"rotate\" button must be held for the current piece to start being rotated repeatedly.",
			null, function():void //TODO
			{
				setYNButtonLabel(_w_autoresrottog);
				enableAutoresRot();
			});
			_bar_autoresrot.addWidget(_w_autoresrottog);
			_bar_autoresrot.addWidget(_w_autoresrotval, "Time (sec):");
			_barlists[PAGE_CTRL].push(_bar_autoresrot);
			
			_widgetlist.push(_w_autoresrottog, _w_autoresrotval);
			
			
			_w_autospeedrot = new EditCompCombo();
			_w_autospeedrot.dataProvider = new DataProvider(_dp_autospeed);
			
			_bar_autospeedrot = new EditBar("Auto-Rotate Speed",
			"Decide how fast a piece will rotate during auto-rotation.",
			null, null); //TODO
			_bar_autospeedrot.addWidget(_w_autospeedrot);
			_bar_autoresrot.reliers.push(_bar_autospeedrot);
			_barlists[PAGE_CTRL].push(_bar_autospeedrot);
			
			_widgetlist.push(_w_autospeedrot);
			
			
			_w_wallkick = new EditCompCheck();
			_w_floorkick = new EditCompCheck();
			_w_ceilkick = new EditCompCheck();
			_w_wallkick.labelPlacement = ButtonLabelPlacement.LEFT;
			_w_floorkick.labelPlacement = ButtonLabelPlacement.LEFT;
			_w_ceilkick.labelPlacement = ButtonLabelPlacement.LEFT;
			_w_wallkick.label = "Wall";
			_w_floorkick.label = "Floor";
			_w_ceilkick.label = "Top";
			
			_bar_kicks = new EditBar("Kicks",
			"A kick will shift a piece that was rotated into a wall to a free space. Without kicks, a piece won't rotate if it collides with something else.",
			null, null);
			_bar_kicks.addWidget(_w_wallkick);
			_bar_kicks.addWidget(_w_floorkick);
			_bar_kicks.addWidget(_w_ceilkick);
			_barlists[PAGE_CTRL].push(_bar_kicks);
			
			_widgetlist.push(_w_wallkick, _w_floorkick, _w_ceilkick);
			_scoreresetters.push(_w_wallkick, _w_floorkick, _w_ceilkick);
			
			
			_w_squeeze = new EditCompButton();
			_ynbuttons.push(_w_squeeze);
			
			_bar_squeeze = new EditBar("Squeeze",
			"If turned on, if rotating a piece would cause it to become sandwiched between tiles, then it will be slid upwards to the next available position (if available).",
			null, function():void //TODO
			{
				setYNButtonLabel(_w_squeeze);
			});
			_bar_squeeze.addWidget(_w_squeeze);
			_barlists[PAGE_CTRL].push(_bar_squeeze);
			
			_widgetlist.push(_w_squeeze);
			_scoreresetters.push(_w_squeeze);
			
			
			_w_freeze = new EditCompButton();
			_ynbuttons.push(_w_freeze);
			addChangeListener(_w_freeze, freezeUpdates);
			
			_bar_freeze = new EditBar("Clear Freeze",
			"If turned off, the game won't become suspended when you make a clear. Clearing tiles rapidly in combos may score you extra points!",
			null, function():void //TODO
			{
				setYNButtonLabel(_w_freeze);
				freezeUpdates();
			});
			_bar_freeze.addWidget(_w_freeze);
			_barlists[PAGE_CTRL].push(_bar_freeze);
			
			_widgetlist.push(_w_freeze);
			_scoreresetters.push(_w_freeze);
			
			
			_w_ctime = new EditCompStepper(); //convert from millis to seconds!
			_w_ctime.minimum = Settings.MIN_CTIME / 1000;
			_w_ctime.maximum = Settings.MAX_CTIME / 1000;
			_w_ctime.stepSize = Settings.STEP_CTIME / 1000;
			_w_ctime.width = NS_WID;
			
			_bar_ctime = new EditBar("Clear Time",
			"Set how long (in seconds) it takes for tiles to disappear from the bin once they have been cleared.",
			null, null); //TODO
			_bar_ctime.addWidget(_w_ctime);
			_barlists[PAGE_CTRL].push(_bar_ctime);
			
			_widgetlist.push(_w_ctime);
			_scoreresetters.push(_w_ctime);
			
			
			_w_ctimereset = new EditCompButton();
			_ynbuttons.push(_w_ctimereset);
			
			_bar_ctimereset = new EditBar("Reset Timer on Clear",
			"Decide if making a new clear while the Clear Timer is running will reset it.",
			null, function():void
			{
				setYNButtonLabel(_w_ctimereset);
			});
			_bar_ctimereset.addWidget(_w_ctimereset);
			_barlists[PAGE_CTRL].push(_bar_ctimereset);
			
			_widgetlist.push(_w_ctimereset);
			_scoreresetters.push(_w_ctimereset);
			
			
			_w_addgroup = new Button();
			_w_addcustom = new Button();
			_w_addgroup.label = "New Group";
			_w_addcustom.label = "New Custom";
			_w_addgroup.addEventListener(MouseEvent.CLICK, addPieceRandom);
			_w_addcustom.addEventListener(MouseEvent.CLICK, addPieceCustom);
			
			_bar_addpiece = new EditBar("Add Piece",
			"Decide what kinds of pieces will appear during play. \"Piece Groups\" are classes of pieces that appear randomly. \"Custom Pieces\" are pieces that you design yourself.",
			null, function():void
			{
				if (_defaultset)
				{
					PopUp.makePopUp(
					"This will undo all changes made to this mode's piece settings. Are you sure you want to do this?",
					Vector.<String>(["Yes, undo changes", "Reset to Standard 7 pieces", "No"]),
					Vector.<Function>([function(e:MouseEvent):void
					{
						_piecebank.resetPieceInfo();
						_w_editlikes.undoChanges();
						_w_editorder.undoChanges();
						PopUp.fadeOut();
						updateMode();
					},
					function(e:MouseEvent):void
					{
						_piecebank.resetToStandard();
						_w_editlikes.data = [[1, 1, 1, 1, 1, 1, 1]];
						_w_editorder.data = [[0, 1, 1, 1, 2, 1, 3, 1, 4, 1, 5, 1, 6, 1]];
						PopUp.fadeOut();
						updateMode();
					},
					PopUp.fadeOut]));
				}
			});
			_bar_addpiece.addWidget(_w_addgroup);
			_bar_addpiece.addWidget(_w_addcustom);
			_barlists[PAGE_PIECE].push(_bar_addpiece);
			
			
			_piecebank = EditPieceBank.makePieceBank();
			_piecebank.addEventListener(EditBarBase.E_RESIZE, updateBarPositionsFromResize);
			_piecebank.addEventListener(IDEvent.GO, notifyPieceDeleted);
			_piecebank.addEventListener(Event.CHANGE, notifyPieceEdited);
			_barlists[PAGE_PIECE].push(_piecebank);
			
			
			_w_ordered = new EditCompCombo();
			_dp_ordered = [
			{label:"Random", data:false},
			{label:"Ordered", data:true}
			];
			_w_ordered.dataProvider = new DataProvider(_dp_ordered);
			addChangeListener(_w_ordered, updateOrderType);
			
			_bar_ordered = new EditBar("Provider Style",
			"Choose whether the pieces that appear in-game are provided randomly, or by a custom sequence you set yourself.",
			null, function():void
			{
				updateOrderType();
			});
			_bar_ordered.addWidget(_w_ordered);
			_barlists[PAGE_PIECE].push(_bar_ordered);
			
			_widgetlist.push(_w_ordered);
			_scoreresetters.push(_w_ordered);
			
			
			_w_editorder = new EditCompArray();
			_w_editorder.WidgetType = EditPieceBarOrdered;
			_w_editorder.poptitle = "Piece Order:\n---\nAdd/remove/reorder pieces that appear during play. The number next to a piece is how many times it will appear.",
			_w_editorder.bartitle = "Level %d";
			_w_editorder.maxnum = Settings.MAX_NUM_LEVELS + 1;
			_w_editorder.zeroindexed = true;
			_w_editorder.lastplus = true;
			
			_bar_editorder = new EditBar("Piece Order",
			"Decide the order that pieces will appear in during play. You can define a unique order for each level.",
			null, function():void
			{
				for each (var lev:Array in _w_editorder.data)
				{
					//Don't reference pieces that don't exist.
					var n:uint = EditPieceBank.getNumPieces();
					for (var i:uint = 0; i < lev.length; i += 2)
					{
						if (lev[i] >= n)
							lev.splice(i, 2);
					}
				}
				_w_editorder.updateLabel();
			});
			_bar_editorder.addWidget(_w_editorder);
			_barlists[PAGE_PIECE].push(_bar_editorder);
			
			_widgetlist.push(_w_editorder);
			_scoreresetters.push(_w_editorder);
			
			
			_w_editlikes = new EditCompArray();
			_w_editlikes.WidgetType = EditPieceBar;
			_w_editlikes.poptitle = "Piece Likelihoods:\n---\nThe number next to each piece is its chance at appearing (high = more likely, 0 = won't appear).",
			_w_editlikes.bartitle = "Level %d";
			_w_editlikes.maxnum = Settings.MAX_NUM_LEVELS + 1;
			_w_editlikes.zeroindexed = true;
			_w_editlikes.lastplus = true;
			
			_bar_editlikes = new EditBar("Piece Likelihoods",
			"Decide how likely each piece is to appear during play. You can define a unique set of likelihoods for each level.",
			null, function():void
			{
				for each (var lev:Array in _w_editlikes.data)
				{
					//Length of array = # of pieces referenced.
					//Don't reference pieces that don't exist, and
					//set pieces that aren't referenced to 0.
					var n:uint = EditPieceBank.getNumPieces();
					while (lev.length > n)
						lev.pop();
					while (lev.length < n)
						lev.push(0);
				}
				_w_editlikes.updateLabel();
			});
			_bar_editlikes.addWidget(_w_editlikes);
			//_bar_editorder.deniers.push(_bar_editlikes);
			_barlists[PAGE_PIECE].push(_bar_editlikes);
			
			_widgetlist.push(_w_editlikes);
			_scoreresetters.push(_w_editlikes);
			
			
			_w_falltype = new EditCompCombo();
			_dp_falltype = [
			{label:"Auto speed-up"},
			{label:"Custom per level"}
			];
			_w_falltype.dataProvider = new DataProvider(_dp_falltype);
			_w_falltype.width *= 1.1;
			addChangeListener(_w_falltype, updateFallType);
			
			_bar_falltype = new EditBar("Fall Speed Type",
			"The fall speed is how quickly a controlled piece will fall during gameplay. Choose how the fall speed will change as the game progresses.",
			null, function():void //Todo?
			{
				updateFallType();
			});
			_bar_falltype.addWidget(_w_falltype);
			_barlists[PAGE_PIECE].push(_bar_falltype);
			
			_widgetlist.push(_w_falltype);
			_scoreresetters.push(_w_falltype);
			
			
			//Remember: large value (max) is SLOWEST fall speed, and small value (min) is FASTEST speed!
			_w_fallautostart = new EditCompStepper();
			_w_fallautodec = new EditCompStepper();
			_w_fallautolimit = new EditCompStepper();
			_w_fallautostart.stepSize = _w_fallautodec.stepSize = _w_fallautolimit.stepSize = Settings.STEP_F / 1000;
			_w_fallautostart.maximum = Settings.MAX_F / 1000;
			_w_fallautostart.minimum = Settings.MIN_F / 1000;
			_w_fallautodec.minimum = 0; //Speeding up by 0 sec is allowable.
			_w_fallautolimit.minimum = Settings.MIN_F / 1000;
			//limit maximum (slowest) & max speedup is the value of start speed, and is set elsewhere to stay updated.
			_w_fallautostart.width = _w_fallautodec.width = _w_fallautolimit.width = NS_WID;
			addChangeListener(_w_fallautostart, updateFallAutoLimit);
			
			_bar_fallauto = new EditBar("FSpeed",
			"Set the initial fall speed, the fastest possible speed, and how much the fall speed will increase on each level up. The speed is the amount of time (in seconds) for a piece to fall by one row, so a *smaller* value indicates a *faster* speed!",
			null, function():void //Todo?
			{
				updateFallAutoLimit();
			});
			_bar_fallauto.addWidget(_w_fallautostart, "Start:");
			_bar_fallauto.addWidget(_w_fallautodec, "Up:");
			_bar_fallauto.addWidget(_w_fallautolimit, "Lim:");
			_barlists[PAGE_PIECE].push(_bar_fallauto);
			
			_widgetlist.push(_w_fallautostart, _w_fallautodec, _w_fallautolimit);
			_scoreresetters.push(_w_fallautostart, _w_fallautodec, _w_fallautolimit);
			
			
			_w_fallcustom = new EditCompArray();
			_w_fallcustom.WidgetType = EditCompStepper;
			_w_fallcustom.poptitle = "Edit Fall Speeds per Level:",
			_w_fallcustom.bartitle = "Level %d";
			_w_fallcustom.maxnum = Settings.MAX_NUM_LEVELS + 1;
			_w_fallcustom.props = [Settings.MIN_F, Settings.MAX_F, 0.1]; //min, max, step
			
			_bar_fallcustom = new EditBar("Custom Fall Speeds", "Set a fall speed for each level.", null, null);
			_bar_fallcustom.addWidget(_w_fallcustom);
			_barlists[PAGE_PIECE].push(_bar_fallcustom);
			
			_widgetlist.push(_w_fallcustom);
			_scoreresetters.push(_w_fallcustom);
			
			
			_w_gravity = new EditCompButton();
			_ynbuttons.push(_w_gravity);
			addChangeListener(_w_gravity, gravityUpdates);
			
			_bar_gravity = new EditBar("Gravity",
			"With gravity, free-floating tiles will fall to the ground. This lets you perform gravity chain combos for extra points!",
			null, function():void
			{
				setYNButtonLabel(_w_gravity);
				gravityUpdates();
			});
			_bar_gravity.addWidget(_w_gravity);
			_barlists[PAGE_PIECE].push(_bar_gravity);
			
			_widgetlist.push(_w_gravity);
			_scoreresetters.push(_w_gravity);
			
			
			_w_lump = new EditCompButton();
			_ynbuttons.push(_w_lump);
			
			_bar_lump = new EditBar("Lump Tiles",
			"Decide if landed tiles should connect to one another. If they do, there will be fewer loose pieces to fall by gravity.",
			null, function():void
			{
				setYNButtonLabel(_w_lump);
			});
			_bar_lump.addWidget(_w_lump);
			_barlists[PAGE_PIECE].push(_bar_lump);
			
			_widgetlist.push(_w_lump);
			_scoreresetters.push(_w_lump);
			
			
			_w_gravspeed = new EditCompStepper();
			_w_gravspeed.minimum = Settings.MIN_FCF;
			_w_gravspeed.maximum = Settings.MAX_FCF;
			_w_gravspeed.stepSize = Settings.STEP_FCF;
			_w_gravspeed.width = NS_WID;
			
			_bar_gravspeed = new EditBar("Gravity Speed",
			"Set how much faster tiles will fall due to gravity then they do to normal falling.",
			null, null); //Todo?
			_bar_gravspeed.addWidget(_w_gravspeed, "x");
			_barlists[PAGE_PIECE].push(_bar_gravspeed);
			
			_widgetlist.push(_w_gravspeed);
			_scoreresetters.push(_w_gravspeed);
			
			
			_w_spawnposy = new EditCompStepper();
			_w_spawnposy.minimum = 0;
			_w_spawnposy.width = NS_WID;
			
			_w_spawntop = new CheckBox();
			_w_spawntop.labelPlacement = ButtonLabelPlacement.LEFT;
			_w_spawntop.label = "Top";
			
			_w_spawntype = new EditCompCombo();
			_dp_spawntype = [
			{label:"Above", data:Settings.OVERFLOW_TOP},
			{label:"Below", data:Settings.OVERFLOW_BOT}
			];
			_w_spawntype.dataProvider = new DataProvider(_dp_spawntype);
			_w_spawntype.width /= 2;
			
			addChangeListener(_w_spawnposy, uncheckTopspawn);
			addChangeListener(_w_spawntop, checkTopspawn);
			
			_bar_spawnpos = new EditBar("Spawn Height",
			"Set the height at which pieces are placed in the bin.",
			PreviewPlayStagePiece, function():void
			{
				_w_spawntop.selected = _w_spawnposy.value == _w_binlen.value - 1;
			});
			_bar_spawnpos.addWidget(_w_spawntop);
			_bar_spawnpos.addWidget(_w_spawntype);
			_bar_spawnpos.addWidget(_w_spawnposy);
			_barlists[PAGE_PIECE].push(_bar_spawnpos);
			
			_widgetlist.push(_w_spawntype, _w_spawnposy);
			_scoreresetters.push(_w_spawntype, _w_spawnposy);
			
			
			_w_toplock = new EditCompButton();
			_ynbuttons.push(_w_toplock);
			
			_bar_toplock = new EditBar("Top Lock",
			"If set to \"on\", then the top of the bin will act as a ceiling.",
			PreviewPlayStagePiece, function():void
			{
				setYNButtonLabel(_w_toplock);
			});
			_bar_toplock.addWidget(_w_toplock);
			_barlists[PAGE_PIECE].push(_bar_toplock);
			
			_widgetlist.push(_w_toplock);
			_scoreresetters.push(_w_toplock);
			
			
			_w_safeshift = new EditCompCombo();
			_dp_safeshift = [
			{label:"None", data:[false, false, false]},
			{label:"Shift sideways", data:[true, false, false]},
			{label:"Shift upwards", data:[false, true, false]},
			{label:"Sideways then upwards", data:[true, true, true]},
			{label:"Upwards then sideways", data:[true, true, false]}
			];
			_w_safeshift.dataProvider = new DataProvider(_dp_safeshift);
			_w_safeshift.width *= 1.5;
			
			_bar_safeshift = new EditBar("Safe Entry",
			"If a piece spawns on top of a tile that's already been placed in the bin, decide if & how the piece should be shifted to a free spot if available, instead of losing a life right away.",
			null, null); //TODO
			_bar_safeshift.addWidget(_w_safeshift);
			_barlists[PAGE_PIECE].push(_bar_safeshift);
			
			_widgetlist.push(_w_safeshift);
			_scoreresetters.push(_w_safeshift);
			
			
			_w_spawnafterclear = new EditCompButton();
			_ynbuttons.push(_w_spawnafterclear);
			
			_bar_spawnafterclear = new EditBar("Spawn After Clear",
			"If set to \"on\", pieces will be put into the bin *after* cleared tiles are removed from the bin. This means there'll be some extra room in the bin before a piece is entered, making it easier to avoid a Game Over in tight situations.",
			null, function():void //TODO
			{
				setYNButtonLabel(_w_spawnafterclear);
			});
			_bar_spawnafterclear.addWidget(_w_spawnafterclear);
			_barlists[PAGE_PIECE].push(_bar_spawnafterclear);
			
			_widgetlist.push(_w_spawnafterclear);
			_scoreresetters.push(_w_spawnafterclear);
			
			
			_w_cleardrop = new EditCompButton();
			_ynbuttons.push(_w_cleardrop);
			
			_bar_cleardrop = new EditBar("Clear Drop",
			"If set turned off, tiles in the bin won't shift down when ones below it have been cleared.",
			null, function():void //TODO
			{
				setYNButtonLabel(_w_cleardrop);
			});
			_bar_cleardrop.addWidget(_w_cleardrop);
			_barlists[PAGE_PIECE].push(_bar_cleardrop);
			
			_widgetlist.push(_w_cleardrop);
			_scoreresetters.push(_w_cleardrop);
			
			
			_w_border = new EditCompButton();
			_w_borcol = new EditCompColor();
			_ynbuttons.push(_w_border);
			addChangeListener(_w_border, enableBorders);
			
			_bar_border = new EditBar("Tile Borders",
			"Turn on/off borders that appear around pieces, and select the colour of the border.",
			PreviewBorder, function():void
			{
				setYNButtonLabel(_w_border);
				enableBorders();
			});
			_bar_border.addWidget(_w_border);
			_bar_border.addWidget(_w_borcol);
			_barlists[PAGE_PIECE].push(_bar_border);
			
			_widgetlist.push(_w_border, _w_borcol);
			
			
			_w_shadows = new EditCompButton();
			_ynbuttons.push(_w_shadows);
			
			_bar_shadows = new EditBar("Shadows",
			"Decide whether or not a piece will drop a shadow, telling you where it will land.",
			PreviewPlayStagePiece,
			function():void
			{
				setYNButtonLabel(_w_shadows);
			});
			_bar_shadows.addWidget(_w_shadows);
			_barlists[PAGE_PIECE].push(_bar_shadows);
			
			_widgetlist.push(_w_shadows);
			_scoreresetters.push(_w_shadows);
			
			
			_w_invis = new EditCompCombo();
			_dp_invis = [
			{label:"Off", data:[false, false]},
			{label:"While falling", data:[false, true]},
			{label:"Once landed", data:[true, false]},
			{label:"Always", data:[true, true]}
			];
			_w_invis.dataProvider = new DataProvider(_dp_invis);
			
			_bar_invis = new EditBar("Invisibility",
			"Decide if & when pieces become invisible.",
			null, null);
			_bar_invis.addWidget(_w_invis);
			_barlists[PAGE_PIECE].push(_bar_invis);
			
			_widgetlist.push(_w_invis);
			_scoreresetters.push(_w_invis);
			
			
			_w_clearstyle = new EditCompCombo();
			_w_clearstyle.dataProvider = new DataProvider(Settings.CLEAR_NAMES.slice());
			
			_bar_clearstyle = new EditBar("Clear Animation",
			"Choose the animation that will be applied to cleared tiles.",
			PreviewPlayStageClear, null);
			_bar_clearstyle.addWidget(_w_clearstyle);
			_barlists[PAGE_PIECE].push(_bar_clearstyle);
			
			_widgetlist.push(_w_clearstyle);
			
			
			_w_lives = new EditCompStepper();
			_w_lives.minimum = 0;
			_w_lives.maximum = Settings.MAX_NUM_LIVES;
			_w_lives.width = NS_WID;
			addChangeListener(_w_lives, livesUpdates);
			
			_bar_lives = new EditBar("Lives",
			"Set the number of times you can fail before getting a Game Over.",
			null, function():void
			{
				livesUpdates();
			});
			_bar_lives.addWidget(_w_lives);
			_barlists[PAGE_RULES].push(_bar_lives);
			
			_widgetlist.push(_w_lives);
			_scoreresetters.push(_w_lives);
			
			
			_w_chances = new EditCompStepper();
			_w_chances.minimum = 0;
			_w_chances.maximum = Settings.MAX_NUM_CHANCES;
			_w_chances.width = NS_WID;
			addChangeListener(_w_chances, chancesUpdates);
			
			_bar_chances = new EditBar("Fit Chances",
			"(Fit Mode setting) Set the number of invalid piece placements you can make before losing a life.",
			null, function():void
			{
				chancesUpdates();
			});
			_bar_chances.addWidget(_w_chances);
			_barlists[PAGE_RULES].push(_bar_chances);
			
			_widgetlist.push(_w_chances);
			_scoreresetters.push(_w_chances);
			
			
			_w_loselife = new EditCompCombo();
			_dp_loselife = [
			{label:"None", data:[false, false]},
			{label:"Reset Score", data:[false, true]},
			{label:"Reset Level", data:[true, false]},
			{label:"Reset All", data:[true, true]}
			];
			_w_loselife.dataProvider = new DataProvider(_dp_loselife);
			
			_bar_loselife = new EditBar("Lose Life Penalty",
			"Choose the penalty that will be applied whenever you lose a life. (No penalty is applied when you get a Game Over.)",
			null, null);
			_bar_loselife.addWidget(_w_loselife);
			_barlists[PAGE_RULES].push(_bar_loselife);
			
			_widgetlist.push(_w_loselife);
			_scoreresetters.push(_w_loselife);
			
			
			_w_timelimittog = new EditCompButton();
			_ynbuttons.push(_w_timelimittog);
			addChangeListener(_w_timelimittog, timelimitUpdates);
			
			_w_timelimitval = new EditCompStepper();
			_w_timelimitval.minimum = Settings.MIN_TIMELIMIT;
			_w_timelimitval.maximum = Settings.MAX_TIMELIMIT;
			
			_bar_timelimit = new EditBar("Time Limit",
			"You may apply a time limit (in seconds) on this mode. If you do, the game will end when time is up.",
			null, function():void
			{
				setYNButtonLabel(_w_timelimittog);
				timelimitUpdates();
			});
			_bar_timelimit.addWidget(_w_timelimittog);
			_bar_timelimit.addWidget(_w_timelimitval);
			_barlists[PAGE_RULES].push(_bar_timelimit);
			
			_widgetlist.push(_w_timelimittog, _w_timelimitval);
			_scoreresetters.push(_w_timelimittog, _w_timelimitval);
			
			
			_w_tlvlupbonus = new EditCompArray();
			_w_tlvlupbonus.WidgetType = EditCompStepper;
			_w_tlvlupbonus.poptitle = "Edit Level Up Time Extend:";
			_w_tlvlupbonus.bartitle = "To Level %d";
			_w_tlvlupbonus.zeroindexed = false;
			_w_tlvlupbonus.props = [0, Settings.MAX_SCOREUPTINY];
			_w_tlvlupbonus.maxnum = Settings.MAX_NUM_LEVELS;
			
			_bar_tlvlupbonus = new EditBar("Level Up Time Extend", "Choose how much extra time will be awarded whenever you level up.", null, null);
			_bar_tlvlupbonus.addWidget(_w_tlvlupbonus);
			_barlists[PAGE_RULES].push(_bar_tlvlupbonus);
			
			_widgetlist.push(_w_tlvlupbonus);
			_scoreresetters.push(_w_tlvlupbonus);
			
			
			_w_levelupreq = new EditCompCombo();
			_dp_levelupreq = [
			{label:"Clears", data:Settings.L_NUMCLEARS},
			{label:"Tile clears", data:Settings.L_TILECLEARS},
			{label:"Pieces set", data:Settings.L_PIECESETS},
			{label:"Tiles set", data:Settings.L_TILESETS},
			{label:"Time", data:Settings.L_TIME},
			{label:"Score", data:Settings.L_SCORE}
			];
			_w_levelupreq.dataProvider = new DataProvider(_dp_levelupreq);
			
			_w_levelupamount = new EditCompArray();
			_w_levelupamount.WidgetType = EditCompStepper;
			_w_levelupamount.poptitle = "Edit Level Up Amounts:";
			_w_levelupamount.bartitle = "To Level %d";
			_w_levelupamount.zeroindexed = false;
			_w_levelupamount.props = [1, Settings.MAX_LEVELUPREQ];
			_w_levelupamount.maxnum = Settings.MAX_NUM_LEVELS;
			
			_bar_levelupreq = new EditBar("Lvl Up Reqs",
			"Determine what kind of action is required for you to level up, and how many times it must be performed to get to each next level.",
			null, null); //Todo?
			_bar_levelupreq.addWidget(_w_levelupreq);
			_bar_levelupreq.addWidget(_w_levelupamount);
			_barlists[PAGE_RULES].push(_bar_levelupreq);
			
			_widgetlist.push(_w_levelupreq, _w_levelupamount);
			_scoreresetters.push(_w_levelupreq, _w_levelupamount);
			
			
			_w_levelmax = new EditCompStepper();
			_w_levelmax.minimum = 1; //Always allow one level up to happen.
			_w_levelmax.maximum = Settings.MAX_NUM_LEVELS;
			_w_levelmax.width = NS_WID;
			
			_w_levelmaxwin = new EditCompCheck();
			_w_levelmaxwin.labelPlacement = ButtonLabelPlacement.LEFT;
			_w_levelmaxwin.label = "Win at Max";
			_w_levelmaxwin.width = _w_levelmaxwin.textField.width + 50;
			addChangeListener(_w_levelmaxwin, winnableUpdates);
			
			_bar_levelmax = new EditBar("Max Level",
			"Set the highest possible level that can be reached. Also decide if you can win the game by reaching this max level.",
			null, function():void
			{
				winnableUpdates();
			});
			_bar_levelmax.addWidget(_w_levelmax);
			_bar_levelmax.addWidget(_w_levelmaxwin);
			_barlists[PAGE_RULES].push(_bar_levelmax);
			
			_widgetlist.push(_w_levelmax, _w_levelmaxwin);
			_scoreresetters.push(_w_levelmax, _w_levelmaxwin);
			
			
			_w_winbonus = new EditCompStepper();
			_w_winbonus.minimum = 0;
			_w_winbonus.maximum = Settings.MAX_SCOREUP;
			
			_bar_winbonus = new EditBar("Win Bonus",
			"Decide how many points are awarded when you win the game.",
			null, null);
			_bar_winbonus.addWidget(_w_winbonus);
			_barlists[PAGE_RULES].push(_bar_winbonus);
			
			_widgetlist.push(_w_winbonus);
			_scoreresetters.push(_w_winbonus);
			
			
			_w_winbonuslives = new EditCompStepper();
			_w_winbonuslives.minimum = 0;
			_w_winbonuslives.maximum = Settings.MAX_SCOREUP;
			
			_bar_winbonuslives = new EditBar("Rem. Lives Bonus",
			"Choose how many points you will be awarded for each leftover life you have when you win.",
			null, null);
			_bar_winbonuslives.addWidget(_w_winbonuslives);
			_barlists[PAGE_RULES].push(_bar_winbonuslives);
			
			_widgetlist.push(_w_winbonuslives);
			_scoreresetters.push(_w_winbonuslives);
			
			
			_w_winbonuschances = new EditCompStepper();
			_w_winbonuschances.minimum = 0;
			_w_winbonuschances.maximum = Settings.MAX_SCOREUP;
			
			_bar_winbonuschances = new EditBar("Rem. Fit Chances Bonus",
			"(Fit Mode setting) Choose how many points you will be awarded for each leftover fit chance you have when you win.",
			null, null);
			_bar_winbonuschances.addWidget(_w_winbonuschances);
			_barlists[PAGE_RULES].push(_bar_winbonuschances);
			
			_widgetlist.push(_w_winbonuschances);
			_scoreresetters.push(_w_winbonuschances);
			
			
			_w_winbonustime = new EditCompStepper();
			_w_winbonustime.minimum = 0;
			_w_winbonustime.maximum = Settings.MAX_SCOREUPTINY;
			
			_bar_winbonustime = new EditBar("Rem. Time Bonus",
			"Choose how many points you will be awarded for each leftover second you have when you win.",
			null, null);
			_bar_winbonustime.addWidget(_w_winbonustime);
			_barlists[PAGE_RULES].push(_bar_winbonustime);
			
			_widgetlist.push(_w_winbonustime);
			_scoreresetters.push(_w_winbonustime);
			
			
			_dp_levelmulttype = [
			{label:"Level multiplier"},
			{label:"Custom per level"}
			];
			
			
			_w_levelmulttype = new EditCompCombo();
			_w_levelmulttype.dataProvider = new DataProvider(_dp_levelmulttype);
			_w_levelmulttype.width *= 1.1;
			addChangeListener(_w_levelmulttype, updateLevelMultType);
			
			_bar_levelmulttype = new EditBar("Level Mult Type",
			"Choose the kind of multipler that the current level will apply to points earned from making clears.",
			null, function():void
			{
				updateLevelMultType();
			});
			_bar_levelmulttype.addWidget(_w_levelmulttype);
			_barlists[PAGE_RULES].push(_bar_levelmulttype);
			
			_widgetlist.push(_w_levelmulttype);
			_scoreresetters.push(_w_levelmulttype);
			
			
			_w_levelmultauto = new EditCompStepper();
			_w_levelmultauto.minimum = Settings.MIN_LEVELMULT;
			_w_levelmultauto.maximum = Settings.MAX_LEVELMULT;
			_w_levelmultauto.stepSize = Settings.STEP_LEVELMULT;
			_w_levelmultauto.width = NS_WID;
			
			_bar_levelmultauto = new EditBar("Level Multiplier", "Points awarded for clearing tiles will be multiplied by the entered value x the current level + 1.", null, null);
			_bar_levelmultauto.addWidget(_w_levelmultauto, "(1+Level)x");
			_barlists[PAGE_RULES].push(_bar_levelmultauto);
			
			_widgetlist.push(_w_levelmultauto);
			_scoreresetters.push(_w_levelmultauto);
			
			
			_w_levelmultcustom = new EditCompArray();
			_w_levelmultcustom.WidgetType = EditCompStepper;
			_w_levelmultcustom.poptitle = "Edit Custom Level Multiplier:";
			_w_levelmultcustom.bartitle = "Level %d";
			_w_levelmultcustom.maxnum = Settings.MAX_NUM_LEVELS + 1;
			_w_levelmultcustom.props = [Settings.MIN_LEVELMULT, Settings.MAX_LEVELMULT, Settings.STEP_LEVELMULT];
			
			_bar_levelmultcustom = new EditBar("Custom Lvl Multiplier", "For each level, Choose the multiplier that will be applied to clear points.", null, null);
			_bar_levelmultcustom.addWidget(_w_levelmultcustom);
			_barlists[PAGE_RULES].push(_bar_levelmultcustom);
			
			_widgetlist.push(_w_levelmultcustom);
			_scoreresetters.push(_w_levelmultcustom);
			
			
			//--
			_w_tlevelmulttype = new EditCompCombo();
			_w_tlevelmulttype.dataProvider = new DataProvider(_dp_levelmulttype);
			_w_tlevelmulttype.width *= 1.1;
			addChangeListener(_w_tlevelmulttype, updateTLevelMultType);
			
			_bar_tlevelmulttype = new EditBar("Time LMult Type",
			"Choose the kind of multipler that the current level will apply to extra time awarded from making clears.",
			null, function():void
			{
				updateTLevelMultType();
			});
			_bar_tlevelmulttype.addWidget(_w_tlevelmulttype);
			_barlists[PAGE_RULES].push(_bar_tlevelmulttype);
			
			_widgetlist.push(_w_tlevelmulttype);
			_scoreresetters.push(_w_tlevelmulttype);
			
			
			_w_tlevelmultauto = new EditCompStepper();
			_w_tlevelmultauto.minimum = Settings.MIN_LEVELMULT;
			_w_tlevelmultauto.maximum = Settings.MAX_LEVELMULT;
			_w_tlevelmultauto.stepSize = Settings.STEP_LEVELMULT;
			_w_tlevelmultauto.width = NS_WID;
			
			_bar_tlevelmultauto = new EditBar("Time Lvl Mult", "Time awarded for clearing tiles will be multiplied by the entered value x the current level + 1.", null, null);
			_bar_tlevelmultauto.addWidget(_w_tlevelmultauto, "(1+Level)x");
			_bar_tlevelmulttype.reliers.push(_bar_tlevelmultauto);
			_barlists[PAGE_RULES].push(_bar_tlevelmultauto);
			
			_widgetlist.push(_w_tlevelmultauto);
			_scoreresetters.push(_w_tlevelmultauto);
			
			
			_w_tlevelmultcustom = new EditCompArray();
			_w_tlevelmultcustom.WidgetType = EditCompStepper;
			_w_tlevelmultcustom.poptitle = "Edit Custom Time Level Multiplier:";
			_w_tlevelmultcustom.bartitle = "Level %d";
			_w_tlevelmultcustom.maxnum = Settings.MAX_NUM_LEVELS + 1;
			_w_tlevelmultcustom.props = [Settings.MIN_LEVELMULT, Settings.MAX_LEVELMULT, Settings.STEP_LEVELMULT];
			_bar_tlevelmultcustom = new EditBar("C.Time Lvl Multiplier", "For each level, choose the multiplier that will be applied to time awarded due to clears.", null, null);
			_bar_tlevelmultcustom.addWidget(_w_tlevelmultcustom);
			_bar_tlevelmulttype.reliers.push(_bar_tlevelmultcustom);
			_barlists[PAGE_RULES].push(_bar_tlevelmultcustom);
			
			_widgetlist.push(_w_tlevelmultcustom);
			_scoreresetters.push(_w_tlevelmultcustom);
			//--
			
			
			_dp_cpointstyle = [
			{label:"Clear Groups"},
			{label:"Tiles Cleared"}
			];
			
			
			_w_cpointstyle = new EditCompCombo();
			_w_cpointstyle.dataProvider = new DataProvider(_dp_cpointstyle);
			addChangeListener(_w_cpointstyle, updateCPointStyle);
			
			_bar_cpointstyle = new EditBar("Clear Point Style",
			"Choose whether points will be awarded based on groups of clears (the number of multiple rectangle clears, or the thickness of cleared lines), or on the number of tiles cleared at once.",
			null, function():void
			{
				updateCPointStyle();
			});
			_bar_cpointstyle.addWidget(_w_cpointstyle);
			_barlists[PAGE_RULES].push(_bar_cpointstyle);
			
			_widgetlist.push(_w_cpointstyle);
			_scoreresetters.push(_w_cpointstyle);
			
			
			_w_clearpoints = new EditCompArray();
			_w_clearpoints.WidgetType = EditCompStepper;
			_w_clearpoints.poptitle = "Edit Clear Points:";
			_w_clearpoints.bartitle = "%d Clear[s]";
			_w_clearpoints.zeroindexed = false;
			_w_clearpoints.maxnum = Settings.MAX_BINY; //Don't update this to prevent deleting data when resetting to default.
			_w_clearpoints.props = [0, Settings.MAX_SCOREUP]; //min, max
			
			_bar_clearpoints = new EditBar("Clear Group Points", "Decide how many points are awarded for performing clears, and groups of clears.", null, null);
			_bar_clearpoints.addWidget(_w_clearpoints);
			_barlists[PAGE_RULES].push(_bar_clearpoints);
			
			_widgetlist.push(_w_clearpoints);
			_scoreresetters.push(_w_clearpoints);
			
			
			_w_tilepoints = new EditCompStepper();
			_w_tilepoints.minimum = 1;
			_w_tilepoints.maximum = Settings.MAX_SCOREUPTINY;
			
			_bar_tilepoints = new EditBar("Tile Clear Points", "Decide how many points are awarded by each cleared tile.", null, null);
			_bar_tilepoints.addWidget(_w_tilepoints);
			_barlists[PAGE_RULES].push(_bar_tilepoints);
			
			_widgetlist.push(_w_tilepoints);
			_scoreresetters.push(_w_tilepoints);
			
			
			//--
			_w_ctimestyle = new EditCompCombo();
			_w_ctimestyle.dataProvider = new DataProvider(_dp_cpointstyle);
			addChangeListener(_w_ctimestyle, updateCTimeStyle);
			
			_bar_ctimestyle = new EditBar("Clear Time Style",
			"Choose whether extra time will be awarded based on groups of clears (the number of multiple rectangle clears, or the thickness of cleared lines), or on the number of tiles cleared at once.",
			null, function():void
			{
				updateCTimeStyle();
			});
			_bar_ctimestyle.addWidget(_w_ctimestyle);
			_barlists[PAGE_RULES].push(_bar_ctimestyle);
			
			_widgetlist.push(_w_ctimestyle);
			_scoreresetters.push(_w_ctimestyle);
			
			
			_w_cleartime = new EditCompArray();
			_w_cleartime.WidgetType = EditCompStepper;
			_w_cleartime.poptitle = "Edit Clear Time Additions:";
			_w_cleartime.bartitle = "%d Clear[s]";
			_w_cleartime.zeroindexed = false;
			_w_cleartime.maxnum = Settings.MAX_BINY; //Don't update this to prevent deleting data when resetting to default.
			_w_cleartime.props = [0, Settings.MAX_SCOREUPTINY]; //min, max
			
			_bar_cleartime = new EditBar("Clear Group Time", "Decide how much extra time is awarded for performing clears, and groups of clears.", null, null);
			_bar_cleartime.addWidget(_w_cleartime);
			_bar_ctimestyle.reliers.push(_bar_cleartime);
			_barlists[PAGE_RULES].push(_bar_cleartime);
			
			_widgetlist.push(_w_cleartime);
			_scoreresetters.push(_w_cleartime);
			
			
			_w_tiletime = new EditCompStepper();
			_w_tiletime.minimum = 1;
			_w_tiletime.maximum = Settings.MAX_SCOREUPTINY;
			
			_bar_tiletime = new EditBar("Tile Clear Time", "Decide how much extra time is awarded by each cleared tile.", null, null);
			_bar_tiletime.addWidget(_w_tiletime);
			_bar_ctimestyle.reliers.push(_bar_tiletime);
			_barlists[PAGE_RULES].push(_bar_tiletime);
			
			_widgetlist.push(_w_tiletime);
			_scoreresetters.push(_w_tiletime);
			//--
			
			
			_w_backbonustog = new EditCompButton();
			_ynbuttons.push(_w_backbonustog);
			addChangeListener(_w_backbonustog, enableBackBonus);
			
			_w_backbonusval = new EditCompArray();
			_w_backbonusval.WidgetType = EditCompStepper;
			_w_backbonusval.poptitle = "Edit Back to Back Multiplier:";
			_w_backbonusval.bartitle = "%dth Clear";
			_w_backbonusval.zeroindexed = false;
			_w_backbonusval.maxnum = Settings.MAX_BONUSCOUNT;
			_w_backbonusval.props = [Settings.MIN_BONUS, Settings.MAX_BONUS, Settings.STEP_BONUS];
			
			_bar_backbonus = new EditBar("B2B Mult", "Set the bonus multipliers for successively making a series of back-to-back clears. (The multiplier is reset when you set a piece without making a clear.)",
			null, function():void
			{
				setYNButtonLabel(_w_backbonustog);
				enableBackBonus();
			});
			_bar_backbonus.addWidget(_w_backbonustog);
			_bar_backbonus.addWidget(_w_backbonusval);
			_barlists[PAGE_RULES].push(_bar_backbonus);
			
			_widgetlist.push(_w_backbonustog, _w_backbonusval);
			_scoreresetters.push(_w_backbonustog, _w_backbonusval);
			
			
			_w_tbackbonusval = new EditCompArray();
			_w_tbackbonusval.WidgetType = EditCompStepper;
			_w_tbackbonusval.poptitle = "Edit Back to Back Time Multiplier:";
			_w_tbackbonusval.bartitle = "%dth Clear";
			_w_tbackbonusval.zeroindexed = false;
			_w_tbackbonusval.maxnum = Settings.MAX_BONUSCOUNT;
			_w_tbackbonusval.props = [Settings.MIN_BONUS, Settings.MAX_BONUS, Settings.STEP_BONUS];
			
			_bar_tbackbonus = new EditBar("B2B Time Mult", "Set the bonus multipliers (applied to added time) for successively making a series of back-to-back clears. (The multiplier is reset when you set a piece without making a clear.)", null, null);
			_bar_tbackbonus.addWidget(_w_tbackbonusval);
			_barlists[PAGE_RULES].push(_bar_tbackbonus);
			
			_widgetlist.push(_w_tbackbonusval);
			_scoreresetters.push(_w_tbackbonusval);
			
			
			_w_multibonus = new EditCompArray();
			_w_multibonus.WidgetType = EditCompStepper;
			_w_multibonus.poptitle = "Edit Multi-Clear Multiplier:";
			_w_multibonus.bartitle = "%dth Clear";
			_w_multibonus.zeroindexed = false;
			_w_multibonus.maxnum = Settings.MAX_BONUSCOUNT;
			_w_multibonus.props = [Settings.MIN_BONUS, Settings.MAX_BONUS, Settings.STEP_BONUS];
			
			_bar_multibonus = new EditBar("Multi-Clear Mult", "Set the bonus multipliers for making multiple clears during the same clear countdown. (The multipler is reset when tiles are cleared.) NOTE: This is only available when Clear Freeze is turned off!", null, null);
			_bar_multibonus.addWidget(_w_multibonus);
			_barlists[PAGE_RULES].push(_bar_multibonus);
			
			_widgetlist.push(_w_multibonus);
			_scoreresetters.push(_w_multibonus);
			
			
			_w_tmultibonus = new EditCompArray();
			_w_tmultibonus.WidgetType = EditCompStepper;
			_w_tmultibonus.poptitle = "Edit Multi-Clear Time Multiplier:";
			_w_tmultibonus.bartitle = "%dth Clear";
			_w_tmultibonus.zeroindexed = false;
			_w_tmultibonus.maxnum = Settings.MAX_BONUSCOUNT;
			_w_tmultibonus.props = [Settings.MIN_BONUS, Settings.MAX_BONUS, Settings.STEP_BONUS];
			
			_bar_tmultibonus = new EditBar("Multi-Clear Time Mult", "Set the multipliers (applied to added time) for making multiple clears during the same clear countdown. (The multipler is reset when tiles are cleared.) NOTE: This is only available when Clear Freeze is turned off!", null, null);
			_bar_tmultibonus.addWidget(_w_tmultibonus);
			_bar_multibonus.reliers.push(_bar_tmultibonus);
			_barlists[PAGE_RULES].push(_bar_tmultibonus);
			
			_widgetlist.push(_w_tmultibonus);
			_scoreresetters.push(_w_tmultibonus);
			
			
			_w_gravbonus = new EditCompArray();
			_w_gravbonus.WidgetType = EditCompStepper;
			_w_gravbonus.poptitle = "Edit Gravity Clear Multiplier:";
			_w_gravbonus.bartitle = "%dth Clear";
			_w_gravbonus.zeroindexed = false;
			_w_gravbonus.maxnum = Settings.MAX_BONUSCOUNT;
			_w_gravbonus.props = [Settings.MIN_BONUS, Settings.MAX_BONUS, Settings.STEP_BONUS];
			
			_bar_gravbonus = new EditBar("Gravity Clear Mult", "Set the bonus multipliers for making multiple clears with tiles falling due to gravity. (The multipler is reset when all tiles have landed.)", null, null);
			_bar_gravbonus.addWidget(_w_gravbonus);
			_barlists[PAGE_RULES].push(_bar_gravbonus);
			
			_widgetlist.push(_w_gravbonus);
			_scoreresetters.push(_w_gravbonus);
			
			
			_w_tgravbonus = new EditCompArray();
			_w_tgravbonus.WidgetType = EditCompStepper;
			_w_tgravbonus.poptitle = "Edit Gravity Clear Time Multiplier:";
			_w_tgravbonus.bartitle = "%dth Clear";
			_w_tgravbonus.zeroindexed = false;
			_w_tgravbonus.maxnum = Settings.MAX_BONUSCOUNT;
			_w_tgravbonus.props = [Settings.MIN_BONUS, Settings.MAX_BONUS, Settings.STEP_BONUS];
			
			_bar_tgravbonus = new EditBar("Grav Clear Time Mult", "Set the bonus multipliers (applied to added time) for making multiple clears with tiles falling due to gravity. (The multipler is reset when all tiles have landed.)", null, null);
			_bar_tgravbonus.addWidget(_w_tgravbonus);
			_bar_gravbonus.reliers.push(_bar_tgravbonus);
			_barlists[PAGE_RULES].push(_bar_tgravbonus);
			
			_widgetlist.push(_w_tgravbonus);
			_scoreresetters.push(_w_tgravbonus);
			
			
			_w_setbonustype = new EditCompCombo();
			_dp_setbonustype = [
			{label:"Per Piece"},
			{label:"Per Tile"}
			];
			_w_setbonustype.dataProvider = new DataProvider(_dp_setbonustype);
			
			_w_setbonusval = new EditCompStepper();
			_w_setbonusval.minimum = 0;
			_w_setbonusval.maximum = Settings.MAX_SCOREUPTINY;
			
			_bar_setbonus = new EditBar("Set Bonus", "Decide how many points are awarded for setting each piece/tile into the bin.", null, null);
			_bar_setbonus.addWidget(_w_setbonustype);
			_bar_setbonus.addWidget(_w_setbonusval);
			_barlists[PAGE_RULES].push(_bar_setbonus);
			
			_widgetlist.push(_w_setbonustype, _w_setbonusval);
			_scoreresetters.push(_w_setbonustype, _w_setbonusval);
			
			
			_w_fastdropbonus = new EditCompStepper();
			_w_fastdropbonus.minimum = 0;
			_w_fastdropbonus.maximum = Settings.MAX_SCOREUPTINY;
			
			_bar_fastdropbonus = new EditBar("Fast Drop Bonus", "Decide how many points are awarded for fast dropping a piece by 1 row.", null, null);
			_bar_fastdropbonus.addWidget(_w_fastdropbonus);
			_bar_fastdrop.reliers.push(_bar_fastdropbonus);
			_barlists[PAGE_RULES].push(_bar_fastdropbonus);
			
			_widgetlist.push(_w_fastdropbonus);
			_scoreresetters.push(_w_fastdropbonus);
			
			
			_w_instdropbonus = new EditCompStepper();
			_w_instdropbonus.minimum = 0;
			_w_instdropbonus.maximum = Settings.MAX_SCOREUPTINY;
			
			_bar_instdropbonus = new EditBar("Instant Drop Bonus", "Decide how many points are awarded for instant dropping a piece for each row that it drops by.", null, null);
			_bar_instdropbonus.addWidget(_w_instdropbonus);
			_bar_instdrop.reliers.push(_bar_instdropbonus);
			_barlists[PAGE_RULES].push(_bar_instdropbonus)
			
			_widgetlist.push(_w_instdropbonus);
			_scoreresetters.push(_w_instdropbonus);
			
			
			_w_szonebonus = new EditCompStepper();
			_w_dzonebonus = new EditCompStepper();
			_w_szonebonus.stepSize = _w_dzonebonus.stepSize = Settings.STEP_ZONEMULT;
			_w_szonebonus.minimum = _w_dzonebonus.minimum = Settings.MIN_ZONEMULT;
			_w_szonebonus.maximum = _w_dzonebonus.maximum = Settings.MAX_ZONEMULT;
			_w_szonebonus.width = _w_dzonebonus.width = NS_WID;
			
			_bar_zonebonus = new EditBar("Zone Bonus",
			"Set the bonus you will receive for making clearing while the highest tile in the bin is in the specified zone.",
			PreviewPlayStage, null);
			_bar_zonebonus.addWidget(_w_szonebonus, "Safe:");
			_bar_zonebonus.addWidget(_w_dzonebonus, "Danger:");
			_bar_zones.reliers.push(_bar_zonebonus);
			_barlists[PAGE_RULES].push(_bar_zonebonus);
			
			_widgetlist.push(_w_szonebonus, _w_dzonebonus);
			_scoreresetters.push(_w_szonebonus, _w_dzonebonus);
			
			//------------End of widget setup------------//
			
			setDefaults();
			for each (var button:Button in _ynbuttons)
			{
				button.toggle = true;
				button.addEventListener(Event.CHANGE, updateYNButtonLabel);
			}
			
			var tabholder:Sprite = new Sprite();
			var xnext:Number = 0;
			const tabmargin:Number = -5;
			for (i = 0; i < NUM_PAGES; i++)
			{
				var tabbutton:TextButton = new TextButton(NAME_PAGES[i], ButtonBackTab, 0xFFFFFF, 12);
				tabbutton.id = i;
				tabbutton.addEventListener(MouseEvent.CLICK, selectPane);
				tabbutton.x = xnext;
				xnext += tabbutton.width + tabmargin;
				tabbutton.y = _tabhidey;
				tabholder.addChildAt(tabbutton, 0);
				_tabbuttons[i] = tabbutton;
			}
			addChild(tabholder);
			
			//Do all default bar initialization.
			for (i = 0; i < NUM_PAGES; i++)
			{
				Main.stage.addChild(_panelist[i]); //Do this so components don't complain about not having a reference to the stage.
				for each (var bar:EditBarBase in _barlists[i])
				{
					_panelist[i].addChildAt(bar, 0);
					bar.setUp();
					if (bar is EditBar)
					{
						EditBar(bar).doUndoFunction();
						if (bar != _bar_addpiece) //Don't do default updates with this bar.
							EditBar(bar).addUndoListener(updateMode);
					}
				}
				Main.stage.removeChild(_panelist[i]);
			}
			
			//Place all bars.
			var ytop:Number;
			for (i = 0; i < NUM_PAGES; i++)
			{
				ytop = 0;
				for each (var bar:EditBarBase in _barlists[i])
				{
					var available:Boolean = !bar.unused && !bar.hidden;
					bar.tabChildren = available;
					bar.tabEnabled = available;
					bar.mouseEnabled = available;
					if (available)
					{
						bar.addEventListener(MouseEvent.CLICK, setSelected);
						bar.addEventListener(MouseEvent.ROLL_OVER, barHoverOver);
						bar.addEventListener(MouseEvent.ROLL_OUT, barHoverOut);
						bar.y = ytop;
						ytop += bar.height;
					}
					else {
						bar.y = ytop - bar.height;
					}
				}
			}
			_piecebank.parent.addChildAt(_piecebank, 0); //Place this at the back.
			_defaultset = true;
			
			//Keep the edited mode updated with every change made.
			for each (var widget:IEditComponent in _widgetlist)
				UIComponent(widget).addEventListener(Event.CHANGE, updateMode);
			
			_scrollpane.x = tabholder.x;
			_scrollpane.y = tabholder.y + tabholder.height;
			addChild(_scrollpane);
			
			_currentpage = PAGE_GEN;
			_piecebank.playing = false; //since not on piece page
			_tabbuttons[_currentpage].y -= _tabhidey;
			addEventListener(Event.ENTER_FRAME, updateScroller);
		}
		
		private function updateYNButtonLabel(e:Event):void
		{
			setYNButtonLabel(Button(e.target));
		}
		
		private function setYNButtonLabel(button:Button):void
		{
			button.label = button.selected ? "On" : "Off";
		}
		
		private function updateScroller(e:Event = null):void
		{
			updateBarPositions();
			
			_scrollpane.source = _panelist[_currentpage];
			_scrollpane.validateNow();
			if (Key.isDown(Keyboard.LEFT) || Key.isDown(Keyboard.RIGHT))
				_scrollpane.horizontalScrollPosition = 0;
			if (Key.isDown(Keyboard.HOME) || Key.isDown(Keyboard.END))
				_scrollpane.verticalScrollPosition = _scrollpsave;
			
			//TODO: if it's important enough, make it so that the focused component is scrolled to if it's out of visible range. (It isn't.)
			/*if (Main.stage.focus is UIComponent)
			{
				var focusComp:UIComponent = UIComponent(Main.stage.focus);
			}*/
			
			_scrollpsave = _scrollpane.verticalScrollPosition;
		}
		
		private function selectPane(e:MouseEvent):void
		{
			_scrollposs[_currentpage] = _scrollpane.verticalScrollPosition;
			_tabbuttons[_currentpage].y += _tabhidey;
			var tabbutton:TextButton = TextButton(e.target.parent);
			tabbutton.parent.addChild(tabbutton); //to put it on top of the display list
			tabbutton.y -= _tabhidey;
			_currentpage = tabbutton.id;
			updateScroller();
			_scrollpane.verticalScrollPosition = _scrollposs[_currentpage];
			
			if (_currentpage == PAGE_PIECE)
			{
				_piecebank.playing = true;
				Main.stage.addEventListener(PopUp.E_POPUP, pausePieceBankPlaying);
				Main.stage.addEventListener(PopUp.E_POPUPGONE, startPieceBankPlaying);
			}
			else
			{
				_piecebank.playing = false;
				Main.stage.removeEventListener(PopUp.E_POPUP, pausePieceBankPlaying);
				Main.stage.removeEventListener(PopUp.E_POPUPGONE, startPieceBankPlaying);
			}
		}
		
		private function pausePieceBankPlaying(e:Event):void
		{
			_piecebank.playing = false;
		}
		private function startPieceBankPlaying(e:Event):void
		{
			_piecebank.playing = true;
		}
		
		// Widget-specific functions
		
		private function fitmodeUpdates(e:Event = null):void
		{
			setUnused(_bar_zones, _w_fitmode.selected);
			setUnused(_bar_fastdrop, _w_fitmode.selected);
			setUnused(_bar_instdrop, _w_fitmode.selected);
			setUnused(_bar_toplock, _w_fitmode.selected);
			setUnused(_bar_fitpass, !_w_fitmode.selected);
			setUnused(_bar_fitforce, !_w_fitmode.selected);
			setUnused(_bar_chances, !_w_fitmode.selected);
			enableWinBonusChances();
		}
		
		private function checkLine(e:Event):void
		{
			if (_w_clearline.selected)
			{
				_w_clearwid.value = _w_binwid.value;
				updateClearArea();
				updateMode();
			}
		}
		
		private function uncheckLine(e:Event):void
		{
			_w_clearline.selected = false;
		}
		
		private function checkTopspawn(e:Event):void
		{
			if (_w_spawntop.selected)
			{
				_w_spawnposy.value = _w_spawnposy.maximum;
				updateMode();
			}
		}
		
		private function uncheckTopspawn(e:Event):void
		{
			_w_spawntop.selected = false;
		}
		
		private function updateClearArea(e:Event = null):void
		{
			_w_clearwid.maximum = _w_binwid.value;
			_w_clearlen.maximum = _w_binlen.value;
			
			if ((_w_binwid.value < _w_clearwid.value) || _w_clearline.selected)
				_w_clearwid.value = _w_binwid.value;
			if (_w_binlen.value < _w_clearlen.value)
				_w_clearlen.value = _w_binlen.value;
			
			updateExtendable();
			updateZoneLimits();
			updateSpawnPos();
		}
		
		private function updateZoneLimits(e:Event = null):void
		{
			_w_szone.maximum = _w_binlen.value - _w_dzone.value - 1;
			_w_dzone.maximum = _w_binlen.value - _w_szone.value - 1;
		}
		
		private function updateSpawnPos(e:Event = null):void
		{
			_w_spawnposy.maximum = _w_binlen.value - 1;
			if (_w_spawntop.selected)
				_w_spawnposy.value = _w_spawnposy.maximum;
		}
		
		private function updateExtendable(e:Event = null):void
		{
			setUnused(_bar_extendable, (_w_clearwid.value == _w_binwid.value && (_w_clearlen.value == 1 || _w_clearlen.value == _w_binlen.value) ));
			setUnused(_bar_priority, _w_extendable.selected);
		}
		
		private function updatePriority(e:Event = null):void
		{
			setUnused(_bar_priority, _w_extendable.selected);
			//setUnused(_bar_priority, _g_extendable.selection == _w_extendableoff);
		}
		
		private function rotateUpdates(e:Event = null):void
		{
			var rotating:Boolean = _dp_rotate[_w_rotate.selectedIndex].data[0] || _dp_rotate[_w_rotate.selectedIndex].data[1];
			setUnused(_bar_rotcen, !rotating);
			setUnused(_bar_autoresrot, !rotating);
			setUnused(_bar_kicks, !rotating);
			setUnused(_bar_squeeze, !rotating);
		}
		
		private function freezeUpdates(e:Event = null):void
		{
			setUnused(_bar_spawnafterclear, !_w_freeze.selected);
			setUnused(_bar_ctimereset, _w_freeze.selected);
			setUnused(_bar_multibonus, _w_freeze.selected);
		}
		
		private function addPieceRandom(e:MouseEvent):void
		{
			if (!checkReachedMaxPieces())
			{
				_piecebank.addDefaultRandomPiece();
				notifyPieceAdded();
			}
		}
		
		private function addPieceCustom(e:MouseEvent):void
		{
			if (!checkReachedMaxPieces())
			{
				_piecebank.addDefaultCustomPiece();
				notifyPieceAdded();
			}
		}
		
		private function checkReachedMaxPieces():Boolean
		{
			if (EditPieceBank.getNumPieces() == Settings.MAX_NUM_PIECES)
			{
				PopUp.makePopUp(
				"You can have no more than " + Settings.MAX_NUM_PIECES + " unique pieces in a game at once. "
				+ "If you want to add a new piece, remove an existing piece first.",
				Vector.<String>(["Okay"]),
				Vector.<Function>([PopUp.fadeOut]));
				return true;
			}
			return false;
		}
		
		private function updateBarPositionsFromResize(e:Event):void
		{
			_dirtypanes.push(_panelist[PAGE_PIECE]);
			//updateBarPositions();
		}
		
		private function notifyPieceAdded():void
		{
			var lev:Array;
			for each (lev in _w_editlikes.data)
				lev.push(1);
			for each (lev in _w_editorder.data)
				lev.push(EditPieceBank.getNumPieces() - 1, 1);
			_w_editlikes.updateLabel();
			_w_editorder.updateLabel();
			updateMinBinSize();
			updateMode();
		}
		
		private function notifyPieceEdited(e:Event):void
		{
			updateMinBinSize();
			updateMode();
		}
		
		private function notifyPieceDeleted(e:IDEvent):void
		{
			var lev:Array;
			for each (lev in _w_editlikes.data)
				lev.splice(e.id, 1);
			for each (lev in _w_editorder.data)
			{
				for (var i:uint = 0; i < lev.length; i += 2)
				{
					if (lev[i] > e.id)
						lev[i]--;
					else if (lev[i] == e.id)
					{
						lev.splice(i, 2);
						i -= 2;
					}
				}
				//If all pieces in the spawn order have been deleted, add something so it won't be empty!
				//A 0th piece is guaranteed to exist, so use that.
				if (lev.length == 0)
					lev.push(0, 1);
			}
			
			_w_editlikes.updateLabel();
			_w_editorder.updateLabel();
			updateMinBinSize();
			updateMode();
		}
		
		/**
		 * Sets the minimum allowable width of the bin to be the width of the widest piece. Same done with height(length).
		 * @param	e
		 */
		private function updateMinBinSize():void
		{
			var maxwid:uint = 0, maxlen:uint = 0;
			for (var i:uint = 0, n:uint = EditPieceBank.getNumPieces(); i < n; i++)
			{
				var info:Array = EditPieceBank.getPieceInfo(i);
				if (info[0] is uint) //random
				{
					maxwid = Math.max(maxwid, info[1][0]);
					maxlen = Math.max(maxlen, info[1][1]);
				}
				else //custom: judge rectangular size from piece map
				{
					maxwid = Math.max(maxwid, GamePiece.getPieceSize(info[0], true));
					maxlen = Math.max(maxlen, GamePiece.getPieceSize(info[0], false));
				}
			}
			_w_binwid.minimum = maxwid;
			_w_binlen.minimum = maxlen;
		}
		
		private function updateOrderType(e:Event = null):void
		{
			var ordered:Boolean = _dp_ordered[_w_ordered.selectedIndex].data;
			setUnused(_bar_editorder, !ordered);
			setUnused(_bar_editlikes, ordered);
		}
		
		private function updateFallType(e:Event = null):void
		{
			var farr:Boolean = _w_falltype.selectedIndex == 1;
			setUnused(_bar_fallauto, farr);
			setUnused(_bar_fallcustom, !farr);
		}
		
		private function updateFallAutoLimit(e:Event = null):void
		{
			_w_fallautolimit.maximum = _w_fallautostart.value;
			_w_fallautodec.maximum = _w_fallautostart.value;
		}
		
		private function gravityUpdates(e:Event = null):void
		{
			setUnused(_bar_lump, !_w_gravity.selected);
			setUnused(_bar_gravspeed, !_w_gravity.selected);
			setUnused(_bar_gravbonus, !_w_gravity.selected);
		}
		
		private function enableBorders(e:Event = null):void
		{
			_w_borcol.enabled = _w_border.selected;
		}
		
		private function enableAutoresRot(e:Event = null):void
		{
			_w_autoresrotval.enabled = _w_autoresrottog.selected;
			setUnused(_bar_autospeedrot, !_w_autoresrottog.selected);
		}
		
		private function enableAutoresSli(e:Event = null):void
		{
			_w_autoresslival.enabled = _w_autoresslitog.selected;
			setUnused(_bar_autospeedsli, !_w_autoresslitog.selected);
		}
		
		private function livesUpdates(e:Event = null):void
		{
			setUnused(_bar_loselife, _w_lives.value == 0);
			enableWinBonusLives();
		}
		
		private function chancesUpdates(e:Event = null):void
		{
			enableWinBonusChances();
		}
		
		private function enableWinBonusLives():void
		{
			setUnused(_bar_winbonuslives, !_w_levelmaxwin.selected || _w_lives.value == 0);
		}
		
		private function enableWinBonusChances():void
		{
			setUnused(_bar_winbonuschances, !_w_levelmaxwin.selected || !_w_fitmode.selected || _w_chances.value == 0);
		}
		
		private function enableWinBonusTime():void
		{
			setUnused(_bar_winbonustime, !_w_levelmaxwin.selected || !_w_timelimittog.selected);
		}
		
		private function winnableUpdates(e:Event = null):void
		{
			setUnused(_bar_winbonus, !_w_levelmaxwin.selected);
			enableWinBonusLives();
			enableWinBonusChances();
			enableWinBonusTime();
		}
		
		private function timelimitUpdates(e:Event = null):void
		{
			_w_timelimitval.enabled = _w_timelimittog.selected;
			setUnused(_bar_tlvlupbonus, !_w_timelimittog.selected);
			setUnused(_bar_tlevelmulttype, !_w_timelimittog.selected);
			setUnused(_bar_ctimestyle, !_w_timelimittog.selected);
			
			enableTBackBonus();
			setUnused(_bar_tmultibonus, !_w_timelimittog.selected);
			setUnused(_bar_tgravbonus, !_w_timelimittog.selected);
			
			enableWinBonusTime();
		}
		
		private function updateLevelMultType(e:Event = null):void
		{
			var arr:Boolean = _w_levelmulttype.selectedIndex == 1;
			setUnused(_bar_levelmultauto, arr);
			setUnused(_bar_levelmultcustom, !arr);
		}
		
		private function updateTLevelMultType(e:Event = null):void
		{
			var arr:Boolean = _w_tlevelmulttype.selectedIndex == 1;
			setUnused(_bar_tlevelmultauto, arr);
			setUnused(_bar_tlevelmultcustom, !arr);
		}
		
		private function updateCPointStyle(e:Event = null):void
		{
			var c_t:Boolean = _w_cpointstyle.selectedIndex == 0;
			setUnused(_bar_clearpoints, !c_t);
			setUnused(_bar_tilepoints, c_t);
		}
		
		private function updateCTimeStyle(e:Event = null):void
		{
			var c_t:Boolean = _w_ctimestyle.selectedIndex == 0;
			setUnused(_bar_cleartime, !c_t);
			setUnused(_bar_tiletime, c_t);
		}
		
		private function enableBackBonus(e:Event = null):void
		{
			_w_backbonusval.enabled = _w_backbonustog.selected;
			enableTBackBonus();
		}
		
		private function enableTBackBonus():void
		{
			setUnused(_bar_tbackbonus, !_w_timelimittog.selected || !_w_backbonustog.selected);
		}
		
		// General functions
		
		private function setDefaults():void
		{
			var key:uint, i:uint; //For use later
			var found:Boolean;
			
			_piecebank.setDefaultPieceInfo(es[SettingNames.PIECES], es[SettingNames.PPROPS], es[SettingNames.PCOL], es[SettingNames.PAPP]);
			updateMinBinSize();
			
			_w_gtitle.defval = es[SettingNames.GTITLE];
			_w_gcol.defval = es[SettingNames.GCOL];
			_w_gtcol.defval = es[SettingNames.GTCOL];
			
			_w_gdesc.defval = es[SettingNames.GDESC];
			
			_w_binwid.defval = es[SettingNames.BINX];
			_w_binlen.defval = es[SettingNames.BINY];
			
			_w_binapp.defval = es[SettingNames.BINAPP];
			_w_bincol.defval = es[SettingNames.BINCOL];
			_w_bgcol.defval = es[SettingNames.BGCOL];
			
			_w_szone.defval = es[SettingNames.SZONE];
			_w_scol.defval = es[SettingNames.SCOL];
			_w_dzone.defval = es[SettingNames.DZONE];
			_w_dcol.defval = es[SettingNames.DCOL];
			
			_w_clearwid.defval = es[SettingNames.CWID];
			_w_clearlen.defval = es[SettingNames.CLEN];
			
			_w_extendable.defval = es[SettingNames.EXTENDABLE];
			_w_priority.defval = (int(es[SettingNames.BTOT]) << 1) | int(es[SettingNames.LTOR]);
			
			found = false;
			for (key = 0; key < _dp_stageside.length; key++)
			{
				if (_dp_stageside[key].data == es[SettingNames.STAGESIDE])
				{
					found = true;
					break;
				}
			}
			_w_stageside.defval = found ? key : 0; //use 'found' here just for safety. It should always be found.
			
			_w_song.defval = es[SettingNames.SONG_TYPE];
			
			_w_wallkick.defval = es[SettingNames.WALLKICK];
			_w_floorkick.defval = es[SettingNames.FLOORKICK];
			_w_ceilkick.defval = es[SettingNames.CEILKICK];
			
			_w_freeze.defval = es[SettingNames.FREEZE];
			_w_ctimereset.defval = es[SettingNames.CRESET];
			_w_squeeze.defval = es[SettingNames.SQUEEZE];
			_w_ctime.defval = es[SettingNames.CTIME] / 1000;
			
			_w_nextnum.defval = es[SettingNames.NEXTNUM];
			
			_w_shadows.defval = es[SettingNames.SHADOWS];
			
			_w_invis.defval = (int(es[SettingNames.INVISILAND]) << 1) | int(es[SettingNames.INVISIBLE]);
			
			_w_clearstyle.defval = es[SettingNames.PCLEAR];
			
			_w_fitmode.defval = es[SettingNames.FITMODE];
			_w_fitpass.defval = es[SettingNames.FITPASS];
			_w_fitforce.defval = es[SettingNames.FITFORCE];
			
			_w_fastdrop.defval = es[SettingNames.DROP];
			_w_instdrop.defval = es[SettingNames.INST];
			
			_w_holdable.defval = es[SettingNames.HOLDABLE];
			
			_w_rotate.defval = (int(!es[SettingNames.RCW]) << 1) | int(!es[SettingNames.RCCW]);
			_w_rotcen.defval = es[SettingNames.ROTCEN];
			
			_w_autoresrottog.defval = es[SettingNames.RESPROT] != -1;
			_w_autoresrotval.defval = es[SettingNames.RESPROT] != -1 ? es[SettingNames.RESPROT] / 1000 : _w_autoresrotval.value;
			found = false;
			for (key = 0; key < _dp_autospeed.length; key++)
			{
				if (_dp_autospeed[key].data == es[SettingNames.SPEEDROT])
				{
					found = true;
					break;
				}
			}
			_w_autospeedrot.defval = found ? key : 0;
			
			_w_autoresslitog.defval = es[SettingNames.RESPSLI] != -1;
			_w_autoresslival.defval = es[SettingNames.RESPSLI] != -1 ? es[SettingNames.RESPSLI] / 1000 : _w_autoresslival.value;
			found = false;
			for (key = 0; key < _dp_autospeed.length; key++)
			{
				if (_dp_autospeed[key].data == es[SettingNames.SPEEDSLI])
				{
					found = true;
					break;
				}
			}
			_w_autospeedsli.defval = found ? key : 0;
			
			_w_ordered.defval = es[SettingNames.ORDERED];
			_w_editorder.defval = es[SettingNames.PORDER];
			_w_editlikes.defval = es[SettingNames.PLIKE];
			
			_w_toplock.defval = es[SettingNames.TOPLOCK];
			_w_spawnposy.defval = es[SettingNames.SPAWNPOSY];
			found = false;
			for (key = 0; key < _dp_spawntype.length; key++)
			{
				if (_dp_spawntype[key].data == es[SettingNames.SPAWNTYPE])
				{
					found = true;
					break;
				}
			}
			_w_spawntype.defval = found ? key : 0;
			
			found = false;
			for (key = 0; key < _dp_safeshift.length; key++)
			{
				if (_dp_safeshift[key].data[0] == es[SettingNames.SAFESHIFT]
				 && _dp_safeshift[key].data[1] == es[SettingNames.TOPSHIFT]
				 && _dp_safeshift[key].data[2] == es[SettingNames.XSFIRST])
				{
					found = true;
					break;
				}
			}
			_w_safeshift.defval = found ? key : 0;
			
			_w_spawnafterclear.defval = es[SettingNames.SPAWNAFTERCLEAR];
			
			_w_cleardrop.defval = es[SettingNames.CLEARDROP];
			
			_w_falltype.defval = es[SettingNames.FARR] ? 1 : 0;
			
			_w_fallautostart.defval = es[SettingNames.FA][0] / 1000;
			_w_fallautodec.defval = es[SettingNames.FDEC] / 1000;
			_w_fallautolimit.defval = es[SettingNames.FMIN] / 1000;
			
			var fa_copy:Array = es[SettingNames.FA].slice();
			for (i = 0; i < fa_copy.length; i++)
				fa_copy[i] /= 1000;
			_w_fallcustom.defval = fa_copy;
			
			_w_gravity.defval = es[SettingNames.GRAVITY];
			_w_lump.defval = es[SettingNames.LUMP];
			_w_gravspeed.defval = es[SettingNames.FCF];
			
			_w_border.defval = es[SettingNames.BORCOL] != -1;
			_w_borcol.defval = es[SettingNames.BORCOL] != -1 ? es[SettingNames.BORCOL] : _w_borcol.selectedColor;
			
			_w_lives.defval = es[SettingNames.LIVES];
			_w_chances.defval = es[SettingNames.FITCHANCES];
			
			found = false;
			for (key = 0; key < _dp_loselife.length; key++)
			{
				if (_dp_loselife[key].data[0] == es[SettingNames.SCOREPEN]
				 && _dp_loselife[key].data[1] == es[SettingNames.LEVELPEN])
				{
					found = true;
					break;
				}
			}
			_w_loselife.defval = found ? key : 0;
			
			_w_timelimittog.defval = es[SettingNames.TIMELIMIT] != 0;
			_w_timelimitval.defval = es[SettingNames.TIMELIMIT]; //If it's 0, the stepper minimum will keep it above that.
			
			_w_tlvlupbonus.defval = es[SettingNames.TLVLUPBONUS];
			
			_w_levelmax.defval = es[SettingNames.LEVELMAX];
			_w_levelmaxwin.defval = es[SettingNames.LEVELMAXWIN];
			_w_winbonus.defval = es[SettingNames.WINBONUS];
			_w_winbonuslives.defval = es[SettingNames.WINLIVESBONUS];
			_w_winbonuschances.defval = es[SettingNames.WINCHANCESBONUS];
			_w_winbonustime.defval = es[SettingNames.WINTIMEBONUS];
			
			_w_levelupreq.defval = es[SettingNames.LEVELUPREQ];
			_w_levelupamount.defval = es[SettingNames.LEVELUPA];
			
			_w_levelmulttype.defval = es[SettingNames.LEVELMULTARR] ? 1 : 0;
			_w_levelmultauto.defval = es[SettingNames.LEVELMULT];
			_w_levelmultcustom.defval = es[SettingNames.LEVELMULTA];
			
			_w_tlevelmulttype.defval = es[SettingNames.TLEVELMULTARR] ? 1 : 0;
			_w_tlevelmultauto.defval = es[SettingNames.TLEVELMULT];
			_w_tlevelmultcustom.defval = es[SettingNames.TLEVELMULTA];
			
			_w_cpointstyle.defval = es[SettingNames.POINTC_T] ? 0 : 1;
			_w_clearpoints.defval = es[SettingNames.CLEARPOINTS];
			_w_tilepoints.defval = es[SettingNames.TILEPOINTS];
			
			_w_ctimestyle.defval = es[SettingNames.TPOINTC_T] ? 0 : 1;
			_w_cleartime.defval = es[SettingNames.TCLEARBONUS];
			_w_tiletime.defval = es[SettingNames.TTILEBONUS];
			
			_w_backbonustog.defval = es[SettingNames.BB_BONUS];
			_w_backbonusval.defval = es[SettingNames.BBCOMBOMOD];
			_w_multibonus.defval = es[SettingNames.COMBOMOD];
			_w_gravbonus.defval = es[SettingNames.GRAVCOMBOMOD];
			
			_w_tbackbonusval.defval = es[SettingNames.TBBCOMBOMOD];
			_w_tmultibonus.defval = es[SettingNames.TCOMBOMOD];
			_w_tgravbonus.defval = es[SettingNames.TGRAVCOMBOMOD];
			
			_w_setbonustype.defval = es[SettingNames.SETBONUSP_T] ? 0 : 1;
			_w_setbonusval.defval = es[SettingNames.SETBONUS];
			
			_w_fastdropbonus.defval = es[SettingNames.SOFTBONUS];
			_w_instdropbonus.defval = es[SettingNames.HARDBONUS];
			
			_w_szonebonus.defval = es[SettingNames.SZONEMULT];
			_w_dzonebonus.defval = es[SettingNames.DZONEMULT];
		}
		
		internal function updateMode(e:Event = null):void
		{
			var i:uint, n:uint;
			
			es[SettingNames.GTITLE] = _w_gtitle.text;
			es[SettingNames.GDESC] = _w_gdesc.text;
			es[SettingNames.GCOL] = _w_gcol.selectedColor;
			es[SettingNames.GTCOL] = _w_gtcol.selectedColor;
			
			es[SettingNames.BINX] = _w_binwid.value;
			es[SettingNames.BINY] = _w_binlen.value;
			es[SettingNames.CWID] = _w_clearwid.value;
			es[SettingNames.CLEN] = _w_clearlen.value;
			
			es[SettingNames.BINAPP] = _w_binapp.selectedIndex;
			es[SettingNames.BINCOL] = _w_bincol.selectedColor;
			es[SettingNames.BGCOL] = _w_bgcol.selectedColor;
			
			es[SettingNames.SZONE] = _w_szone.value;
			es[SettingNames.DZONE] = _w_dzone.value;
			es[SettingNames.SCOL] = _w_scol.selectedColor;
			es[SettingNames.DCOL] = _w_dcol.selectedColor;
			
			es[SettingNames.EXTENDABLE] = _w_extendable.selected;
			es[SettingNames.BTOT] = _dp_priority[_w_priority.selectedIndex].data[0];
			es[SettingNames.LTOR] = _dp_priority[_w_priority.selectedIndex].data[1];
			
			es[SettingNames.STAGESIDE] = _dp_stageside[_w_stageside.selectedIndex].data;
			es[SettingNames.SONG_TYPE] = _w_song.selectedIndex;
			
			es[SettingNames.WALLKICK] = _w_wallkick.selected;
			es[SettingNames.FLOORKICK] = _w_floorkick.selected;
			es[SettingNames.CEILKICK] = _w_ceilkick.selected;
			
			es[SettingNames.FREEZE] = _w_freeze.selected;
			es[SettingNames.CRESET] = _w_ctimereset.selected;
			es[SettingNames.SQUEEZE] = _w_squeeze.selected;
			es[SettingNames.CTIME] = _w_ctime.value * 1000;
			
			es[SettingNames.FITMODE] = _w_fitmode.selected;
			es[SettingNames.FITPASS] = _w_fitpass.selected;
			es[SettingNames.FITFORCE] = _w_fitforce.selected;
			
			es[SettingNames.DROP] = _w_fastdrop.selected;
			es[SettingNames.INST] = _w_instdrop.selected;
			es[SettingNames.HOLDABLE] = _w_holdable.selected;
			es[SettingNames.NEXTNUM] = _w_nextnum.value;
			es[SettingNames.SHADOWS] = _w_shadows.selected;
			
			es[SettingNames.INVISILAND] = _dp_invis[_w_invis.selectedIndex].data[0];
			es[SettingNames.INVISIBLE] = _dp_invis[_w_invis.selectedIndex].data[1];
			
			es[SettingNames.PCLEAR] = _w_clearstyle.selectedIndex;
			
			es[SettingNames.RCW] = _dp_rotate[_w_rotate.selectedIndex].data[0];
			es[SettingNames.RCCW] = _dp_rotate[_w_rotate.selectedIndex].data[1];
			es[SettingNames.ROTCEN] = _w_rotcen.selected;
			
			es[SettingNames.RESPROT] = !_w_autoresrottog.selected ? -1 : _w_autoresrotval.value * 1000;
			es[SettingNames.SPEEDROT] = _dp_autospeed[_w_autospeedrot.selectedIndex].data;
			
			es[SettingNames.RESPSLI] = !_w_autoresslitog.selected ? -1 : _w_autoresslival.value * 1000;
			es[SettingNames.SPEEDSLI] = _dp_autospeed[_w_autospeedsli.selectedIndex].data;
			
			var pieces:Array = [];
			var pprops:Array = [];
			var pcol:Array = [];
			var papp:Array = [];
			for (i = 0, n = EditPieceBank.getNumPieces(); i < n; i++)
			{
				var info:Array = EditPieceBank.getPieceInfo(i);
				pieces.push(info[0]);
				pprops.push(info[1]);
				pcol.push(info[2]);
				papp.push(info[3]);
			}
			//All copies, so safe to assign.
			es[SettingNames.PIECES] = pieces;
			es[SettingNames.PPROPS] = pprops;
			es[SettingNames.PCOL] = pcol;
			es[SettingNames.PAPP] = papp;
			
			G.arrayCopy2D(es[SettingNames.PLIKE], _w_editlikes.data as Array);
			G.arrayCopy2D(es[SettingNames.PORDER], _w_editorder.data as Array);
			
			es[SettingNames.ORDERED] = _dp_ordered[_w_ordered.selectedIndex].data;
			
			es[SettingNames.SPAWNPOSY] = _w_spawnposy.value;
			es[SettingNames.SPAWNTYPE] = _dp_spawntype[_w_spawntype.selectedIndex].data;
			es[SettingNames.TOPLOCK] = _w_toplock.selected;
			
			es[SettingNames.SAFESHIFT] = _dp_safeshift[_w_safeshift.selectedIndex].data[0];
			es[SettingNames.TOPSHIFT] = _dp_safeshift[_w_safeshift.selectedIndex].data[1];
			es[SettingNames.XSFIRST] = _dp_safeshift[_w_safeshift.selectedIndex].data[2];
			
			es[SettingNames.SPAWNAFTERCLEAR] = _w_spawnafterclear.selected;
			
			es[SettingNames.CLEARDROP] = _w_cleardrop.selected;
			
			es[SettingNames.FARR] = _w_falltype.selectedIndex == 1;
			
			es[SettingNames.FDEC] = _w_fallautodec.value * 1000;
			es[SettingNames.FMIN] = _w_fallautolimit.value * 1000;
			if (!es[SettingNames.FARR])
				es[SettingNames.FA][0] = _w_fallautostart.value * 1000;
			else
			{
				es[SettingNames.FA] = _w_fallcustom.data;
				for (i = 0; i < es[SettingNames.FA].length; i++)
					es[SettingNames.FA][i] *= 1000;
			}
			
			es[SettingNames.GRAVITY] = _w_gravity.selected;
			es[SettingNames.LUMP] = _w_lump.selected;
			es[SettingNames.FCF] = _w_gravspeed.value;
			
			es[SettingNames.BORCOL] = !_w_border.selected ? -1 : _w_borcol.selectedColor;
			
			es[SettingNames.LIVES] = _w_lives.value;
			es[SettingNames.FITCHANCES] = _w_chances.value;
			es[SettingNames.SCOREPEN] = _dp_loselife[_w_loselife.selectedIndex].data[0];
			es[SettingNames.LEVELPEN] = _dp_loselife[_w_loselife.selectedIndex].data[1];
			
			es[SettingNames.TIMELIMIT] = _w_timelimittog.selected ? _w_timelimitval.value : 0;
			
			es[SettingNames.TLVLUPBONUS] = _w_tlvlupbonus.data;
			
			es[SettingNames.LEVELMAX] = _w_levelmax.value;
			es[SettingNames.LEVELMAXWIN] = _w_levelmaxwin.selected;
			es[SettingNames.WINBONUS] = _w_winbonus.value;
			es[SettingNames.WINLIVESBONUS] = _w_winbonuslives.value;
			es[SettingNames.WINCHANCESBONUS] = _w_winbonuschances.value;
			es[SettingNames.WINTIMEBONUS] = _w_winbonustime.value;
			
			es[SettingNames.LEVELUPREQ] = _w_levelupreq.selectedIndex;
			es[SettingNames.LEVELUPA] = _w_levelupamount.data;
			
			es[SettingNames.LEVELMULTARR] = _w_levelmulttype.selectedIndex == 1;
			es[SettingNames.LEVELMULT] = _w_levelmultauto.value;
			es[SettingNames.LEVELMULTA] = _w_levelmultcustom.data;
			
			es[SettingNames.TLEVELMULTARR] = _w_tlevelmulttype.selectedIndex == 1;
			es[SettingNames.TLEVELMULT] = _w_tlevelmultauto.value;
			es[SettingNames.TLEVELMULTA] = _w_tlevelmultcustom.data;
			
			es[SettingNames.POINTC_T] = _w_cpointstyle.selectedIndex == 0;
			es[SettingNames.CLEARPOINTS] = _w_clearpoints.data;
			es[SettingNames.TILEPOINTS] = _w_tilepoints.value;
			
			es[SettingNames.TPOINTC_T] = _w_ctimestyle.selectedIndex == 0;
			es[SettingNames.TCLEARBONUS] = _w_cleartime.data;
			es[SettingNames.TTILEBONUS] = _w_tiletime.value;
			
			es[SettingNames.BB_BONUS] = _w_backbonustog.selected;
			es[SettingNames.BBCOMBOMOD] = _w_backbonusval.data;
			es[SettingNames.COMBOMOD] = _w_multibonus.data;
			es[SettingNames.GRAVCOMBOMOD] = _w_gravbonus.data;
			
			es[SettingNames.TBBCOMBOMOD] = _w_tbackbonusval.data;
			es[SettingNames.TCOMBOMOD] = _w_tmultibonus.data;
			es[SettingNames.TGRAVCOMBOMOD] = _w_tgravbonus.data;
			
			es[SettingNames.SETBONUSP_T] = _w_setbonustype.selectedIndex == 0;
			es[SettingNames.SETBONUS] = _w_setbonusval.value;
			
			es[SettingNames.SOFTBONUS] = _w_fastdropbonus.value;
			es[SettingNames.HARDBONUS] = _w_instdropbonus.value;
			
			es[SettingNames.SZONEMULT] = _w_szonebonus.value;
			es[SettingNames.DZONEMULT] = _w_dzonebonus.value;
			
			dispatchEvent(new Event(E_UPDATE));
		}
		
		public function saveMode(resetScores:Boolean):void
		{
			//Reset the settings of all disabled widgets...?
			/*var changed:Boolean = false;
			for each (var widget:IEditComponent in _widgetlist)
			{
				var bar:EditBarBase = EditBarBase(G.getTargetByType(widget, EditBarBase));
				if ((bar.unused || bar.hidden) && !widget.isDefault())
				{
					changed = true;
					widget.undoChanges();
				}
			}
			if (changed)
				updateMode();
			*/
			if (cs == null)
				cs = Settings.copyGameType(es, resetScores, true, resetScores);
			else
				cs.copySettingsOf(es, resetScores, true, resetScores);
			
			SaveData.saveGameSetting(cs);
			SaveData.flush();
			
			//Update the defaults to equal the settings of the saved mode.
			setDefaults();
		}
		
		private function setSelected(e:MouseEvent):void
		{
			var target:EditBarBase = EditBarBase(G.getTargetByType(e.target, EditBarBase));
			//Exception to rule: select the "add piece" bar instead of the piece bank bar.
			if (target == _piecebank)
				target = _bar_addpiece;
			
			if (target == _selected)
				return;
			if (_selected != null)
			{
				_selected.undoable = false;
				//More unselection actions?
			}
			_selected = EditBar(target);
			_selected.undoable = true;
			
			dispatchEvent(new ObjEvent(ObjEvent.GO, _selected.signal));
		}
		
		private function barHoverOver(e:MouseEvent):void
		{
			var target:EditBarBase = EditBarBase(G.getTargetByType(e.target, EditBarBase));
			if (target == _piecebank)
				target = _bar_addpiece;
			
			if (target == _hovered)
				return;
			_hovered = EditBar(target);
			if (_hovered != _selected)
				_hovered.undoable = true;
		}
		
		private function barHoverOut(e:MouseEvent = null):void
		{
			if (_hovered != _selected)
				_hovered.undoable = false;
			_hovered = null;
		}
		
		private function setUnused(bar:EditBarBase, unused:Boolean, hidden_instead:Boolean = false):void
		{
			var rbar:EditBarBase;
			for each (rbar in bar.reliers)
				setUnused(rbar, unused, true);
			for each (rbar in bar.deniers)
				setUnused(rbar, !unused, true);
			
			if ((!hidden_instead && bar.unused == unused) || (hidden_instead && bar.hidden == unused))
				return;
			
			if (!hidden_instead)
				bar.unused = unused;
			else
				bar.hidden = unused;
			bar.mouseChildren = !unused;
			
			if (_defaultset)
			{
				if (!unused && !bar.hasEventListener(MouseEvent.CLICK))
				{
					bar.addEventListener(MouseEvent.CLICK, setSelected);
					bar.addEventListener(MouseEvent.ROLL_OVER, barHoverOver);
					bar.addEventListener(MouseEvent.ROLL_OUT, barHoverOut);
				}
				else if (unused && bar.hasEventListener(MouseEvent.CLICK))
				{
					//barHoverOut();
					bar.removeEventListener(MouseEvent.CLICK, setSelected);
					bar.removeEventListener(MouseEvent.ROLL_OVER, barHoverOver);
					bar.removeEventListener(MouseEvent.ROLL_OUT, barHoverOut);
				}
			}
			
			//mark the bar's parent pane as dirty (needs its bar positions to be updated).
			if (_defaultset && _dirtypanes.indexOf(bar.parent) == -1)
				_dirtypanes.push(bar.parent);
			
			//Tween only if the bars are visible & changed. Also, for parent call only.
			//if (_defaultset && !hidden_instead)
				//updateBarPositions();
		}
		
		private function updateBarPositions(e:Event = null):void
		{
			for each (var pane:Sprite in _dirtypanes)
			{
				var i:uint = _panelist.indexOf(pane);
				var ytop:Number = 0;
				for each (var bar:EditBarBase in _barlists[i])
				{
					var available:Boolean = !bar.unused && !bar.hidden;
					bar.tabChildren = available;
					bar.tabEnabled = available;
					bar.mouseEnabled = available;
					
					var dest:Number;
					if (available)
					{
						dest = ytop;
						ytop += bar.height;
					}
					else
						dest = ytop - bar.height;
					
					if (bar.y != dest)
					{
						if (i != _currentpage)
							bar.y = dest;
						else
							TweenLite.to(bar, SLIDE_TIME, { y:dest } );
					}
				}
			}
			_dirtypanes = new Vector.<Sprite>();
		}
		
		// Public functions
		
		public function isChanged(scoreresetting:Boolean):Boolean
		{
			for each (var widget:IEditComponent in !scoreresetting ? _widgetlist : _scoreresetters)
			{
				var bar:EditBarBase = EditBarBase(G.getTargetByType(widget, EditBarBase));
				if (bar == null)
					continue;
				if (!bar.unused && !bar.hidden && UIComponent(widget).enabled && !widget.isDefault())
					return true;
			}
			//Piece Bank checks
			var pchange:uint = _piecebank.isChanged();
			return scoreresetting ? pchange >= 2 : pchange > 0;
		}
		
		public function setInteractable(enabled:Boolean):void
		{
			for each (var bar:EditBarBase in _barlists[_currentpage])
				bar.setInteractable(enabled);
		}
		
		private function addChangeListener(widget:UIComponent, listener:Function):void
		{
			_listenlist.push(widget);
			_listeners.push(listener);
			widget.addEventListener(Event.CHANGE, listener);
		}
		
		public function cleanUp():void
		{
			removeEventListener(Event.ENTER_FRAME, updateScroller);
			if (Main.stage.hasEventListener(PopUp.E_POPUP))
				Main.stage.removeEventListener(PopUp.E_POPUP, pausePieceBankPlaying);
			if (Main.stage.hasEventListener(PopUp.E_POPUPGONE))
				Main.stage.removeEventListener(PopUp.E_POPUPGONE, startPieceBankPlaying);
			
			_piecebank.removeEventListener(IDEvent.GO, notifyPieceDeleted);
			_w_addgroup.removeEventListener(MouseEvent.CLICK, addPieceRandom);
			_w_addcustom.removeEventListener(MouseEvent.CLICK, addPieceCustom);
			
			while (_listeners.length != 0)
				_listenlist.pop().removeEventListener(Event.CHANGE, _listeners.pop());
			
			for each (var widget:IEditComponent in _widgetlist)
				if (widget is ICleanable)
					ICleanable(widget).cleanUp();
			
			for each (var button:Button in _ynbuttons)
				button.removeEventListener(Event.CHANGE, updateYNButtonLabel);
			
			for each (var barlist:Vector.<EditBarBase> in _barlists)
			{
				for each (var bar:EditBarBase in barlist)
				{
					if (!bar.unused)
					{
						bar.removeEventListener(MouseEvent.CLICK, setSelected);
						bar.removeEventListener(MouseEvent.ROLL_OVER, barHoverOver);
						bar.removeEventListener(MouseEvent.ROLL_OUT, barHoverOut);
					}
					bar.cleanUp();
				}
			}
			
			for each (var tabbutton:TextButton in _tabbuttons)
				tabbutton.removeEventListener(MouseEvent.CLICK, selectPane);
		}
	}

}