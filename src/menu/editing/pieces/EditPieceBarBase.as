package menu.editing.pieces 
{
	import com.greensock.TweenLite;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import menu.editing.EditBarBase;
	
	/**
	 * ...
	 * @author XJ
	 */
	internal class EditPieceBarBase extends EditBarBase
	{
		protected var _width:Number;
		private const _height:Number = E_HEIGHT * 1.8;
		
		private var _container:Sprite;
		private var _cols:uint;
		private const _margin:Number = 15;
		
		protected var _entries:Vector.<EditPieceEntry> = new Vector.<EditPieceEntry>();
		private var _entrywid:Number;
		private var _entryhgt:Number;
		
		private var _rows:uint = 1;
		
		//Piece entry properties, per bar type
		protected function get entrydel():Boolean { return false; }
		protected function get entrycount():Boolean { return false; }
		protected function get reindex():Boolean { return false; }
		
		protected var _dragentry:EditPieceEntry;
		private var _dragslot:uint;
		
		public function EditPieceBarBase(width:Number)
		{
			_width = width;
			_entrywid = EditPieceEntry.SIZE + (entrycount ? EditPieceEntry.COUNTSIZE : 0);
			_entryhgt = EditPieceEntry.SIZE;
			
			_container = new Sprite();
			_cols = uint(_width / (_entrywid + _margin));
			_container.x = (_width - _cols * (_entrywid + _margin) + _margin) / 2;
		}
		
		public function getNumPieces():uint
		{
			return _entries.length;
		}
		
		protected function drawEntries():void
		{
			addChild(_container);
			for (var i:uint = 0; i < _entries.length; i++)
				placeEntry(_entries[i], i, false);
			
			_rows = Math.ceil(_entries.length / _cols);
			drawBack();
		}
		
		protected function addNewEntry(piecedata:*, props:Array, col:*, app:uint, index:int = -1):EditPieceEntry
		{
			var entry:EditPieceEntry = new EditPieceEntry(index == -1 ? _entries.length : index, piecedata, props, col, app);
			//If deletable, draggable.
			if (entrydel)
			{
				entry.makeDeletable(deleteEntry, dragEntryStart);
				Main.stage.addEventListener(MouseEvent.MOUSE_UP, dragEntryEnd);
			}
			_entries.push(entry);
			return entry;
		}
		
		protected function deleteEntry(e:MouseEvent):void
		{
			if (_entries.length == 1)
				return;
			var i:uint = _entries.indexOf(EditPieceEntry(G.getTargetByType(e.target, EditPieceEntry)));
			_entries[i].parent.removeChild(_entries[i]);
			_entries[i].cleanUp();
			_entries.splice(i, 1);
			for (; i < _entries.length; i++)
				placeEntry(_entries[i], i, false);
			
			if (_entries.length % _cols == 0)
			{
				_rows--;
				drawBack();
			}
		}
		
		protected function dragEntryStart(e:MouseEvent):void
		{
			_dragentry = EditPieceEntry(G.getTargetByType(e.target, EditPieceEntry));
			_dragentry.startDrag();
			_dragslot = _entries.indexOf(_dragentry);
			_container.addChild(_dragentry);
			addEventListener(Event.ENTER_FRAME, dragEntryDuring);
		}
		
		protected function dragEntryDuring(e:Event):void
		{
			var moveslot:int = -1;
			var entry:EditPieceEntry;
			var i:uint, n:uint = _entries.length;
			for (i = 0; i < n; i++)
			{
				if (i == _dragslot || _entries[i].tweening)
					continue;
				if (Math.abs(Point.distance(new Point(_dragentry.x, _dragentry.y), new Point(_entries[i].x, _entries[i].y)))
					< EditPieceEntry.SIZE * 0.6)
				{
					moveslot = i;
					break;
				}
			}
			if (moveslot == -1)
				return;
			
			_entries.splice(_dragslot, 1);
			_entries.splice(moveslot, 0, _dragentry);
			_dragslot = moveslot;
			if (reindex)
				_dragentry.index = _dragslot;
			
			for (i = 0; i < n; i++)
			{
				if (i == _dragslot)
					continue;
				entry = _entries[i];
				placeEntry(entry, i, false);
			}
		}
		
		protected function dragEntryEnd(e:MouseEvent = null):void
		{
			if (_dragentry != null)
			{
				_dragentry.stopDrag();
				var entry:EditPieceEntry = _dragentry;
				_dragentry = null;
				placeEntry(entry, _dragslot, false);
			}
			removeEventListener(Event.ENTER_FRAME, dragEntryDuring);
		}
		
		protected function placeEntry(entry:EditPieceEntry, index:uint, drawnow:Boolean):void
		{
			if (reindex)
				entry.index = index;
			
			var x:uint = index % _cols;
			var y:uint = Math.floor(index / _cols);
			
			//Lengthen the bar if necessary. Placing a new entry will only increase the size.
			if (drawnow && y + 1 > _rows)
			{
				_rows = y + 1;
				//If first draw hasn't happened, don't draw yet.
				if (_back != null)
					drawBack();
			}
			var destx:Number = (_entrywid + _margin) * x;
			var desty:Number = (_height - _entryhgt) / 2 + _height * y;
			
			if (entry.parent == null)
			{
				entry.x = destx;
				entry.y = desty;
			}
			else if (entry.x != destx || entry.y != desty)
			{
				entry.tweening = true;
				TweenLite.to(entry, 0.2, { x:destx, y:desty, onComplete:function():void
				{
					entry.tweening = false;
				}} );
			}
			
			var maxdepth:uint = _dragentry == null ? uint.MAX_VALUE : _container.getChildIndex(_dragentry) - 1;
			_container.addChildAt(entry, Math.min(index, maxdepth));
		}
		
		protected function drawBack(extrarows:uint = 0):void
		{
			var first:Boolean = (_back == null);
			if (first)
				_back = new Sprite();
			else
				_back.graphics.clear();
			
			_back.graphics.beginFill(COLDARK);
			_back.graphics.drawRect(0, 0, _width, _height * (_rows + extrarows));
			addChildAt(_back, 0);
			
			if (!first)
				dispatchEvent(new Event(E_RESIZE));
		}
		
		override public function cleanUp():void 
		{
			for each (var entry:EditPieceEntry in _entries)
				entry.cleanUp();
			Main.stage.removeEventListener(MouseEvent.MOUSE_UP, dragEntryEnd);
		}
		
		public function set playing(value:Boolean):void
		{
			for each (var entry:EditPieceEntry in _entries)
				entry.playing = value;
		}
		
	}

}