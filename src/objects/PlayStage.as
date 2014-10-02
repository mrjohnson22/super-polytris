package objects 
{
	import data.SettingNames;
	import data.Settings;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import visuals.Tile;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class PlayStage extends Sprite 
	{
		private var s:uint = G.S;
		
		private var _playZone:Sprite;
		public function get playZone():Sprite
		{
			return _playZone;
		}
		
		public function PlayStage(cs:Settings)
		{
			//create background
			var bg:Sprite = new Sprite();
			if (!cs[SettingNames.FITMODE])
			{
				var matrix:Matrix = new Matrix();
				matrix.createGradientBox(s * cs[SettingNames.BINX], -s * cs[SettingNames.BINY], Math.PI / 2);
				bg.graphics.beginGradientFill(
					GradientType.LINEAR,
					[cs[SettingNames.SCOL], cs[SettingNames.SCOL], cs[SettingNames.BGCOL], cs[SettingNames.BGCOL], cs[SettingNames.DCOL], cs[SettingNames.DCOL]],
					[1, 1, 1, 1, 1, 1],
					[0, Math.max(255 * (cs[SettingNames.SZONE] - 0.5) / cs[SettingNames.BINY], 0),
					255 * (cs[SettingNames.SZONE] + 0.5) / cs[SettingNames.BINY], 255 * (cs[SettingNames.BINY] - cs[SettingNames.DZONE] - 0.5) / cs[SettingNames.BINY],
					Math.min(255 * (cs[SettingNames.BINY] - cs[SettingNames.DZONE] + 0.5) / cs[SettingNames.BINY], 255), 255],
					matrix);
			}
			else
				bg.graphics.beginFill(cs[SettingNames.BGCOL]);
			
			bg.graphics.drawRect(0, 0, s * cs[SettingNames.BINX], -s * cs[SettingNames.BINY]);
			bg.x = s;
			bg.y = -s;
			addChild(bg);
			
			//create grid
			var grid:Sprite = new Sprite();
			grid.graphics.lineStyle(2, 0, 0.25);
			var i:uint;
			for (i = 0; i < cs[SettingNames.BINX] - 1; i++)
			{
				grid.graphics.moveTo(s * (2 + i), -s);
				grid.graphics.lineTo(s * (2 + i), -cs[SettingNames.BINY] * s - s);
			}
			for (i = 0; i < cs[SettingNames.BINY] - 1; i++)
			{
				grid.graphics.moveTo(s, -s * (2 + i));
				grid.graphics.lineTo(cs[SettingNames.BINX] * s + s, -s * (2 + i));
			}
			addChild(grid);
			
			//set up bin
			var bin:Tile;
			var binypos:Number = -s * cs[SettingNames.BINY];
			for (i = 0; i < cs[SettingNames.BINX] * 2 + 4; i++)
			{
				bin = new Tile(cs[SettingNames.BINCOL], cs[SettingNames.BINAPP], null);
				bin.x = s * int(i / 2);
				if (i % 2 == 0)
					bin.y = 0;
				else
					bin.y = binypos - s;
				addChild(bin);
			}
			
			var binxpos:Number = s * (cs[SettingNames.BINX] + 1);
			for (i = 1; i <= cs[SettingNames.BINY] * 2; i++)
			{
				bin = new Tile(cs[SettingNames.BINCOL], cs[SettingNames.BINAPP], null);
				bin.y = -s * int((i + 1) / 2);
				if (i % 2 == 1)
					bin.x = 0;
				else
					bin.x = binxpos;
				addChild(bin);
			}
			
			//set up masker
			var masker:Sprite = new Sprite();
			masker.graphics.beginFill(0);
			masker.graphics.drawRect(s, -s, s * cs[SettingNames.BINX], -s * cs[SettingNames.BINY]);
			_playZone = new Sprite();
			addChild(masker);
			addChild(_playZone);
			_playZone.mask = masker;
			_playZone.x += s;
			_playZone.y -= s;
		}
		
	}

}