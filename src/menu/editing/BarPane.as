package menu.editing 
{
	import fl.core.UIComponent;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	/**
	 * Use this instead of a normal Sprite to avoid getting
	 * improper sizes for objects with components inside them.
	 * @author XJ
	 */
	public class BarPane extends Sprite 
	{
		override public function get height():Number
		{
			//This works because it uses child height properties that may be overrides.
			var max:Number = 0;
			var i:uint = 0;
			var obj:DisplayObject;
			while (true)
			{
				try {
					obj = getChildAt(i++);
				} catch (e:Error) {
					break;
				}
				if (obj is UIComponent)
					continue;
				max = Math.max(max, obj.y + obj.height);
			}
			return max;
		}
	}

}