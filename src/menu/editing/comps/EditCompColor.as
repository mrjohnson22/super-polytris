package menu.editing.comps 
{
	import data.Settings;
	import fl.controls.ColorPicker;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class EditCompColor extends ColorPicker implements IEditComponent 
	{
		public function EditCompColor()
		{
			super();
			this.customColors = Settings.COLORS_PICK;
		}
		
		public function get data():Object
		{
			return this.selectedColor;
		}
		
		public function set data(value:Object):void
		{
			this.selectedColor = uint(value);
		}
		
		private var _defval:uint;
		public function set defval(value:Object):void 
		{
			_defval = uint(value);
		}
		
		public function isDefault():Boolean 
		{
			return _defval == this.selectedColor;
		}
		
		public function undoChanges():void 
		{
			this.selectedColor = _defval;
		}
		
		public function setProperties(props:Array):void
		{
			this.customColors = props[0];
		}
	}
}