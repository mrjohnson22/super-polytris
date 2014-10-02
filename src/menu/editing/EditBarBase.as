package menu.editing
{
	import flash.display.Sprite;
	import menu.ICleanable;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class EditBarBase extends Sprite implements ICleanable
	{
		public static var E_RESIZE:String = "resize piece bar";
		
		public static const E_WIDTH:Number = G.STAGE_WIDTH * 0.9;
		public static const E_HEIGHT:Number = 50;
		
		protected const COLDARK:Number = 0x008DD8;
		protected const COLLITE:Number = 0x0098FF;
		
		public var unused:Boolean = false;
		public var hidden:Boolean = false;
		
		private var _reliers:Vector.<EditBarBase> = new Vector.<EditBarBase>();
		public function get reliers():Vector.<EditBarBase>
		{
			return _reliers;
		}
		
		private var _deniers:Vector.<EditBarBase> = new Vector.<EditBarBase>();
		public function get deniers():Vector.<EditBarBase>
		{
			return _deniers;
		}
		
		protected var _back:Sprite;
		
		//don't allow setting width/height
		override public function set width(value:Number):void { }
		override public function set height(value:Number):void { }
		
		override public function get width():Number
		{
			return E_WIDTH;
		}
		
		override public function get height():Number
		{
			return _back.height;
		}
		
		//Abstracts
		public function setUp():void { };
		public function setInteractable(enabled:Boolean):void { };
		public function cleanUp():void { };
	}
}