package menu.editing.pieces 
{	
	import fl.core.UIComponent;
	import flash.display.Sprite;
	import menu.ICleanable;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class EditPiece extends Sprite implements ICleanable
	{
		protected var _back:Sprite;
		protected var _ytop:Number = 0;
		protected var _complist:Vector.<UIComponent> = new Vector.<UIComponent>();
		
		override public function get width():Number 
		{
			return _back.width;
		}
		override public function get height():Number 
		{
			return _back.height;
		}
		
		override public function set width(value:Number):void { };
		override public function set height(value:Number):void { };
		
		public function EditPiece()
		{
			if (!(this is EditPieceGroup) && !(this is EditPieceCustom))
				throw new Error("Don't instantiate this directly. Use EditPieceGroup or EditPieceCustom instead.");
		}
		
		/**
		 * Returns all available info on this entry's piece. The info is returned in the form of an array:
		 * info\[0] = number of tiles for piece group, or piece map array for custom group
		 * info\[1] = properties (size for piece group, or direction map for custom piece)
		 * info\[2] = color (array for piece group, uint for custom)
		 * info\[3] = appearance style number
		 * @return
		 */
		public function getPieceInfo():Array { return null; }
		
		public function cleanUp():void { }
	}
}