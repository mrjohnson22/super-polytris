package visuals.tilestyles
{
	import flash.display.Sprite;
	
	public class ShadedCircle extends Sprite implements IAppearSuite
	{
		public function get Masker():Class 
		{
			return MaskerCircle;
		}
	}
}