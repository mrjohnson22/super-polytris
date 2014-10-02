package menu.editing 
{
	import fl.containers.ScrollPane;
	import fl.controls.ScrollPolicy;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	import menu.editing.pieces.EditPieceBar;
	import menu.editing.pieces.EditPieceBarOrdered;
	import menu.ICleanable;
	import menu.TextButton;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class EditArray extends Sprite implements ICleanable
	{
		private static const BARNUM:Number = 5;
		private static const PIECENUM:Number = 6;
		private static const LASTTAG:String = "+";
		
		private var _back:Sprite;
		
		private var _scrollpane:ScrollPane;
		private var _scrollpsave:Number = 0;
		private var _barlist:Vector.<EditArrayBar> = new Vector.<EditArrayBar>();
		private var _barpane:BarPane;
		
		private var _bartitle:String;
		private var _WidgetType:Class;
		private var _props:Array;
		private var _maxnum:uint;
		private var _zeroindexed:Boolean;
		private var _lastplus:Boolean;
		
		private var _b_add:TextButton;
		private var _b_rem:TextButton;
		
		private var _piecebar:Boolean;
		
		override public function get width():Number
		{
			return _back.width;
		}
		
		override public function get height():Number
		{
			return _back.height;
		}
		
		public function EditArray(bartitle:String, WidgetType:Class, data:Array, props:Array, maxnum:uint, zeroindexed:Boolean, lastplus:Boolean) 
		{
			_bartitle = bartitle;
			_WidgetType = WidgetType;
			_props = props;
			_maxnum = maxnum;
			_zeroindexed = zeroindexed;
			_lastplus = lastplus;
			
			_scrollpane = new ScrollPane();
			_barpane = new BarPane();
			
			_piecebar = _WidgetType == EditPieceBar || _WidgetType == EditPieceBarOrdered;
			
			const wid:Number = !_piecebar ? EditArrayBar.E_WIDTH : EditPieceBar.E_WIDTH;
			for (var i:uint = 0; i < data.length; i++)
			{
				var bar:EditArrayBar = new EditArrayBar(makeTitle(i, i == data.length - 1), _WidgetType, wid, _props, data[i]);
				_barpane.addChildAt(bar, 0);
				_barlist.push(bar);
				if (_piecebar)
					bar.widget.addEventListener(EditBarBase.E_RESIZE, updateHeights);
			}
			updateHeights();
			
			_b_add = new TextButton("Add");
			_b_rem = new TextButton("Remove");
			
			_b_add.width = _b_rem.width;
			
			const margin:Number = 10;
			_back = new EditModeBack();
			_back.width = wid + margin * 2;
			
			_scrollpane.setSize(wid, EditBarBase.E_HEIGHT * (!_piecebar ? BARNUM : PIECENUM));
			_scrollpane.horizontalScrollPolicy = ScrollPolicy.OFF;
			_scrollpane.verticalScrollPolicy = ScrollPolicy.ON;
			_scrollpane.tabEnabled = false;
			
			_scrollpane.x = margin;
			_scrollpane.y = margin;
			
			var buttonContainer:Sprite = new Sprite();
			buttonContainer.addChild(_b_add);
			buttonContainer.addChild(_b_rem);
			_b_rem.x = _b_add.x + _b_add.width + 5;
			G.centreX(buttonContainer, _back);
			buttonContainer.y = _scrollpane.y + _scrollpane.height + 5;
			
			_back.height = buttonContainer.y + buttonContainer.height + 20;
			
			addChild(_back);
			addChild(_scrollpane);
			addChild(buttonContainer);
			
			_b_add.addEventListener(MouseEvent.CLICK, addBar);
			_b_rem.addEventListener(MouseEvent.CLICK, remBar);
			
			if (_barlist.length >= _maxnum)
				_b_add.clickable = false;
			else if (_barlist.length == 1)
				_b_rem.clickable = false;
			
			_scrollpane.source = _barpane;
			Main.stage.addEventListener(Event.ENTER_FRAME, updateScroller);
		}
		
		private function updateScroller(e:Event = null):void
		{
			_scrollpane.source = _barpane;
			_scrollpane.validateNow();
			if (Key.isDown(Keyboard.LEFT) || Key.isDown(Keyboard.RIGHT))
				_scrollpane.horizontalScrollPosition = 0;
			if (Key.isDown(Keyboard.HOME) || Key.isDown(Keyboard.END))
				_scrollpane.verticalScrollPosition = _scrollpsave;
			_scrollpsave = _scrollpane.verticalScrollPosition;
		}
		
		private function updateHeights(e:Event = null):void
		{
			var ytop:Number = 0;
			for each (var bar:EditArrayBar in _barlist)
			{
				bar.y = ytop;
				ytop += bar.height;
			}
			if (parent != null)
				updateScroller();
		}
		
		private function makeTitle(i:uint, last:Boolean):String
		{
			var num:uint = i + (_zeroindexed ? 0 : 1);
			var t:String = _bartitle;
			
			if (_bartitle.indexOf("[s]") != -1)
				t = t.replace("[s]", num == 1 ? "" : "s");
			
			if (_bartitle.indexOf("th") != -1)
			{
				t = t.replace("%d", num.toString()) + ((last && _lastplus && i != _maxnum) ? LASTTAG : "");
				if (4 < num && num < 19)
					return t;
				switch (num % 10) {
					case 1:
						return t.replace("th", "st");
					case 2:
						return t.replace("th", "nd");
					case 3:
						return t.replace("th", "rd");
					default:
						return t;
				}
			}
			else
				return t.replace("%d", num.toString() + ((last && _lastplus && i != _maxnum) ? LASTTAG : ""));
		}
		
		private function addBar(e:MouseEvent):void
		{
			var i:uint = _barlist.length;
			
			if (_lastplus && i > 0)
				_barlist[i - 1].title = _barlist[i - 1].title.replace(LASTTAG, "");
			
			var bar:EditArrayBar = new EditArrayBar(makeTitle(i, true), _WidgetType,
				!_piecebar ? EditArrayBar.E_WIDTH : EditPieceBar.E_WIDTH, _props);
			bar.y = _barpane.height;
			_barpane.addChildAt(bar, 0);
			_barlist.push(bar);
			
			if (_barlist.length == _maxnum)
				_b_add.clickable = false;
			else if (_barlist.length == 2)
				_b_rem.clickable = true;
			
			if (_WidgetType == EditPieceBarOrdered)
				bar.widget.addEventListener(EditBarBase.E_RESIZE, updateHeights);
			
			updateScroller();
			_scrollpane.verticalScrollPosition = _scrollpane.maxVerticalScrollPosition;
		}
		
		private function remBar(e:MouseEvent):void
		{
			var bar:EditArrayBar = _barlist.pop();
			bar.cleanUp();
			_barpane.removeChild(bar);
			
			if (_lastplus)
				_barlist[_barlist.length - 1].title = makeTitle(_barlist.length - 1, true);
			
			if (_barlist.length == _maxnum - 1)
				_b_add.clickable = true;
			else if (_barlist.length == 1)
				_b_rem.clickable = false;
			
			updateScroller();
			_scrollpane.verticalScrollPosition = _scrollpane.maxVerticalScrollPosition;
		}
		
		public function getAllData():Array
		{
			Main.resetFocus();
			var data:Array = [];
			for each (var bar:EditArrayBar in _barlist)
				data.push(bar.data);
			return data;
		}
		
		public function cleanUp():void
		{
			_b_add.removeEventListener(MouseEvent.CLICK, addBar);
			_b_rem.removeEventListener(MouseEvent.CLICK, remBar);
			for each (var bar:EditArrayBar in _barlist)
			{
				if (_piecebar)
					bar.widget.removeEventListener(EditBarBase.E_RESIZE, updateHeights);
				bar.cleanUp();
			}
			Main.stage.removeEventListener(Event.ENTER_FRAME, updateScroller);
		}
		
	}

}