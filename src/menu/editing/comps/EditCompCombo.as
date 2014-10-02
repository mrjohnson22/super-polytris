package menu.editing.comps 
{
	import fl.controls.ComboBox;
	import fl.managers.StyleManager;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class EditCompCombo extends ComboBox implements IEditComponent 
	{
		public static const WID:Number = 150;
		public function EditCompCombo()
		{
			super();
			this.width = WID;
			this.dropdown.setRendererStyle("embedFonts", StyleManager.getComponentStyle(ComboBox, "embedFonts"));
			this.dropdown.setRendererStyle("textFormat", StyleManager.getComponentStyle(ComboBox, "textFormat"));
		}
		
		public function get data():Object
		{
			return this.selectedIndex;
		}
		
		public function set data(value:Object):void
		{
			this.selectedIndex = uint(value);
		}
		
		private var _defval:uint;
		public function set defval(value:Object):void 
		{
			_defval = uint(value);
		}
		
		public function isDefault():Boolean 
		{
			return _defval == this.selectedIndex;
		}
		
		public function undoChanges():void 
		{
			this.selectedIndex = _defval;
		}
		
		public function setProperties(props:Array):void { };
	}
}