package
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;

	public class Key
	{
		private static const NUM_CODES = 222;
		
		private static var keys:Array = new Array(NUM_CODES);
		private static var taps:Array = new Array(NUM_CODES);
		private static var lift:Array = new Array(NUM_CODES);
		private static var held:Array = new Array(NUM_CODES);
		
		private static var keytru:Array = new Array();
		private static var taptru:Array = new Array();
		private static var liftru:Array = new Array();
		
		private static var stage:Stage;
		private static var holdwatch:Boolean = false;
		
		public static function init(s:Stage)
		{
			stage = s;
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, downHandle, false, 0, true);
			stage.addEventListener(KeyboardEvent.KEY_UP, upHandle, false, 0, true);
			stage.addEventListener(Event.DEACTIVATE, clearKeys, false, 0, true);
			stage.addEventListener(Event.ENTER_FRAME, clearInst, false, -1000, true); //want lowest priority
		}
		
		private static function downHandle(e:KeyboardEvent):void
		{
			if (!keys[e.keyCode])
			{
				keys[e.keyCode] = taps[e.keyCode] = true;
				keytru.push(e.keyCode);
				taptru.push(e.keyCode);
				
				lift[e.keyCode] = false;
				G.removeEntry(liftru, e.keyCode);
			}
		}
		
		private static function upHandle(e:KeyboardEvent):void
		{
			if (keys[e.keyCode])
			{
				keys[e.keyCode] = false;
				lift[e.keyCode] = true;
				keytru.splice(keytru.indexOf(e.keyCode), 1);
				liftru.push(e.keyCode);
				
				taps[e.keyCode] = false;
				G.removeEntry(taptru, e.keyCode);
				held[e.keyCode] = 0;
			}
		}
		
		private static function holdCount(e:Event):void
		{
			for each (var keyCode in keytru)
				if (held[keyCode])
					held[keyCode]++;
				else
					held[keyCode] = 1;
		}
		
		private static function clearInst(e:Event):void
		{
			while (taptru.length > 0)
				taps[taptru.shift()] = false;

			while (liftru.length > 0)
				lift[liftru.shift()] = false;
		}
		
		private static function clearKeys(e:Event):void
		{
			while (keytru.length > 0)
				stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, keytru[0]));
			
			//clearInst(e);
		}
		
		public static function isDown(keyCode:uint, ...keyCodes):Boolean
		{
			if (keyCodes.length == 0)	//if only 1 key is pressed
				return keys[keyCode];
			else
			{
				if (!keys[keyCode])
					return false;

				for (var i:uint = 0; i < keyCodes.length; i++)
				{
					if (!keys[keyCodes[i]])
						return false;
				}
				return true;
			}
		}
		
		public static function isTap(keyCode:uint, ...keyCodes):Boolean
		{
			if (keyCodes.length == 0)	//if only 1 key is pressed
				return taps[keyCode];
			else
			{
				if (!taps[keyCode])
					return false;
				
				for (var i:uint = 0; i < keyCodes.length; i++)
				{
					if (!taps[keyCodes[i]])
						return false;
				}
				return true;
			}
		}
		
		public static function isUp(keyCode:uint, ...keyCodes):Boolean
		{
			if (keyCodes.length == 0)	//if only 1 key is pressed
				return !(keys[keyCode]);
			else
			{
				if (keys[keyCode])
					return false;
				
				for (var i:uint = 0; i < keyCodes.length; i++)
				{
					if (keys[keyCodes[i]])
						return false;
				}
				return true;
			}
		}
		
		public static function isLift(keyCode:uint, ...keyCodes):Boolean
		{
			if (keyCodes.length == 0)	//if only 1 key is pressed
				return lift[keyCode];
			else
			{
				if (!lift[keyCode])
					return false;

				for (var i:uint = 0; i < keyCodes.length; i++)
				{
					if (!lift[keyCodes[i]])
						return false;
				}
				return true;
			}
		}
		
		public static function noKeys():Boolean
		{
			for (var i:uint = 0; i < NUM_CODES; i++)
			{
				if (keys[i])
					return false;
			}
			return true;
		}
		
		/**
		 * Checks if a key was held down for a certain number of frames.
		 * @param	keyCode The key to check.
		 * @param	timeHeld The amount of time (for frames or milliseconds) the key must be held down for.
		 * *NOTE*: If this value is set to -1, no key is considered to be held.
		 * @param	secondsTime Use milliseconds for timeHeld if true, frames otherwise.
		 * @param	interval The interval (in frames) at which the key should be "pressed" when held long enough.
		 * The default value is 1, which indicates a continuous press.
		 */
		public static function isHeld(keyCode:uint, timeHeld:int, secondsTime:Boolean = false, interval:uint = 1):Boolean
		{
			if (held[keyCode] == 0 || timeHeld == -1)
				return false;
			
			if (secondsTime)
				timeHeld = timeHeld * stage.frameRate / 1000;
			
			if (held[keyCode] < timeHeld)
				return false;
			return (held[keyCode] - timeHeld) % Math.max(interval, 1) == 0;
		}
		
		public static function holdval(keyCode:uint):int
		{
			return held[keyCode];
		}
		
		public static function resetHold(keyCode:int, ...keyCodes):void
		{
			if (keyCode != -1)
			{
				held[keyCode] = 0;
				for each (keyCode in keyCodes)
					held[keyCode] = 0;
			}
			else
			{
				for each (keyCode in keytru)
					held[keyCode] = 0;
			}
		}
		
		public static function resetAllHold():void
		{
			for (var i:uint = 0; i < held.length; i++)
				held[i] = 0;
		}
		
		public static function startHoldCount():void
		{
			if (!holdwatch)
			{
				stage.addEventListener(Event.ENTER_FRAME, holdCount, false, -999, true); //2nd lowest priority
				holdwatch = true;
			}
		}
		
		public static function pauseHoldCount():void
		{
			if (holdwatch)
			{
				stage.removeEventListener(Event.ENTER_FRAME, holdCount);
				holdwatch = false;
			}
		}
		
	}
}