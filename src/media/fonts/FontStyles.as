package media.fonts
{
	/**
	 * ...
	 * @author XJ
	 */
	public class FontStyles 
	{
		[Embed(source = "JOYSTIX MONOSPACE.OTF",
		fontName = "_Joystix",
		mimeType = "application/x-font",
		advancedAntiAliasing="true")]
		private static const F_Joystix:Class;
		public static const F_JOYSTIX:String = "_Joystix";
		
		[Embed(source = "year_200x.ttf",
		fontName = "_Year 200X",
		mimeType = "application/x-font",
		advancedAntiAliasing="true")]
		private static const F_Year200X:Class;
		public static const F_YEAR200X:String = "_Year 200X";
		
		[Embed(source = "arial.ttf",
		fontName = "_Arial",
		mimeType = "application/x-font",
		advancedAntiAliasing="true")]
		private static const F_Arial:Class;
		public static const F_ARIAL:String = "_Arial";
		
		[Embed(source = "LUCON.TTF",
		fontName = "_Lucida",
		mimeType = "application/x-font",
		advancedAntiAliasing="true")]
		private static const F_Lucida:Class;
		public static const F_LUCIDA:String = "_Lucida";
		
		[Embed(source = "GOTHIC.TTF",
		fontName = "_Gothic",
		mimeType = "application/x-font",
		advancedAntiAliasing="true")]
		private static const F_Gothic:Class;
		public static const F_GOTHIC:String = "_Gothic";
		
	}

}