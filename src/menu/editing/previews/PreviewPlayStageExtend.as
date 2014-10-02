package menu.editing.previews 
{
	import data.SettingNames;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class PreviewPlayStageExtend extends PreviewPlayStageClear
	{
		private var s:Number = G.S;
		
		override protected function firstDraw():void 
		{
			super.firstDraw();
			
			if (cs[SettingNames.CLEN] > 1 && cs[SettingNames.EXTENDABLE]) {
				if (cs[SettingNames.CLEN] != cs[SettingNames.BINY])
					for (var x:uint = 1; x <= cs[SettingNames.CWID]; x++)
						drawTile(0x0000FF, x, cs[SettingNames.CLEN] + 1);
				if (cs[SettingNames.CWID] != cs[SettingNames.BINX])
					for (var y:uint = 1; y <= cs[SettingNames.CLEN]; y++)
						drawTile(0x0000FF, cs[SettingNames.CWID] + 1, y);
			}
		}
		
		override public function update():void 
		{
			removeChild(_playStage);
			firstDraw();
		}
		
	}

}