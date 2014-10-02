package menu.editing.pieces 
{
	import data.Settings;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import media.sounds.SoundList;
	import media.sounds.Sounds;
	import menu.ICleanable;
	import objects.GamePiece;
	import visuals.boxes.NextBox;
	import visuals.boxes.NextBox1;
	
	/**
	 * ...
	 * @author XJ
	 */
	internal class EditPieceBuilder extends Sprite implements ICleanable
	{
		private const CANVAS_TILESIZE = Settings.MAX_NUM_TILES;
		
		private var _box:NextBox;
		private var _canvas:Sprite;
		private var _tileslots:Vector.<Sprite> = new Vector.<Sprite>();
		private var _hover:Sprite;
		
		private var _tilemap:Array;
		private var _tiles:Vector.<PExGameTile>;
		private var _edgelist:Vector.<SimpleButton>;
		
		private var _offsetwid:int;
		private var _offsetlen:int;
		
		private var _coords:Array;
		private var _dirs:Array;
		private var _col:uint;
		private var _app:uint;
		
		private var _maxzoom:uint = 4;
		
		/**
		 * The number of tiles visible on the edge of the tile slot canvas.
		 * That means a smaller zoom value is actually zoomed in more.
		 */
		private var _zoom:uint = 4;
		internal function get zoom():uint
		{
			return _zoom;
		}
		
		internal function set zoom(value:uint):void
		{
			value = Math.ceil(value / 2) * 2;
			if (value > CANVAS_TILESIZE)
				return;
			_zoom = value;
			_canvas.scaleX = _canvas.scaleY = 4 / _zoom;
			G.centreX(_canvas, _box.viewbox);
			G.centreY(_canvas, true, _box.viewbox);
		}
		
		public function EditPieceBuilder(piecedata:Array, props:Array, col:uint, app:uint) 
		{
			_coords = piecedata.slice();
			G.arrayCopy2D(_dirs = [], props);
			_col = col;
			_app = app;
			
			_box = new NextBox1();
			_canvas = new Sprite();
			
			for (var y:uint = 0; y < CANVAS_TILESIZE; y++)
				for (var x:uint = 0; x < CANVAS_TILESIZE; x++)
				{
					var slot:Sprite = new TileSlot();
					_tileslots.push(slot);
					slot.x = G.S * x;
					slot.y = -G.S * y;
					_canvas.addChild(slot);
					
					slot.tabChildren = slot.tabEnabled = false;
					slot.buttonMode = true;
					slot.addEventListener(MouseEvent.MOUSE_OVER, displayHover);
					slot.addEventListener(MouseEvent.MOUSE_OUT, hideHover);
					slot.addEventListener(MouseEvent.MOUSE_DOWN, toggleTile);
				}
			
			_canvas.mask = _box.viewbox;
			addChild(_box);
			
			//Don't need to offset coords to make then non-negative, as they should already be non-neg at the start.
			_offsetwid = Math.ceil((CANVAS_TILESIZE - GamePiece.getPieceSize(_coords, true)) / 2);
			_offsetlen = Math.ceil((CANVAS_TILESIZE - GamePiece.getPieceSize(_coords, false)) / 2);
			createTiles();
		}
		
		private function createTiles():void
		{
			_tilemap = G.create2DArray(CANVAS_TILESIZE, CANVAS_TILESIZE);
			_tiles = new Vector.<PExGameTile>();
			
			if (_edgelist != null)
				for each (var eb:SimpleButton in _edgelist)
					_canvas.removeChild(eb);
			_edgelist = new Vector.<SimpleButton>();
			
			var tile:PExGameTile, i:uint;
			for (i = 0; i < _coords.length; i += 2)
			{
				tile = new PExGameTile(null, _col, _app);
				tile.mouseChildren = tile.mouseEnabled = false;
				_tilemap[_coords[i] + _offsetwid][_coords[i + 1] + _offsetlen] = tile;
				_tiles.push(tile);
				
				tile.x = G.S * (_coords[i] + _offsetwid);
				tile.y = -G.S * (_coords[i + 1] + _offsetlen);
				
				_canvas.addChild(tile);
			}
			
			for (i = 0; i < _tiles.length; i++)
			{
				tile = _tiles[i];
				
				if (_dirs[i][0])
					tile.dirs[0] = _tilemap[_coords[2 * i] + _offsetwid][_coords[2 * i + 1] + _offsetlen + 1];
				if (_dirs[i][1])
					tile.dirs[1] = _tilemap[_coords[2 * i] + _offsetwid + 1][_coords[2 * i + 1] + _offsetlen];
				var xtest:int = _coords[2 * i] + _offsetwid;
				var ytest:int = _coords[2 * i + 1] + _offsetlen - 1;
				if (0 <= xtest && xtest < CANVAS_TILESIZE && 0 <= ytest && ytest < CANVAS_TILESIZE
					&& _tilemap[xtest][ytest] != null)
				{
					makeEdgeButton(tile, true);
					if (_dirs[i][2])
						tile.dirs[2] = _tilemap[xtest][ytest];
				}
				xtest = _coords[2 * i] + _offsetwid - 1;
				ytest = _coords[2 * i + 1] + _offsetlen;
				if (0 <= xtest && xtest < CANVAS_TILESIZE && 0 <= ytest && ytest < CANVAS_TILESIZE
					&& _tilemap[xtest][ytest] != null)
				{
					makeEdgeButton(tile, false);
					if (_dirs[i][3])
						tile.dirs[3] = _tilemap[xtest][ytest];
				}
				
				tile.update();
			}
		}
		
		private function makeEdgeButton(tile:Sprite, bot_left:Boolean):void
		{
			var eb:SimpleButton = new TileEdgeButton();
			eb.x = tile.x;
			eb.y = tile.y;
			if (bot_left)
				eb.rotation = 90;
			
			_edgelist.push(eb)
			_canvas.addChild(eb);
			eb.mouseEnabled = true;
			eb.tabEnabled = false;
			eb.addEventListener(MouseEvent.CLICK, toggleEdge);
		}
		
		private function removeEdgeButton(tile:Sprite, bot_left:Boolean):Boolean
		{
			var eb:SimpleButton = null;
			for (var i:uint = 0; i < _edgelist.length; i++)
			{
				if (_edgelist[i].x == tile.x && _edgelist[i].y == tile.y &&
				((!bot_left && _edgelist[i].rotation == 0) || (bot_left && _edgelist[i].rotation != 0)))
				{
					eb = _edgelist[i];
					break;
				}
			}
			if (eb == null)
				return false;
			eb.removeEventListener(MouseEvent.CLICK, toggleEdge);
			_edgelist.splice(_edgelist.indexOf(eb), 1);
			_canvas.removeChild(eb);
			return true;
		}
		
		static internal const UP:uint = 0;
		static internal const RIGHT:uint = 1;
		static internal const DOWN:uint = 2;
		static internal const LEFT:uint = 3;
		internal function slideTiles(dir:uint):void
		{
			var xshift:int, yshift:int, i:uint;
			switch (dir)
			{
				case UP:
					for (i = 0; i < CANVAS_TILESIZE; i++)
						if (_tilemap[i][CANVAS_TILESIZE - 1] != null)
							return;
					xshift = 0;
					yshift = 1;
					break;
				case RIGHT:
					for (i = 0; i < CANVAS_TILESIZE; i++)
						if (_tilemap[CANVAS_TILESIZE - 1][i] != null)
							return;
					xshift = 1;
					yshift = 0;
					break;
				case DOWN:
					for (i = 0; i < CANVAS_TILESIZE; i++)
						if (_tilemap[i][0] != null)
							return;
					xshift = 0;
					yshift = -1;
					break;
				case LEFT:
					for (i = 0; i < CANVAS_TILESIZE; i++)
						if (_tilemap[0][i] != null)
							return;
					xshift = -1;
					yshift = 0;
					break;
				default:
					return;
			}
			
			_offsetwid += xshift;
			_offsetlen += yshift;
			
			for each (var tile:PExGameTile in _tiles)
				_canvas.removeChild(tile);
			createTiles();
			if (_hover != null)
				_canvas.addChild(_hover);
		}
		
		private function displayHover(e:MouseEvent):void
		{
			if (_hover != null)
				_canvas.removeChild(_hover);
			
			var target:Sprite = Sprite(e.target);
			_hover = new TileSlotHover();
			_hover.x = target.x;
			_hover.y = target.y;
			_hover.mouseEnabled = _hover.mouseChildren = false;
			_canvas.addChild(_hover);
		}
		
		private function hideHover(e:MouseEvent):void
		{
			//Possible that a new hover came before this one & removed it already.
			//Only remove a hover if you rolled off the current one.
			//Note: I think mouse outs have higher priority over mouse rolls, so this isn't really that necessary.
			var target:Sprite = Sprite(e.target);
			if (target.x != _hover.x || target.y != _hover.y)
				return;
			
			_canvas.removeChild(_hover);
			_hover = null;
		}
		
		private function toggleTile(e:MouseEvent):void
		{
			var tarnum = _tileslots.indexOf(e.target);
			var x:int = tarnum % CANVAS_TILESIZE;
			var y:int = Math.floor(tarnum / CANVAS_TILESIZE);
			
			var tile:PExGameTile;
			var i:uint;
			if (_tilemap[x][y] == null)
			{
				if (_tiles.length >= CANVAS_TILESIZE)
					return;
				
				//Add tile
				Sounds.playSingleSound(SoundList.BlipHi);
				tile = new PExGameTile(null, _col, _app);
				_tilemap[x][y] = tile;
				_tiles.push(tile);
				
				tile.x = G.S * x;
				tile.y = -G.S * y;
				tile.mouseChildren = tile.mouseEnabled = false;
				if (_hover != null)
					_canvas.addChildAt(tile, _canvas.getChildIndex(_hover));
				else
					_canvas.addChild(tile);
				
				_coords.push(x - _offsetwid, y - _offsetlen);
				_dirs.push([false, false, false, false]);
				
				var n:uint = _tiles.length - 1;
				if (y + 1 < CANVAS_TILESIZE && _tilemap[x][y + 1] != null)
				{
					i = _tiles.indexOf(_tilemap[x][y + 1]);
					tile.dirs[0] = _tiles[i];
					_tiles[i].dirs[2] = tile;
					_dirs[n][0] = true;
					_dirs[i][2] = true;
					makeEdgeButton(_tiles[i], true);
				}
				if (x + 1 < CANVAS_TILESIZE && _tilemap[x + 1][y] != null)
				{
					i = _tiles.indexOf(_tilemap[x + 1][y]);
					tile.dirs[1] = _tiles[i];
					_tiles[i].dirs[3] = tile;
					_dirs[n][1] = true;
					_dirs[i][3] = true;
					makeEdgeButton(_tiles[i], false);
				}
				if (y - 1 >= 0 && _tilemap[x][y - 1] != null)
				{
					i = _tiles.indexOf(_tilemap[x][y - 1]);
					tile.dirs[2] = _tiles[i];
					_tiles[i].dirs[0] = tile;
					_dirs[n][2] = true;
					_dirs[i][0] = true;
					makeEdgeButton(tile, true);
				}
				if (x - 1 >= 0 && _tilemap[x - 1][y] != null)
				{
					i = _tiles.indexOf(_tilemap[x - 1][y]);
					tile.dirs[3] = _tiles[i];
					_tiles[i].dirs[1] = tile;
					_dirs[n][3] = true;
					_dirs[i][1] = true;
					makeEdgeButton(tile, false);
				}
				
				for each (tile in _tiles)
					tile.update();
			}
			else
			{
				//Remove tile
				Sounds.playSingleSound(SoundList.BlipLow);
				tile = _tilemap[x][y];
				_tilemap[x][y] = null;
				_canvas.removeChild(tile);
				
				if (y + 1 < CANVAS_TILESIZE && _tilemap[x][y + 1] != null)
				{
					removeEdgeButton(_tilemap[x][y + 1], true);
					if (tile.dirs[0])
					{
						tile.dirs[0].dirs[2] = null;
						PExGameTile(tile.dirs[0]).update();
						_dirs[_tiles.indexOf(tile.dirs[0])][2] = false;
					}
				}
				if (x + 1 < CANVAS_TILESIZE && _tilemap[x + 1][y] != null)
				{
					removeEdgeButton(_tilemap[x + 1][y], false);
					if (tile.dirs[1])
					{
						tile.dirs[1].dirs[3] = null;
						PExGameTile(tile.dirs[1]).update();
						_dirs[_tiles.indexOf(tile.dirs[1])][3] = false;
					}
				}
				if (y - 1 >= 0 && _tilemap[x][y - 1] != null)
				{
					removeEdgeButton(tile, true);
					if (tile.dirs[2])
					{
						tile.dirs[2].dirs[0] = null;
						PExGameTile(tile.dirs[2]).update();
						_dirs[_tiles.indexOf(tile.dirs[2])][0] = false;
					}
				}
				if (x - 1 >= 0 && _tilemap[x - 1][y] != null)
				{
					removeEdgeButton(tile, false);
					if (tile.dirs[3])
					{
						tile.dirs[3].dirs[1] = null;
						PExGameTile(tile.dirs[3]).update();
						_dirs[_tiles.indexOf(tile.dirs[3])][1] = false;
					}
				}
				
				var i:uint = _tiles.indexOf(tile);
				_tiles.splice(i, 1);
				_coords.splice(2 * i, 2);
				_dirs.splice(i, 1);
			}
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		private function toggleEdge(e:MouseEvent):void
		{
			var target:SimpleButton = SimpleButton(e.target);
			var x:Number = target.x / G.S;
			var y:Number = -target.y / G.S;
			var vert:Boolean = target.rotation != 0;
			var tile1:PExGameTile = _tilemap[x][y];
			var tile2:PExGameTile = !vert ? _tilemap[x - 1][y] : _tilemap[x][y - 1];
			var d1:uint = !vert ? 3 : 2;
			var d2:uint = !vert ? 1 : 0;
			
			if (tile1.dirs[d1] != null)
			{
				Sounds.playSingleSound(SoundList.BlipLow);
				tile1.dirs[d1] = null;
				tile2.dirs[d2] = null;
				_dirs[_tiles.indexOf(tile1)][d1] = false;
				_dirs[_tiles.indexOf(tile2)][d2] = false;
			}
			else
			{
				Sounds.playSingleSound(SoundList.BlipHi);
				tile1.dirs[d1] = tile2;
				tile2.dirs[d2] = tile1;
				_dirs[_tiles.indexOf(tile1)][d1] = true;
				_dirs[_tiles.indexOf(tile2)][d2] = true;
			}
			
			tile1.update();
			tile2.update();
		}
		
		/**
		 * Places the tile canvas on the stage. Don't access width/height after calling this!
		 */
		internal function setUp():void
		{
			if (_canvas.parent != null)
				return;
			_box.addChild(_canvas);
			zoom = Math.ceil(Math.max(GamePiece.getPieceSize(_coords, true), GamePiece.getPieceSize(_coords, false)) / 2) * 2;
		}
		
		internal function setCol(col:uint):void
		{
			_col = col;
			for each (var tile:PExGameTile in _tiles)
				tile.setColor(col);
		}
		
		internal function setApp(app:uint):void
		{
			_app = app;
			for each (var tile:PExGameTile in _tiles)
				tile.setAppearance(app);
		}
		
		/**
		 * Returns all available info on this entry's piece. The info is returned in the form of an array:
		 * info\[0] = map of tile coordinates (positive Cartesian)
		 * info\[1] = direction map
		 * info\[2] = color (uint)
		 * info\[3] = appearance style number
		 * @return
		 */
		internal function getPieceInfo():Array
		{
			return [GamePiece.getOffsetCoords(_coords), _dirs, _col, _app];
		}
		
		internal function getTileCount():uint
		{
			return _dirs.length;
		}
		
		public function cleanUp():void
		{
			for each (var slot:Sprite in _tileslots)
			{
				slot.removeEventListener(MouseEvent.MOUSE_OVER, displayHover);
				slot.removeEventListener(MouseEvent.MOUSE_OUT, hideHover);
				slot.removeEventListener(MouseEvent.MOUSE_DOWN, toggleTile);
			}
			for each (var eb:SimpleButton in _edgelist)
				eb.removeEventListener(MouseEvent.CLICK, toggleEdge);
		}
		
	}

}

import objects.GamePiece;
import objects.GameTile;
internal class PExGameTile extends GameTile 
{
	public function PExGameTile(piece:GamePiece, color:uint, appearStyle:int = -1, clearStyle:int = -1)
	{
		super(piece, color, appearStyle, clearStyle);
	}
	
	internal function update():void
	{
		_borDraw(0);
	}
	
}