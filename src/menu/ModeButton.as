package menu 
{
	import flash.display.Sprite;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import media.fonts.FontStyles;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class ModeButton extends BlockableButton
	{
		private var _back:Sprite;
		protected var _field:TextField;
		
		public var id:int = 0;
		
		/**
		 * Cannot manually set width of ModeButtons.
		 */
		override public function set width(value:Number):void 
		{
			return;
		}
		/**
		 * Cannot manually set height of ModeButtons.
		 */
		override public function set height(value:Number):void 
		{
			return;
		}
		
		public function set active(value:Boolean):void
		{
			clickable = !value;
			addChild(_field);
		}
		
		/**
		 * A button which includes text and a clickable background. The button is resized to fit
		 * the entirety of the text. **NOTE:** Timeline must have _up, _over, and _down frame labels.
		 * @param	text The text that is to appear on the button.
		 * @param	gtcol The color of the title text.
		 * @param	gcol The color of the button's background.
		 * @param	locked The button will take on a slightly different appearance if the mode is locked.
		 */
		public function ModeButton(text:String, gtcol:uint, gcol:uint, locked:Boolean)
		{
			var bwidth:Number = this.width;
			var bheight:Number = this.height;
			
			var format:TextFormat = new TextFormat(FontStyles.F_JOYSTIX, 26, gtcol);
			format.align = TextFormatAlign.CENTER;
			
			_back = new Sprite();
			_back.graphics.beginFill(gcol);
			_back.graphics.drawRect(0, 0, bwidth, bheight);
			
			_field = new TextField();
			G.setTextField(_field, format);
			_field.autoSize = TextFieldAutoSize.CENTER;
			_field.text = text;
			
			//Resize to fit button
			G.matchSizeV(_field, bwidth * 0.95, Infinity, false);
			
			G.centreX(_field, _back);
			G.centreY(_field, false, _back);
			addChild(_field);
			addChildAt(_back, 0);
			
			_field.mouseEnabled = false;
			_back.mouseEnabled = false;
			
			if (locked)
			{
				var g:GlowFilter = new GlowFilter(0x00FFFF);
				g.blurX = g.blurY = 5;
				g.quality = BitmapFilterQuality.HIGH;
				filters = [g];
			}
		}
	}

}