package menu.editing.previews 
{
	import data.SettingNames;
	import data.Settings;
	import objects.GamePiece;
	import objects.GameTile;
	
	/**
	 * ...
	 * @author XJ
	 */
	internal class PExGamePiece extends GamePiece 
	{
		public function PExGamePiece(coords:Array, dirs:Array, color:uint, borcol:int, appearStyle:int = -1, clearStyle:int = -1)
		{
			super(coords, dirs, color, borcol, appearStyle, clearStyle);
		}
		
		internal function update():void
		{
			cs = Settings.currentGame;
			_borcol = cs[SettingNames.BORCOL];
			borDraw();
		}
		
	}

}