package menu.editing 
{
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import media.fonts.FontStyles;
	import menu.editing.comps.IEditComponent;
	import menu.editing.pieces.EditPieceBar;
	import menu.ICleanable;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class EditArrayBar extends Sprite implements ICleanable
	{
		internal static const E_WIDTH:Number = G.STAGE_WIDTH * 0.55;
		internal static const E_HEIGHT:Number = 50;
		
		private const COLDARK:Number = 0x008DD8;
		private const COLLITE:Number = 0x0098FF;
		
		private const MARGIN_INNER:Number = 5;
		private const MARGIN_OUTER:Number = 10;
		
		private var _back:Sprite;
		
		private var _titlelabel:TextField;
		public function get title():String
		{
			return _titlelabel.text;
		}
		public function set title(value:String):void
		{
			_titlelabel.text = value;
		}
		
		private var _widget:Sprite;
		public function get widget():Sprite
		{
			return _widget;
		}
		
		public function get data():Object
		{
			if (_widget is IEditComponent)
				return IEditComponent(_widget).data;
			if (_widget is EditPieceBar)
				return EditPieceBar(_widget).getAllPieceInfo();
			return null;
		}
		
		override public function get height():Number 
		{
			return !(_widget is EditPieceBar) ? _back.height : _back.height + _widget.height;
		}
		
		public function EditArrayBar(title:String, WidgetType:*, width:Number, props:Array = null, data:Object = null)
		{
			//Use a gradient to separate entries.
			_back = new Sprite();
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(width, E_HEIGHT, Math.PI / 2);
			_back.graphics.beginGradientFill(
				GradientType.LINEAR, [COLLITE, COLDARK], [1, 1], [0, 255], matrix);
			_back.graphics.drawRect(0, 0, width, E_HEIGHT);
			addChild(_back);
			
			_titlelabel = new TextField();
			var titleformat:TextFormat = new TextFormat(FontStyles.F_JOYSTIX, 20, 0xFFCC00);
			G.setTextField(_titlelabel, titleformat);
			_titlelabel.autoSize = TextFieldAutoSize.LEFT;
			_titlelabel.text = title;
			_titlelabel.filters = [new DropShadowFilter()];
			//_titlelabel.x = 0;
			G.centreY(_titlelabel, false, _back);
			addChild(_titlelabel);
			
			if (WidgetType is Class)
				_widget = WidgetType != EditPieceBar ? new WidgetType() : new EditPieceBar();
			else
				_widget = WidgetType;
			
			if (_widget is EditPieceBar)
			{
				EditPieceBar(_widget).prepareEntries(data as Array);
				_widget.x = _back.x;
				_widget.y = _back.y + _back.height;
			}
			else
			{
				if (_widget is IEditComponent)
				{
					if (props != null)
						IEditComponent(_widget).setProperties(props);
					if (data != null)
						IEditComponent(_widget).data = data;
				}
				G.centreY(_widget, false, _back);
				G.rightAlign(_widget, 20, _back);
			}
			addChild(_widget);
		}
		
		public function cleanUp():void
		{
			if (_widget is ICleanable)
				ICleanable(_widget).cleanUp();
		}
		
	}

}