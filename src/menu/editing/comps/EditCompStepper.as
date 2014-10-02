package menu.editing.comps 
{
	import fl.controls.NumericStepper;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class EditCompStepper extends NumericStepper implements IEditComponent 
	{
		public function get data():Object
		{
			return this.value;
		}
		
		public function set data(value:Object):void
		{
			this.value = Number(value);
		}
		
		private var _defval:Number;
		public function set defval(value:Object):void 
		{
			_defval = Number(value);
		}
		
		public function isDefault():Boolean 
		{
			return _defval == this.value;
		}
		
		public function undoChanges():void
		{
			this.value = _defval;
		}
		
		public function setProperties(props:Array):void
		{
			this.minimum = props[0];
			this.maximum = props[1];
			this.stepSize = props.length < 3 ? 1 : props[2];
		}
	}
}