package menu.editing.previews 
{
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import media.fonts.FontStyles;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class PreviewNone extends PreviewItem 
	{
		override protected function firstDraw():void
		{
			var label:TextField = new TextField();
			var format:TextFormat = new TextFormat(FontStyles.F_JOYSTIX, 15, 0xFFFF00);
			format.align = TextFormatAlign.CENTER;
			G.setTextField(label, format);
			label.autoSize = TextFieldAutoSize.LEFT;
			label.text = "No Preview\nAvailable";
			addChild(label);
		}
		
	}

}