package menu.editing.pieces 
{	
	/**
	 * ...
	 * @author XJ
	 */
	public class EditPieceBar extends EditPieceBarBase
	{
		public static const E_WIDTH:Number = G.STAGE_WIDTH * 0.9;
		
		override protected function get entrycount():Boolean { return true; }
		
		public function EditPieceBar()
		{
			super(E_WIDTH);
		}
		
		protected function addPieceFromBank(i:uint, count:uint):void
		{
			var info:Array = EditPieceBank.getPieceInfo(i);
			var entry:EditPieceEntry = addNewEntry(info[0], info[1], info[2], info[3], i);
			entry.makeCountable(count, this is EditPieceBarOrdered);
		}
		
		public function prepareEntries(pinfo:Array = null):void
		{
			if (pinfo == null)
			{
				for (var i:uint = 0, n:uint = EditPieceBank.getNumPieces(); i < n; i++)
					addPieceFromBank(i, 1);
			}
			else
			{
				for (var i:uint = 0, n:uint = EditPieceBank.getNumPieces(); i < n; i++)
					addPieceFromBank(i, pinfo[i]);
			}
			drawEntries();
		}
		
		/**
		 * Returns an array containing all relevant piece information for this bar.
		 * (Either an array of likelihoods, or of order information.)
		 * @return
		 */
		public function getAllPieceInfo():Array
		{
			var ret:Array = [];
			for each (var entry:EditPieceEntry in _entries)
				ret.push(entry.count);
			
			return ret;
		}
	}

}