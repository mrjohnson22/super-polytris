package menu.editing.previews 
{
	import data.SettingNames;
	import visuals.Tile;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class PreviewPlayStageClear extends PreviewPlayStage
	{
		private var s:Number = G.S;
		
		override protected function firstDraw():void 
		{
			super.firstDraw();
			
			for (var x:uint = 1; x <= cs[SettingNames.CWID]; x++)
				for (var y:uint = 1; y <= cs[SettingNames.CLEN]; y++)
					drawTile(0xFF0000, x, y);
		}
		
		protected function drawTile(color:uint, x:uint, y:uint)
		{
			var tile:Tile = new Tile(color, 0, cs[SettingNames.PCLEAR]);
			tile.x = x * s;
			tile.y = -y * s;
			tile.addClearStyle();
			_playStage.addChild(tile);
		}
		
		override public function update():void 
		{
			removeChild(_playStage);
			firstDraw();
		}
		
	}

}