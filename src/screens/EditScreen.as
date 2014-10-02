package screens 
{
	import data.SettingNames;
	import data.Settings;
	import events.ObjEvent;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import media.fonts.FontStyles;
	import media.sounds.SongList;
	import media.sounds.SoundList;
	import media.sounds.Sounds;
	import menu.editing.EditPane;
	import menu.editing.EditPreviewBox;
	import menu.editing.EditSignal;
	import menu.editing.previews.PreviewItem;
	import menu.editing.previews.PreviewNone;
	import menu.PopUp;
	import menu.TextButton;
	import visuals.backs.BG;
	import visuals.SCWarning;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class EditScreen extends Menu 
	{
		public static const DEF_TITLE:String = "---";
		public static const DEF_DESC:String = "Edit any mode setting below.";
		public static const DEF_PREVIEW:String = "Preview";
		
		private var _firstsetting:int;
		private var _filelink:Boolean;
		private var _editPane:EditPane;
		
		private var _infolabel:TextField;
		private var _desclabel:TextField;
		private var _preview:PreviewItem;
		private var _previewbox:MovieClip;
		private var _previewlabel:TextField;
		
		private var _infowidth:Number;
		private var _descheight:Number;
		
		private var _btn_save:TextButton;
		private var _warnicon:MovieClip;
		
		public function EditScreen() 
		{
			addChildAt(new BG(), 0);
			setTitle("Mode Edit");
			Sounds.playSong(SongList.StopAndGo);
			setBackButton(MSelectScreen);
			_firstsetting = Settings.currentGame != null ? Settings.currentGame.gtype : -1;
			_filelink = _firstsetting != -1 && Settings.currentGame[SettingNames.FILEID] != 0;
			
			_btn_save = new TextButton("Save Changes");
			addButtonListener(_btn_save, overwriteCheck);
			G.centreX(_btn_save);
			_btn_save.y = _backbutton.y;
			addChild(_btn_save);
			
			_warnicon = new SCWarning();
			_warnicon.x = _btn_save.x - _warnicon.width - 5;
			G.matchSizeV(_warnicon, Infinity, _btn_save.height, true);
			G.bottomAlign(_warnicon, 0, _btn_save);
			_warnicon.filters = [new DropShadowFilter()];
			_warnicon.visible = false;
			addChild(_warnicon);
			
			_editPane = new EditPane();
			_editPane.x = (G.STAGE_WIDTH - _editPane.width) / 2;
			_editPane.y = _btn_save.y - _editPane.height - 5;
			addChild(_editPane);
			
			_editPane.addEventListener(ObjEvent.GO, setSelected);
			_editPane.addEventListener(EditPane.E_UPDATE, update);
			
			//------------Start of info setup------------//
			_infolabel = new TextField();
			var titleformat:TextFormat = new TextFormat(FontStyles.F_JOYSTIX, 20, 0xFFCC00);
			titleformat.align = TextFormatAlign.LEFT;
			G.setTextField(_infolabel, titleformat);
			_infolabel.autoSize = TextFieldAutoSize.LEFT;
			_infolabel.text = DEF_TITLE;
			_infolabel.filters = [new DropShadowFilter];
			
			_desclabel = new TextField();
			var descformat:TextFormat = new TextFormat(FontStyles.F_JOYSTIX, 15, 0xFFFF00);
			descformat.align = TextFormatAlign.LEFT;
			G.setTextField(_desclabel, descformat);
			_desclabel.autoSize = TextFieldAutoSize.LEFT;
			_desclabel.wordWrap = true;
			_desclabel.text = DEF_DESC;
			_desclabel.filters = [new DropShadowFilter()];
			
			_previewbox = new EditPreviewBox();
			
			_previewlabel = new TextField();
			var previewformat:TextFormat = new TextFormat(FontStyles.F_JOYSTIX, 15, 0xFFFF00);
			previewformat.align = TextFormatAlign.LEFT;
			G.setTextField(_previewlabel, previewformat);
			_previewlabel.autoSize = TextFieldAutoSize.LEFT;
			_previewlabel.text = DEF_PREVIEW;
			_previewlabel.filters = [new DropShadowFilter()];
			
			_infolabel.x = _editPane.x;
			_infolabel.y = _titlelabel.y + _titlelabel.height + 5;
			_desclabel.x = _editPane.x;
			_desclabel.y = _infolabel.y + _infolabel.height + 5;
			
			_previewlabel.y = _infolabel.y;
			_previewbox.y = _previewlabel.y + _previewlabel.height + 5;
			_previewbox.height = _editPane.y - _previewbox.y - 5;
			_previewbox.width = _previewbox.height * 1.4;
			_previewbox.x = _editPane.x + _editPane.width - _previewbox.width;
			_previewlabel.x = _previewbox.x;
			
			_infowidth = _previewbox.x - _infolabel.x - 5;
			_descheight = _editPane.y - _desclabel.y - 5;
			
			_desclabel.width = _infowidth;
			
			addChild(_previewbox);
			addChild(_infolabel);
			addChild(_desclabel);
			addChild(_previewlabel);
			
			_preview = new PreviewNone();
			placePreview();
			addChild(_preview);
			//------------End of info setup------------//
			
			Main.stage.addEventListener(PopUp.E_POPUP, stopInteraction);
			Main.stage.addEventListener(PopUp.E_POPUPGONE, allowInteraction);
		}
		
		private function stopInteraction(e:Event = null):void
		{
			Main.resetFocus();
			_editPane.setInteractable(false);
		}
		
		private function allowInteraction(e:Event = null):void
		{
			_editPane.setInteractable(true);
		}
		
		private function setSelected(e:ObjEvent):void
		{
			var signal:EditSignal = EditSignal(e.obj);
			
			_infolabel.text = signal.title;
			G.textFieldFitSize(_infolabel, _infowidth);
			
			_desclabel.text = signal.desc;
			G.textFieldFitSize(_desclabel, _descheight, false);
			
			if (_preview != null)
				removeChild(_preview);
			
			_preview = signal.Preview != null ? PreviewItem(new signal.Preview()) : (new PreviewNone());
			placePreview();
			addChild(_preview);
		}
		
		private function update(e:Event):void
		{
			if (_preview == null)
				return;
			
			_preview.update();
			placePreview();
			
			_warnicon.visible = _firstsetting != -1 && _editPane.isChanged(true);
		}
		
		private function placePreview():void
		{
			const scale:Number = 0.75; //Don't use a NextBox with viewbox, since the preview box is scale 9!
			_preview.scaleX = _preview.scaleY = 1;
			G.matchSizeV(_preview, _previewbox.width * scale, _previewbox.height * scale, true);
			G.centreX(_preview, _previewbox);
			G.centreY(_preview, false, _previewbox);
		}
		
		private function overwriteCheck(e:MouseEvent = null):void
		{
			//If you type something & then click "save" without clicking anything else, the text value won't be seen.
			//So manually perform a check now.
			if (e != null)
			{
				Main.resetFocus();
				overwriteCheck();
				return;
			}
			if (_warnicon.visible)//_firstsetting != -1 && _editPane.isChanged(true))
			{
				PopUp.makePopUp(
				"The changes you made to this mode require its high scores to be reset"
				+ (_filelink && APIUtils.hasUserSession ? ", but you will be able to share the mode after saving it" : "") + ". Save anyway?",
				Vector.<String>(["Yes", "No"]),
				Vector.<Function>(
				[function(e:MouseEvent):void
				{
					PopUp.fadeOut();
					saveMode(true);
				}, PopUp.fadeOut])
				);
			}
			else
				saveMode(false);
		}
		
		private function saveMode(resetScores:Boolean):void
		{
			if (_firstsetting != -1 && !_editPane.isChanged(false))
			{
				PopUp.makePopUp(
				"No changes were made, so nothing was saved.",
				Vector.<String>(["Play Mode", "Continue Editing"]),
				Vector.<Function>(
				[function(e:MouseEvent):void
				{
					Settings.setGameType(_editPane.actualGame);
					goTo(PrepareScreen, false);
				}, PopUp.fadeOut]));
				return;
			}
			
			_editPane.saveMode(resetScores);
			_warnicon.visible = false;
			if (resetScores)
				_filelink = false;
			
			_preview.refreshSettings();
			if (_firstsetting == -1)
				_firstsetting = Settings.numtypes - 1; //New modes always added to end of modes list.
			
			Sounds.playSingleSound(SoundList.Clear1);
			PopUp.makePopUp(
			"Save complete!",
			Vector.<String>(["Play Mode", "Continue Editing"]),
			Vector.<Function>(
			[function(e:MouseEvent):void
			{
				Settings.setGameType(_editPane.actualGame);
				goTo(PrepareScreen, false);
			}, PopUp.fadeOut]));
		}
		
		private function resetToFirstSetting():void
		{
			if (_firstsetting != -1)
				Settings.setGameType(_firstsetting);
			else
				Settings.clearType();
		}
		
		override protected function goBack(e:MouseEvent):void 
		{
			if (_firstsetting == -1 || _editPane.isChanged(false))
			{
				PopUp.makePopUp(
				"Are you sure you want to exit? Unsaved data will be lost.",
				Vector.<String>(["Yes", "No"]),
				Vector.<Function>(
				[function(e:MouseEvent):void
				{
					resetToFirstSetting();
					goTo(_backScreen, true);
				}, PopUp.fadeOut])
				);
			}
			else
			{
				resetToFirstSetting();
				goTo(_backScreen, true);
			}
		}
		
		override protected function cleanUp():void 
		{
			_editPane.cleanUp();
			Main.stage.removeEventListener(PopUp.E_POPUP, stopInteraction);
			Main.stage.removeEventListener(PopUp.E_POPUPGONE, allowInteraction);
			super.cleanUp();
		}
		
	}

}