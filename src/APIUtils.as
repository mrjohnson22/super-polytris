package
{
	import com.newgrounds.*;
	import flash.display.Sprite;
	import media.sounds.SoundList;
	import media.sounds.Sounds;
	import menu.PopUp;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class APIUtils
	{
		private static const _API_ID:String = "Secret!";
		private static const _API_ENCRYPT:String = "Also secret!";
		
		public static const SG_DATA:String = "User Data";
		public static const SG_SHARED:String = "Shared Modes";
		
		public static const SB_NAME:String = "High Scores";
		
		public static const RT_GAME:String = "Rating";
		
		public static const MSG_ERROR:String = "Error occurred. Try again, and maybe try reloading this game.";
		
		private static var _connectpoint:Sprite = null;
		
		public static function get connected():Boolean
		{
			return API.connected;
		}
		
		public static const GUEST_NAME:String = "Guest";
		public static function get username():String
		{
			return API.hasUserSession && API.username != null && API.username != "null" ? API.username : GUEST_NAME;
		}
		public static function hasUserSession():Boolean
		{
			return username != GUEST_NAME;
		}
		
		private static var _readyFunction:Function;
		/**
		 * Initialize the API.
		 * @param	connectpoint The Sprite to connect the API. Using root is recommended.
		 * @param	readyFunction A function to perform on the first connection attempt. The function
		 * must have an APIEvent as its only parameter.
		 */
		public static function init(connectpoint:Sprite, readyFunction:Function = null):void
		{
			if (_connectpoint != null)
				return;
			
			_readyFunction = readyFunction;
			API.debugMode = API.RELEASE_MODE;
			API.addEventListener(APIEvent.API_CONNECTED, onAPIConnected);
			API.addEventListener(APIEvent.FILE_LOADED, updateLastLoadedModeFile);
			_connectpoint = connectpoint;
			API.connect(_connectpoint, _API_ID, _API_ENCRYPT);
		}
		
		private static var _currentFile:SaveFile;
		private static function updateLastLoadedModeFile(e:APIEvent):void
		{
			if (e.success)
				_currentFile = SaveFile.currentFile;
		}
		public static function getLastLoadedFile():SaveFile
		{
			return _currentFile;
		}
		public static function clearLastLoadedFile():void
		{
			_currentFile = null;
		}

		public static function makeErrorPopUp(message:String = null)
		{
			if (message == null)
				message = MSG_ERROR;
			PopUp.makePopUp(message, Vector.<String>(["Okay"]),	Vector.<Function>([PopUp.fadeOut]));
		}
		
		private static var _connectFunction:Function;
		/**
		 * Safely perform an action that requires connection to the NG API. If there is no connection,
		 * the action is not taken.
		 * @param	f A parameterless function to perform if sufficient API connection is confirmed.
		 */
		public static function actOnConnect(f:Function):void
		{
			if (API.connected)
				f();
			else
			{
				Main.enableInteraction(false);
				_connectFunction = f;
				reconnect();
			}
		}
		
		private static function reconnect():void
		{
			API.disconnect();
			API.connect(_connectpoint, _API_ID, _API_ENCRYPT);
		}
		
		private static function onAPIConnected(e:APIEvent):void
		{
			Main.enableInteraction(true);
			if (_connectFunction != null)
			{
				if (e.success)
					_connectFunction();
				else
					failedToConnect();
				_connectFunction = null;
			}
			if (_readyFunction != null)
			{
				_readyFunction(e);
				_readyFunction = null;
			}
		}
		
		private static function failedToConnect():void
		{
			PopUp.makePopUp("Not connected to the Newgrounds API. Refresh this game to try again.",
			Vector.<String>(["OK"]),
			Vector.<Function>([PopUp.fadeOut]));
		}
	}
}