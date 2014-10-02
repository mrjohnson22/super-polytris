package menu.editing.comps 
{
	import menu.ICleanable;
	/**
	 * ...
	 * @author XJ
	 */
	public interface IEditComponent
	{
		function get data():Object;
		function set data(value:Object):void;
		function set defval(value:Object):void;
		function isDefault():Boolean;
		function undoChanges():void;
		function setProperties(props:Array):void;
	}
}