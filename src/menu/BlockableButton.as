package menu 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author X
	 */
	public class BlockableButton extends MovieClip 
	{
		protected static const VEIL_FRAME:String = "_veil";
		
		private var _listeners:Array = [];
		
		protected var _clickable:Boolean = true;
		public function get clickable():Boolean
		{
			return _clickable;
		}
		
		public function set clickable(value:Boolean):void
		{
			if (_clickable == value)
				return;
			
			_clickable = value;
			this.buttonMode = value;
			this.mouseEnabled = value;
			this.tabEnabled = value;
			if (!value)
			{
				disableClicking();
				gotoAndStop(VEIL_FRAME);
			}
			else
			{
				enableClicking();
				gotoAndStop(1);
			}
		}
		
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void 
		{
			super.addEventListener(type, listener);
			if (type == MouseEvent.CLICK)
				_listeners.push(listener);
		}
		
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void 
		{
			super.removeEventListener(type, listener);
			if (type == MouseEvent.CLICK)
				G.removeEntry(_listeners, listener);
		}
		
		private function disableClicking():void
		{
			super.removeEventListener(MouseEvent.CLICK, keepFocus);
			for each(var listener:Function in _listeners)
				super.removeEventListener(MouseEvent.CLICK, listener);
		}
		
		private function enableClicking():void
		{
			super.addEventListener(MouseEvent.CLICK, keepFocus, false, int.MIN_VALUE, true);
			for each(var listener:Function in _listeners)
				super.addEventListener(MouseEvent.CLICK, listener);
		}
		
		private function keepFocus(e:MouseEvent):void
		{
			Main.stage.focus = Main.stage;
		}
		
		private function removeKeepFocus(e:Event):void
		{
			super.removeEventListener(MouseEvent.CLICK, keepFocus);
		}
		
		/**
		 * A button drawn in the Flash IDE that can be turned on & off. Veil is also drawn
		 * in the IDE (for sizing purposes). **Needs one frame labeled "_veil".**
		 */
		public function BlockableButton()
		{
			tabChildren = false;
			tabEnabled = false;
			if (this is TextButton)
				return;
			
			this.stop();
			this.buttonMode = true;
			
			super.addEventListener(Event.REMOVED_FROM_STAGE, removeKeepFocus);
		}
		
	}

}