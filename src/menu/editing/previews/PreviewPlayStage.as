package menu.editing.previews 
{
	import objects.PlayStage;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class PreviewPlayStage extends PreviewItem 
	{
		protected var _playStage:PlayStage;
		
		override protected function firstDraw():void 
		{
			_playStage = new PlayStage(cs);
			_playStage.y = _playStage.height;
			addChild(_playStage);
		}
		
		override public function update():void 
		{
			removeChild(_playStage);
			firstDraw();
		}
		
	}

}