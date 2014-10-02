package menu.editing.pieces 
{
	import fl.controls.NumericStepper;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import menu.TextButton;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class EditPieceBarOrdered extends EditPieceBar
	{
		override protected function get entrydel():Boolean { return true; }
		
		private var _addentry:EditPieceEntry;
		private var _addsel:NumericStepper;
		private var _addbutton:TextButton;
		private var _addcontainer:Sprite;
		
		public function EditPieceBarOrdered()
		{
			super();
			
			var info:Array = EditPieceBank.getPieceInfo(0);
			_addentry = new EditPieceEntry(-1, info[0], info[1], info[2], info[3]);
			
			_addsel = new NumericStepper();
			_addsel.value = 0;
			_addsel.minimum = 0;
			_addsel.maximum = EditPieceBank.getNumPieces() - 1;
			_addsel.width = 40;
			
			_addbutton = new TextButton("<- Add to queue", null, 0xFFFFFF, 10);
			
			_addcontainer = new Sprite();
			
			const selmargin:Number = 0; //adjust to my liking
			_addsel.x = selmargin;
			_addsel.y = -selmargin + _addentry.height - _addsel.height;
			
			_addbutton.x = _addentry.width;
			G.centreY(_addbutton, false, _addentry);
			
			_addcontainer.addChild(_addentry);
			_addcontainer.addChild(_addsel);
			_addcontainer.addChild(_addbutton);
			_addcontainer.x = (E_WIDTH - EditPieceEntry.SIZE - EditPieceEntry.COUNTSIZE) / 2;
			
			_addsel.addEventListener(Event.CHANGE, showPieceToAdd);
			_addbutton.addEventListener(MouseEvent.CLICK, addPieceToQueue);
		}
		
		private function showPieceToAdd(e:Event):void
		{
			var info:Array = EditPieceBank.getPieceInfo(_addsel.value);
			_addentry.setPieceInfo(info[0], info[1], info[2], info[3]);
			_addcontainer.addChildAt(_addentry, 0);
		}
		
		private function addPieceToQueue(e:MouseEvent):void
		{
			addPieceFromBank(_addsel.value, 1);
			placeEntry(_entries[_entries.length - 1], _entries.length - 1, true);
		}
		
		override public function prepareEntries(pinfo:Array = null):void
		{
			if (pinfo == null)
			{
				for (var i:uint = 0, n:uint = EditPieceBank.getNumPieces(); i < n; i++)
					addPieceFromBank(i, 1);
			}
			else
			{
				for (var i:uint = 0; i < pinfo.length; i += 2)
					addPieceFromBank(pinfo[i], pinfo[i + 1]);
			}
			drawEntries();
		}
		
		override protected function drawBack(extrarows:uint = 0):void
		{
			super.drawBack(1);
			_addcontainer.y = _back.y + _back.height - EditPieceEntry.SIZE;
			addChildAt(_addcontainer, getChildIndex(_back) + 1);
		}
		
		/**
		 * Returns an array containing all relevant piece information for this bar.
		 * (Either an array of likelihoods, or of order information.)
		 * @return
		 */
		override public function getAllPieceInfo():Array
		{
			var ret:Array = [];
			for each (var entry:EditPieceEntry in _entries)
				ret.push(entry.index, entry.count);
			
			return ret;
		}
		
		override public function cleanUp():void 
		{
			_addsel.removeEventListener(Event.CHANGE, showPieceToAdd);
			_addbutton.removeEventListener(MouseEvent.CLICK, addPieceToQueue);
			super.cleanUp();
		}
	}

}