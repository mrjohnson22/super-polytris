package media.sounds
{
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	public class Sounds
	{
		private static var _BGSong:Class;
		private static var _bgMusic:SoundChannel = new SoundChannel();
		private static var _soundChannel:SoundChannel = new SoundChannel();
		private static var _bgMusicSettings:SoundTransform = new SoundTransform(1);
		
		private static var _singleSoundChannel:SoundChannel = new SoundChannel();
		private static var _soundSettings:SoundTransform = new SoundTransform(1);
		
		private static var _channelList:Array = [];
		
		private static var _maxSongVolume:Number = 1;
		private static var _fullSongVolume:Number = 1;
		private static var _songVolume:Number = 1;
		private static var _maxSfxVolume:Number = 1;
		private static var _fullSfxVolume:Number = 1;
		private static var _sfxVolume:Number = 1;
		
		private static var _fadeSpeed:Number = 0;
		
		/**
		 * Play a sound. All sounds played by this function can be played on top of each other.
		 * @param	PSound The class of the sound to play. NOTE: enter the class itself, not an instance of it.
		 * @param	volume How loud the sound will be as a percentage of the max sfx volume.
		 */
		public static function playSound(PSound:Class, volume:Number = 1):SoundChannel
		{
			var tempSound:Sound = new PSound() as Sound;
			var channel:SoundChannel;
			
			if (volume != 1)
			{
				var tempSettings:SoundTransform = _soundSettings;
				tempSettings.volume *= volume;
				channel = tempSound.play(0, 0, tempSettings);
			}
			else
				channel = tempSound.play(0, 0, _soundSettings);
			
			_channelList.push(channel);
			channel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			
			return channel;
		}
		
		private static function onSoundComplete(e:Event):void
		{
			_channelList.splice(_channelList.indexOf(e.target));
			SoundChannel(e.target).removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
		}
		
		/**
		 * Play a sound. Only one sound played by this function can play at a time.
		 * @param	PSound The class of the sound to play. NOTE: enter the class itself, not an instance of it.
		 * @param	volume How loud the sound will be as a percentage of the max sfx volume.
		 */
		public static function playSingleSound(PSound:Class, volume:Number = 1):void
		{
			var tempSound = new PSound() as Sound;
			_singleSoundChannel.stop();
			if (volume != 1)
			{
				var tempSettings:SoundTransform = _soundSettings;
				tempSettings.volume *= volume;
				_singleSoundChannel = tempSound.play(0, 0, tempSettings);
			}
			else
				_singleSoundChannel = tempSound.play(0, 0, _soundSettings);
		}
		
		public static function stopAllSounds():void
		{
			while (_channelList.length > 0)
			{
				var channel:SoundChannel = _channelList.pop();
				channel.stop();
			}
			_singleSoundChannel.stop();
		}
		
		/**
		 * Choose the song to play in the background. Only one song can be played at a time.
		 * @param	PSong The class of the song to play. NOTE: enter the class itself, not an instance of it.
		 * @param	force Set to true if the song should play even if it is already playing.
		 */
		public static function playSong(PSong:Class, force:Boolean = false):void
		{
			if (!force && _BGSong != null && _BGSong == PSong)
				return;
			_BGSong = PSong;
			_bgMusic = (new _BGSong() as Sound).play(0, int.MAX_VALUE, _bgMusicSettings);
		}
		
		public static function stopSong():void
		{
			_bgMusic.stop();
		}
		
		public static function addSongEndListener(listener:Function, useWeakReference:Boolean = false):void
		{
			_bgMusic.addEventListener(Event.SOUND_COMPLETE, listener, false, 0, useWeakReference);
		}
		
		public static function removeSongEndListener(listener:Function):void
		{
			_bgMusic.removeEventListener(Event.SOUND_COMPLETE, listener);
		}
		
		/**
		 * Set the volume of background music. Is applied immediately.
		 * @param	volume A volume value between 0 and 1 inclusive.
		 */
		public static function set songVolume(volume:Number):void
		{
			if (_fadeSpeed != 0)
				fadeOutEnd();
			
			_fullSongVolume = volume;
			_songVolume = _maxSongVolume * volume;
			_bgMusicSettings.volume = _songVolume;
			_bgMusic.soundTransform = _bgMusicSettings;
		}
		
		public static function get songVolume():Number
		{
			return _songVolume;
		}
		
		/**
		 * Set the volume of sounds. (The volume of currently playing sounds remains unchanged.)
		 * @param	volume A volume value between 0 and 1 inclusive.
		 */
		public static function set sfxVolume(volume:Number):void
		{
			_fullSfxVolume = volume;
			_sfxVolume = _maxSfxVolume * volume;
			_soundSettings.volume = _sfxVolume;
		}
		
		public static function get sfxVolume():Number
		{
			return _sfxVolume;
		}
		
		public static function set maxSongVolume(value:Number):void
		{
			_maxSongVolume = value;
			songVolume = _fullSongVolume; //to set effective volume
		}
		
		public static function set maxSfxVolume(value:Number):void
		{
			_maxSfxVolume = value;
			sfxVolume = _fullSfxVolume; //to set effective volume
		}
		
		public static function get maxSongVolume():Number
		{
			return _maxSongVolume;
		}
		
		public static function get maxSfxVolume():Number
		{
			return _maxSfxVolume;
		}
		
		public static function fadeOutSong(fadeSpeed:Number = 0.05):void
		{
			//Don't fade out if fading is already in progress.
			if (_fadeSpeed != 0)
				return;
			
			_fadeSpeed = fadeSpeed;
			Main.stage.addEventListener(Event.ENTER_FRAME, fadeOutLoop);
		}
		
		private static function fadeOutLoop(e:Event):void
		{
			if (_bgMusicSettings.volume - _fadeSpeed <= 0)
				fadeOutEnd();
			else
			{
				_bgMusicSettings.volume -= _fadeSpeed;
				_bgMusic.soundTransform = _bgMusicSettings;
			}
		}
		
		private static function fadeOutEnd():void
		{
			_fadeSpeed = 0;
			_bgMusic.stop();
			_bgMusicSettings.volume = _songVolume;
			_bgMusic.soundTransform = _bgMusicSettings;
			_BGSong = null;
			Main.stage.removeEventListener(Event.ENTER_FRAME, fadeOutLoop);
		}
	}
}