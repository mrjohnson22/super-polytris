package menu.editing.comps 
{
	import fl.controls.Button;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import menu.editing.EditArray;
	import menu.ICleanable;
	import menu.PopUp;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class EditCompArray extends Button implements IEditComponent, ICleanable
	{
		private static const DEF_LABEL:String = "Edit..."
		
		private var _editarray:EditArray;
		
		public var WidgetType:Class = null;
		public var poptitle:String = "Edit Values";
		public var bartitle:String = "";
		public var props:Array = null;
		public var zeroindexed:Boolean = true;
		public var lastplus:Boolean = true;
		public var maxnum:uint = 1;
		
		public function EditCompArray()
		{
			super();
			label = DEF_LABEL;
			addEventListener(MouseEvent.CLICK, showEditPane);
		}
		
		private var _showchange:Boolean = true;
		public function set showchange(value:Boolean):void
		{
			_showchange = value;
		}
		
		public function updateLabel():void
		{
			this.label = (_showchange && !isDefault() ? "*": "") + DEF_LABEL;
		}
		
		private var _data:Array = [];
		public function get data():Object
		{
			return _data.slice(); //Copy, just to be safe.
		}
		
		public function set data(value:Object):void
		{
			G.arrayCopy2D(_data, value as Array);
			updateLabel();
		}
		
		private var _defval:Array = [];
		public function set defval(value:Object):void
		{
			G.arrayCopy2D(_defval, value as Array);
			updateLabel();
		}
		
		public function isDefault():Boolean 
		{
			if (_data.length != _defval.length)
				return false;
			
			for (var i:uint = 0; i < _data.length; i++)
			{
				if (!(_data[i] is Array) && !(_defval[i] is Array))
				{
					if (_data[i] != _defval[i])
						return false;
				}
				else if (_data[i] is Array && _defval[i] is Array)
				{
					var a1:Array = _data[i] as Array;
					var a2:Array = _defval[i] as Array;
					if (a1.length != a2.length)
						return false;
					for (var j:uint = 0; j < a1.length; j++)
					{
						if (a1[j] != a2[j])
							return false;
					}
				}
				else
					return false;
			}
			
			return true;
		}
		
		public function undoChanges():void 
		{
			G.arrayCopy2D(_data, _defval);
			label = DEF_LABEL;
		}
		
		public function showEditPane(e:MouseEvent = null):void
		{
			_editarray = new EditArray(bartitle, WidgetType, _data, props, maxnum, zeroindexed, lastplus);
			PopUp.makePopUp(
			poptitle,
			Vector.<String>(["Accept", "Cancel"]),
			Vector.<Function>([
			function(e:MouseEvent):void
			{
				data = _editarray.getAllData();
				dispatchEvent(new Event(Event.CHANGE)); //to update the mode
				PopUp.fadeOut();
			},
			function(e:MouseEvent):void
			{
				PopUp.fadeOut();
			}]),
			_editarray
			);
		}
		
		public function cleanUp():void
		{
			removeEventListener(MouseEvent.CLICK, showEditPane);
		}
		
		public function setProperties(props:Array):void
		{
			
		}
	}
}