package visuals 
{
	import data.SettingNames;
	import data.Settings;
	import fl.transitions.easing.None;
	import fl.transitions.easing.Regular;
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import media.fonts.FontStyles;
	import visuals.scorebacks.ScoreEntry;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class ScoreList extends Sprite
	{
		private static const NOCHANCES:int = -2;
		
		private var _lives:int = 0;
		private var _chances:int = NOCHANCES;
		
		private var _container:Sprite;
		
		private var _scorelabel:TextField;
		private var _levellabel:TextField;
		private var _reqvallabel:TextField;
		private var _nextlabel:TextField;
		private var _liveslabel:TextField;
		private var _timelabel:TextField;
		
		private var _scoretext:ScoreEntry;
		private var _leveltext:ScoreEntry;
		private var _reqvaltext:ScoreEntry;
		private var _nexttext:ScoreEntry;
		private var _livestext:ScoreEntry;
		private var _timetext:ScoreEntry;
		
		private var _bbcombopop:TextField;
		private var _combopop:TextField;
		private var _gravcombopop:TextField;
		private var _bbcombotween:Tween;
		private var _combotween:Tween;
		private var _gravcombotween:Tween;
		
		private var _dzonemark:TextField;
		private var _szonemark:TextField;
		
		private var _timeaddpop:TextField;
		private var _timeaddtween:Tween;
		private var _timeaddtimer:FrameTimer;
		
		private var _pulsetweend:Tween;
		private var _pulsetweens:Tween;
		
		private var _fadetweenc:Tween;
		private var _fadetweenb:Tween;
		private var _fadetweeng:Tween;
		
		public function set score(value:uint):void
		{
			if (_scorelabel != null)
				_scoretext.text = value.toString();
		}
		
		public function set level(value:uint):void
		{
			if (_leveltext != null)
			{
				if (cs[SettingNames.LEVELMAX] && cs[SettingNames.LEVELMAXWIN])
					_leveltext.text = value.toString() + "/" + cs[SettingNames.LEVELMAX].toString();
				else
					_leveltext.text = value.toString();
			}
		}
		
		public function set reqval(value:uint):void
		{
			if (_reqvaltext != null)
				_reqvaltext.text = cs[SettingNames.LEVELUPREQ] != Settings.L_TIME ? value.toString() : G.timeString(value);
		}
		
		public function clearStop():void
		{
			if (_reqvaltext != null)
				_nexttext.text = "MAX";
		}
		
		public function set next(value:uint):void
		{
			if (_nexttext != null)
				_nexttext.text = cs[SettingNames.LEVELUPREQ] != Settings.L_TIME ? value.toString() : G.timeString(value);
		}
		
		public function set lives(value:uint):void
		{
			if (_livestext != null)
			{
				_lives = value;
				if (_chances == NOCHANCES)
					_livestext.text = value.toString();
				else
					lifechanceText();
			}
		}
		
		public function set chances(value:uint):void
		{
			if (_livestext != null)
			{
				_chances = value;
				lifechanceText();
			}
		}
		
		public function set danger(value:Boolean):void
		{
			if (_dzonemark == null)
				return;
			
			if (value)
				showAnyZoneMark(_dzonemark);
			else
				hideAnyZoneMark(_dzonemark);
		}
		
		public function set safe(value:Boolean):void
		{
			if (_szonemark == null)
				return;
			
			if (value)
				showAnyZoneMark(_szonemark);
			else
				hideAnyZoneMark(_szonemark);
		}
		
		private function lifechanceText():void
		{
			_livestext.text = _lives.toString() + "." + _chances.toString();
		}
		
		public function set time(value:uint):void
		{
			if (_timetext != null)
				_timetext.text = G.timeString(value);
		}
		
		public function flashScore():void
		{
			if (_scoretext != null)
				_scoretext.playAttract();
		}
		
		public function flashLevel():void
		{
			if (_leveltext != null)
				_leveltext.playAttract();
		}
		
		public function flashReqval():void
		{
			if (_reqvaltext != null)
				_reqvaltext.playAttract();
		}
		
		public function flashNext():void
		{
			if (_nexttext != null)
				_nexttext.playAttract();
		}
		
		public function startHoldLevel():void
		{
			if (_leveltext != null)
				_leveltext.playWarning();
		}
		
		public function stopHoldLevel():void
		{
			if (_leveltext != null)
				_leveltext.stopWarning();
		}
		
		public function startHoldTime():void
		{
			if (_timetext != null)
				_timetext.playWarning();
		}
		
		public function stopHoldTime():void
		{
			if (_timetext != null)
				_timetext.stopWarning();
		}
		
		public function startHoldLives():void
		{
			if (_livestext != null)
				_livestext.playWarning();
		}
		
		public function stopHoldLives():void
		{
			if (_livestext != null)
				_livestext.stopWarning();
		}
		
		private var cs:Settings;
		
		public function ScoreList()
		{
			cs = Settings.currentGame;
			var labels:Array = [];
			
			var labelformat:TextFormat = new TextFormat(FontStyles.F_JOYSTIX, 18, 0xFF0000);
			var textformat:TextFormat = new TextFormat(FontStyles.F_JOYSTIX, 20, 0xFFFFFF);
			textformat.align = TextFormatAlign.RIGHT;
			var textheight:Number = 32;
			var textwidth:Number = 115;
			
			var bpopformat:TextFormat = new TextFormat(FontStyles.F_JOYSTIX, 15, 0xFF0000);
			var cpopformat:TextFormat = new TextFormat(FontStyles.F_JOYSTIX, 15, 0xFFFF00);
			var gpopformat:TextFormat = new TextFormat(FontStyles.F_JOYSTIX, 15, 0x0033FF);
			var tpopformat:TextFormat = new TextFormat(FontStyles.F_JOYSTIX, 20, 0xFFFFFF);
			var dmarkformat:TextFormat = new TextFormat(FontStyles.F_JOYSTIX, 15, cs[SettingNames.DCOL]);
			var smarkformat:TextFormat = new TextFormat(FontStyles.F_JOYSTIX, 15, cs[SettingNames.SCOL]);
			tpopformat.align = TextFormatAlign.RIGHT;
			
			var ScoreEntryType:Class = Settings.SCORE_TYPES[cs[SettingNames.SCORE_TYPE]];
			
			_scorelabel = new TextField();
			_scoretext = new ScoreEntryType();
			_levellabel = new TextField();
			_leveltext = new ScoreEntryType();
			_nextlabel = new TextField();
			_nexttext = new ScoreEntryType();
			
			if (cs[SettingNames.LEVELUPREQ] != Settings.L_SCORE)
			{
				_reqvallabel = new TextField();
				_reqvaltext = new ScoreEntryType();
				labels.push(_scorelabel, _scoretext, _levellabel, _leveltext, _reqvallabel, _reqvaltext, _nextlabel, _nexttext);
			}
			else
				labels.push(_scorelabel, _scoretext, _nextlabel, _nexttext, _levellabel, _leveltext);
			
			if (cs[SettingNames.LIVES] != 0 || cs[SettingNames.FITMODE])
			{
				_liveslabel = new TextField();
				_livestext = new ScoreEntryType();
				labels.push(_liveslabel, _livestext);
			}
			
			if (cs[SettingNames.TIMELIMIT] != 0)
			{
				_timelabel = new TextField();
				_timetext = new ScoreEntryType();
				labels.push(_timelabel, _timetext);
			}
			
			_container = new Sprite();
			var ypos:Number = 0;
			for (var i:uint = 0; i < labels.length; i += 2)
			{
				//labels
				_container.addChild(labels[i]);
				G.setTextField(labels[i], labelformat);
				labels[i].autoSize = TextFieldAutoSize.LEFT;
				labels[i].y = ypos;
				ypos += 25;
				
				//score texts
				_container.addChild(labels[i + 1]);
				labels[i + 1].y = ypos;
				ypos += 45;
			}
			
			_scorelabel.text = "Score";
			_levellabel.text = "Level";
			if (_reqvallabel != null)
			{
				switch (cs[SettingNames.LEVELUPREQ])
				{
					case Settings.L_NUMCLEARS:
						_reqvallabel.text = (cs[SettingNames.CWID] != cs[SettingNames.BINX] || cs[SettingNames.CLEN] > 1) ? "Clears" : "Lines";
						break;
					
					case Settings.L_PIECESETS:
						_reqvallabel.text = "Pcs[SettingNames.SET]";
						break;
					
					case Settings.L_TILECLEARS:
						_reqvallabel.text = "Tls.Clear";
						break;
					
					case Settings.L_TILESETS:
						_reqvallabel.text = "Tls.Set";
						break;
					
					case Settings.L_TIME:
						_reqvallabel.text = "Time"; //NOT time remaining. That can increase by scoring. This is TOTAL time!
						break;
					
					default:
						throw new Error("Invalid level up type.");
				}
			}
			_nextlabel.text = "To Next";
			if (_liveslabel != null) _liveslabel.text = "Lives";
			if (_timelabel != null) _timelabel.text = "Time Left";
			
			for (i = 0; i < labels.length; i += 2)
				G.matchSizeV(labels[i], textwidth, Infinity, false);
			
			var backmargin:Number = 10;
			var back:Sprite = new ScoreBack();
			back.width = _container.width + 2 * backmargin;
			back.height = _container.height + 2 * backmargin;
			G.centreX(_container, back);
			G.centreY(_container, false, back);
			addChild(back);
			addChild(_container);
			
			_bbcombopop = new TextField();
			G.setTextField(_bbcombopop, bpopformat);
			_bbcombopop.filters = [new GlowFilter(0xFFFFFF, 1, 10, 10, 1)];
			_bbcombopop.autoSize = TextFieldAutoSize.LEFT;
			//G.rightAlign(_bbcombopop, 0, _scoretext);
			
			_combopop = new TextField();
			G.setTextField(_combopop, cpopformat);
			_combopop.filters = [new GlowFilter(0xFFFFFF, 1, 10, 10, 1)];
			_combopop.autoSize = TextFieldAutoSize.LEFT;
			//G.rightAlign(_combopop, 0, _scoretext);
			
			_gravcombopop = new TextField();
			G.setTextField(_gravcombopop, gpopformat);
			_gravcombopop.filters = [new GlowFilter(0xFFFFFF)];
			_gravcombopop.autoSize = TextFieldAutoSize.LEFT;
			//G.rightAlign(_gravcombopop, 0, _scoretext);
			
			if (cs[SettingNames.DZONEMULT] != 1)
			{
				_dzonemark = new TextField();
				G.setTextField(_dzonemark, dmarkformat);
				_dzonemark.autoSize = TextFieldAutoSize.RIGHT;
				_dzonemark.text = "Danger: x" + cs[SettingNames.DZONEMULT].toString();
				G.textFieldFitSize(_dzonemark, back.width - backmargin * 2);
				G.rightAlign(_dzonemark, 0, _scoretext);
				_dzonemark.y = _scoretext.y + _scoretext.height;
				
				_pulsetweend = new Tween(_dzonemark, "alpha", None.easeNone, 1, 0.5, 0.5, true);
				_pulsetweend.addEventListener(TweenEvent.MOTION_FINISH, loopTween);
				_pulsetweend.stop();
			}
			
			if (cs[SettingNames.SZONEMULT] != 1)
			{
				_szonemark = new TextField();
				G.setTextField(_szonemark, smarkformat);
				_szonemark.autoSize = TextFieldAutoSize.RIGHT;
				_szonemark.text = "Safe: x" + cs[SettingNames.SZONEMULT].toString();
				G.textFieldFitSize(_szonemark, back.width - backmargin * 2);
				G.rightAlign(_szonemark, 0, _scoretext);
				_szonemark.y = _scoretext.y + _scoretext.height;
				
				_pulsetweens = new Tween(_szonemark, "alpha", None.easeNone, 1, 0.5, 0.5, true);
				_pulsetweens.addEventListener(TweenEvent.MOTION_FINISH, loopTween);
				_pulsetweens.stop();
			}
			
			_timeaddpop = new TextField();
			G.setTextField(_timeaddpop, tpopformat);
			_timeaddpop.autoSize = TextFieldAutoSize.RIGHT;
			G.rightAlign(_timeaddpop, 0, _timetext);
			
			const topdest:Number = _scorelabel.y - 10;
			const popmargin:Number = 10;
			
			const combodest:Number = topdest - _bbcombopop.height - _gravcombopop.height - popmargin * 2;
			const gravcombodest:Number = topdest - _bbcombopop.height - popmargin;
			const bbcombodest:Number = topdest;
			_combotween = new Tween(_combopop, "y", Regular.easeOut, _scoretext.y, combodest, 0.5, true);
			_combotween.addEventListener(TweenEvent.MOTION_FINISH, endComboTween);
			_bbcombotween = new Tween(_bbcombopop, "y", Regular.easeOut, _scoretext.y, bbcombodest, 0.5, true);
			_bbcombotween.addEventListener(TweenEvent.MOTION_FINISH, endBBTween);
			_gravcombotween = new Tween(_gravcombopop, "y", Regular.easeOut, _scoretext.y, gravcombodest, 0.5, true);
			_gravcombotween.addEventListener(TweenEvent.MOTION_FINISH, endGravTween);
			if (cs[SettingNames.TIMELIMIT] != 0)
			{
				_timeaddtween = new Tween(_timeaddpop, "y", Regular.easeOut, _timetext.y + 10, _timetext.y + _timetext.height, 1, true);
				_timeaddtween.addEventListener(TweenEvent.MOTION_FINISH, hideTimeAddPop);
				_timeaddtimer = new FrameTimer(5);
				_timeaddtimer.addEventListener(TimerEvent.TIMER, pulseTimeAddPop);
			}
			
			_fadetweenc = new Tween(_combopop, "alpha", Regular.easeOut, 1, 0, 3, true);
			_fadetweenb = new Tween(_bbcombopop, "alpha", Regular.easeOut, 1, 0, 3, true);
			_fadetweeng = new Tween(_gravcombopop, "alpha", Regular.easeOut, 1, 0, 3, true);
			_fadetweenc.addEventListener(TweenEvent.MOTION_FINISH, hideComboPop);
			_fadetweenb.addEventListener(TweenEvent.MOTION_FINISH, hideBBComboPop);
			_fadetweeng.addEventListener(TweenEvent.MOTION_FINISH, hideGravComboPop);
			
			_bbcombotween.stop();
			_combotween.stop();
			_gravcombotween.stop();
			_fadetweenb.stop();
			_fadetweenc.stop();
			_fadetweeng.stop();
			if (cs[SettingNames.TIMELIMIT] != 0)
				_timeaddtween.stop();
		}
		
		private function loopTween(e:TweenEvent):void
		{
			Tween(e.target).rewind();
			Tween(e.target).start();
		}
		
		public function showBBComboPop(num:Number):void
		{
			showAnyComboPop(_bbcombopop, num);
		}
		
		public function showComboPop(num:Number):void
		{
			showAnyComboPop(_combopop, num);
		}
		
		public function showGravComboPop(num:Number):void
		{
			showAnyComboPop(_gravcombopop, num);
		}
		
		public function showDZoneMark():void
		{
			if (_dzonemark != null)
				showAnyZoneMark(_dzonemark);
		}
		
		public function showSZoneMark():void
		{
			if (_szonemark != null)
				showAnyZoneMark(_szonemark);
		}
		
		public function showTimeAddPop(num:Number):void
		{
			var newnum:Number = !_timeaddtimer.running ? num : (num + Number(_timeaddpop.text));
			showAnyComboPop(_timeaddpop, newnum);
		}
		
		private function showAnyComboPop(popfield:TextField, num:Number):void
		{
			if (popfield == null)
				return;
			var poptween:Tween;
			var opchar:String = popfield != _timeaddpop ? "x" : "+";
			var msg:String;
			switch(popfield)
			{
				case _bbcombopop:
					poptween = _bbcombotween;
					msg = "B2B";
					
					_fadetweenb.rewind();
					_fadetweenb.stop();
					break;
				
				case _combopop:
					poptween = _combotween;
					msg = "Chain";
					
					_fadetweenc.rewind();
					_fadetweenc.stop();
					break;
				
				case _gravcombopop:
					poptween = _gravcombotween;
					msg = "Grav";
					
					_fadetweeng.rewind();
					_fadetweeng.stop();
					break;
					
				case _timeaddpop:
					poptween = _timeaddtween;
					msg = "";
					
					_timeaddtimer.reset();
					_timeaddtimer.start();
					break;
				
				default:
					return;
			}
			
			if (popfield.parent == null)
			{
				popfield.alpha = 1;
				_container.addChild(popfield);
			}
			
			var numstring:String = (num % 1 == 0) ? num.toString() : num.toFixed(1).toString();
			popfield.text = msg + " " + opchar + numstring;
			
			poptween.rewind();
			poptween.start();
		}
		
		public function showAnyZoneMark(mark:TextField):void
		{
			if (mark == null)
				return;
			switch(mark)
			{
				case _dzonemark:
					_pulsetweend.start();
					break;
				
				case _szonemark:
					_pulsetweens.start();
					break;
				
				default:
					return
			}
			
			if (mark.parent == null)
				_container.addChild(mark);
		}
		
		public function hideAnyZoneMark(mark:TextField):void
		{
			var remtween:Tween;
			switch(mark)
			{
				case _dzonemark:
					remtween = _pulsetweend;
					break;
				
				case _szonemark:
					remtween = _pulsetweens;
					break;
				
				default:
					return
			}
			
			if (mark.parent != null)
			{
				_container.removeChild(mark);
				remtween.rewind();
				remtween.stop();
			}
		}
		
		private function endComboTween(e:TweenEvent):void
		{
			_fadetweenc.start();
		}
		
		private function endBBTween(e:TweenEvent):void
		{
			_fadetweenb.start();
		}
		
		private function endGravTween(e:TweenEvent):void
		{
			_fadetweeng.start();
		}
		
		private function pulseTimeAddPop(e:TimerEvent):void
		{
			_timeaddpop.visible = !_timeaddpop.visible;
		}
		
		private function hideBBComboPop(e:TweenEvent):void
		{
			_container.removeChild(_bbcombopop);
		}
		
		private function hideComboPop(e:TweenEvent):void
		{
			_container.removeChild(_combopop);
		}
		
		private function hideGravComboPop(e:TweenEvent):void
		{
			_container.removeChild(_gravcombopop);
		}
		
		private function hideTimeAddPop(e:TweenEvent):void
		{
			_container.removeChild(_timeaddpop);
			_timeaddtimer.reset();
		}
		
		public function cleanUp():void
		{
			_scoretext.cleanUp();
			_leveltext.cleanUp();
			if (_reqvaltext != null)
				_reqvaltext.cleanUp();
			if (_nexttext != null)
				_nexttext.cleanUp();
			if (_livestext != null)
				_livestext.cleanUp();
			if (_timetext != null)
				_timetext.cleanUp();
			
			if (_bbcombotween != null)
			{
				_bbcombotween.stop();
				_bbcombotween.removeEventListener(TweenEvent.MOTION_FINISH, endBBTween);
				_fadetweenb.stop();
				_fadetweenb.removeEventListener(TweenEvent.MOTION_FINISH, hideBBComboPop);
			}
			if (_combotween != null)
			{
				_combotween.stop();
				_fadetweenc.stop();
				_fadetweenc.removeEventListener(TweenEvent.MOTION_FINISH, hideComboPop);
			}
			if (_gravcombotween != null)
			{
				_gravcombotween.stop();
				_gravcombotween.removeEventListener(TweenEvent.MOTION_FINISH, endGravTween);
				_fadetweeng.stop();
				_fadetweeng.removeEventListener(TweenEvent.MOTION_FINISH, hideGravComboPop);
			}
			if (_timeaddtween != null)
			{
				_timeaddtween.stop();
				_timeaddtween.removeEventListener(TweenEvent.MOTION_FINISH, hideTimeAddPop);
				_timeaddtimer.stop();
				_timeaddtimer.removeEventListener(TimerEvent.TIMER, pulseTimeAddPop);
			}
			if (_pulsetweend != null)
			{
				_pulsetweend.stop();
				_pulsetweend.removeEventListener(TweenEvent.MOTION_FINISH, loopTween);
			}
			if (_pulsetweens != null)
			{
				_pulsetweens.stop();
				_pulsetweens.removeEventListener(TweenEvent.MOTION_FINISH, loopTween);
			}
		}
		
	}

}