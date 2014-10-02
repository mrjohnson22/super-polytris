package
{
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	import flash.text.GridFitType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author XJ
	 */
	public class G
	{
		//stage values
		public static const STAGE_WIDTH = Main.stage.stageWidth;
		public static const STAGE_HEIGHT = Main.stage.stageHeight;
		
		//various constants
		public static const FRAMERATE:Number = Main.stage.frameRate;
		public static const S:Number = 16;
		
		public static function centreX(obj:DisplayObject, back:* = null):void
		{
			if (!back is DisplayObject && !back is Rectangle)
				throw new Error("Only use DisplayObjects or Rectangles for the back parameter.");
			if (back == null)
				obj.x = (STAGE_WIDTH - obj.width) / 2;
			else
				obj.x = back.x + (back.width - obj.width) / 2;
		}
		
		public static function betweenX(obj:DisplayObject, leftobj:*, rightobj:*):void
		{
			if ((!leftobj is DisplayObject && !leftobj is Rectangle) || (!rightobj is DisplayObject && !rightobj is Rectangle))
				throw new Error("Only use DisplayObjects or Rectangles for left/right parameters.");
			
			var leftnum:Number, rightnum:Number;
			
			if (leftobj == null)
				leftnum = 0;
			else
				leftnum = leftobj.x + leftobj.width;
			
			if (rightobj == null)
				rightnum = STAGE_WIDTH;
			else
				rightnum = rightobj.x;
			
			obj.x = (leftnum + rightnum - obj.width) / 2.0;
		}
		
		public static function betweenY(obj:DisplayObject, topobj:*, botobj:*):void
		{
			if ((!topobj is DisplayObject && !topobj is Rectangle) || (!botobj is DisplayObject && !botobj is Rectangle))
				throw new Error("Only use DisplayObjects or Rectangles for top/bot parameters.");
			
			var topnum:Number, botnum:Number;
			
			if (topobj == null)
				topnum = 0;
			else
				topnum = topobj.y + topobj.height;
			
			if (botobj == null)
				botnum = STAGE_HEIGHT;
			else
				botnum = botobj.y;
			
			obj.y = (topnum + botnum - obj.height) / 2.0;
		}
		
		public static function rightAlign(obj:DisplayObject, margin:Number = 0, back:* = null):void
		{
			if (back == null)
				obj.x = STAGE_WIDTH - obj.width - margin;
			else
				obj.x = back.x + (back.width - obj.width) - margin;
		}
		
		public static function bottomAlign(obj:DisplayObject, margin:Number = 50, back:* = null):void
		{
			if (back == null)
				obj.y = STAGE_HEIGHT - obj.height - margin;
			else
				obj.y = back.y + (back.height - obj.height) - margin;
		}
		
		public static function centreY(obj:DisplayObject, bottom_register:Boolean = false, back:* = null):void
		{
			if (!back is DisplayObject && !back is Rectangle)
				throw new Error("Only use DisplayObjects or Rectangles for the back parameter.");
			if (back == null)
				obj.y = (STAGE_HEIGHT - obj.height) / 2 + (!bottom_register ? 0 : obj.height);
			else
				obj.y = back.y + (back.height - obj.height) / 2 + (!bottom_register ? 0 : obj.height);
		}
		
		/*public static function centrexMidVal(obj:DisplayObject, back:DisplayObject = null):void
		{
			obj.x = (STAGE_WIDTH / 2 - obj.width) / 2 + STAGE_WIDTH / 2;
		}*/
		
		public static function matchSizeC(obj:DisplayObject, container:*, growToFit:Boolean):void
		{
			if (!container is DisplayObject && !container is Rectangle)
				throw new Error("Only use DisplayObjects or Rectangles for the container parameter.");
			matchSizeV(obj, container.width, container.height, growToFit);
		}
		
		public static function matchSizeV(obj:DisplayObject, width:Number, height:Number, growToFit:Boolean):void
		{
			var newScale:Number = Math.min(width / obj.width, height / obj.height);
			if (growToFit || newScale < 1)
				obj.scaleX = obj.scaleY = newScale;
		}
		
		/**
		 * Removes an entry with a specified value from an array, if this value
		 * exists in the array. Returns the length of the array after (possible) deletion.
		 * @param	a
		 * @param	value_to_remove
		 */
		public static function removeEntry(a:Array, value_to_remove:*):uint
		{
			var i:int;
			if ( (i = a.indexOf(value_to_remove)) != -1)
				a.splice(i, 1);
			
			return a.length;
		}
		
		/**
		 * Create a shallow copy of an array whose entries may be a nested array.
		 * @param	copy_to The array to copy to. Need not be empty, as it will be emptied by this function.
		 * @param	copy_from The array to copy.
		 */
		public static function arrayCopy2D(copy_to:Array, copy_from:Array):void
		{
			var i:uint = 0, j:uint = 0;
			while (i < copy_to.length)
				copy_to.pop();
			for (i = 0; i < copy_from.length; i++)
				copy_to.push(!(copy_from[i] is Array) ? copy_from[i] : copy_from[i].slice());
		}
		
		public static function arrayCopy3D(copy_to:Array, copy_from:Array):void
		{
			var i:uint = 0, j:uint = 0;
			while (i < copy_to.length)
				copy_to.pop();
			for (i = 0; i < copy_from.length; i++)
				arrayCopy2D(copy_to[i] = [], copy_from[i]);
		}
		
		/**
		 * Creates and returns a 2D array with specified length & width.
		 * @param	len The length of the array (number of arrays in returned array).
		 * @param	wid The width of the array (length of arrays in the returned array).
		 * @return	A 2D array.
		 */
		public static function create2DArray(len:uint, wid:uint, defval:* = null):Array
		{
			var a:Array = [];
			for (var i:uint = 0; i < len; i++)
			{
				var arr:Array = [];
				arr.length = wid;
				for (var j:uint = 0; j < wid; j++)
					arr[j] = defval;
				a.push(arr);
			}
			
			return a;
		}
		
		/**
		 * Returns a desired element of an array. If the index of the element to
		 * return is outside the bounds of the array, the array's final entry is returned.
		 * @param	a The array to get the entry of.
		 * @param	i The index of the entry to return. If this index does not exist, the
		 * final entry will be returned.
		 * @return	Either the entry at the specified index, or the final entry of the array.
		 */
		public static function safeIndex(a:Array, i:uint):*
		{
			if (i < a.length)
				return a[i];
			
			return a[a.length - 1];
		}
		
		public static function timeString(seconds:uint):String
		{
			var min:uint = int(seconds / 60);
			var sec:uint = seconds % 60;
			return min.toString() + ":" + (sec < 10 ? "0" : "") + sec.toString();
		}
		
		public static function setTextField(field:TextField, defaultTextFormat:TextFormat):void
		{
			field.embedFonts = true;
			field.selectable = false;
			field.gridFitType = GridFitType.PIXEL;
			field.defaultTextFormat = defaultTextFormat;
		}
		
		public static function textFieldFitSize(field:TextField, value:Number, width_height:Boolean = true):void
		{
			var format:TextFormat = field.defaultTextFormat;
			while ((width_height ? field.textWidth : field.textHeight) > value)
			{
				format.size = int(format.size) - 1;
				field.setTextFormat(format);
			}
		}
		
		/**
		 * Given a target, returns its parent that matches the specified type.
		 * NOTE: The returned value must still be cast as the desired type.
		 * @param	obj The target to find the proper parent of.
		 * @param	ParentType The type to match.
		 * @return	The parent of the target that matches the given type; null if no such parent exists.
		 */
		public static function getTargetByType(obj:Object, ParentType:Class):Object
		{
			while (!(obj is ParentType))
			{
				if (obj.parent == null)
					return null;
				obj = obj.parent;
			}
			return obj;
		}
	}
}