package data
{
	import flash.net.SharedObject;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class SaveData
	{
		private static var _savefile:SharedObject = SharedObject.getLocal("poly");
		private static var _newfile:Boolean;
		public static function get newfile():Boolean
		{
			return _newfile;
		}
		
		public static function init():void
		{
			//clearAllData();
			if (_newfile = (_savefile.data.gtypes == null))
			//if (true)
			{
				_savefile.data.gtypes = []; //TODO is this safe? Probably.
				_savefile.data.ktypes = [];
				//set default settings for new file
				DefaultSettings.setDefaultKeys(true);
				DefaultSettings.setDefaultSettings();
			}
			else
			{
				createAllKeySettings();
				createAllGameSettings();
			}
		}
		
		private static function createAllKeySettings():void
		{
			for each (var cs:Object in _savefile.data.ktypes)
				KeySettings.copyKeyConfig(cs);
			
			KeySettings.getKeyConfig(_savefile.data.kselect, false);
		}
		
		public static function createAllGameSettings():void
		{
			for each (var cs:Object in _savefile.data.gtypes)
				Settings.addGameType(Settings.copyGameType(cs, false, false, false));
		}
		
		/**
		 * Load in a previously-saved list of game modes. This overwrites all current mode data.
		 * @param	data
		 */
		public static function loadSavedGameSettings(data:Array):void
		{
			Settings.removeAllGameTypes();
			_savefile.data.gtypes = (data as Array).slice();
			createAllGameSettings();
			_savefile.flush();
		}
		
		/**
		 * Save the specified key configuration setting.
		 * @param	ks The setting to save.
		 * @param	i The index of the setting to be saved in the array of saved settings.
		 * Use -1 to save in whatever index the setting is already in, or specify the index.
		 */
		public static function saveKeySetting(ks:KeySettings, i:int = -1):void
		{
			if (i < 0)
				i = ks.ktype;
			/*else if (i > KeySettings.MAX_KEYCONFIGS)
				throw new Error("Please don't save too many key configurations.");*/
			_savefile.data.ktypes[i] = ks;
		}
		
		/**
		 * Save the specified game setting.
		 * @param	cs The setting to save.
		 * @param	i The index of the setting to be saved in the array of saved settings.
		 * Use -1 to save in whatever index the setting is already in, or specify the index.
		 */
		public static function saveGameSetting(cs:Settings, i:int = -1):void
		{
			if (cs.gtype == -1)
				Settings.addGameType(cs);
			if (i < 0)
				i = cs.gtype;
			else if (i > Settings.MAX_GAMES)
				throw new Error("Please don't save too many game modes.");
			_savefile.data.gtypes[i] = cs;
		}
		
		public static function removeGameSetting(cs:Settings):void
		{
			var gtype:int = cs.gtype;
			if (gtype == -1)
				throw new Error("Can only remove modes that have been saved into the list of modes.");
			
			_savefile.data.gtypes.splice(gtype, 1);
			Settings.removeGameType(cs);
			
			var n:int = Settings.numtypes;
			for (var i:int = gtype; i < n; i++)
				_savefile.data.gtypes[i] = Settings.getGameType(i);
		}
		
		public static function removeAllGameSettings():void
		{
			Settings.removeAllGameTypes();
			_savefile.data.gtypes = [];
			DefaultSettings.setDefaultSettings(); //this flushes.
		}
		
		/**
		 * Save the key configuration setting to use the next time the game is started.
		 * @param	i The index of the configuration to select.
		 */
		public static function selectKeySetting(i:uint):void
		{
			_savefile.data.kselect = i;
		}
		
		private static function clearAllData():void
		{
			_savefile.clear();
			_savefile.flush();
		}
		
		public static function flush():void
		{
			_savefile.flush();
		}
	}
}