package menu.editing.pieces
{
	import data.DefaultSettings;
	import events.GameEvent;
	import events.IDEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import menu.editing.EditBarBase;
	import menu.PopUp;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class EditPieceBank extends EditPieceBarBase
	{
		override protected function get entrydel():Boolean { return true; }
		override protected function get reindex():Boolean { return true; }
		
		private var _editpiece:EditPiece;
		
		private static var _staticmake:Boolean = false;
		public function EditPieceBank()
		{
			if (_staticmake)
				super(EditBarBase.E_WIDTH);
			else
				throw new Error("Instantiate with makePieceBank() instead.");
		}
		
		private static var _instance:EditPieceBank;
		public static function makePieceBank():EditPieceBank
		{
			if (_instance != null)
				throw new Error("EditPieceBank should not be instantiated more than once.");
			
			_staticmake = true;
			_instance = new EditPieceBank();
			_staticmake = false;
			return _instance;
		}
		
		private var _defpieces:Array = [];
		private var _defpprops:Array = [];
		private var _defpcol:Array = [];
		private var _defpapp:Array = [];
		public function setDefaultPieceInfo(pieces:Array, pprops:Array, pcol:Array, papp:Array):void
		{
			G.arrayCopy2D(_defpieces, pieces);
			G.arrayCopy3D(_defpprops, pprops);
			G.arrayCopy2D(_defpcol, pcol);
			G.arrayCopy2D(_defpapp, papp);
			resetPieceInfo();
		}
		
		/**
		 * The degree to which pieces have been changed from the parent mode's default settings.
		 * 0: no change. 1: safe change. 2: score-resetting change.
		 */
		public function isChanged():uint
		{
			if (_defpieces.length != _entries.length)
				return 2;
			
			var pchange:uint = 0;
			for (var i:uint = 0; i < _defpieces.length; i++)
			{
				var info:Array = _entries[i].getPieceInfo();
				//If any piece changed from a custom to a group (or vice versa), it's a major change.
				if ((_defpieces[i] is uint && info[0] is Array) || (_defpieces[i] is Array && info[0] is uint))
					return 2;
				pchange = pchange | checkForChange(info, [_defpieces[i], _defpprops[i], _defpcol[i], _defpapp[i]], _entries[i].isCustom());
				if (pchange > 2)
					return pchange;
			}
			return pchange;
		}
		
		override protected function addNewEntry(piecedata:*, props:Array, col:*, app:uint, index:int = -1):EditPieceEntry 
		{
			var entry:EditPieceEntry = super.addNewEntry(piecedata, props, col, app, index);
			entry.box.addEventListener(MouseEvent.CLICK, showEditPieceMenu);
			entry.box.buttonMode = true;
			return entry;
		}
		
		private function showEditPieceMenu(e:MouseEvent):void
		{
			const entry:EditPieceEntry = EditPieceEntry(G.getTargetByType(e.target, EditPieceEntry));
			var custom:Boolean = entry.isCustom();
			var info:Array = entry.getPieceInfo(); //Contains the piece info BEFORE it's been edited.
			_editpiece = new (custom ? EditPieceCustom : EditPieceGroup)(info[0], info[1], info[2], info[3]);
			PopUp.makePopUp(
			!custom ? "Edit Piece Group" : "Edit Custom Piece\n---\nClick the grid to add/remove tiles and side connections. Arrow keys shift the view.",
			Vector.<String>(["Accept", "Cancel"]),
			Vector.<Function>([
			function(e:MouseEvent):void
			{
				var info2:Array = _editpiece.getPieceInfo(); //Contains the piece info AFTER it's edited.
				if (info[1].length != 0)
				{
					if (checkForChange(info, info2, custom) > 0)
					{
						entry.setPieceInfo(info2[0], info2[1], info2[2], info2[3]);
						dispatchEvent(new Event(Event.CHANGE)); //to update the mode
					}
					_editpiece = null;
					PopUp.fadeOut();
				}
				else
					PopUp.makePopUp(
					"A custom piece must have at least one tile.",
					Vector.<String>(["Okay, sorry"]),
					Vector.<Function>([PopUp.fadeOut]));
			},
			function(e:MouseEvent):void
			{
				_editpiece = null;
				PopUp.fadeOut();
			}]),
			_editpiece);
		}
		
		/**
		 * Check for a difference between two piece infos (piecedata, props, col, app).
		 * They MUST be of the same type (either both custom or both groups)!
		 * @param	info1 The first piece's info.
		 * @param	info2 The second piece's info.
		 * @param	custom Set to true if the compared pieces are both custom pieces.
		 * @return	The level of change between the two pieces (0 = none, 1 = minor, 2 = score-resetting, 3 = both).
		 */
		private function checkForChange(info1:Array, info2:Array, custom:Boolean):uint
		{
			//Do all safe change checks first, then major changes. Can quit after finding a major change.
			var pchange:uint = 0;
			if (info1[3] != info2[3]) //appearance
				pchange = 1;
			
			var i:uint;
			if (!custom)
			{
				if (info1[2].length != info2[2].length) //colour list length
					pchange = 1;
				for (i = 0; i < info1[2].length && pchange == 0; i++) //color list values
					if (info1[2][i] != info2[2][i])
						pchange = 1;
				
				if (info1[0] != info2[0]) //# tiles
					return pchange | 2;
				
				if (info1[1][0] != info2[1][0] || info1[1][1] != info2[1][1]) //area
					return pchange | 2;
			}
			else
			{
				if (info1[2] != info2[2]) //color
					pchange = 1;
				
				if (info1[0].length != info2[0].length) //# tiles
					return pchange | 2;
				
				var coordcop:Array = info2[0].slice();
				var dirscop:Array = info2[1].slice();
				var j:uint;
				for (i = 0; i < info1[1].length; i++)
				{
					var same:Boolean = false;
					for (j = 0; j < dirscop.length; j++)
					{
						if (info1[0][2 * i] == coordcop[2 * j] && info1[0][2 * i + 1] == coordcop[2 * j + 1])
						{
							coordcop.splice(2 * j, 2);
							same = true;
							break;
						}
					}
					if (!same)
						return pchange | 2;
					
					for (var k:uint = 0; k < 4; k++)
						if (info1[1][i][k] != dirscop[j][k]) //use the same j!
							return pchange | 2;
					
					dirscop.splice(j, 1);
				}
			}
			
			return pchange;
		}
		
		private function setAllPieceInfo(pieces:Array, pprops:Array, pcol:Array, papp:Array):void
		{
			while (_entries.length > 0)
			{
				var entry:EditPieceEntry = _entries.pop();
				entry.parent.removeChild(entry);
				entry.cleanUp();
			}
			
			for (var i:uint = 0; i < pieces.length; i++)
				addNewEntry(pieces[i], pprops[i], pcol[i], papp[i]);
			drawEntries();
		}
		
		public function resetPieceInfo():void
		{
			setAllPieceInfo(_defpieces, _defpprops, _defpcol, _defpapp);
		}
		
		public function resetToStandard():void
		{
			setAllPieceInfo(
			[DefaultSettings.PIECE_I, DefaultSettings.PIECE_L, DefaultSettings.PIECE_RL, DefaultSettings.PIECE_T, DefaultSettings.PIECE_Z, DefaultSettings.PIECE_S, DefaultSettings.PIECE_O],
			[DefaultSettings.DIRS_I, DefaultSettings.DIRS_L, DefaultSettings.DIRS_RL, DefaultSettings.DIRS_T, DefaultSettings.DIRS_Z, DefaultSettings.DIRS_S, DefaultSettings.DIRS_O],
			DefaultSettings.COLORS_STND,
			[0, 0, 0, 0, 0, 0, 0]);
		}
		
		public function addDefaultRandomPiece(e:Event = null):void
		{
			var i:uint = _entries.length;
			var entry:EditPieceEntry = addNewEntry(4, [4, 4], DefaultSettings.COLORS_STND.slice(), 0);
			placeEntry(entry, i, true);
			entry.box.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		}
		
		public function addDefaultCustomPiece(e:Event = null):void
		{
			var i:uint = _entries.length;
			var dirs:Array = [];
			G.arrayCopy2D(dirs, DefaultSettings.DIRS_L);
			var entry:EditPieceEntry = addNewEntry(DefaultSettings.PIECE_L.slice(), dirs, 0xFF0000, 0);
			placeEntry(entry, i, true);
			entry.box.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		}
		
		override protected function deleteEntry(e:MouseEvent):void
		{
			if (_entries.length == 1)
				return;
			
			var entry:EditPieceEntry = EditPieceEntry(G.getTargetByType(e.target, EditPieceEntry));
			var info:Array = entry.getPieceInfo();
			var entryCopy:EditPieceEntry = new EditPieceEntry(entry.index, info[0], info[1], info[2], info[3]);
			var deleteEntryF:Function = super.deleteEntry;
			
			PopUp.makePopUp(
			"Are you sure you want to delete this piece?",
			Vector.<String>(["Yes", "No"]),
			Vector.<Function>([
			function(e2:MouseEvent):void
			{
				entryCopy.cleanUp();
				deleteEntryF(e);
				dispatchEvent(new IDEvent(IDEvent.GO, entryCopy.index));
				PopUp.fadeOut();
			}, PopUp.fadeOut]),
			entryCopy);
		}
		
		override protected function dragEntryEnd(e:MouseEvent = null):void 
		{
			super.dragEntryEnd(e);
			dispatchEvent(new Event(Event.CHANGE)); //to update the mode
		}
		
		public static function getNumPieces():uint
		{
			return _instance.getNumPieces();
		}
		
		/**
		 * Returns all available info on the piece of the specified index. The info is returned in the form of an array:
		 * info\[0] = number of tiles for piece group, or piece map array for custom group
		 * info\[1] = properties (size for piece group, or direction map for custom piece)
		 * info\[2] = color (array for piece group, uint for custom)
		 * info\[3] = appearance style number
		 * @param	i
		 * @return
		 */
		public static function getPieceInfo(i:uint):Array
		{
			return _instance._entries[i].getPieceInfo();
		}
		
		override public function cleanUp():void 
		{
			super.cleanUp();
			for each (var entry:EditPieceEntry in _entries)
				entry.box.removeEventListener(MouseEvent.CLICK, showEditPieceMenu);
			Main.stage.addEventListener(GameEvent.CHANGE, nullifyInstance);
		}
		
		private static function nullifyInstance(e:Event):void
		{
			Main.stage.removeEventListener(GameEvent.CHANGE, nullifyInstance);
			_instance = null;
		}
	}
}