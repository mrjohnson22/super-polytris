package menu.editing.previews 
{
	import data.SettingNames;
	import visuals.Tile;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class PreviewPlayStagePriority extends PreviewPlayStage
	{
		private var s:Number = G.S;
		
		private var _xmax:uint;
		private var _ymax:uint;
		private var _tilemap:Array;
		
		override protected function firstDraw():void 
		{
			super.firstDraw();
			
			_xmax = Math.min(cs[SettingNames.CWID] + 1, cs[SettingNames.BINX]);
			_ymax = Math.min(cs[SettingNames.CLEN] + 1, cs[SettingNames.BINY]);
			_tilemap = G.create2DArray(_xmax, _ymax);
			
			for (var x:uint = 1; x <= _xmax; x++)
				for (var y:uint = 1; y <= _ymax; y++)
					drawTile(0xFF0000, x, y);
			
			updateCleared();
		}
		
		protected function drawTile(color:uint, x:uint, y:uint)
		{
			var tile:Tile = new Tile(color, 0, cs[SettingNames.PCLEAR]);
			tile.x = x * s;
			tile.y = -y * s;
			_playStage.addChild(tile);
			_tilemap[x - 1][y - 1] = tile;
		}
		
		private function updateCleared():void
		{
			var left:uint = _xmax == cs[SettingNames.CWID] || cs[SettingNames.LTOR] ? 0 : 1;
			var right:uint = left + cs[SettingNames.CWID];
			var bot:uint = _ymax == cs[SettingNames.CLEN] || cs[SettingNames.BTOT] ? 0 : 1;
			var top:uint = bot + cs[SettingNames.CLEN];
			
			for (var x:uint = left; x < right; x++)
				for (var y:uint = bot; y < top; y++)
					Tile(_tilemap[x][y]).addClearStyle();
		}
		
		override public function update():void 
		{
			for (var x:uint = 0; x < _xmax; x++)
				for (var y:uint = 0; y < _ymax; y++)
					Tile(_tilemap[x][y]).removeClearStyle();
			
			updateCleared();
		}
		
	}

}