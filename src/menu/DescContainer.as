package menu 
{
	import data.SettingNames;
	import data.Settings;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import media.fonts.FontStyles;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class DescContainer extends MovieClip
	{
		public static const E_START:String = "Startgame";
		public static const E_SCORE:String = "Scoregame";
		public static const E_EDIT:String = "Editgame";
		public static const E_COPY:String = "Copygame";
		public static const E_DEL:String = "Delgame";
		public static const E_SHARE:String = "Sharegame";
		
		private static const DEFAULT_TITLE:String = "SELECT A MODE";
		private static const DEFAULT_DESC:String = "Select a game mode from the table above!";
		private static const DEFAULT_AUTH:String = "-----";
		
		private static const TAG_AUTHOR:String = "Created by: ";
		private static const TAG_SPLIT:String = " || ";
		private static const TAG_EDITER:String = "Edited by: ";
		
		private var _back:MovieClip;
		
		private var _titlelabel:TextField;
		private var _titlewidth:Number;
		private var _desclabel:TextField;
		private var _descheight:Number;
		private var _authlabel:TextField;
		
		private var _startbutton:BlockableButton;
		private var _sharebutton:BlockableButton;
		private var _scorebutton:TextButton;
		private var _copybutton:TextButton;
		private var _editbutton:TextButton;
		private var _delbutton:TextButton;
		
		private var _simple:Boolean = false;
		
		public function DescContainer(simple:Boolean)
		{
			_simple = simple;
			
			_back = new DescBack();
			_back.width = 450; //don't set height yet.
			addChild(_back);
			var container:Sprite = new Sprite();
			
			_titlelabel = new TextField();
			var titleformat:TextFormat = new TextFormat(FontStyles.F_JOYSTIX, 30, 0xFF0000);
			titleformat.align = TextFormatAlign.CENTER;
			G.setTextField(_titlelabel, titleformat);
			_titlelabel.width = _titlewidth = 400;
			_titlelabel.height = 40;
			_titlelabel.filters = [new DropShadowFilter(5, 45, 0, 1, 5, 5)];
			_titlelabel.text = DEFAULT_TITLE;
			G.centreX(_titlelabel, _back);
			container.addChild(_titlelabel);
			
			_authlabel = new TextField();
			var authformat:TextFormat = new TextFormat(FontStyles.F_GOTHIC, 15, 0xFFFFFF, true);
			authformat.align = TextFormatAlign.CENTER;
			G.setTextField(_authlabel, authformat);
			_authlabel.autoSize = TextFieldAutoSize.CENTER;
			_authlabel.filters = [new DropShadowFilter()];
			_authlabel.text = DEFAULT_AUTH;
			G.centreX(_authlabel, _back);
			_authlabel.y = _titlelabel.y + _titlelabel.height;
			container.addChild(_authlabel);
			
			_desclabel = new TextField();
			var descformat:TextFormat = new TextFormat(FontStyles.F_LUCIDA, 16, 0xFFFFFF);
			descformat.align = TextFormatAlign.LEFT;
			descformat.leading = 2;
			G.setTextField(_desclabel, descformat);
			_desclabel.autoSize = TextFieldAutoSize.LEFT;
			_desclabel.wordWrap = true;
			_desclabel.width = 400;
			_desclabel.height = _descheight = 65;
			_desclabel.text = DEFAULT_DESC;
			G.centreX(_desclabel, _back);
			_desclabel.y = _authlabel.y + _authlabel.height + 5;
			container.addChild(_desclabel);
			
			_startbutton = new ButtonStart();
			G.centreX(_startbutton, _back);
			_startbutton.y = _desclabel.y + _descheight;
			_startbutton.clickable = false;
			container.addChild(_startbutton);
			
			_scorebutton = new TextButton("View High Scores");
			const bmarginX:Number = 5;
			const bmarginY:Number = 5;
			_scorebutton.y = _startbutton.y + _startbutton.height + bmarginY;
			G.centreX(_scorebutton, _startbutton);
			_scorebutton.clickable = false;
			container.addChild(_scorebutton);
			
			_startbutton.addEventListener(MouseEvent.CLICK, startGame);
			_scorebutton.addEventListener(MouseEvent.CLICK, viewHighScore);
			
			if (!_simple)
			{
				_copybutton = new TextButton("Copy");
				_editbutton = new TextButton("Edit");
				_delbutton = new TextButton("Delete");
				_sharebutton = new ButtonShare();
				
				_copybutton.width = _delbutton.width;
				_editbutton.width = _delbutton.width;
				
				_copybutton.y = _scorebutton.y + _scorebutton.height + 5;
				_editbutton.y = _copybutton.y;
				_delbutton.y = _copybutton.y;
				
				G.centreX(_editbutton, _startbutton);
				_copybutton.x = _editbutton.x - _copybutton.width - bmarginX;
				_delbutton.x = _editbutton.x + _editbutton.width + bmarginX;
				
				G.centreX(_sharebutton, _back);
				_sharebutton.y = _editbutton.y + _editbutton.height + bmarginY;
				
				_copybutton.clickable = false;
				_editbutton.clickable = false;
				_delbutton.clickable = false;
				_sharebutton.clickable = false;
				
				container.addChild(_copybutton);
				container.addChild(_editbutton);
				container.addChild(_delbutton);
				container.addChild(_sharebutton);
				
				_copybutton.addEventListener(MouseEvent.CLICK, copyMode);
				_editbutton.addEventListener(MouseEvent.CLICK, editMode);
				_delbutton.addEventListener(MouseEvent.CLICK, deleteMode);
				_sharebutton.addEventListener(MouseEvent.CLICK, shareMode);
			}
			
			var bottombutton:Sprite = !_simple ? _sharebutton : _scorebutton;
			container.y = 15;
			_back.height =  bottombutton.y + bottombutton.height + container.y * 2.5;
			addChild(container);
		}
		
		/**
		 * Updates the UI based on the currently-selected mode.
		 */
		public function updateSelected():void
		{
			var cs:Settings = Settings.currentGame;
			var n:Boolean = (cs == null);
			
			_titlelabel.text = !n ? cs[SettingNames.GTITLE] : DEFAULT_TITLE;
			_desclabel.text = !n ? cs[SettingNames.GDESC] : DEFAULT_DESC;
			_authlabel.text = !n ? authorString(cs[SettingNames.GAUTHOR], cs[SettingNames.GEDITER]) : DEFAULT_AUTH;
			
			_authlabel.textColor = n || cs[SettingNames.FILEID] == 0 ? 0xFFFFFF : 0xFFCC00;
			
			G.textFieldFitSize(_titlelabel, _titlewidth, true);
			G.textFieldFitSize(_desclabel, _descheight, false);
			G.textFieldFitSize(_authlabel, _back.width * 0.95);
			//colour update for text? And maybe background?
			
			_startbutton.clickable = !n;
			_scorebutton.clickable = !n;
			if (!_simple)
			{
				_copybutton.clickable = !n;
				_editbutton.clickable = !n && !cs[SettingNames.LOCKED];
				_delbutton.clickable = !n && !cs[SettingNames.LOCKED];
				_sharebutton.clickable = !n && !cs[SettingNames.LOCKED];
			}
		}
		
		private function authorString(author:String, editer:String):String
		{
			var firstpart:String = author == Settings.DEFAULT_AUTHOR ? author : TAG_AUTHOR + author;
			return author != editer ? firstpart + TAG_SPLIT + TAG_EDITER + editer : firstpart;
		}
		
		private function startGame(e:MouseEvent):void
		{
			dispatchEvent(new Event(E_START));
		}
		
		private function viewHighScore(e:MouseEvent):void
		{
			dispatchEvent(new Event(E_SCORE));
		}
		
		private function copyMode(e:MouseEvent):void
		{
			dispatchEvent(new Event(E_COPY));
		}
		
		private function editMode(e:MouseEvent):void
		{
			dispatchEvent(new Event(E_EDIT));
		}
		
		private function deleteMode(e:MouseEvent):void
		{
			dispatchEvent(new Event(E_DEL));
		}
		
		private function shareMode(e:MouseEvent):void
		{
			dispatchEvent(new Event(E_SHARE));
		}
		
		public function cleanUp():void
		{
			_startbutton.removeEventListener(MouseEvent.CLICK, startGame);
			_scorebutton.removeEventListener(MouseEvent.CLICK, viewHighScore);
			if (!_simple)
			{
				_copybutton.removeEventListener(MouseEvent.CLICK, copyMode);
				_editbutton.removeEventListener(MouseEvent.CLICK, editMode);
				_delbutton.removeEventListener(MouseEvent.CLICK, deleteMode);
				_sharebutton.removeEventListener(MouseEvent.CLICK, shareMode);
			}
		}
	}
}