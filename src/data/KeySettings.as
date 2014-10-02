package data
{
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class KeySettings
	{
		public static const MAX_KEYCONFIGS:uint = 3;
		public static const KEYNAME_MAP:Object = {
			39:"Right Arrow",
			37:"Left Arrow",
			38:"Up Arrow",
			40:"Down Arrow",
			32:"Space Bar",
			13:"Enter",
			16:"Shift",
			17:"Ctrl",
			46:"Delete",
			45:"Insert",
			36:"Home",
			35:"End",
			33:"Page Up",
			34:"Page Down",
			27:"Esc"
		};
		public static const KEYBADS:Vector.<uint> = Vector.<uint>([
			9 //TAB
		]);
		
		public var ktitle:String;
		
		public var k_right:uint;
		public var k_left:uint;
		public var k_up:uint;
		public var k_down:uint;
		public var k_rotcw:uint;
		public var k_rotccw:uint;
		public var k_hold:uint;
		public var k_place:uint;
		public var k_pause:uint;
		
		public var name_right:String;
		public var name_left:String;
		public var name_up:String;
		public var name_down:String;
		public var name_rotcw:String;
		public var name_rotccw:String;
		public var name_hold:String;
		public var name_place:String;
		public var name_pause:String;
		
		public function get ktype():uint
		{
			return _allConfigs.indexOf(this);
		}
		
		//public
		
		//static properties
		private static var _allConfigs:Vector.<KeySettings> = new Vector.<KeySettings>();
		
		private static var _currentKeys:KeySettings;
		public static function get currentConfig():KeySettings
		{
			return _currentKeys;
		}
		public static function clearKeyConfig():void
		{
			_currentKeys = null;
		}
		
		public static function get numtypes():uint
		{
			return _allConfigs.length;
		}
		
		public static function getKeyConfig(ktype:uint, save:Boolean = true):KeySettings
		{
			if (ktype >= numtypes)
				addKeyConfig(ktype = numtypes);
			
			_currentKeys = _allConfigs[ktype];
			if (save)
			{
				SaveData.selectKeySetting(ktype);
				SaveData.flush();
			}
			return _currentKeys;
		}
		
		/**
		 * Add a new, blank key configuration.
		 * @param	ktype The index of the new type. Set to -1 to add the type to the end of the types list.
		 * @return	The newly-created type;
		 */
		public static function addKeyConfig(ktype:int = -1):KeySettings
		{
			var ks:KeySettings = new KeySettings();
			if (ktype < 0)
				ktype = numtypes;
			_allConfigs.splice(ktype, 0, ks);
			
			return ks;
		}
		
		public static function copyKeyConfig(cs:Object):void
		{
			var ks:KeySettings = addKeyConfig();
			ks.k_down = cs.k_down;
			ks.k_hold = cs.k_hold;
			ks.k_left = cs.k_left;
			ks.k_pause = cs.k_pause;
			ks.k_place = cs.k_place;
			ks.k_right = cs.k_right;
			ks.k_rotccw = cs.k_rotccw;
			ks.k_rotcw = cs.k_rotcw;
			ks.k_up = cs.k_up;
			ks.ktitle = cs.ktitle;
			ks.name_down = cs.name_down;
			ks.name_hold = cs.name_hold;
			ks.name_left = cs.name_left;
			ks.name_pause = cs.name_pause;
			ks.name_place = cs.name_place;
			ks.name_right = cs.name_right;
			ks.name_rotccw = cs.name_rotccw;
			ks.name_rotcw = cs.name_rotcw;
			ks.name_up = cs.name_up;
		}
		
		/*public static function deleteKeyConfig(i:uint):void
		{
			_allConfigs.splice(i, 1);
			//update savedata's array
		}*/
		
		/**
		 * Designates which input keys are allowable. If allowable, returns the key name.
		 * @param	charCode The character code of the selected key.
		 * @param	keyCode The keyCode of the selected key.
		 * @return	The key name if allowed, null otherwise.
		 */
		public static function getAllowableName(keyCode:uint, charCode:int = -1):String
		{
			var keyName:String = null;
			if (keyCode != 0)
				keyName = KEYNAME_MAP[keyCode];
			if (keyName == null && charCode != 0)
			{
				if (charCode == -1)
					charCode = keyCode;
				keyName = String.fromCharCode(charCode);
			}
			return keyName != null ? keyName : "";
		}
	}
}