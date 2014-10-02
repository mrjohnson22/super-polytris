package menu.editing.previews 
{
	import data.DefaultSettings;
	import data.SettingNames;
	import flash.display.Shape;
	import objects.GamePiece;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class PreviewBorder extends PreviewItem 
	{
		protected var _piece:PExGamePiece;
		override protected function firstDraw():void
		{
			//Have a blank rectangle to fill up some space, so the piece doesn't get auto-sized too large.
			var blank:Shape = new Shape();
			blank.graphics.beginFill(0, 0);
			blank.graphics.drawRect(0, 0, G.S * 5, G.S * 5);
			addChild(blank);
			
			_piece = new PExGamePiece(DefaultSettings.PIECE_Z, DefaultSettings.DIRS_Z, 0xFF0000, cs[SettingNames.BORCOL], 0);
			G.centreX(_piece, blank);
			G.centreY(_piece, false, blank);
			addChild(_piece);
		}
		
		override public function update():void 
		{
			_piece.update();
		}
		
	}

}