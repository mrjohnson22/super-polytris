package screens 
{
	import com.newgrounds.API;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import menu.PopUp;
	import visuals.backs.BG;
	import visuals.CreditsBox;
	/**
	 * ...
	 * @author XJ
	 */
	public class BadHostScreen extends MovieClip 
	{
		public function BadHostScreen() 
		{
			addChild(new BG());
			PopUp.makePopUp("You aren't playing the official version of this game! Play it on *Newgrounds.com*!",
			Vector.<String>(["Play Official Version"]),
			Vector.<Function>([function(e:MouseEvent):void
			{
				API.loadOfficialVersion();
			}]));
		}	
	}
}