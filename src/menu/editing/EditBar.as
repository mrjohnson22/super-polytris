package menu.editing 
{
	import fl.core.UIComponent;
	import flash.display.GradientType;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import media.fonts.FontStyles;
	import menu.editing.comps.IEditComponent;
	
	/**
	 * ...
	 * @author XJ
	 */
	internal class EditBar extends EditBarBase
	{
		private const MARGIN_INNER:Number = 5;
		private const MARGIN_OUTER:Number = 10;
		
		private var _wlabels:Vector.<TextField> = new Vector.<TextField>();
		private var _widgets:Vector.<UIComponent> = new Vector.<UIComponent>();
		
		private var _wformat:TextFormat;
		
		private var _undobutton:SimpleButton;
		private var _undoFunction:Function;
		
		private var _titlelabel:TextField;
		
		internal var signal:EditSignal;
		
		internal var noundo:Boolean = false;
		
		public function EditBar(title:String, desc:String, Preview:Class, undoFunction:Function)
		{
			//Use a gradient to separate entries.
			_back = new Sprite();
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(E_WIDTH, E_HEIGHT, Math.PI / 2);
			_back.graphics.beginGradientFill(
				GradientType.LINEAR, [COLLITE, COLDARK], [1, 1], [0, 255], matrix);
			_back.graphics.drawRect(0, 0, E_WIDTH, E_HEIGHT);
			addChild(_back);
			
			_undoFunction = undoFunction;
			_undobutton = new UndoButton();
			_undobutton.filters = [new DropShadowFilter()];
			_undobutton.addEventListener(MouseEvent.CLICK, doUndoFunction);
			G.centreY(_undobutton, false, _back);
			_undobutton.visible = false;
			addChild(_undobutton);
			
			_titlelabel = new TextField();
			var titleformat:TextFormat = new TextFormat(FontStyles.F_JOYSTIX, 20, 0xFFCC00);
			G.setTextField(_titlelabel, titleformat);
			_titlelabel.autoSize = TextFieldAutoSize.LEFT;
			_titlelabel.text = title;
			_titlelabel.filters = [new DropShadowFilter()];
			_titlelabel.x = _undobutton.x + _undobutton.width;
			G.centreY(_titlelabel, false, _back);
			addChild(_titlelabel);
			
			signal = new EditSignal(title, desc, Preview);
			
			_wformat = new TextFormat(FontStyles.F_JOYSTIX, 13, 0xFFFFFF);
		}
		
		internal function addUndoListener(listener:Function):void
		{
			_undobutton.addEventListener(MouseEvent.CLICK, listener);
		}
		
		/**
		 * Adds a new widget to the rightmost free space of the bar.
		 * @param	wname The title to display next to the widget.
		 * @param	widget The widget itself.
		 */
		public function addWidget(widget:UIComponent, wname:String = null):void
		{
			var wlabel:TextField = null;
			if (wname != null)
			{
				wlabel = new TextField();
				G.setTextField(wlabel, _wformat);
				wlabel.autoSize = TextFieldAutoSize.LEFT;
				wlabel.text = wname;
			}
			
			_wlabels.push(wlabel);
			_widgets.push(widget);
		}
		
		/**
		 * Call this function to actually put all of the bar's widgets on the display list.
		 */
		override public function setUp():void
		{
			var n:int = _widgets.length;
			var i:int;
			for (i = 0; i < n; i++)
			{
				addChild(_widgets[i]);
				if (_wlabels[i] != null)
					addChild(_wlabels[i]);
			}
			
			var rightmost:Number;
			for (i = n - 1; i >= 0; i--)
			{
				G.centreY(_widgets[i], false, _back);
				if (i == n - 1)
					G.rightAlign(_widgets[i], 20, _back);
				else
					_widgets[i].x = rightmost - _widgets[i].width - MARGIN_OUTER;
				
				if (_wlabels[i] != null)
				{
					G.centreY(_wlabels[i], false, _back);
					_wlabels[i].x = _widgets[i].x - _wlabels[i].width - MARGIN_INNER;
					rightmost = _wlabels[i].x;
				}
				else
					rightmost = _widgets[i].x;
			}
		}
		
		public function undoChanges():void
		{
			for each (var widget:UIComponent in _widgets)
			{
				if (widget is IEditComponent)
					IEditComponent(widget).undoChanges();
			}
		}
		
		public function set undoable(value:Boolean):void
		{
			_undobutton.visible = value;
		}
		
		public function doUndoFunction(e:MouseEvent = null):void
		{
			undoChanges();
			if (_undoFunction != null)
				_undoFunction(null);
			
			dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		}
		
		override public function setInteractable(enabled:Boolean):void
		{
			for each (var widget:UIComponent in _widgets)
			{
				widget.mouseEnabled = enabled;
				widget.tabEnabled = enabled;
			}
		}
		
		override public function cleanUp():void
		{
			if (_undoFunction != null)
				_undobutton.removeEventListener(MouseEvent.CLICK, _undoFunction);
		}
		
	}

}