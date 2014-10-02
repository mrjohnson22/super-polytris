package visuals
{
	import data.Settings;
	import flash.display.Sprite;
	import flash.events.Event;
	import visuals.clearstyles.ClearSuite;
	import visuals.tilestyles.IAppearSuite;
	
	public class Tile extends Sprite
	{
		protected var _clearinstance:ClearSuite;
		protected var _ClearStyle:Class;
		
		private var _body:Sprite;
		private var _coat:IAppearSuite;
		private var _masker:Sprite;
		
		public function hasCleared():Boolean
		{
			return _clearinstance != null;
		}
		
		public function Tile(color:uint, appearStyle:int = -1, clearStyle:int = -1)
		{
			if (clearStyle >= 0)
			{
				_ClearStyle = Settings.CLEAR_STYLES[clearStyle];
				addEventListener(Event.REMOVED_FROM_STAGE, cleanUp);
			}
			else
				_ClearStyle = null;
			
			_body = new Sprite();
			setColor(color);
			addChild(_body);
			
			setAppearance(appearStyle);
		}
		
		public function setColor(color:int):void
		{
			_body.graphics.clear();
			_body.graphics.beginFill(color);
			_body.graphics.drawRect(0, 0, G.S, -G.S);
		}
		
		public function setAppearance(appearStyle:int):void
		{
			if (_coat != null)
			{
				removeChild(Sprite(_coat));
				removeChild(_masker);
				_body.mask = null;
			}
			if (appearStyle >= 0 && Settings.APP_STYLES[appearStyle] != null)
			{
				_coat = new Settings.APP_STYLES[appearStyle]();
				_masker = new _coat.Masker();
				addChild(_masker);
				_body.mask = _masker;
				addChild(Sprite(_coat));
			}
		}
		
		public function addClearStyle():void
		{
			if (_ClearStyle != null)
				addChild(_clearinstance = new _ClearStyle());
		}
		
		public function pauseClearStyle():void
		{
			if (_clearinstance != null)
				_clearinstance.stop();
		}
		
		public function resumeClearStyle():void
		{
			if (_clearinstance != null)
				_clearinstance.play();
		}
		
		public function removeClearStyle():void
		{
			if (_clearinstance != null)
			{
				_clearinstance.remove();
				removeChild(_clearinstance);
				_clearinstance = null;
			}
		}
		
		private function cleanUp(e:Event = null):void
		{
			if (_clearinstance != null)
				removeClearStyle();
			removeEventListener(Event.REMOVED_FROM_STAGE, cleanUp);
		}
	}
}