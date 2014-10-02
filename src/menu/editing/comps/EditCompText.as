package menu.editing.comps 
{
	import fl.controls.TextInput;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class EditCompText extends TextInput implements IEditComponent 
	{
		public function get data():Object
		{
			return this.text;
		}
		
		public function set data(value:Object):void
		{
			this.text = String(value);
		}
		
		private var _defval:String;
		public function set defval(value:Object):void 
		{
			_defval = String(value);
		}
		
		public function isDefault():Boolean 
		{
			return _defval == this.text;
		}
		
		public function undoChanges():void 
		{
			this.text = _defval;
		}
		
		public function setProperties(props:Array):void
		{
			this.maxChars = props[0];
		}
	}
}