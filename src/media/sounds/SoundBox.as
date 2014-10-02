package media.sounds
{
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	public class SoundBox
	{
		private var _sound:Sound;
		private var _channel:SoundChannel;
		private var _settings:SoundTransform;
		
		private var _pausepos:Number = 0;
		private var _listeners:Array = [];
		
		private var _isPlaying:Boolean = false;
		public function get isPlaying():Boolean
		{
			return _isPlaying;
		}
		
		public function SoundBox(PSound:Class)
		{
			setSound(PSound);
			_channel = new SoundChannel();
		}
		
		public function setSound(PSound:Class)
		{
			_sound = new PSound() as Sound;
		}
		
		/**
		 * Play the sound associated with this instance.
		 * @param	loops The number of times to play the sound. Set to -1 to loop the sound.
		 */
		public function play(loops:int = 0, volume:Number = 1):void
		{
			_channel.stop();
			_settings = new SoundTransform(volume * Sounds.maxSfxVolume);
			_channel = _sound.play(_pausepos, loops != -1 ? loops : int.MAX_VALUE, _settings);
			_isPlaying = true;
			
			while (_listeners.length > 0)
			{
				var listener:Function = _listeners.pop();
				_channel.addEventListener(Event.SOUND_COMPLETE, listener, false, 0, true);
			}
		}
		
		public function pause():void
		{
			_pausepos = _channel.position;
			_channel.stop();
		}
		
		public function stop():void
		{
			_pausepos = 0;
			_channel.stop();
		}
		
		public function addSoundEndListener(listener:Function):void
		{
			if (!_isPlaying)
				_listeners.push(listener);
			else
				_channel.addEventListener(Event.SOUND_COMPLETE, listener, false, 0, true);
		}
		
		public function removeSoundEndListener(listener:Function):void
		{
			if (!_isPlaying)
				G.removeEntry(_listeners, listener);
			else
				_channel.removeEventListener(Event.SOUND_COMPLETE, listener);
		}
		
	}
}