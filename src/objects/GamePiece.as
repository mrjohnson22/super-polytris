package objects
{
	import data.SettingNames;
	import data.Settings;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	public class GamePiece extends Sprite
	{
		private var s:Number = G.S;
		
		/**
		 * A dense vector containing all Tiles in the Piece.
		 */
		private var _tiles:Vector.<GameTile> = new Vector.<GameTile>();
		public function get tiles():Vector.<GameTile>
		{
			return _tiles;
		}
			
		/**
		 * The number of Tiles in the Piece.
		 */
		public function get numtiles():uint
		{
			return _tiles.length;
		}
		
		/**
		 * True if the piece is in midair and falling due to gravity, false otherwise.
		 */
		public var gravfall:Boolean = false;
		
		/**
		 * Set to true only during a clearDropS.
		 */
		public var dropping:Boolean = false;
		
		private var _poscoords:Array; //aligned to upper-left
		private var _coords:Array = []; //tilemap coordinates
		private var _dirs:Vector.<Vector.<GameTile>> = new Vector.<Vector.<GameTile>>();
		
		protected var cs:Settings;
		protected var _borcol:int;
		
		/**
		 * Create a new game piece. (Number of tiles in a Piece is specified
		 * by the length of coordinates array.)
		 * @param	coords Coordinate data for each tile. Enter in the form
		 * 			[x1,y1, x2,y2,...***rmax,dmax***]. NOTE: +y is UPWARDS.
		 * @param	dirs Boundary data for each tile (true if a tile exists on one
		 * 			of four sides). Enter in the form [ [u1,r1,d1,l1], [u2,r2,d2,l2], ...]
		 * @param	appearStyle The appearance of the tiles in the piece.
		 * @param	clearStyle The animation that the tile plays when it is cleared.
		 */
		public function GamePiece(coords:Array, dirs:Array, color:uint, borcol:int, appearStyle:int = -1, clearStyle:int = -1)
		{
			cs = Settings.currentGame;
			_borcol = borcol;
			
			//If we're making a simple piece, quit now.
			if (coords == null || dirs == null)
				return;
			
			_poscoords = coords.slice();
			
			var i:uint;
			//coords: [x1,y1, x2,y2,...]
			//dirs: [u1,r1,d1,l1, u2,r2,d2,l2, ...]
			
			//Align piece to upper-left corner.
			var minX:int = int.MAX_VALUE;
			var maxY:int = int.MIN_VALUE;
			for (i = 0; i < _poscoords.length; i += 2)
			{
				if (_poscoords[i] < minX)
					minX = _poscoords[i];
				if (_poscoords[i + 1] > maxY)
					maxY = _poscoords[i + 1];
			}
			for (i = 0; i < _poscoords.length; i += 2)
			{
				_poscoords[i] -= minX;
				_poscoords[i + 1] -= maxY;
			}
			
			var numtiles:uint = coords.length / 2;
			var littlemap:Array = G.create2DArray(getPieceSize(coords, true), getPieceSize(coords, false));
			
			for (i = 0; i < numtiles; i++)
			{
				var tile:GameTile = new GameTile(this, color, appearStyle, clearStyle);
				addChild(tile);
				
				tile.x = s * _poscoords[2 * i];
				tile.y = -s * (_poscoords[2 * i + 1] - 1); //-1 for lower registration
				
				tile.xcor = coords[2 * i];
				tile.ycor = coords[2 * i + 1];
				
				_tiles.push(tile);
				
				littlemap[tile.xcor][tile.ycor] = tile;
			}
			
			for (i = 0; i < dirs.length; i++)
			{
				tile = _tiles[i];
				
				if (dirs[i][0])
					tile.dirs[0] = littlemap[tile.xcor][tile.ycor + 1];
				if (dirs[i][1])
					tile.dirs[1] = littlemap[tile.xcor + 1][tile.ycor];
				if (dirs[i][2])
					tile.dirs[2] = littlemap[tile.xcor][tile.ycor - 1];
				if (dirs[i][3])
					tile.dirs[3] = littlemap[tile.xcor - 1][tile.ycor];
				
				_dirs.push(tile.dirs.slice());
				
				tile.borDraw(_borcol);
			}
			
			if (cs[SettingNames.ROTCEN])
				cenPiece(false);
			else
				findCentreTile();
			
			for (i = 0; i < numtiles; i++)
			{
				_coords.push(_tiles[i].xcor);
				_coords.push(_tiles[i].ycor);
			}
		}
		
		/**
		 * Creates and returns a shadow of this piece. Note that the piece will have an empty direction connector map.
		 * @return
		 */
		public function shadowCopy():GamePiece
		{
			var shad:GamePiece = new GamePiece(getOffsetCoords(_poscoords), [], 0, -1);
			//shad.alpha = 0.8;
			return shad;
		}
		
		public static function createRandomPiece(tiles:uint, widmax:uint, lenmax:uint, colors:Array, borcol:int, appearStyle:int, clearStyle:int = -1):GamePiece
		{
			var i:uint;
			var color:uint = colors[Math.floor(Math.random() * colors.length)];
			
			//If piece has only one tile, skip the calculations and just make a 1-tile piece.
			if (tiles == 1)
				return new GamePiece([0,0], [[false, false, false, false]], color, borcol, appearStyle, clearStyle);
			
			//coords of tiles in piece. Always contains a tile at 0, 0;
			//offset 0 by tiles to avoid negative indices in newmap array.
			var coords:Array = [widmax - 1, lenmax - 1];
			
			//newmap: 2D array, keeps track of x/y of new tiles. Value of
			//entries are the index of the new tile being referenced.
			//-1 means no tile exists for the given x/y.
			var newmap:Array = [];
			for (i = 0; i < widmax * 2 - 1; i++)
			{
				newmap.push([]);
				for (var j:uint = 0; j < lenmax * 2 - 1; j++)
					newmap[i].push(-1);
			}
			
			//Always start with tile 0 at centre.
			newmap[widmax - 1][lenmax - 1] = 0;
			
			var dirs:Array = [];
			for (i = 0; i < tiles; i++)
			{
				dirs.push([]);
				for (j = 0; j < 4; j++)
					dirs[i].push(false);
			}
			
			var edges:Array = [lenmax - 1, widmax - 1, lenmax - 1, widmax - 1];
			var et:int;
			var widreach:Boolean = false;
			var lenreach:Boolean = false;
			var side:uint;
			
			//dirposs: array containing NESW directions for each tile, where a
			//new tile can fit around the tile. Index = tile number.
			var dirposs:Vector.<Array> = new Vector.<Array>();
			if (widmax == 1)
			{
				dirposs.push([0, 2]);
				widreach = true;
			}
			else if (lenmax == 1)
			{
				dirposs.push([1, 3]);
				lenreach = true;
			}
			else
				dirposs.push([0, 1, 2, 3]);
			
			//somefree: array containing which tiles have free adjancent spots.
			var somefree:Array = [0];
			
			for (i = 1; i < tiles; i++)
			{
				//ptile: the tile that the new tile will be adjacent to. Need pti for index.
				var pti:uint = Math.floor(Math.random() * somefree.length);
				var ptile:uint = somefree[pti];
				
				//place: NESW adjacent to _pausebutton. Need pli for index.
				var pli:uint = Math.floor(Math.random() * dirposs[ptile].length);
				var place:uint = dirposs[ptile][pli];
				
				//cc: coordinates of the new tile. Adjacent to another tile,
				//so starts off as the coordinates of that tile.
				var cc:Point = new Point(coords[ptile * 2], coords[ptile * 2 + 1]);
				var oc:int; //index of adjacent tile
				
				switch (place)
				{
					case 0:
						cc.y++;
						edges[place] = Math.max(cc.y, edges[place]);
						break;
					
					case 1:
						cc.x++;
						edges[place] = Math.max(cc.x, edges[place]);
						break;
					
					case 2:
						cc.y--;
						edges[place] = Math.min(cc.y, edges[place]);
						break;
					
					case 3:
						cc.x--;
						edges[place] = Math.min(cc.x, edges[place]);
						break;
					
					default:
						throw new Error("Something really dumb happened. I don't even know what it could be. Sorry.");
				}
				coords.push(cc.x, cc.y);
				
				//if (i == tiles - 1)
				//	break;
				
				newmap[cc.x][cc.y] = i;
				somefree.push(i);
				dirposs.push([0, 1, 2, 3]);
				
				if (!widreach)
				{
					if (edges[1] - edges[3] >= widmax - 1)
					{
						widreach = true;
						
						//Check from bottom to top, on each side, for tiles
						//that exist on the edge, to prevent tiles from being
						//placed next (left/right) to them.
						
						for (j = edges[2]; j <= edges[0]; j++)
						{
							for each (side in [1, 3])
							{
								//et: index of edge tile.
								if ( (et = newmap[edges[side]][j]) != -1)
								{
									if (G.removeEntry(dirposs[et], side) == 0)
										G.removeEntry(somefree, et);
								}
							}
						}
					}
				}
				else
				{
					for each (side in [1, 3])
					{
						if (cc.x == edges[side])
						{
							if (G.removeEntry(dirposs[i], side) == 0)
								G.removeEntry(somefree, i);
						}
					}
				}
				
				if (!lenreach)
				{
					if (edges[0] - edges[2] >= lenmax - 1)
					{
						lenreach = true;
						
						//Check from left to right, on top & bottom, for tiles
						//that exist on the edge, to prevent tiles from being
						//placed next (above/below) to them.
						
						for (j = edges[3]; j <= edges[1]; j++)
						{
							for each (side in [0, 2])
							{
								//et: index of edge tile.
								if ( (et = newmap[j][edges[side]]) != -1)
								{
									if (G.removeEntry(dirposs[et], side) == 0)
										G.removeEntry(somefree, et);
								}
							}
						}
					}
				}
				else
				{
					for each (side in [0, 2])
					{
						if (cc.y == edges[side])
						{
							if (G.removeEntry(dirposs[i], side) == 0)
								G.removeEntry(somefree, i);
						}
					}
				}
				
				
				if (cc.y + 1 < newmap[0].length && (oc = newmap[cc.x][cc.y + 1]) != -1) //a tile exists on top of new one
				{
					G.removeEntry(dirposs[i], 0);
					if (G.removeEntry(dirposs[oc], 2) == 0)
						G.removeEntry(somefree, oc);
					
					dirs[i][0] = true;
					dirs[oc][2] = true;
				}
				if (cc.x + 1 < newmap.length && (oc = newmap[cc.x + 1][cc.y]) != -1) //...to the right
				{
					G.removeEntry(dirposs[i], 1);
					if (G.removeEntry(dirposs[oc], 3) == 0)
						G.removeEntry(somefree, oc);
					
					dirs[i][1] = true;
					dirs[oc][3] = true;
				}
				if (cc.y - 1 >= 0 && (oc = newmap[cc.x][cc.y - 1]) != -1) //...on the bottom
				{
					G.removeEntry(dirposs[i], 2);
					if (G.removeEntry(dirposs[oc], 0) == 0)
						G.removeEntry(somefree, oc);
					
					dirs[i][2] = true;
					dirs[oc][0] = true;
				}
				if (cc.x - 1 >= 0 && (oc = newmap[cc.x - 1][cc.y]) != -1) //...to the left
				{
					G.removeEntry(dirposs[i], 3);
					if (G.removeEntry(dirposs[oc], 1) == 0)
						G.removeEntry(somefree, oc);
					
					dirs[i][3] = true;
					dirs[oc][1] = true;
				}
				
				if (dirposs[i].length == 0)
					G.removeEntry(somefree, i);
			}
			
			return new GamePiece(getOffsetCoords(coords), dirs, color, borcol, appearStyle, clearStyle);
		}
		
		public function placePiece(yloc:uint):void
		{
			//Place all pieces in the centre of the bin.
			var xloc:uint = Math.ceil((cs[SettingNames.BINX] - getPieceSize(_poscoords, true)) / 2);
			
			x = 0;
			y = 0;
			scaleX = scaleY = 1;
			
			//Using: lower y values = lower position.
			var tile:GameTile;
			var y_edge:int = 0;
			var maxy:int = 0;
			var miny:int = int.MAX_VALUE;
			var minx:int = int.MAX_VALUE; //Using this centres the piece properly.
			
			for each (tile in _tiles)
			{
				if (tile.ycor * cs[SettingNames.SPAWNTYPE] > y_edge * cs[SettingNames.SPAWNTYPE])
					y_edge = tile.ycor;
				if (tile.xcor < minx)
					minx = tile.xcor;
			}
			
			for each (tile in _tiles)
			{
				tile.xpos = xloc + tile.xcor - minx;
				tile.ypos = yloc + tile.ycor - y_edge;
				
				tile.x = tile.xpos * s;
				tile.y = -tile.ypos * s;
				
				if (tile.ypos > maxy)
					maxy = tile.ypos;
				if (tile.ypos < miny)
					miny = tile.ypos;
			}
			
			if ((cs[SettingNames.TOPLOCK] || cs[SettingNames.FITMODE]) && maxy >= cs[SettingNames.BINY]) //Force toplock in Fit Mode.
				movePiece(0, cs[SettingNames.BINY] - maxy - 1);
			else if (miny < 0)
				movePiece(0, -miny); //double negative
		}
		
		public function resetPosition():void
		{
			//DID: Rotating screws this up! Not anymore.
			for (var i:uint = 0; i < numtiles; i++)
			{
				var tile:GameTile = _tiles[i];
				//tile.x = s * tile.xcor;
				//tile.y = -s * tile.ycor;
				tile.x = s * _poscoords[2 * i];
				tile.y = -s * (_poscoords[2 * i + 1] - 1);
				
				tile.xcor = _coords[2 * i];
				tile.ycor = _coords[2 * i + 1];
				
				tile._dirs = _dirs[i].slice();
				tile.borDraw(_borcol);
			}
		}
		
		public function movePiece(xshift:int = 0, yshift:int = 0):void
		{
			var tile:GameTile;
			if (xshift != 0)
			{
				for each (tile in _tiles)
				{
					tile.x += xshift * s;
					tile.xpos += xshift;
				}
			}
			
			if (yshift != 0)
			{
				for each (tile in _tiles)
				{
					tile.y -= yshift * s;
					tile.ypos += yshift;
				}
			}
		}
		
		public function rotPiece(left_right:Boolean):void
		{
			var xtemp:int;
			var ytemp:int;
			
			for each (var tile:GameTile in _tiles)
			{
				xtemp = tile.xcor;
				ytemp = tile.ycor;
				
				if (left_right) //left
				{
					tile.ycor = tile.xcor;
					tile.xcor = -ytemp;
				}
				else //right
				{
					tile.xcor = tile.ycor;
					tile.ycor = -xtemp;
				}
				
				tile.x += (tile.xcor - xtemp) * s;
				tile.y -= (tile.ycor - ytemp) * s;
				
				tile.xpos += (tile.xcor - xtemp);
				tile.ypos += (tile.ycor - ytemp);
			}
			
			if (cs[SettingNames.ROTCEN])
				cenPiece(true);
			
			if (left_right)
				dirShiftLeft();
			else
				dirShiftRight();
		}
		
		/**
		 * Removes a tile from the piece, and checks if doing so breaks
		 * the piece into multiple parts.
		 * @param	tile
		 */
		public function removeTile(tile:GameTile):void
		{
			//Detatch remaining tiles from the removed one.
			if (tile.dirs[0] && !tile.dirs[0].checked)
			{
				tile.dirs[0].dirs[2] = null;
				tile.dirs[0].borDraw(_borcol);
			}
			if (tile.dirs[1] && !tile.dirs[1].checked)
			{
				tile.dirs[1].dirs[3] = null;
				tile.dirs[1].borDraw(_borcol);
			}
			if (tile.dirs[2] && !tile.dirs[2].checked)
			{
				tile.dirs[2].dirs[0] = null;
				tile.dirs[2].borDraw(_borcol);
			}
			if (tile.dirs[3] && !tile.dirs[3].checked)
			{
				tile.dirs[3].dirs[1] = null;
				tile.dirs[3].borDraw(_borcol);
			}
			
			//Remove the tile.
			tile.removeClearStyle();
			removeChild(tile);
			_tiles.splice(_tiles.indexOf(tile), 1);
		}
		
		public function breakCheck():Vector.<GamePiece>
		{
			//Did removing a tile break the piece into more pieces?
			//If so, return these pieces.
			var bpieces:Vector.<GamePiece> = new Vector.<GamePiece>();
			for each (var tile:GameTile in _tiles)
			{
				//Only check unchecked tiles.
				if (tile.checked)
					continue;
				
				//Find the entirety of the piece each tile is part of.
				var ptiles:Vector.<GameTile> = pieceCheck(tile);
				
				//If *any* whole piece has as many tiles as the original,
				//the piece was not broken. Exit function.
				if (ptiles.length == numtiles)
				{
					uncheckTiles();
					return null;
				}
				
				//Seperate each fragment of tiles into a new piece.
				var bpiece:GamePiece = simplePiece(_borcol);
				bpieces.push(bpiece);
				for each (var ptile:GameTile in ptiles)
				{
					bpiece._tiles.push(ptile);
					bpiece.addChild(ptile);
					ptile.piece = bpiece;
				}
			}
			
			uncheckTiles();
			return bpieces.length > 0 ? bpieces : null;
		}
		
		public static function simplePiece(borcol:int):GamePiece
		{
			return new GamePiece(null, null, 0, borcol);
		}
		
		public function uncheckTiles():void
		{
			for each (var tile:GameTile in _tiles)
				tile.checked = false;
		}
		
		public function borDraw():void
		{
			for each (var tile:GameTile in _tiles)
				tile.borDraw(cs[SettingNames.BORCOL]);
		}
		
		/**
		 * Use this to get the width/length of a piece represented by a coord-like array [x0,y0, x1,y1, ... xt,yt].
		 * @param	coords
		 * @param	wid_len Set to true if you want the width of the piece, or false if you want the length.
		 * @return	
		 */
		public static function getPieceSize(coords:Array, wid_len:Boolean):uint
		{
			var min:int = int.MAX_VALUE, max:int = int.MIN_VALUE;
			for (var i:uint = wid_len ? 0 : 1; i < coords.length; i += 2)
			{
				min = Math.min(min, coords[i]);
				max = Math.max(max, coords[i]);
			}
			return max - min + 1;
		}
		
		/**
		 * Shifts the x/y coordinates of the piece's tiles to be non-negative.
		 * @param	coords The coordinates to shift.
		 * @return	A new array containing the offset coordinates.
		 */
		public static function getOffsetCoords(coords:Array):Array
		{
			var ocoords:Array = coords.slice();
			var minx:int = int.MAX_VALUE, miny:int = int.MAX_VALUE;
			for (var i:uint = 0; i < ocoords.length; i += 2)
			{
				minx = Math.min(minx, ocoords[i]);
				miny = Math.min(miny, ocoords[i + 1]);
			}
			for (var i:uint = 0; i < ocoords.length; i += 2)
			{
				ocoords[i] -= minx;
				ocoords[i + 1] -= miny;
			}
			return ocoords;
		}
		
		private function cenPiece(reposition:Boolean):void
		{
			var xcen:Number = 0;
			var ycen:Number = 0;
			
			for each (var tile:GameTile in _tiles)
			{
				xcen += tile.xcor;
				ycen += tile.ycor;
			}
			
			xcen /= numtiles;
			ycen /= numtiles;
			
			xcen = Math.round(xcen - 0.1);
			ycen = Math.round(ycen);
			
			//If centre coordinates are not (0, 0), set them as such!
			if (xcen != 0 || ycen != 0)
			{
				for each (tile in _tiles)
				{
					tile.xcor -= xcen;
					tile.ycor -= ycen;
				}
				
				//Move piece opposite to centre discrepency
				if (reposition)
					movePiece( -xcen, -ycen);
			}
		}
		
		private function findCentreTile():void
		{
			cenPiece(false);
			//After cenPiece, the centroid is (0,0), but a tile might not exist there.
			//So find the one closest to (0,0), and set THAT tile as (0,0)!
			
			var tile:GameTile, ctile:GameTile;
			var mindiff:int = int.MAX_VALUE;
			for each (tile in _tiles) {
				var diff:int = Math.abs(tile.xcor) + Math.abs(tile.ycor);
				//Favour upper-right tiles if distances are equal.
				if (diff < mindiff || (diff == mindiff && tile.xcor > ctile.xcor && tile.ycor > ctile.ycor)) {
					mindiff = diff;
					ctile = tile;
				}
			}
			
			var xcen:int = ctile.xcor;
			var ycen:int = ctile.ycor;
			for each (tile in _tiles)
			{
				tile.xcor -= xcen;
				tile.ycor -= ycen;
			}
		}
		
		private function dirShiftLeft():void
		{
			for each (var tile:GameTile in _tiles)
			{
				tile.dirs.push(tile.dirs.shift());
				tile.borDraw(_borcol);
			}
		}
		
		private function dirShiftRight():void
		{
			for each (var tile:GameTile in _tiles)
			{
				tile.dirs.unshift(tile.dirs.pop());
				tile.borDraw(_borcol);
			}
		}
		
		/**
		 * Given a tile in a piece, finds all other tiles connected to the
		 * same piece. Called recursively.
		 * @param	tile The tile to check for connections around.
		 * @param	inpiece A growing Vector of connected tiles.
		 * @return	A Vector of connected GameTiles.
		 */
		private function pieceCheck(tile:GameTile, inpiece:Vector.<GameTile> = null):Vector.<GameTile>
		{
			if (inpiece == null)
				inpiece = new Vector.<GameTile>();
			
			tile.checked = true;
			
			for (var d:uint = 0; d < 4; d++)
			{
				if (tile.dirs[d] && !tile.dirs[d].checked)
					pieceCheck(tile.dirs[d], inpiece);
			}
			
			inpiece.push(tile);
			return inpiece;
		}
		
	}
}