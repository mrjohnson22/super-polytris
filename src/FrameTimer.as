package
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	
	public class FrameTimer extends EventDispatcher
	{
		private static var _ready:Boolean = false;
		private static var _stage:Stage;
		
		private static var _list:Vector.<FrameTimer> = new Vector.<FrameTimer>();
		private static var _disptimer:Vector.<FrameTimer> = new Vector.<FrameTimer>();
		private static var _dispcomp:Vector.<FrameTimer> = new Vector.<FrameTimer>();
		
		/**
		 * Before creating any FrameTimer instances, this function must be called
		 * with Main's stage as the argument.
		 * @param	stage
		 */
		public static function init(stage:Stage):void
		{
			_stage = stage;
			_ready = true;
		}
		
		/**
		 * Add a timer to the list of activated timers. Their counters will all be triggered
		 * by the same EnterFrame event.
		 * @param	timer The timer to be activated.
		 */
		private static function addTimer(timer:FrameTimer):void
		{
			if (_list.length == 0)
				_stage.addEventListener(Event.ENTER_FRAME, timeWatchAll);
			
			_list.push(timer);
		}
		
		/**
		 * Remove a timer from the list of activated timers, and turn off EnterFrame
		 * event listening if no active timers are left.
		 * @param	timer The timer to be stopped.
		 */
		private static function removeTimer(timer:FrameTimer):void
		{
			_list.splice(_list.indexOf(timer), 1);
			
			if (_list.length == 0)
				_stage.removeEventListener(Event.ENTER_FRAME, timeWatchAll);
		}
		
		private static function timeWatchAll(e:Event):void
		{
			//for each (var timer:FrameTimer in _list)
				//timer.timeWatch();
			for (var i:uint = 0; i < _list.length; i++)
				_list[i].timeWatch();
			
			while (_disptimer.length > 0)
				_disptimer.pop().dispatchEvent(new TimerEvent(TimerEvent.TIMER));
			while (_dispcomp.length > 0)
			{
				var timer:FrameTimer = _dispcomp.pop();
				timer.reset();
				timer.dispatchEvent(new TimerEvent(TimerEvent.TIMER_COMPLETE));
			}
		}
		
		
		private var _currentCount:uint = 0;
		/**
		 * The total number of times the timer has fired since it started at zero.
		 * If the timer has been reset, only the fires since the reset are counted.
		 */
		public function get currentCount():uint
		{
			return _currentCount;
		}
		public function set currentCount(value:uint):void
		{
			_currentCount = value;
		}
		
		/**
		 * Delay time in real units (frames).
		 */
		private var _delay:uint;
		
		/**
		 * The time, in frames, between timer events.
		 * If you set the delay interval while the timer is running, the timer will restart
		 * at the same repeatCount iteration.
		 */
		public function get frameDelay():Number
		{
			return _delay;
		}
		public function set frameDelay(value:Number):void
		{
			_timeCount = 0;
			_delay = Math.max(value, 1);
		}
		
		/**
		 * The time, in milliseconds, between timer events.
		 * If you set the delay interval while the timer is running, the timer will restart
		 * at the same repeatCount iteration.
		 */
		public function get secondsDelay():Number
		{
			return _delay / _stage.frameRate * 1000;
		}
		public function set secondsDelay(value:Number):void
		{
			_timeCount = 0;
			_delay = Math.max(value * _stage.frameRate / 1000, 1); //0 delay not allowed, min is 1
		}
		
		private var _repeatCount:uint = 0;
		/**
		 * The total number of times the timer is set to run.
		 * If the repeat count is set to 0, the timer continues forever 
		 * or until the stop() method is invoked or the program stops.
		 * If the repeat count is nonzero, the timer runs the specified number of times. 
		 * If repeatCount is set to a total that is the same or less then currentCount
		 * the timer stops and will not fire again.
		 */
		public function get repeatCount():int
		{
			return _repeatCount;
		}
		public function set repeatCount(value:int):void
		{
			_repeatCount = value;
		}
		
		private var _running:Boolean = false;
		/**
		 * [read-only] The timer's current state; true if the timer is running, otherwise false.
		 */
		public function get running():Boolean
		{
			return _running;
		}
		
		private var _timeCount:int = 0;
		/**
		 * [read-only] The number of frames that have passed since start(), or
		 * since the last time a Timer event was dispatched.
		 */
		public function get timeCount():int
		{
			return _timeCount;
		}
		
		/**
		 * Constructs a new Timer object with the specified delay
		 * and repeatCount states.
		 * 
		 *   The timer does not start automatically; you must call the start() method
		 * to start it.
		 * @param	delay The delay, in frames, between timer events. If the secondsTime
		 * parameter is set, the delay is translated to milliseconds. A value of 0 or less
		 * translates to an EnterFrame watch.
		 * @param	repeatCount repeatCount	Specifies the number of repetitions.
		 *   If zero, the timer repeats infinitely. 
		 *   If nonzero, the timer runs the specified number of times and then stops.
		 * @param	secondsTime Set to true if delay parameter should be in milliseconds
		 * rather than frames.
		 * @throws	Error if the delay specified is negative or not a finite number,
		 * or if the FrameTimer class has not yet been initialized.
		 */
		public function FrameTimer(delay:Number, secondsTime:Boolean = false, repeatCount:int = 0)
		{
			if (!_ready)
				throw new Error("The FrameTimer class must be initialized with init(stage) before instances can be created.");
			
			_repeatCount = repeatCount;
			
			if (delay <= 0)
				this.frameDelay = 1;
			else if (!secondsTime)
				this.frameDelay = delay;
			else
				this.secondsDelay = delay;
		}
		
		private function timeWatch():void
		{
			if (++_timeCount >= _delay)
			{
				_disptimer.unshift(this);
				_currentCount++;
				_timeCount = 0;
				if (_currentCount == _repeatCount)
					_dispcomp.unshift(this);
			}
		}
		
		/**
		 * Stops the timer, if it is running, and sets the currentCount property back to 0,
		 * like the reset button of a stopwatch. Then, when start() is called,
		 * the timer instance runs for the specified number of repetitions,
		 * as set by the repeatCount value.
		 */
		public function reset():void
		{
			_currentCount = 0;
			_timeCount = 0;
			stop();
		}
		
		/**
		 * Resets the time recorded by the timer to zero. currentCount is preserved,
		 * and the timer continues to run uninterrupted.
		 */
		public function resetTime():void
		{
			_timeCount = 0;
		}
		
		/**
		 * Starts the timer, if it is not already running.
		 */
		public function start():void
		{
			if (!_running)
			{
				addTimer(this);
				_running = true;
			}
		}
		
		/**
		 * Stops the timer, if it is not already stopped. When start() is called
		 * after stop(), the timer instance resumes from where it last left off.
		 */
		public function stop():void
		{
			if (_running)
			{
				removeTimer(this);
				_running = false;
			}
		}
	}
}