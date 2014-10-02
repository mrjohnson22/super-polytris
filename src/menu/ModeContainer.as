package menu 
{
	import com.greensock.TweenLite;
	import data.SettingNames;
	import data.Settings;
	import events.IDEvent;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import menu.ModeButton;
	import menu.Nextbar;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class ModeContainer extends Sprite 
	{
		private static const ROWS:uint = 4;
		private static const COLS:uint = 2;
		
		private static const MMARGIN:Number = 15;
		private static const BMARGINX:Number = 60;
		private static const BMARGINY:Number = 20;
		private static const PMARGIN:Number = 60;
		
		private static const DURATION:Number = 0.5;
		
		private var _modeBack:MovieClip;
		
		private var _modelist:Vector.<ModeButton> = new Vector.<ModeButton>();
		private var _buttonPages:Vector.<Sprite> = new Vector.<Sprite>();
		private var _pageN:Sprite;
		private var _pageC:Sprite;
		private var _pageP:Sprite;
		private var _numpages:uint;
		private var _cpage:uint;
		
		private var _nextbutton:Nextbar;
		private var _prevbutton:Nextbar;
		
		private var _slidepage:Sprite;
		private var _moving:Boolean = false;
		
		private var _masker:Sprite;
		
		private var _selected:int = -1;
		public function get selected():int
		{
			return _selected;
		}
		public function set selected(value:int)
		{
			if (value > _modelist.length || value < 0)
				return;
			
			selectModeAuto(value);
		}
		
		public function ModeContainer()
		{
			var i:uint;
			var cs:Settings;
			var n:int = Settings.numtypes;
			for (i = 0; i < n; i++)
			{
				cs = Settings.getGameType(i);
				var modebutton:ModeButton = new ModeButton(cs[SettingNames.GTITLE], cs[SettingNames.GTCOL], cs[SettingNames.GCOL], cs[SettingNames.LOCKED]);
				modebutton.addEventListener(MouseEvent.CLICK, selectModeClick);
				modebutton.id = i;
				
				_modelist.push(modebutton);
			}
			
			var row:uint = 0;
			var col:uint = 0;
			var bspaceX:Number = 10;
			var bspaceY:Number = 10;
			var container:Sprite;
			_numpages = 1;
			{
				_buttonPages.push(container = new Sprite());
				for (i = 0; i < _modelist.length; i++)
				{
					if (row == ROWS)
					{
						row = 0;
						if (++col == COLS)
						{
							_buttonPages.push(container = new Sprite());
							_numpages++;
							col = 0;
						}
					}
					_modelist[i].x = col * (_modelist[i].width + bspaceX);
					_modelist[i].y = (row++) * (_modelist[i].height + bspaceY);
					container.addChild(_modelist[i]);
				}
			}
			_pageC = _buttonPages[0];
			_pageP = null;
			if (_numpages > 1)
				_pageN = _buttonPages[1];
			_cpage = 0;
			
			_modeBack = new ModeBack();
			_modeBack.width = COLS * (_modelist[0].width + bspaceX) - bspaceX + BMARGINX * 2;
			_modeBack.height = ROWS * (_modelist[0].height + bspaceY) - bspaceY + BMARGINY * 2;
			addChild(_modeBack);
			
			for each (container in _buttonPages)
				container.y = BMARGINY;
			_pageC.x = BMARGINX;
			addChild(_pageC);
			
			_nextbutton = new Nextbar();
			_prevbutton = new Nextbar();
			addChild(_nextbutton);
			addChild(_prevbutton);
			
			var bwidth:Number = 40;
			_nextbutton.width = bwidth;
			_nextbutton.height = _modeBack.height - 2 * MMARGIN;
			_nextbutton.y = MMARGIN;
			G.rightAlign(_nextbutton, MMARGIN, _modeBack);
			
			_prevbutton.width = bwidth;
			_prevbutton.height = _nextbutton.height;
			_prevbutton.scaleX *= -1;
			_prevbutton.y = MMARGIN;
			_prevbutton.x = MMARGIN + _prevbutton.width;
			
			_masker = new Sprite();
			_masker.graphics.beginFill(0);
			_masker.graphics.drawRect(MMARGIN, MMARGIN, 
				_modeBack.width - 2 * MMARGIN, _modeBack.height - 2 * MMARGIN);
			addChild(_masker);
			_pageC.mask = _masker;
			
			_prevbutton.addEventListener(MouseEvent.CLICK, prevPage);
			_nextbutton.addEventListener(MouseEvent.CLICK, nextPage);
			_prevbutton.clickable = false;
			_nextbutton.clickable = _numpages > 1;
		}
		
		private function nextPage(e:MouseEvent):void
		{
			if (!_moving)
				_moving = true;
			else
				return;
			
			_pageN.x = _pageC.x + _pageC.width + PMARGIN;
			var moveto:Number = BMARGINX - _pageN.x;
			addChild(_slidepage = new Sprite());
			swapChildren(_slidepage, _pageC);
			_slidepage.addChild(_pageC);
			_slidepage.addChild(_pageN);
			_slidepage.cacheAsBitmap = true;
			_slidepage.mask = _masker;
			_slidepage.mouseChildren = false;
			_slidepage.tabChildren = false;
			
			TweenLite.to(_slidepage, DURATION, { x:moveto, onComplete:nextFinish } );
		}
		
		private function prevPage(e:MouseEvent):void
		{
			if (!_moving)
				_moving = true;
			else
				return;
			
			_pageP.x = _pageC.x - _pageP.width - PMARGIN;
			var moveto:Number = BMARGINX - _pageP.x;
			addChild(_slidepage = new Sprite());
			swapChildren(_slidepage, _pageC);
			_slidepage.addChild(_pageC);
			_slidepage.addChild(_pageP);
			_slidepage.cacheAsBitmap = true;
			_slidepage.mask = _masker;
			_slidepage.mouseChildren = false;
			_slidepage.tabChildren = false;
			
			TweenLite.to(_slidepage, DURATION, { x:moveto, onComplete:prevFinish } );
		}
		
		private function nextFinish():void
		{
			_cpage++;
			_pageP = _pageC;
			_pageC = _pageN;
			_prevbutton.clickable = true;
			if (_cpage == _numpages - 1)
			{
				_pageN = null;
				_nextbutton.clickable = false;
			}
			else
				_pageN = _buttonPages[_cpage + 1];
			
			addChild(_pageC);
			swapChildren(_pageC, _slidepage);
			removeChild(_slidepage);
			_pageC.x = BMARGINX;
			_pageC.mask = _masker;
			
			_moving = false;
		}
		
		private function prevFinish():void
		{
			_cpage--;
			_pageN = _pageC;
			_pageC = _pageP;
			_nextbutton.clickable = true;
			if (_cpage == 0)
			{
				_pageP = null;
				_prevbutton.clickable = false;
			}
			else
				_pageP = _buttonPages[_cpage - 1];
			
			addChild(_pageC);
			swapChildren(_pageC, _slidepage);
			removeChild(_slidepage);
			_pageC.x = BMARGINX;
			_pageC.mask = _masker;
			
			_moving = false;
		}
		
		private function selectMode(modebutton:ModeButton):void
		{
			if (_selected != -1)
				_modelist[_selected].active = false;
			_selected = modebutton.id;
			modebutton.active = true;
			//graphic effect to the selected button
			
			dispatchEvent(new IDEvent(IDEvent.GO, _selected));
		}
		
		private function selectModeClick(e:MouseEvent):void
		{
			selectMode(ModeButton(e.target));
		}
		
		private function selectModeAuto(selected:uint):void
		{
			var newpage:uint = uint(selected / (ROWS * COLS));
			if (newpage != _cpage)
			{
				_cpage = newpage;
				var oldx:Number = _pageC.x;
				removeChild(_pageC);
				_pageC = _buttonPages[_cpage];
				_pageC.x = oldx;
				addChildAt(_pageC, Math.min(getChildIndex(_nextbutton), getChildIndex(_prevbutton)));
				if (_cpage == _numpages - 1)
				{
					_pageN = null;
					_nextbutton.clickable = false;
				}
				else
				{
					_pageN = _buttonPages[_cpage + 1];
					_nextbutton.clickable = true;
				}
				
				if (_cpage == 0)
				{
					_pageP = null;
					_prevbutton.clickable = false;
				}
				else
				{
					_pageP = _buttonPages[_cpage - 1];
					_prevbutton.clickable = true;
				}
			}
			
			selectMode(_modelist[selected]);
		}
		
		public function cleanUp():void
		{
			_prevbutton.removeEventListener(MouseEvent.CLICK, prevPage);
			_nextbutton.removeEventListener(MouseEvent.CLICK, nextPage);
			for each (var modebutton:ModeButton in _modelist)
				modebutton.addEventListener(MouseEvent.CLICK, selectMode);
		}
	}
}