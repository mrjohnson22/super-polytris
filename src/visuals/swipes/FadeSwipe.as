package visuals.swipes
{
	import fl.transitions.easing.None;
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	
	public class FadeSwipe extends Swipe
	{
		private var _dark:Sprite = new Sprite();
		private var _fadespeed:Number = 0.3;
		private var _fadetween:Tween;
		private var _waittimer:FrameTimer = new FrameTimer(200, true, 1);
		
		public function FadeSwipe()
		{
			_dark.graphics.beginFill(0);
			_dark.graphics.drawRect(0, 0, G.STAGE_WIDTH, G.STAGE_HEIGHT);
			addChild(_dark);
			super();
		}
		
		override protected function playAnim():void 
		{
			_fadetween = new Tween(_dark, "alpha", None.easeNone, 0, 1, _fadespeed, true);
			_fadetween.addEventListener(TweenEvent.MOTION_FINISH, fadeWait);
			_fadetween.start();
		}
		
		private function fadeWait(e:TweenEvent):void
		{
			_fadetween.stop();
			_fadetween.removeEventListener(TweenEvent.MOTION_FINISH, fadeOut);
			_waittimer.addEventListener(TimerEvent.TIMER_COMPLETE, fadeOut);
			_waittimer.start();
		}
		
		private function fadeOut(e:TimerEvent):void
		{
			_waittimer.removeEventListener(TimerEvent.TIMER_COMPLETE, fadeOut);
			startAction();
			_fadetween = new Tween(_dark, "alpha", None.easeNone, 1, 0, _fadespeed, true);
			_fadetween.addEventListener(TweenEvent.MOTION_FINISH, cleanUp);
		}
		
		override protected function stopAnim():void 
		{
			_fadetween.stop();
			_fadetween.removeEventListener(TweenEvent.MOTION_FINISH, cleanUp);
			removeChild(_dark);
		}
		
	}

}