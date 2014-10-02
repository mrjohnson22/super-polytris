package visuals.tilestyles
{
	import flash.display.Sprite;
	
	public class ShadedSquare extends Sprite implements IAppearSuite
	{
		public function get Masker():Class 
		{
			return MaskerSquare;
		}
	}
}