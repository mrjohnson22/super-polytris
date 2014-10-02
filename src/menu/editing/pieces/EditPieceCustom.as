package menu.editing.pieces 
{	
	import data.DefaultSettings;
	import data.Settings;
	import fl.controls.ColorPicker;
	import fl.data.DataProvider;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.ui.Keyboard;
	import media.fonts.FontStyles;
	import menu.editing.BarPane;
	import menu.editing.comps.EditCompCombo;
	import menu.editing.EditArrayBar;
	import menu.editing.EditModeBack;
	import menu.TextButton;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class EditPieceCustom extends EditPiece
	{
		private var _compcol:ColorPicker;
		private var _compapp:EditCompCombo;
		
		private var _entry:EditPieceBuilder;
		private var _zoomin:TextButton;
		private var _zoomout:TextButton;
		private var _tilecount:TextField;
		
		public function EditPieceCustom(piecedata:Array, props:Array, col:uint, app:uint)
		{
			_entry = new EditPieceBuilder(piecedata, props, col, app);
			_entry.width = _entry.height = 250;
			
			_back = new EditModeBack();
			_back.width = G.STAGE_WIDTH * 0.8;
			
			//Set up controls
			_compcol = new ColorPicker();
			_compcol.colors = Settings.COLORS_PICK;
			_compcol.selectedColor = col;
			_compcol.addEventListener(Event.CHANGE, updateColor);
			
			_compapp = new EditCompCombo();
			_compapp.dataProvider = new DataProvider(Settings.APP_NAMES.slice());
			_compapp.selectedIndex = app;
			_compapp.addEventListener(Event.CHANGE, updateAppearance);
			
			_zoomin = new TextButton("+", null, 0xFFFFFF, 14);
			_zoomout = new TextButton("-", null, 0xFFFFFF, 14);
			
			_zoomin.y = _entry.y + _entry.height;
			_zoomout.y = _zoomin.y;
			
			_zoomin.addEventListener(MouseEvent.CLICK, zoomIn);
			_zoomout.addEventListener(MouseEvent.CLICK, zoomOut);
			
			var container:BarPane = new BarPane();
			container.addChild(_entry);
			_ytop += _zoomin.y + _zoomin.height + 5;
			
			_complist.push(_compcol, _compapp);
			var titles:Array = ["Color:", "Appearance:"];
			const margin:Number = 10;
			for (var i:uint = 0; i < _complist.length; i++)
			{
				var bar:EditArrayBar = new EditArrayBar(titles[i], _complist[i], _back.width - margin * 2);
				bar.y = _ytop;
				_ytop += bar.height;
				container.addChild(bar);
			}
			
			G.centreX(_entry, container.getChildAt(_complist.length));
			
			var zoomtext:TextField = new TextField();
			G.setTextField(zoomtext, new TextFormat(FontStyles.F_JOYSTIX, 15, 0xFFFFFF));
			zoomtext.autoSize = TextFieldAutoSize.LEFT;
			zoomtext.text = "Zoom:";
			zoomtext.x = _entry.x;
			G.centreY(zoomtext, false, _zoomin);
			_zoomin.x = zoomtext.x + zoomtext.width + 5;
			_zoomout.x = _zoomin.x + _zoomin.width + 5;
			
			_tilecount = new TextField();
			G.setTextField(_tilecount, new TextFormat(FontStyles.F_JOYSTIX, 15, null, null, null, null, null, null, TextFormatAlign.RIGHT));
			_tilecount.autoSize = TextFieldAutoSize.RIGHT;
			typeTileCount(null);
			G.rightAlign(_tilecount, 5, _entry);
			G.centreY(_tilecount, false, _zoomin);
			
			container.addChild(zoomtext);
			container.addChild(_zoomin);
			container.addChild(_zoomout);
			container.addChild(_tilecount);
			
			_back.height = container.height + margin * 2;
			container.x = margin;
			container.y = margin;
			addChild(_back);
			addChild(container);
			
			_entry.setUp();
			_entry.addEventListener(Event.CHANGE, typeTileCount);
			Main.stage.addEventListener(Event.ENTER_FRAME, slideCheck);
		}
		
		private function zoomIn(e:MouseEvent):void
		{
			_entry.zoom -= 2;
		}
		
		private function zoomOut(e:MouseEvent):void
		{
			_entry.zoom += 2;
		}
		
		private function typeTileCount(e:Event):void
		{
			var c:uint = _entry.getTileCount();
			_tilecount.text = c.toString() + "/" + Settings.MAX_NUM_TILES;
			_tilecount.textColor = c < Settings.MAX_NUM_TILES ? 0xFFFFFF : 0xFF0000;
		}
		
		private function slideCheck(e:Event):void
		{
			Main.resetFocus();
			if (Key.isTap(Keyboard.UP))
				_entry.slideTiles(EditPieceBuilder.DOWN);
			else if (Key.isTap(Keyboard.RIGHT))
				_entry.slideTiles(EditPieceBuilder.LEFT);
			else if (Key.isTap(Keyboard.DOWN))
				_entry.slideTiles(EditPieceBuilder.UP);
			else if (Key.isTap(Keyboard.LEFT))
				_entry.slideTiles(EditPieceBuilder.RIGHT);
		}
		
		private function updateColor(e:Event):void
		{
			_entry.setCol(_compcol.selectedColor);
		}
		
		private function updateAppearance(e:Event):void
		{
			_entry.setApp(_compapp.selectedIndex);
		}
		
		override public function getPieceInfo():Array
		{
			return _entry.getPieceInfo();
		}
		
		override public function cleanUp():void
		{
			_compcol.removeEventListener(Event.CHANGE, updateColor);
			_compapp.removeEventListener(Event.CHANGE, updateAppearance);
			_zoomin.removeEventListener(MouseEvent.CLICK, zoomIn);
			_zoomout.removeEventListener(MouseEvent.CLICK, zoomOut);
			_entry.removeEventListener(Event.CHANGE, typeTileCount);
			Main.stage.removeEventListener(Event.ENTER_FRAME, slideCheck);
			_entry.cleanUp();
		}
	}
}