package menu.editing.pieces 
{	
	import data.DefaultSettings;
	import data.Settings;
	import fl.controls.NumericStepper;
	import fl.data.DataProvider;
	import flash.events.Event;
	import menu.editing.BarPane;
	import menu.editing.comps.EditCompArray;
	import menu.editing.comps.EditCompColor;
	import menu.editing.comps.EditCompCombo;
	import menu.editing.EditArrayBar;
	import menu.editing.EditModeBack;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class EditPieceGroup extends EditPiece
	{
		private var _comptiles:NumericStepper;
		private var _compwid:NumericStepper;
		private var _complen:NumericStepper;
		private var _compcols:EditCompArray;
		private var _compapp:EditCompCombo;
		
		private var _entry:EditPieceEntry;
		
		public function EditPieceGroup(piecedata:uint, props:Array, col:Array, app:uint)
		{
			_entry = new EditPieceEntry( -1, piecedata, props, col, app);
			_entry.width = _entry.height = 170;
			
			_back = new EditModeBack();
			_back.width = G.STAGE_WIDTH * 0.8;
			
			//Set up controls
			_comptiles = new NumericStepper();
			_comptiles.minimum = 1;
			_comptiles.maximum = Settings.MAX_NUM_TILES;
			
			_compwid = new NumericStepper();
			_compwid.minimum = 1;
			_compwid.value = props[0];
			_compwid.addEventListener(Event.CHANGE, updateAllowableSize);
			
			_complen = new NumericStepper();
			_complen.minimum = 1;
			_complen.value = props[1];
			_complen.addEventListener(Event.CHANGE, updateAllowableSize);
			
			_comptiles.addEventListener(Event.CHANGE, updateSizeMax);
			_comptiles.value = uint(piecedata);
			
			_comptiles.width = _compwid.width = _complen.width = 45;
			
			_compcols = new EditCompArray();
			_compcols.WidgetType = EditCompColor;
			_compcols.props = [Settings.COLORS_PICK];
			_compcols.poptitle = "Select Possible Colors:";
			_compcols.bartitle = "Color %d";
			_compcols.maxnum = 20;
			_compcols.lastplus = false;
			_compcols.showchange = false;
			_compcols.data = col as Array;
			
			_compapp = new EditCompCombo();
			_compapp.dataProvider = new DataProvider(Settings.APP_NAMES.slice());
			_compapp.selectedIndex = app;
			
			var container:BarPane = new BarPane();
			container.addChild(_entry);
			_ytop += _entry.height + 0;
			
			_complist.push(_comptiles, _compwid, _complen, _compcols, _compapp);
			var titles:Array = ["Tiles:", "Max length:", "Max height:", "Colors:", "Appearance:"];
			const margin:Number = 10;
			for (var i:uint = 0; i < _complist.length; i++)
			{
				var bar:EditArrayBar = new EditArrayBar(titles[i], _complist[i], _back.width - margin * 2);
				bar.y = _ytop;
				_ytop += bar.height;
				container.addChild(bar);
				_complist[i].addEventListener(Event.CHANGE, updatePreview);
			}
			
			G.centreX(_entry, container.getChildAt(_complist.length));
			
			_back.height = container.height + margin * 2;
			container.x = margin;
			container.y = margin;
			addChild(_back);
			addChild(container);
			
			updateSizeMax(null);
		}
		
		private function updateSizeMax(e:Event):void
		{
			_compwid.maximum = _complen.maximum = _comptiles.value;
			_compwid.value = _complen.value = _comptiles.value;
		}
		
		private function updateAllowableSize(e:Event):void
		{
			if (_compwid.value * _complen.value < _comptiles.value)
				NumericStepper(G.getTargetByType(e.target, NumericStepper)).value++;
		}
		
		private function updatePreview(e:Event):void
		{
			_entry.setPieceInfo(_comptiles.value, [_compwid.value, _complen.value], _compcols.data, _compapp.selectedIndex);
		}
		
		override public function getPieceInfo():Array
		{
			return _entry.getPieceInfo();
		}
		
		override public function cleanUp():void
		{
			_entry.cleanUp();
			_comptiles.removeEventListener(Event.CHANGE, updateSizeMax);
			_compwid.removeEventListener(Event.CHANGE, updateAllowableSize);
			_complen.removeEventListener(Event.CHANGE, updateAllowableSize);
			
			super.cleanUp();
		}
	}
}