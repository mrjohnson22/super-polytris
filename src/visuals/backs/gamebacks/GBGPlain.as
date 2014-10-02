package visuals.backs.gamebacks 
{
	import com.greensock.TimelineLite;
	import com.greensock.TweenLite;
	import fl.transitions.easing.None;
	import flash.display.Sprite;
	import flash.events.Event;
	import media.sounds.SoundList;
	import media.sounds.Sounds;
	import visuals.backs.BGStill;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class GBGPlain extends GBG
	{
		private var _backSquare:Sprite;
		private var _backTween:TimelineLite;
		private var _timeSquare:Sprite;
		private var _timeTween:TimelineLite;
		private var _levelSquare:Sprite;

		public function GBGPlain()
		{
			_bg = new BGStill();
			
			//create background "flavour colouring"
			_backSquare = new Sprite();
			_backSquare.graphics.beginFill(0xFF0000);
			_backSquare.graphics.drawRect(0, 0, G.STAGE_WIDTH, G.STAGE_HEIGHT);
			_backSquare.alpha = 0;
			
			_backTween = new TimelineLite();
			_backTween.append(new TweenLite(_backSquare, 1, { alpha:0.5, ease:None.easeNone } ));
			_backTween.append(new TweenLite(_backSquare, 1, { alpha:0, ease:None.easeNone, onComplete:repeat } ));
			_backTween.stop();
			
			//now, for time danger
			_timeSquare = new Sprite();
			_timeSquare.graphics.beginFill(0xFF9900);
			_timeSquare.graphics.drawRect(0, 0, G.STAGE_WIDTH, G.STAGE_HEIGHT);
			_timeSquare.alpha = 0;
			
			_timeTween = new TimelineLite();
			_timeTween.append(new TweenLite(_timeSquare, 1, { alpha:0.5 } ));
			_timeTween.append(new TweenLite(_timeSquare, 1, { alpha:0, onComplete:repeat2 } ));
			_timeTween.stop();
			
			//for level up
			_levelSquare = new Sprite();
			_levelSquare.graphics.beginFill(0xFFFF00);
			_levelSquare.graphics.drawRect(0, 0, G.STAGE_WIDTH, G.STAGE_HEIGHT);
			_levelSquare.alpha = 0;
			
			addChild(_bg);
			addChild(_timeSquare);
			addChild(_backSquare);
			addChild(_levelSquare);
		}
		
		override public function levelUp():void
		{
			_levelSquare.alpha = 1;
			TweenLite.to(_levelSquare, 1, { alpha:0 } );
			Sounds.playSound(SoundList.Levelup1);
		}
		
		override public function set danger(value:Boolean):void 
		{
			super.danger = value;
			
			if (value)
				_backTween.gotoAndPlay(0);
			else
				_backTween.gotoAndStop(0);
		}
		
		override public function set timedanger(value:Boolean):void 
		{
			super.timedanger = value;
			
			if (value)
				_timeTween.gotoAndPlay(0);
			else
				_timeTween.gotoAndStop(0);
		}
		
		private function repeat():void
		{
			//_backTween.gotoAndPlay(0);
			if (_danger)
				_backTween.gotoAndPlay(0);
			else
				_backTween.gotoAndStop(0);
		}
		
		private function repeat2():void
		{
			//_timeTween.gotoAndPlay(0);
			if (_timedanger)
				_timeTween.gotoAndPlay(0);
			else
				_timeTween.gotoAndStop(0);
		}
		
		override protected function cleanUp():void 
		{
			_backTween.kill();
			_timeTween.kill();
		}
	}

}