package visuals.backs 
{
	import media.images.Images;
	/**
	 * ...
	 * @author XJ
	 */
	public class PauseBack extends BG
	{	
		override protected function get TileStyle():Class
		{
			return Images.PBGTile;
		}
	}
}