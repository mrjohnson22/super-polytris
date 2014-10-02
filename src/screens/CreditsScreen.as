package screens 
{
	import flash.display.MovieClip;
	import flash.filters.DropShadowFilter;
	import visuals.backs.BG;
	import visuals.CreditsBox;
	/**
	 * ...
	 * @author XJ
	 */
	public class CreditsScreen extends Menu 
	{
		private var _creditsBox:MovieClip;
		public function CreditsScreen() 
		{
			addChild(new BG());
			setTitle("Credits");
			setBackButton(MainMenu);
			
			_creditsBox = new CreditsBox();
			G.centreX(_creditsBox);
			G.centreY(_creditsBox);
			_creditsBox.filters = [new DropShadowFilter()];
			addChild(_creditsBox);
		}	
	}
}