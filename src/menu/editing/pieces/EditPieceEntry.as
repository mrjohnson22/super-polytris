package menu.editing.pieces 
{
	import data.Settings;
	import fl.controls.NumericStepper;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import media.fonts.FontStyles;
	import menu.ICleanable;
	import objects.GamePiece;
	import visuals.boxes.FancyBorder;
	import visuals.boxes.NextBox;
	import visuals.boxes.NextBox1;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class EditPieceEntry extends MovieClip implements ICleanable
	{
		public static const SIZE:Number = 76;
		public static const COUNTSIZE:Number = 45;
		
		private var _container:Sprite;
		
		private var _box:NextBox;
		public function get box():NextBox
		{
			return _box;
		}
		
		private var _piececontainer:Sprite;
		private var _randpiece:GamePiece;
		
		private var _indexlabel:TextField;
		private var _index:int;
		public function get index():int
		{
			return _index;
		}
		public function set index(value:int):void
		{
			if (value == -1)
				_indexlabel.visible = false;
			else
			{
				_indexlabel.visible = true;
				_indexlabel.text = value.toString();
			}
			_index = value;
		}
		
		private var _randtimer:FrameTimer;
		
		private var _delbutton:SimpleButton;
		private var _deleteFunction:Function;
		
		private var _dragbutton:SimpleButton;
		private var _dragFunctionStart:Function;
		public var tweening:Boolean = false;
		
		private var _counter:NumericStepper;
		
		private var _piecedata:Object;
		private var _props:Array = [];
		private var _col:Object;
		private var _app:uint;
		
		public function isCustom():Boolean
		{
			return _col is uint;
		}
		
		public function EditPieceEntry(index:int, piecedata:*, props:Array, col:*, app:uint) 
		{
			_box = new NextBox1();
			addChild(_box);
			
			_randtimer = new FrameTimer(200, true);
			_randtimer.addEventListener(TimerEvent.TIMER, drawRandomPiece);
			
			//Draw index
			_indexlabel = new TextField();
			G.setTextField(_indexlabel, new TextFormat(FontStyles.F_JOYSTIX, 11, 0xFF0000));
			_indexlabel.autoSize = TextFieldAutoSize.LEFT;
			this.index = index; //handles visual update
			const indexmargin:Number = 0;
			_indexlabel.x = _box.viewbox.x + indexmargin;
			G.bottomAlign(_indexlabel, indexmargin, _box.viewbox);
			_indexlabel.filters = [new DropShadowFilter()];
			_indexlabel.mouseEnabled = false;
			_box.addChild(_indexlabel);
			
			//Handles drawing
			setPieceInfo(piecedata, props, col, app);
			
			G.matchSizeV(this, SIZE, SIZE, false);
		}
		
		public function makeDeletable(deleteFunction:Function, dragFunctionStart:Function):void
		{
			if (_deleteFunction != null)
			{
				_delbutton.removeEventListener(MouseEvent.CLICK, _deleteFunction);
				_dragbutton.removeEventListener(MouseEvent.MOUSE_DOWN, _dragFunctionStart);
			}
			
			_delbutton = new DeleteButton();
			_delbutton.x = _box.x + _box.width - _delbutton.width;
			_delbutton.y = _box.y;
			addChild(_delbutton);
			_delbutton.addEventListener(MouseEvent.CLICK, _deleteFunction = deleteFunction);
			
			const margin:Number = 5;
			_dragbutton = new DragButton();
			_dragbutton.x = _box.x - margin;
			_dragbutton.y = _box.y - margin;
			addChild(_dragbutton);
			_dragbutton.addEventListener(MouseEvent.MOUSE_DOWN, _dragFunctionStart = dragFunctionStart);
		}
		
		public function makeCountable(value:uint, ordered:Boolean):void
		{
			_counter = new NumericStepper();
			_counter.minimum = ordered ? 1 : 0;
			_counter.maximum = ordered ? Settings.MAX_PIECE_LIKE : Settings.MAX_PIECE_FREQ;
			_counter.value = value;
			
			_counter.width = COUNTSIZE;
			_counter.x = _box.x + _box.width;
			_counter.y = _box.y + _box.height - _counter.height;
			addChild(_counter);
		}
		
		public function get count():uint
		{
			return _counter.value; //Yes, throw an error if counter is null.
		}
		
		public function set count(value:uint):void
		{
			_counter.value = value;
		}
		
		public function setPieceInfo(piecedata:*, props:Array, col:*, app:uint):void
		{
			_randtimer.reset();
			if (_container != null)
				_container.parent.removeChild(_container);
			_container = new Sprite();
			_piececontainer = null;
			_randpiece = null;
			
			_app = app;
			_props = props.slice();
			if (piecedata is uint && col is Array)
			{
				_piecedata = piecedata;
				_col = (col as Array).slice();
				drawRandom();
				_randtimer.start();
			}
			else if (piecedata is Array && col is uint)
			{
				_piecedata = (piecedata as Array).slice();
				_col = col;
				drawCustom();
			}
			else
				throw new Error("Invalid types. Expected data & colour to be Array & uint (or vice-versa).");
		}
		
		/**
		 * Returns all available info on this entry's piece. The info is returned in the form of an array:
		 * info\[0] = number of tiles for piece group, or piece map array for custom group
		 * info\[1] = properties (size for piece group, or direction map for custom piece)
		 * info\[2] = color (array for piece group, uint for custom)
		 * info\[3] = appearance style number
		 * @return
		 */
		public function getPieceInfo():Array
		{
			var info:Array = [];
			if (!isCustom())
			{
				info[0] = uint(_piecedata);
				G.arrayCopy2D(info[1] = [], _props);
				info[2] = (_col as Array).slice();
			}
			else
			{
				info[0] = (_piecedata as Array).slice();
				info[1] = _props.slice();
				info[2] = uint(_col);
			}
			info[3] = _app;
			
			return info;
		}
		
		
		private function drawRandom():void
		{
			var labelcontainer:Sprite = new Sprite();
			
			var biglabel:TextField = new TextField();
			var format:TextFormat = new TextFormat(FontStyles.F_JOYSTIX, 16, 0xFFFFFF);
			G.setTextField(biglabel, format);
			biglabel.autoSize = TextFieldAutoSize.LEFT;
			biglabel.text = _piecedata.toString();
			biglabel.mouseEnabled = false;
			labelcontainer.addChild(biglabel);
			
			var tinylabel:TextField = new TextField();
			format = new TextFormat(FontStyles.F_JOYSTIX, 10, 0xFFFFFF);
			G.setTextField(tinylabel, format);
			tinylabel.autoSize = TextFieldAutoSize.LEFT;
			tinylabel.text = "Tiles";
			tinylabel.mouseEnabled = false;
			labelcontainer.addChild(tinylabel);
			
			tinylabel.x = biglabel.x + biglabel.width;
			G.centreX(labelcontainer, _box.viewbox);
			labelcontainer.y = _box.viewbox.y;
			biglabel.filters = [new DropShadowFilter(4)];
			tinylabel.filters = [new DropShadowFilter(4)];
			G.matchSizeC(labelcontainer, _box.viewbox, false);
			
			_piececontainer = new Sprite();
			var border:NextBox = new FancyBorder();
			border.scaleX = G.S * _props[0] / border.viewbox.width;
			border.scaleY = G.S * _props[1] / border.viewbox.height;
			_piececontainer.addChild(border);
			drawRandomPiece();
			
			const scale:Number = 0.95;
			G.matchSizeV(_piececontainer, _box.viewbox.width * scale, _box.viewbox.height * scale, false);
			G.centreX(_piececontainer, _box.viewbox);
			G.centreY(_piececontainer, false, _box.viewbox);
			
			_container.addChild(_piececontainer);
			_container.addChild(labelcontainer);
			_box.addChildAt(_container, _box.getChildIndex(_indexlabel));
		}
		
		private function drawRandomPiece(e:TimerEvent = null):void
		{
			if (_randpiece != null)
				_randpiece.parent.removeChild(_randpiece);
			_randpiece = GamePiece.createRandomPiece(uint(_piecedata), _props[0], _props[1], _col as Array, -1, _app);
			G.centreX(_randpiece, _piececontainer.getChildAt(0));
			G.centreY(_randpiece, false, _piececontainer.getChildAt(0));
			_piececontainer.addChildAt(_randpiece, 0);
		}
		
		private function drawCustom():void
		{
			var piece:GamePiece = new GamePiece(_piecedata as Array, _props, uint(_col), 0, _app);
			G.matchSizeC(piece, _box.viewbox, false);
			_container.addChild(piece);
			G.centreX(_container, _box);
			G.centreY(_container, false, _box);
			_box.addChildAt(_container, _box.getChildIndex(_indexlabel));
		}
		
		public function set playing(value:Boolean):void
		{
			if (!isCustom() && value)
				_randtimer.start();
			else
				_randtimer.stop();
		}
		
		public function cleanUp():void
		{
			_randtimer.stop();
			_randtimer.removeEventListener(TimerEvent.TIMER, drawRandomPiece);
			if (_delbutton != null)
			{
				_delbutton.removeEventListener(MouseEvent.CLICK, _deleteFunction);
				_deleteFunction = null;
				_dragbutton.removeEventListener(MouseEvent.MOUSE_DOWN, _dragFunctionStart);
			}
		}
		
	}

}