package menu.editing.previews 
{
	import data.DefaultSettings;
	import data.SettingNames;
	import data.Settings;
	import objects.GamePiece;
	import objects.PlayStage;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class PreviewPlayStagePiece extends PreviewPlayStage
	{
		private var _piece:GamePiece;
		private var _shad:GamePiece;
		private var _biny:uint;
		
		override protected function firstDraw():void 
		{
			super.firstDraw();
			if (_piece == null)
			{
				_biny = cs[SettingNames.BINY];
				drawPiece();
				pieceUpdate();
			}
		}
		
		override public function update():void 
		{
			super.update();
			if (fitChange())
				drawPiece();
			pieceUpdate();	
		}
		
		protected function fitChange():Boolean
		{
			var newy:uint = Math.min(cs[SettingNames.BINY], 4);
			if (_biny != newy)
			{
				_biny = newy;
				return true;
			}
			return false;
		}
		
		protected function drawPiece():void
		{
			_piece = GamePiece.createRandomPiece(4, 1, _biny, [0xFF0000], cs[SettingNames.BORCOL], 0);
			_shad = _piece.shadowCopy();
			_shad.alpha = Settings.SHADOW_ALPHA;
		}
		
		protected function pieceUpdate():void
		{
			_shad.visible = cs[SettingNames.SHADOWS];
			_piece.placePiece(cs[SettingNames.SPAWNPOSY]);
			_shad.placePiece(0);
			_playStage.playZone.addChild(_shad);
			_playStage.playZone.addChild(_piece);
		}
		
	}

}