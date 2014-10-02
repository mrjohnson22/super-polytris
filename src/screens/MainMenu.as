package screens
{
	import com.newgrounds.API;
	import data.Settings;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import media.sounds.SongList;
	import media.sounds.Sounds;
	import menu.PopUp;
	import menu.TextButton;
	import visuals.backs.BG;
	import visuals.NGLogo;
	import visuals.swipes.FadeSwipe;
	import visuals.TitleLogo;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class MainMenu extends Menu
	{
		private static var _loadProblem:Boolean = false;
		private static var _beenViewed:Boolean = false;
		public static function set loadProblem(value:Boolean):void
		{
			_loadProblem = value && !_beenViewed;
		}
		
		private var _titlelogo:MovieClip;
		
		private var _btn_qstart:TextButton;
		private var _btn_modesel:TextButton;
		private var _btn_newmode:TextButton;
		private var _btn_usermodes:TextButton;
		private var _btn_options:TextButton;
		private var _btn_credits:TextButton;//
		
		private var _ngbutton:MovieClip;
		
		public function MainMenu()
		{
			_beenViewed = true;
			addChildAt(new BG(), 0);
			Settings.clearType();
			APIUtils.clearLastLoadedFile();
			Sounds.playSong(SongList.Summertime);
			
			_btn_qstart = new TextButton("Quick Start");
			_btn_modesel = new TextButton("Mode Select");
			_btn_newmode = new TextButton("Create New Mode");
			_btn_usermodes = new TextButton("View Usermade Modes");
			_btn_options = new TextButton("Options & Save Data");
			_btn_credits = new TextButton("Credits");//
			
			addButtonListener(_btn_qstart, startGame);
			addButtonListener(_btn_modesel, modeSelect);
			addButtonListener(_btn_newmode, createMode);
			addButtonListener(_btn_usermodes, viewUserModes);
			addButtonListener(_btn_options, viewOptions);
			addButtonListener(_btn_credits, viewCredits);
			
			var buttonlist:Vector.<TextButton> = new Vector.<TextButton>();
			buttonlist.push(_btn_qstart, _btn_modesel, _btn_newmode, _btn_usermodes, _btn_options, _btn_credits);
			
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
			
			_titlelogo = new TitleLogo();
			G.centreX(_titlelogo);
			_titlelogo.y = 20;
			bcontainer.y = _titlelogo.y + _titlelogo.height + 10;
			addChild(bcontainer);
			addChild(_titlelogo);
			
			_ngbutton = new NGLogo();
			_ngbutton.scaleX = _ngbutton.scaleY = 0.5;
			_ngbutton.x = 195;
			_ngbutton.y = 530;
			_ngbutton.buttonMode = true;
			_ngbutton.filters = [new DropShadowFilter()];
			addChild(_ngbutton);
			addButtonListener(_ngbutton, function(e:MouseEvent):void
			{
				API.loadNewgrounds();
			});
			
			if (_loadProblem)
			{
				_loadProblem = false;
				addEventListener(Event.ADDED_TO_STAGE, showLoadProblemPopup);
			}
		}
		
		private function showLoadProblemPopup(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, showLoadProblemPopup);
			PopUp.makePopUp("An error occurred while loading your data, try again. (The rest of the game will still work, though!)",
			Vector.<String>(["Okay"]),
			Vector.<Function>([PopUp.fadeOut]));
		}
		
		private function startGame(e:MouseEvent):void
		{
			Settings.setGameType(0);
			goTo(PrepareScreen, false, FadeSwipe);
		}
		
		private function modeSelect(e:MouseEvent = null):void
		{
			goTo(MSelectScreen);
		}
		
		private function createMode(e:MouseEvent):void
		{
			if (Settings.numtypes == Settings.MAX_GAMES)
				PopUp.makePopUp(
				Settings.MAX_MESSAGE,
				Vector.<String>(["Mode Select Screen", "Back"]),
				Vector.<Function>([modeSelect, PopUp.fadeOut])
				);
			else
			{
				Settings.clearType();
				goTo(EditScreen, true);
			}
		}
		
		private function viewUserModes(e:MouseEvent):void
		{
			APIUtils.actOnConnect(function():void
			{
				goTo(UsermodeScreen);
			});
		}
		
		private function viewOptions(e:MouseEvent):void
		{
			goTo(OptionsScreen);
		}
		
		private function viewCredits(e:MouseEvent):void
		{
			goTo(CreditsScreen);
		}
	}
}