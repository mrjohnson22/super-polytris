package objects
{

	import flash.display.Sprite;
	import visuals.OverlapSquare;
	import visuals.Tile;
	
	public class GameTile extends Tile
	{
		private var s:Number = G.S;
		
		public var xpos:int;
		public var ypos:int;
		
		public var xcor:int;
		public var ycor:int;
		
		private var _bord:Sprite = new Sprite();
		private var _overbox:OverlapSquare;
		
		private var _overlap:Boolean = false;
		
		public function get overlap():Boolean
		{
			return _overlap;
		}
		
		public function set overlap(value:Boolean):void
		{
			if (value == _overlap)
				return;
			
			_overlap = value;
			if (value)
			{
				_overbox = new OverlapSquare();
				addChild(_overbox);
			}
			else
			{
				removeChild(_overbox);
				_overbox = null;
			}
		}
		
		/**
		 * Signifies which directions adjacent to a tile are occupied
		 * by another tile of the same piece. Entries reference these tiles.
		 */
		internal var _dirs:Vector.<GameTile> = new Vector.<GameTile>(4); //[up, down, left, right];
		public function get dirs():Vector.<GameTile>
		{
			return _dirs;
		}
		
		/**
		 * Which piece the tile belongs to.
		 */
		public var piece:GamePiece;
		
		public var checked:Boolean = false;
		
		public function GameTile(piece:GamePiece, color:uint, appearStyle:int = -1, clearStyle:int = -1)
		{
			this.piece = piece;
			super(color, appearStyle, clearStyle);
			addChild(_bord);
		}
		
		internal function borDraw(borcol:int):void
		{
			_borDraw(borcol);
		}
		
		protected function _borDraw(borcol:int):void
		{
			_bord.graphics.clear();
			if (borcol == -1)
				return;
			
			_bord.graphics.lineStyle(2, borcol);
			if (_dirs[3] != null)
				_bord.graphics.moveTo(0, -s);
			else
				_bord.graphics.lineTo(0, -s);
			
			if (_dirs[0] != null)
				_bord.graphics.moveTo(s, -s);
			else
				_bord.graphics.lineTo(s, -s);
			
			if (_dirs[1] != null)
				_bord.graphics.moveTo(s, 0);
			else
				_bord.graphics.lineTo(s, 0);
			
			if (_dirs[2] != null)
				_bord.graphics.moveTo(0, 0);
			else
				_bord.graphics.lineTo(0, 0);
		}
	}
}