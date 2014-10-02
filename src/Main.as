package
{
	import com.newgrounds.API;
	import com.newgrounds.APIEvent;
	import com.newgrounds.SaveFile;
	import data.SaveData;
	import events.GameEvent;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import menu.FPSDemo;
	import menu.PopUp;
	import menu.SimpleSoundController;
	import screens.*;
	import visuals.swipes.*;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class Main extends MovieClip
	{
		private static var _FirstScreen:Class = MainMenu;
		public static function get FirstScreen():Class
		{
			return _FirstScreen;
		}
		private static var _instance:Main;
		
		private static var _swipe:Swipe;
		public static function get swipe():Swipe
		{
			return _swipe;
		}
		
		private static var _stage:Stage;
		public static function get stage():Stage
		{
			return _stage;
		}
		
		public static function resetFocus():void
		{
			_stage.focus = _stage;
		}
		
		private static var _frametwo:Boolean = false;
		public static function get frametwo():Boolean
		{
			return _frametwo;
		}
		private var _soundcontrol:SimpleSoundController;
		private var _fpsDemo:FPSDemo;
		
		private var _layerlock:Sprite;
		private var _layermid:Sprite;
		public static function get layermid():Sprite
		{
			return _instance._layermid;
		}
		
		/**
		 * Converts a given delay value in milliseconds to a delay in number of frames.
		 * @param	mseconds Number of milliseconds between timer events.
		 * @return	The number of frames between events.
		 */
		public static function secondsToFrames(mseconds:Number):Number
		{
			return mseconds * _stage.frameRate / 1000;
		}
		
		private var _gamescreen:MovieClip;
		public static function get gamescreen():MovieClip
		{
			return _instance._gamescreen;
		}
		
		public static function enableInteraction(enabled:Boolean):void
		{
			if (_instance._gamescreen != null)
				_instance._gamescreen.mouseChildren = enabled;
		}
		
		private static var _PrevScreen:Class;
		public static function get PrevScreen():Class
		{
			return _PrevScreen;
		}
		
		public function Main()
		{
			if (_stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public function init(e:Event = null):void
		{
			stop();
			stage.showDefaultContextMenu = false;
			_instance = this;
			removeEventListener(Event.ADDED_TO_STAGE, init);
			Main._stage = this.stage;
			//Note: stage can't have tabChildren or tabEnabled modified.
			
			Key.init(_stage);
			FrameTimer.init(_stage);
			SaveData.init();
			
			_layermid = new Sprite();
			_layerlock = new Sprite();
			/*_layermid.tabChildren = false;
			_layermid.tabEnabled = false;
			_layerlock.tabChildren = false;
			_layerlock.tabEnabled = false;*/
			_stage.addChild(_layermid);
			_stage.addChild(_layerlock);
			
			APIUtils.init(this, firstScreenLoad);
		}
		
		private function firstScreenLoad(e:APIEvent):void
		{
			if (e.error == APIEvent.ERROR_HOST_BLOCKED)
			{
				_FirstScreen = BadHostScreen;
				return;
			}
			var paramObj:Object = loaderInfo.parameters;
			var fileId:uint = paramObj.hasOwnProperty("NewgroundsAPI_SaveFileID") ? uint(paramObj["NewgroundsAPI_SaveFileID"]) : 0;
			if (e.success)
			{
				if (fileId != 0)
				{
					API.addEventListener(APIEvent.FILE_LOADED, loadFirstFile);
					API.loadSaveFile(fileId, true);
				}
			}
			else if (fileId != 0)
				MainMenu.loadProblem = true;
		}
		
		private function loadFirstFile(e:APIEvent):void
		{
			API.removeEventListener(APIEvent.FILE_LOADED, loadFirstFile);
			if (e.success)
			{
				var file:SaveFile = SaveFile(e.data);
				if (file.group.name == APIUtils.SG_SHARED)
					_FirstScreen = UsermodeScreen;
				else if (file.group.name == APIUtils.SG_DATA)
					_FirstScreen = OptionsScreen;
			}
			else
				MainMenu.loadProblem = true;
		}
		
		private function onFrameTwo():void
		{
			gotoAndStop(2);
			_frametwo = true;
			
			_soundcontrol = new SimpleSoundController();
			_soundcontrol.x = 5;
			_soundcontrol.y = _stage.stageHeight - _soundcontrol.height - 5;
			_layerlock.addChild(_soundcontrol);
			
			/*_fpsDemo = new FPSDemo();
			_fpsDemo.x = _soundcontrol.x + _soundcontrol.width + 5;
			_fpsDemo.y = _soundcontrol.y;
			_layerlock.addChild(_fpsDemo);*/
			
			StyleSetter.apply();
		}
		
		private function changeScreenAction(e:GameEvent):void
		{
			//clear objects on screen first
			if (_frametwo)
			{
				if (_instance._gamescreen is ISwappable)
					ISwappable(_instance._gamescreen).onSwap();
				_stage.removeChild(_gamescreen);
			}
			else
				onFrameTwo();
			
			PopUp.cleanUp();
			resetFocus();
			
			_gamescreen = new e.Screen();
			//_gamescreen.tabChildren = false;
			//_gamescreen.tabEnabled = false;
			_stage.addChildAt(_gamescreen, 0);
			
			_stage.dispatchEvent(e);
		}
		
		private function changeScreenFinish(e:Event):void
		{
			_swipe.removeEventListener(GameEvent.CHANGE, changeScreenAction);
			_swipe.removeEventListener(EventAnim.DONE, changeScreenFinish);
			_swipe = null;
		}

		/**
		 * Global function to change screens. Only one screen change can happen at a time.
		 * @param	Screen The screen to change to. (A class, not an instance.)
		 * @param	SwipeType The type of swipe to use. (A class, not an instance.) Keep as null to use default type.
		 * @return	False if a screen transition is already in progress, true otherwise.
		 */
		public static function changeScreen(Screen:Class, SwipeType:Class = null):Boolean
		{
			if (_swipe != null)
				return false;
			
			PopUp.setInteractionEnabled(false);
			
			_PrevScreen = Object(_instance._gamescreen).constructor;
			if (SwipeType == null)
				SwipeType = SideSwipe;
			_swipe = new SwipeType();
			_swipe.Screen = Screen;
			_swipe.addEventListener(GameEvent.CHANGE, _instance.changeScreenAction);
			_swipe.addEventListener(EventAnim.DONE, _instance.changeScreenFinish);
			_instance._layermid.addChild(_swipe);
			
			if (_instance._gamescreen != null)
				_instance._gamescreen.mouseChildren = false;
			
			return true;
		}
	}
}