package  
{
	import fl.controls.Button;
	import fl.controls.CheckBox;
	import fl.controls.ColorPicker;
	import fl.controls.ComboBox;
	import fl.controls.List;
	import fl.controls.NumericStepper;
	import fl.controls.TextInput;
	import fl.managers.StyleManager;
	import flash.text.TextFormat;
	import media.fonts.FontStyles;
	import menu.editing.comps.*;
	/**
	 * ...
	 * @author XJ
	 */
	public class StyleSetter 
	{
		public static function apply()
		{
			var tf:TextFormat = new TextFormat(FontStyles.F_JOYSTIX, 10, 0);
			for each (var CompType:Class in [EditCompArray, Button, EditCompButton, NumericStepper, EditCompStepper, TextInput, ComboBox, List, EditCompCombo])
			{
				StyleManager.setComponentStyle(CompType, "embedFonts", true);
				StyleManager.setComponentStyle(CompType, "textFormat", tf);
			}
			
			var tf2:TextFormat = new TextFormat(FontStyles.F_JOYSTIX, 13, 0xFFFFFF);
			for each (var CompType:Class in [CheckBox, EditCompCheck, ColorPicker, EditCompColor])
			{
				StyleManager.setComponentStyle(CompType, "embedFonts", true);
				StyleManager.setComponentStyle(CompType, "textFormat", tf2);
			}
			
			var tfcases:TextFormat = new TextFormat(FontStyles.F_LUCIDA, 13, 0);
			for each (var CompType:Class in [EditCompText])
			{
				StyleManager.setComponentStyle(CompType, "embedFonts", true);
				StyleManager.setComponentStyle(CompType, "textFormat", tfcases);
			}
			
			/*for each (var CompType:Class in [EditCompCombo])
			{
				StyleManager.setComponentStyle();
			}*/
		}
		
	}

}