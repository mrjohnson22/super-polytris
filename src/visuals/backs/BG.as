package visuals.backs 
{
	import com.greensock.TimelineMax;
	import com.greensock.TweenLite;
	import fl.transitions.easing.None;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import media.images.Images;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class BG extends MovieClip //Leave as MC in case other background types use Flash IDE animation.
	{
		private var _twid:Number;
		private var _thgt:Number;
		
		private var _back:Sprite;
		private var _tween:TimelineMax;
		
		protected function get TileStyle():Class
		{
			return Images.BGTile;
		}
		
		protected function get animated():Boolean
		{
			return true;
		}
		
		public function BG() 
		{
			var tile:Bitmap = (new this.TileStyle()) as Bitmap;
			_twid = tile.width;
			_thgt = tile.height;
			
			_back = new Sprite();
			_back.graphics.beginBitmapFill(tile.bitmapData);
			_back.graphics.drawRect(-_twid, -_thgt, G.STAGE_WIDTH + _twid, G.STAGE_HEIGHT + _thgt);
			_back.graphics.endFill();
			addChild(_back);
			
			if (animated)
			{
				addEventListener(Event.REMOVED_FROM_STAGE, endTween);
				_tween = new TimelineMax();
				_tween.append(new TweenLite(_back, 1, { ease:None.easeNone, x:_twid, y:_thgt }));
				_tween.repeat( -1);
			}
		}
		
		private function endTween(e:Event):void
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, endTween);
			_tween.kill();
		}
		
	}

}