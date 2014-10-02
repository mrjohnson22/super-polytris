package menu
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import media.sounds.Sounds;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class SimpleSoundController extends MovieClip 
	{
		private static const VOLS:Vector.<Number> = Vector.<Number>([1, 0.66, 0.33, 0]); //# of entries = # of frames in this MC.
		private var _box:Sprite;
		
		public function SimpleSoundController() 
		{
			stop();
			filters = [new GlowFilter(0xFFFFFF)];
			
			_box = new Sprite();
			_box.graphics.beginFill(0, 0);
			_box.graphics.drawRect(0, 0, width, height);
			addChild(_box);
			_box.buttonMode = true;
			_box.addEventListener(MouseEvent.CLICK, adjustVolume);
			
			tabChildren = false;
			tabEnabled = false;
		}
		
		private function adjustVolume(e:MouseEvent):void
		{
			if (currentFrame != 4) //4 frames in movie clip.
				nextFrame();
			else
				gotoAndStop(1);
			filters = [new GlowFilter(0xFFFFFF)];
			
			Sounds.maxSongVolume = VOLS[currentFrame - 1];
			Sounds.maxSfxVolume = VOLS[currentFrame - 1];
		}
		
	}

}