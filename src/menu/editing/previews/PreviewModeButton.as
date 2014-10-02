package menu.editing.previews 
{
	import menu.ModeButton;
	import data.SettingNames;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class PreviewModeButton extends PreviewItem
	{
		private var _button:ModeButton;
		
		override protected function firstDraw():void
		{
			_button = new ModeButton(cs[SettingNames.GTITLE], cs[SettingNames.GTCOL], cs[SettingNames.GCOL], false);
			_button.mouseEnabled = false;
			_button.mouseChildren = false;
			_button.tabEnabled = false;
			addChild(_button);
		}
		
		override public function update():void
		{
			removeChild(_button);
			firstDraw();
		}
		
	}

}