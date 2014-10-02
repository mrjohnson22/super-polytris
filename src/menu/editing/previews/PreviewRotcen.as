package menu.editing.previews 
{
	import flash.events.TimerEvent;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class PreviewRotcen extends PreviewBorder 
	{
		protected var _timer:FrameTimer;
		
		override protected function firstDraw():void
		{
			super.firstDraw();
			_timer = new FrameTimer(500, true);
			_timer.addEventListener(TimerEvent.TIMER, rotate);
			_timer.start();
		}
		
		override public function update():void 
		{
			_piece.resetPosition();
			super.update();
			_piece.update();
			_timer.resetTime();
		}
		
		private function rotate(e:TimerEvent):void
		{
			_piece.rotPiece(true);
		}
		
		override protected function cleanUp():void 
		{
			_timer.reset();
			_timer.removeEventListener(TimerEvent.TIMER, rotate);
			_timer = null;
		}
		
	}

}