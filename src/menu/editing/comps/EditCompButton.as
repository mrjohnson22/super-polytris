package menu.editing.comps 
{
	import fl.controls.Button;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class EditCompButton extends Button implements IEditComponent 
	{
		public function get data():Object
		{
			return this.selected;
		}
		
		public function set data(value:Object):void
		{
			this.selected = Boolean(value);
		}
		
		private var _defval:Boolean;
		public function set defval(value:Object):void 
		{
			_defval = Boolean(value);
		}
		
		public function isDefault():Boolean 
		{
			return _defval == this.selected;
		}
		
		public function undoChanges():void 
		{
			this.selected = _defval;
		}
		
		public function setProperties(props:Array):void { };
	}
}